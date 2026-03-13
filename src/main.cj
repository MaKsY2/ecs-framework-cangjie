package ecsFramework

import std.collection.*

public func runBenchmarkEcsDense(world: EcsWorld, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runEcsDenseUpdate(world, 100)
        i += 1
    }
    println("  ECS Dense Update: completed ${iterations} iterations")
}

public func runBenchmarkOopDense(world: ArrayList<OopEntity>, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runOopDenseUpdate(world, 100)
        i += 1
    }
    println("  OOP Dense Update: completed ${iterations} iterations")
}

public func runBenchmarkEcsSelective(world: EcsWorld, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runEcsSelectiveUpdate(world, 100)
        i += 1
    }
    println("  ECS Selective: completed ${iterations} iterations")
}

public func runBenchmarkOopSelective(world: ArrayList<OopEntity>, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runOopSelectiveUpdate(world, 100)
        i += 1
    }
    println("  OOP Selective: completed ${iterations} iterations")
}

public func runBenchmarkEcsCreateDestroy(n: Int64, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runEcsCreateDestroy(n / 10, 10)
        i += 1
    }
    println("  ECS Create/Destroy: completed ${iterations} iterations")
}

public func runBenchmarkOopCreateDestroy(n: Int64, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runOopCreateDestroy(n / 10, 10)
        i += 1
    }
    println("  OOP Create/Destroy: completed ${iterations} iterations")
}

public func runBenchmarkEcsMixed(n: Int64, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runEcsMixedFrame(n, 10)
        i += 1
    }
    println("  ECS Mixed Frame: completed ${iterations} iterations")
}

public func runBenchmarkOopMixed(n: Int64, iterations: Int64): Unit {
    var i: Int64 = 0
    while (i < iterations) {
        let _ = runOopMixedFrame(n, 10)
        i += 1
    }
    println("  OOP Mixed Frame: completed ${iterations} iterations")
}

main(): Int64 {
    println("=== ECS vs OOP Benchmarks ===")
    println("Note: Use external timing tools for accurate measurements\n")
    
    let sizes = [1000, 10000, 100000]
    let iterations: Int64 = 5
    
    for (n in sizes) {
        println("--- Size: ${n} entities ---")
        
        println("\n1. Dense Update (all entities have Position + Velocity):")
        let ecsWorldDense = buildEcsWorldDense(n)
        runBenchmarkEcsDense(ecsWorldDense, iterations)
        
        let oopWorldDense = buildOopWorldDense(n)
        runBenchmarkOopDense(oopWorldDense, iterations)
        
        println("\n2. Selective Query (50% have Velocity):")
        let ecsWorldSel = buildEcsWorldSelective(n)
        runBenchmarkEcsSelective(ecsWorldSel, iterations)
        
        let oopWorldSel = buildOopWorldSelective(n)
        runBenchmarkOopSelective(oopWorldSel, iterations)
        
        println("\n3. Create/Destroy:")
        runBenchmarkEcsCreateDestroy(n, iterations)
        runBenchmarkOopCreateDestroy(n, iterations)
        
        println("\n4. Mixed Frame:")
        runBenchmarkEcsMixed(n, iterations)
        runBenchmarkOopMixed(n, iterations)
        
        println("\n")
    }
    
    println("Sink value (prevent optimization): ${sink}")
    println("\nBenchmarks completed. Use 'time' command or profiler for measurements.")
    0
}