package ecsFramework.game

import std.collection.*
import std.sync.*
import std.time.*
import ecsmacros.*
import ecsFramework.framework.*
import ecsFramework.bench.Rng
import ecsFramework.bench.fmt2
import ecsFramework.bench.pad

// "Swarm" — a terminal showcase: 100k critters simulated by the ECS every
// tick, while a shadow OOP simulation runs the exact same logic for a live
// side-by-side timing in the HUD. The player walks a viewport over the world.

let WORLD_W: Float64 = 240.0
let WORLD_H: Float64 = 120.0
let VIEW_W: Int64 = 80
let VIEW_H: Int64 = 22
let CRITTERS: Int64 = 100000
let TTL_MAX: Int64 = 600
let RUN_FRAMES: Int64 = 300

foreign func system(command: CString): Int32

foreign func read(fd: Int32, buf: CPointer<UInt8>, count: UIntNative): IntNative

foreign func isatty(fd: Int32): Int32

func sh(cmd: String): Unit {
    unsafe {
        let cs = LibC.mallocCString(cmd)
        system(cs)
        LibC.free(cs)
    }
}

let KEY_NONE: Int64 = -2
let KEY_EOF: Int64 = -1

// Unbuffered single-byte stdin read: getStdIn() buffers internally and blocks
// on an interactive tty until its buffer fills, so raw keys never arrive.
// On a tty in `min 0 time 0` mode, n == 0 means "no key pending" (KEY_NONE);
// on a pipe n == 0 means end of input (callers treat both as quit there).
func readKey(buf: CPointer<UInt8>): Int64 {
    let n = unsafe { read(0, buf, 1) }
    if (n < 0) {
        KEY_EOF
    } else if (n == 0) {
        KEY_NONE
    } else {
        Int64(unsafe { buf.read(0) })
    }
}

// Raw terminal: keys act immediately, no Enter; reads never block so the
// simulation can run continuously. Harmless no-op when stdin is a pipe.
func rawModeOn(): Unit {
    sh("stty -icanon -echo min 0 time 0 2>/dev/null")
    print("\u{1b}[?25l")
}

func rawModeOff(): Unit {
    print("\u{1b}[?25h")
    sh("stty icanon echo 2>/dev/null")
}

class TimeStats {
    public var minMs: Float64 = 1.0e18
    public var maxMs: Float64 = 0.0
    public var sumMs: Float64 = 0.0
    public var count: Int64 = 0

    public init() {}

    public func add(ms: Float64): Unit {
        if (ms < minMs) {
            minMs = ms
        }
        if (ms > maxMs) {
            maxMs = ms
        }
        sumMs += ms
        count += 1
    }

    public func avg(): Float64 {
        if (count == 0) {
            0.0
        } else {
            sumMs / Float64(count)
        }
    }

    public func lo(): Float64 {
        if (count == 0) {
            0.0
        } else {
            minMs
        }
    }

    public func reset(): Unit {
        minMs = 1.0e18
        maxMs = 0.0
        sumMs = 0.0
        count = 0
    }
}

@Component
public struct Wpos {
    public var x: Float64
    public var y: Float64
    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

@Component
public struct Wvel {
    public var vx: Float64
    public var vy: Float64
    public init(vx: Float64, vy: Float64) {
        this.vx = vx
        this.vy = vy
    }
}

@Component
public struct Whp {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct Wburn {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct Wttl {
    public var t: Int64
    public init(t: Int64) {
        this.t = t
    }
}

let moveGroup = OwnGroup2<Wpos, Wvel>()
let burnGroup = OwnGroup2<Whp, Wburn>()

@System
public func moveSys(): Unit {
    @EachG2[Wpos, pi, Wvel, vi, eid, moveGroup](
        let p = Wpos.denseValueAt(pi)
        let v = Wvel.denseValueAt(vi)
        var x = p.x + v.vx
        var y = p.y + v.vy
        var vx = v.vx
        var vy = v.vy
        if (x < 0.0) {
            x = -x
            vx = -vx
        } else if (x > WORLD_W) {
            x = WORLD_W + WORLD_W - x
            vx = -vx
        }
        if (y < 0.0) {
            y = -y
            vy = -vy
        } else if (y > WORLD_H) {
            y = WORLD_H + WORLD_H - y
            vy = -vy
        }
        Wpos.denseSetAt(pi, Wpos(x, y))
        if (vx != v.vx || vy != v.vy) {
            Wvel.denseSetAt(vi, Wvel(vx, vy))
        }
    )
}

@System
public func burnSys(): Unit {
    @EachG2[Whp, hi, Wburn, bi, eid, burnGroup](
        Whp.denseSetAt(hi, Whp(Whp.denseValueAt(hi).v - Wburn.denseValueAt(bi).v * 0.001))
    )
}

@System
public func ttlSys(): Unit {
    @Each1[Wttl, i, eid](
        Wttl.denseSetAt(i, Wttl(Wttl.denseValueAt(i).t - 1))
    )
}

class GameState {
    public let world = World()
    public let rng = Rng(20260708)
    public var fireFrac: Int64 = 20 // 1 in N burns; 20 => 5%
    public var playerX: Float64 = WORLD_W / 2.0
    public var playerY: Float64 = WORLD_H / 2.0
    public var tickNo: Int64 = 0
    public let ecsStats = TimeStats()
    public let oopStats = TimeStats()
    public let deadIds = ArrayList<Int64>()
    public let shadow = OopShadow()

