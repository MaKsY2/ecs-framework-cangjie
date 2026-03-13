package ecsFramework

import std.collection.*

public func runOopDenseUpdate(world: ArrayList<OopEntity>, frames: Int64): Int64 {
    var acc: Int64 = 0
    let dt = 0.016
    
    var f: Int64 = 0
    while (f < frames) {
        var i: Int64 = 0
        while (i < world.size) {
            let e = world[i]
            e.px = e.px + e.vx * dt
            e.py = e.py + e.vy * dt
            acc += Int64(e.px + e.py)
            i += 1
        }
        f += 1
    }
    
    sink = acc
    acc
}

public func runOopSelectiveUpdate(world: ArrayList<OopEntity>, frames: Int64): Int64 {
    var acc: Int64 = 0
    let dt = 0.016
    
    var f: Int64 = 0
    while (f < frames) {
        var i: Int64 = 0
        while (i < world.size) {
            let e = world[i]
            if (e.hasVelocity) {
                e.px = e.px + e.vx * dt
                e.py = e.py + e.vy * dt
                acc += Int64(e.px + e.py)
            }
            i += 1
        }
        f += 1
    }
    
    sink = acc
    acc
}

public func runOopCreateDestroy(n: Int64, rounds: Int64): Int64 {
    var acc: Int64 = 0
    let world = ArrayList<OopEntity>()
    
    var r: Int64 = 0
    while (r < rounds) {
        var i: Int64 = 0
        while (i < n) {
            let px = Float64(i % 100)
            let py = Float64(i / 100)
            world.add(OopEntity(px, py, 1.0, 0.5, true))
            acc += i
            i += 1
        }
        
        let toDestroy = n / 10
        var d: Int64 = 0
        while (d < toDestroy && world.size > 0) {
            let lastIdx = world.size - 1
            world.remove(lastIdx..lastIdx + 1)
            acc += 1
            d += 1
        }
        
        r += 1
    }
    
    sink = acc
    acc
}

public func runOopMixedFrame(n: Int64, frames: Int64): Int64 {
    let world = buildOopWorldDense(n)
    var acc: Int64 = 0
    let dt = 0.016
    
    var f: Int64 = 0
    while (f < frames) {
        var i: Int64 = 0
        while (i < world.size) {
            let e = world[i]
            if (e.hasVelocity) {
                e.px = e.px + e.vx * dt
                e.py = e.py + e.vy * dt
                acc += Int64(e.px + e.py)
            }
            i += 1
        }
        
        let toDestroy = n / 100
        var d: Int64 = 0
        while (d < toDestroy && world.size > 0) {
            let lastIdx = world.size - 1
            world.remove(lastIdx..lastIdx + 1)
            d += 1
        }
        
        var c: Int64 = 0
        while (c < toDestroy) {
            world.add(OopEntity(0.0, 0.0, 1.0, 0.5, true))
            c += 1
        }
        
        f += 1
    }
    
    sink = acc
    acc
}