package ecsFramework

import std.time.*

public func measureTime(name: String, iterations: Int64, fn: () -> Int64): Unit {
    let warmup = 3
    var w: Int64 = 0
    while (w < warmup) {
        let _ = fn()
        w += 1
    }
    
    var times = ArrayList<Int64>()
    var i: Int64 = 0
    while (i < iterations) {
        let start = DateTime.now().unixTimestamp
        let result = fn()
        let end = DateTime.now().unixTimestamp
        let elapsed = end - start
        times.add(elapsed)
        i += 1
    }
    
    var total: Int64 = 0
    var j: Int64 = 0
    while (j < times.size) {
        total += times[j]
        j += 1
    }
    let avg = total / times.size
    
    println("${name}: avg=${avg}ns")
}

main(): Int64 {
    println("=== ECS vs OOP Benchmarks ===\n")
    
    let sizes = [1000, 10000, 100000]
    let frames: Int64 = 100
    let iterations: Int64 = 5
    
    for (n in sizes) {
        println("--- Size: ${n} entities ---")
        
        println("\n1. Dense Update (all entities have Position + Velocity):")
        let ecsWorldDense = buildEcsWorldDense(n)
        measureTime("  ECS Dense Update", iterations, fn() => {
            runEcsDenseUpdate(ecsWorldDense, frames)
        })
        
        let oopWorldDense = buildOopWorldDense(n)
        measureTime("  OOP Dense Update", iterations, fn() => {
            runOopDenseUpdate(oopWorldDense, frames)
        })
        
        println("\n2. Selective Query (50% have Velocity):")
        let ecsWorldSel = buildEcsWorldSelective(n)
        measureTime("  ECS Selective", iterations, fn() => {
            runEcsSelectiveUpdate(ecsWorldSel, frames)
        })
        
        let oopWorldSel = buildOopWorldSelective(n)
        measureTime("  OOP Selective", iterations, fn() => {
            runOopSelectiveUpdate(oopWorldSel, frames)
        })
        
        println("\n3. Create/Destroy:")
        measureTime("  ECS Create/Destroy", iterations, fn() => {
            runEcsCreateDestroy(n / 10, 10)
        })
        
        measureTime("  OOP Create/Destroy", iterations, fn() => {
            runOopCreateDestroy(n / 10, 10)
        })
        
        println("\n4. Mixed Frame:")
        measureTime("  ECS Mixed Frame", iterations, fn() => {
            runEcsMixedFrame(n, 10)
        })
        
        measureTime("  OOP Mixed Frame", iterations, fn() => {
            runOopMixedFrame(n, 10)
        })
        
        println("\n")
    }
    
    println("Sink value (prevent optimization): ${sink}")
    0
}