    public init() {}

    public func spawnCritter(ttl: Int64): Unit {
        let e = world.create()
        let x = Float64(rng.below(2400)) / 10.0
        let y = Float64(rng.below(1200)) / 10.0
        let vx = Float64(rng.below(100) - 50) / 100.0
        let vy = Float64(rng.below(100) - 50) / 100.0
        world.add<Wpos>(e, Wpos(x, y)).add<Wvel>(e, Wvel(vx, vy))
        world.add<Whp>(e, Whp(1000.0)).add<Wttl>(e, Wttl(ttl))
        if (rng.below(fireFrac) == 0) {
            world.add<Wburn>(e, Wburn(1.0))
        }
    }

    public func setup(): Unit {
        moveGroup.activate()
        burnGroup.activate()
        var i: Int64 = 0
        while (i < CRITTERS) {
            spawnCritter((i % TTL_MAX) + 1)
            i += 1
        }
        shadow.setup(CRITTERS, TTL_MAX, fireFrac)
    }

    /** One simulation step of both backends; returns (ecsMs, oopMs). */
    public func step(): (Float64, Float64) {
        let t0 = MonoTime.now()
        world.tick()
        deadIds.clear()
        @Each1[Wttl, i, eid](
            if (Wttl.denseValueAt(i).t <= 0) {
                deadIds.add(eid)
            }
        )
        for (id in deadIds) {
            Wpos.removeById(id)
            Wvel.removeById(id)
            Whp.removeById(id)
            Wburn.removeById(id)
            Wttl.removeById(id)
            world.destroy(world.entityOf(id))
        }
        for (_ in deadIds) {
            spawnCritter(TTL_MAX)
        }
        let t1 = MonoTime.now()
        shadow.tick()
        let t2 = MonoTime.now()

        let ecsMs = Float64((t1 - t0).toNanoseconds()) / 1.0e6
        let oopMs = Float64((t2 - t1).toNanoseconds()) / 1.0e6
        ecsStats.add(ecsMs)
        oopStats.add(oopMs)
        tickNo += 1
        (ecsMs, oopMs)
    }

    public func resetStats(): Unit {
        ecsStats.reset()
        oopStats.reset()
    }

    /** Change the burning fraction: 1 in `denom` critters is on fire. */
    public func setFire(denom: Int64): Unit {
        fireFrac = denom
        let ids = ArrayList<Int64>()
        @Each1[Whp, i, eid](
            ids.add(eid)
        )
        for (id in ids) {
            let shouldBurn = (id % denom == 0)
            if (shouldBurn && !Wburn.hasById(id)) {
                world.add<Wburn>(world.entityOf(id), Wburn(1.0))
            } else if (!shouldBurn && Wburn.hasById(id)) {
                Wburn.removeById(id)
            }
        }
        shadow.setFire(denom)
        resetStats()
    }

