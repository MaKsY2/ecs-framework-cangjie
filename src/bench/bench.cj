package ecsFramework.bench

import std.collection.*
import std.time.*
import ecsFramework.framework.*

public let NUM_ENTITIES: Int64 = 50000
public let NUM_FRAMES: Int64 = 30
public var WORK_ITERS: Int64 = 60
public let WORKERS: Int64 = 4

public func kernel(seed: Float64): Float64 {
    var v = seed
    var i: Int64 = 0
    while (i < WORK_ITERS) {
        v = v * 0.9999999 + 0.5
        i += 1
    }
    v
}

public class Particle {
    public var a0: Float64 = 0.0
    public var a1: Float64 = 0.0
    public var a2: Float64 = 0.0
    public var a3: Float64 = 0.0
    public let input: Float64

    public init(input: Float64) {
        this.input = input
    }
}

func oopFrameSingle(ps: Array<Particle>): Unit {
    for (p in ps) {
        p.a0 = kernel(p.a0 + p.input)
    }
    for (p in ps) {
        p.a1 = kernel(p.a1 + p.input)
    }
    for (p in ps) {
        p.a2 = kernel(p.a2 + p.input)
    }
    for (p in ps) {
        p.a3 = kernel(p.a3 + p.input)
    }
}

func oopFrameMulti(ps: Array<Particle>): Unit {
    let fs = ArrayList<Future<Unit>>()
    fs.add(spawn {
        for (p in ps) {
            p.a0 = kernel(p.a0 + p.input)
        }
    })
    fs.add(spawn {
        for (p in ps) {
            p.a1 = kernel(p.a1 + p.input)
        }
    })
    fs.add(spawn {
        for (p in ps) {
            p.a2 = kernel(p.a2 + p.input)
        }
    })
    fs.add(spawn {
        for (p in ps) {
            p.a3 = kernel(p.a3 + p.input)
        }
    })
    for (f in fs) {
        f.get()
    }
}

func fmt2(x: Float64): String {
    let scaled = Int64(x * 100.0 + 0.5)
    let intPart = scaled / 100
    let frac = scaled % 100
    let fracStr = if (frac < 10) {
        "0${frac}"
    } else {
        "${frac}"
    }
    "${intPart}.${fracStr}"
}

func timeMs(frames: Int64, frame: () -> Unit): Float64 {
    frame()
    let t0 = MonoTime.now()
    var i: Int64 = 0
    while (i < frames) {
        frame()
        i += 1
    }
    let t1 = MonoTime.now()
    Float64((t1 - t0).toNanoseconds()) / 1.0e6
}

func pad(s: String, width: Int64): String {
    var out = s
    while (out.size < width) {
        out = out + " "
    }
    out
}

func row(label: String, ms: Float64, baseline: Float64, note: String): Unit {
    let perFrame = fmt2(ms / Float64(NUM_FRAMES))
    let speedup = fmt2(baseline / ms)
    println(
        "  ${pad(label, 22)}${pad("${fmt2(ms)} ms", 14)}${pad("${perFrame} ms", 14)}${pad("${speedup}x", 9)}${note}")
}

public func runBenchmarks(): Unit {
    println("ECS vs OOP benchmark")
    println(
        "  entities=${NUM_ENTITIES}  frames=${NUM_FRAMES}  work/entity=${WORK_ITERS}  systems=4  workers=${WORKERS}")
    println("")

    let particles = Array<Particle>(NUM_ENTITIES, {i => Particle(Float64(i % 7) * 0.5 + 1.0)})

    let w = World(WORKERS)
    var i: Int64 = 0
    while (i < NUM_ENTITIES) {
        let e = w.create()
        w
            .add<Input>(e, Input(Float64(i % 7) * 0.5 + 1.0))
            .add<Acc0>(e, Acc0())
            .add<Acc1>(e, Acc1())
            .add<Acc2>(e, Acc2())
            .add<Acc3>(e, Acc3())
        i += 1
    }
    w
        .addSystem(acc0System_system)
        .addSystem(acc1System_system)
        .addSystem(acc2System_system)
        .addSystem(acc3System_system)

    let oop1 = timeMs(NUM_FRAMES, {=> oopFrameSingle(particles)})
    let oopN = timeMs(NUM_FRAMES, {=> oopFrameMulti(particles)})
    let ecs1 = timeMs(NUM_FRAMES, {=> w.tickSequential()})
    let ecsN = timeMs(NUM_FRAMES, {=> w.tick()})

    println("  ${pad("mode", 22)}${pad("total", 14)}${pad("per-frame", 14)}${pad("vs OOP1", 9)}notes")
    println("  ${pad("----", 22)}${pad("-----", 14)}${pad("---------", 14)}${pad("-------", 9)}-----")
    row("OOP  single-thread", oop1, oop1, "")
    row("OOP  multi-thread", oopN, oop1, "")
    row("ECS  single-thread", ecs1, oop1, "")
    row("ECS  multi-thread", ecsN, oop1, "scheduler vs ECS1 ${fmt2(ecs1 / ecsN)}x")

    println("")
    println("  ECS single-thread overhead vs work per entity (OOP1 baseline):")
    println("  ${pad("work/entity", 14)}${pad("OOP1", 14)}${pad("ECS1", 14)}ECS1/OOP1")
    for (work in [0, 30, 120, 480, 1080, 2160, 4320]) {
        WORK_ITERS = work
        let o = timeMs(10, {=> oopFrameSingle(particles)})
        let e = timeMs(10, {=> w.tickSequential()})
        println("  ${pad("${work}", 14)}${pad("${fmt2(o)} ms", 14)}${pad("${fmt2(e)} ms", 14)}${fmt2(e / o)}x")
    }
    WORK_ITERS = 60

    let checksum = Acc0.getById(0).v + Acc3.getById(NUM_ENTITIES - 1).v + particles[0].a0
    println("")
    println("  checksum=${fmt2(checksum)}")

    accessMicro(particles, w.registry(), 50)

    selectiveBenchmark()
}

