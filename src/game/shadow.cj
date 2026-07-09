package ecsFramework.game

import std.collection.*
import ecsFramework.bench.Rng

// Shadow OOP simulation: identical per-tick logic (move + bounce, burn,
// ttl + churn) written the idiomatic OOP way — an ArrayList of heap objects
// scanned in full every pass. Timed each tick next to the ECS backend.

class Critter {
    public var x: Float64
    public var y: Float64
    public var vx: Float64
    public var vy: Float64
    public var hp: Float64
    public var onFire: Bool
    public var burn: Float64
    public var ttl: Int64

    public init(x: Float64, y: Float64, vx: Float64, vy: Float64, onFire: Bool, ttl: Int64) {
        this.x = x
        this.y = y
        this.vx = vx
        this.vy = vy
        this.hp = 1000.0
        this.onFire = onFire
        this.burn = 1.0
        this.ttl = ttl
    }
}

public class OopShadow {
    private let critters = ArrayList<Critter>()
    private let rng = Rng(20260708)
    private var fireFrac: Int64 = 20
    private var ttlMax: Int64 = 600

    public init() {}

    private func spawnOne(ttl: Int64): Unit {
        let x = Float64(rng.below(2400)) / 10.0
        let y = Float64(rng.below(1200)) / 10.0
        let vx = Float64(rng.below(100) - 50) / 100.0
        let vy = Float64(rng.below(100) - 50) / 100.0
        critters.add(Critter(x, y, vx, vy, rng.below(fireFrac) == 0, ttl))
    }

    public func setup(count: Int64, ttlMax: Int64, fireFrac: Int64): Unit {
        this.ttlMax = ttlMax
        this.fireFrac = fireFrac
        var i: Int64 = 0
        while (i < count) {
            spawnOne((i % ttlMax) + 1)
            i += 1
        }
    }

    public func tick(): Unit {
        for (c in critters) {
            var x = c.x + c.vx
            var y = c.y + c.vy
            if (x < 0.0) {
                x = -x
                c.vx = -c.vx
            } else if (x > WORLD_W) {
                x = WORLD_W + WORLD_W - x
                c.vx = -c.vx
            }
            if (y < 0.0) {
                y = -y
                c.vy = -c.vy
            } else if (y > WORLD_H) {
                y = WORLD_H + WORLD_H - y
                c.vy = -c.vy
            }
            c.x = x
            c.y = y
        }
        for (c in critters) {
            if (c.onFire) {
                c.hp -= c.burn * 0.001
            }
        }
        for (c in critters) {
            c.ttl -= 1
        }
        var died: Int64 = 0
        var i: Int64 = 0
        while (i < critters.size) {
            if (critters[i].ttl <= 0) {
                critters[i] = critters[critters.size - 1]
                critters.remove(at: critters.size - 1)
                died += 1
            } else {
                i += 1
            }
        }
        var k: Int64 = 0
        while (k < died) {
            spawnOne(ttlMax)
            k += 1
        }
    }

    public func setFire(denom: Int64): Unit {
        fireFrac = denom
        var i: Int64 = 0
        while (i < critters.size) {
            critters[i].onFire = (i % denom == 0)
            i += 1
        }
    }
}