    public func movePlayer(dx: Float64, dy: Float64): Unit {
        playerX += dx
        playerY += dy
        if (playerX < 0.0) { playerX = 0.0 }
        if (playerX > WORLD_W) { playerX = WORLD_W }
        if (playerY < 0.0) { playerY = 0.0 }
        if (playerY > WORLD_H) { playerY = WORLD_H }
    }
}

func render(g: GameState): Unit {
    let cells = Array<Int64>(VIEW_W * VIEW_H, repeat: 0)
    let burnCells = Array<Int64>(VIEW_W * VIEW_H, repeat: 0)
    let left = g.playerX - Float64(VIEW_W) / 2.0
    let top = g.playerY - Float64(VIEW_H) / 2.0

    @Each1[Wpos, i, eid](
        let p = Wpos.denseValueAt(i)
        let cx = Int64(p.x - left)
        let cy = Int64(p.y - top)
        if (cx >= 0 && cx < VIEW_W && cy >= 0 && cy < VIEW_H) {
            let idx = cy * VIEW_W + cx
            cells[idx] += 1
            if (Wburn.hasById(eid)) {
                burnCells[idx] += 1
            }
        }
    )

    let sb = StringBuilder()
    sb.append("\u{1b}[H")

    let ecsAvg = g.ecsStats.avg()
    let oopAvg = g.oopStats.avg()
    let fps = if (ecsAvg > 0.0) { 1000.0 / ecsAvg } else { 0.0 }
    let speedup = if (ecsAvg > 0.0) { oopAvg / ecsAvg } else { 0.0 }
    sb.append("\u{1b}[1m ECS ${pad(fmt2(ecsAvg) + " ms", 9)}(min ${fmt2(g.ecsStats.lo())} / max ${fmt2(g.ecsStats.maxMs)})")
    sb.append("  OOP ${pad(fmt2(oopAvg) + " ms", 9)}(min ${fmt2(g.oopStats.lo())} / max ${fmt2(g.oopStats.maxMs)})\u{1b}[0m\u{1b}[K\n")
    let burning = burnGroup.size()
    let pct = burning * 100 / CRITTERS
    sb.append(" speedup ${fmt2(speedup)}x | fps(ECS avg) ${fmt2(fps)} | critters ${CRITTERS}")
    sb.append(" | burning ${burning} (~${pct}%) | tick ${g.tickNo} | pos (${Int64(g.playerX)}, ${Int64(g.playerY)})\u{1b}[K\n")

    let playerCx = Int64(g.playerX - left)
    let playerCy = Int64(g.playerY - top)
    var y: Int64 = 0
    while (y < VIEW_H) {
        var x: Int64 = 0
        while (x < VIEW_W) {
            if (x == playerCx && y == playerCy) {
                sb.append("\u{1b}[1;33m@\u{1b}[0m")
            } else {
                let idx = y * VIEW_W + x
                let n = cells[idx]
                if (burnCells[idx] > 0 && burnCells[idx] * 2 >= n) {
                    sb.append("\u{1b}[31mx\u{1b}[0m")
                } else if (n == 0) {
                    sb.append(" ")
                } else if (n == 1) {
                    sb.append(".")
                } else if (n <= 3) {
                    sb.append(":")
                } else if (n <= 6) {
                    sb.append("+")
                } else if (n <= 10) {
                    sb.append("*")
                } else {
                    sb.append("#")
                }
            }
            x += 1
        }
        sb.append("\u{1b}[K\n")
        y += 1
    }
    sb.append(" [wasd] move | r turbo on/off | 1..4 fire 100/25/5/1% | q quit\u{1b}[K\n")
    print(sb.toString())
}

public func runGame(): Unit {
    let g = GameState()
    g.setup()
    g.step()
    g.resetStats()

    rawModeOn()
    print("\u{1b}[2J")
    render(g)

    let keyBuf = unsafe { LibC.malloc<UInt8>(count: 1) }
    let interactive = unsafe { isatty(0) } == 1

    if (interactive) {
        // Real-time loop: the world ticks constantly, keys steer instantly.
        var running = true
        var turbo = false
        while (running) {
            // Drain every key pressed since the previous frame.
            var key = readKey(keyBuf)
            while (key != KEY_NONE) {
                if (key == KEY_EOF || key == 113) { // 'q'
                    running = false
                } else if (key == 114) { // 'r' — toggle turbo (no frame pacing)
                    turbo = !turbo
                } else if (key == 49) { // '1'
                    g.setFire(1)
                } else if (key == 50) { // '2'
                    g.setFire(4)
                } else if (key == 51) { // '3'
                    g.setFire(20)
                } else if (key == 52) { // '4'
                    g.setFire(100)
                } else if (key == 119) { // 'w'
                    g.movePlayer(0.0, -2.0)
                } else if (key == 115) { // 's'
                    g.movePlayer(0.0, 2.0)
                } else if (key == 97) { // 'a'
                    g.movePlayer(-2.0, 0.0)
                } else if (key == 100) { // 'd'
                    g.movePlayer(2.0, 0.0)
                }
                key = readKey(keyBuf)
            }
            if (!running) {
                break
            }
            g.step()
            render(g)
            if (!turbo) {
                sleep(Duration.millisecond * 16)
            }
        }
    } else {
        // Piped input (tests): one blocking key = one tick, EOF quits.
        while (true) {
            let key = readKey(keyBuf)
            if (key == KEY_EOF || key == KEY_NONE || key == 113) {
                break
            } else if (key == 114) { // 'r'
                var f: Int64 = 0
                while (f < RUN_FRAMES) {
                    g.step()
                    render(g)
                    f += 1
                }
            } else if (key == 49) {
                g.setFire(1)
            } else if (key == 50) {
                g.setFire(4)
            } else if (key == 51) {
                g.setFire(20)
            } else if (key == 52) {
                g.setFire(100)
            } else if (key == 119) {
                g.movePlayer(0.0, -2.0)
            } else if (key == 115) {
                g.movePlayer(0.0, 2.0)
            } else if (key == 97) {
                g.movePlayer(-2.0, 0.0)
            } else if (key == 100) {
                g.movePlayer(2.0, 0.0)
            } else if (key == 10 || key == 13) {
                continue
            }
            g.step()
            render(g)
        }
    }
    unsafe { LibC.free(keyBuf) }
    rawModeOff()
    println("bye")
}