func accessMicro(particles: Array<Particle>, reg: Registry, frames: Int64): Unit {
    let saved = WORK_ITERS
    WORK_ITERS = 0

    let oop = timeMs(frames, {
        =>
        for (p in particles) {
            p.a0 = kernel(p.a0)
        }
    })

    let q = Query1<Mut<Acc0>>()
    let ecsEach = timeMs(frames, {
        =>
        q.each(reg, { _, acc => acc.set(Acc0(kernel(acc.get().v))) })
    })

    let rawEid = timeMs(frames, {
        =>
        let n = Acc0.denseSize()
        var i: Int64 = 0
        while (i < n) {
            let eid = Acc0.denseEntityAt(i)
            Acc0.setById(eid, Acc0(kernel(Acc0.getById(eid).v)))
            i += 1
        }
    })

    let rawDense = timeMs(frames, {
        =>
        let n = Acc0.denseSize()
        var i: Int64 = 0
        while (i < n) {
            Acc0.denseSetAt(i, Acc0(kernel(Acc0.denseValueAt(i).v)))
            i += 1
        }
    })

    let body: (Int64) -> Unit = { i => Acc0.denseSetAt(i, Acc0(kernel(Acc0.denseValueAt(i).v))) }
    let concreteClosure = timeMs(frames, {
        =>
        let n = Acc0.denseSize()
        var i: Int64 = 0
        while (i < n) {
            body(i)
            i += 1
        }
    })

    WORK_ITERS = saved

    println("")
    println("Access overhead micro-bench (1 component, work=0, ${frames} frames over ${NUM_ENTITIES}):")
    println("  ${pad("variant", 26)}${pad("total", 14)}vs OOP")
    println("  ${pad("OOP field a=f(a)", 26)}${pad("${fmt2(oop)} ms", 14)}${fmt2(oop / oop)}x")
    println("  ${pad("ECS Query1 each", 26)}${pad("${fmt2(ecsEach)} ms", 14)}${fmt2(ecsEach / oop)}x")
    println("  ${pad("raw-eid getById/setById", 26)}${pad("${fmt2(rawEid)} ms", 14)}${fmt2(rawEid / oop)}x")
    println("  ${pad("raw-dense denseAt(i)", 26)}${pad("${fmt2(rawDense)} ms", 14)}${fmt2(rawDense / oop)}x")
    println("  ${pad("concrete+closure", 26)}${pad("${fmt2(concreteClosure)} ms", 14)}${fmt2(concreteClosure / oop)}x")
}

public class Agent {
    public var hp: Float64
    public var onFire: Bool = false
    public var burn: Float64 = 1.0
    public var p0: Float64 = 1.0
    public var p1: Float64 = 2.0
    public var p2: Float64 = 3.0
    public var p3: Float64 = 4.0
    public var p4: Float64 = 5.0

    public init(hp: Float64) {
        this.hp = hp
    }
}

func oopBurnFrame(agents: Array<Agent>): Unit {
    for (a in agents) {
        if (a.onFire) {
            a.hp = a.hp - a.burn
        }
    }
}

func countMultiples(n: Int64, s: Int64): Int64 {
    (n - 1) / s + 1
}

public func selectiveBenchmark(): Unit {
    let n: Int64 = 100000
    let frames: Int64 = 20

    println("")
    println("Selective processing: ${n} entities, system touches only the on-fire subset")
    println("  naive OOP scans ALL entities; ECS iterates only the dense Burn pool")
    println("")
    println("  ${pad("on-fire %", 12)}${pad("subset", 10)}${pad("OOP scan-all", 16)}${pad("ECS subset", 16)}OOP/ECS")

    let agents = Array<Agent>(n, { _ => Agent(100.0) })

    let w = World(1)
    var i: Int64 = 0
    while (i < n) {
        let e = w.create()
        w.add<Hp>(e, Hp(100.0)).add<Burn>(e, Burn(1.0))
        i += 1
    }
    w.addSystem(burnSystem_system)

    for (s in [1, 4, 16, 64, 256]) {
        var k: Int64 = 0
        while (k < n) {
            agents[k].onFire = (k % s == 0)
            k += 1
        }
        k = 0
        while (k < n) {
            if (k % s != 0) {
                w.remove<Burn>(w.registry().entityOf(k))
            }
            k += 1
        }

        let subset = countMultiples(n, s)
        let oms = timeMs(frames, { => oopBurnFrame(agents) })
        let ems = timeMs(frames, { => w.tickSequential() })
        let frac = fmt2(Float64(subset) * 100.0 / Float64(n))
        println("  ${pad(frac, 12)}${pad("${subset}", 10)}${pad("${fmt2(oms)} ms", 16)}${pad("${fmt2(ems)} ms", 16)}${fmt2(oms / ems)}x")
    }
}
