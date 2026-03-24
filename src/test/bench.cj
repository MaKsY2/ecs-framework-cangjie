package ecsFramework.test

import std.unittest.*
import std.unittest.testmacro.*
import std.time.*
import ecsFramework.scenario.*

func measureNs(f: () -> Unit): Int64 {
    let t0 = MonoTime.now()
    f()
    let t1 = MonoTime.now()
    (t1 - t0).toNanoseconds()
}

func buildEcsBench(n: Int64): EcsWorld {
    let world = EcsWorld()
    var i: Int64 = 0
    while (i < n) {
        world.addObject(Float64(i), Float64(i), 1.0, 1.0)
        i += 1
    }
    world
}

func buildOopBench(n: Int64): OopWorld {
    let world = OopWorld()
    var i: Int64 = 0
    while (i < n) {
        world.addObject(Float64(i), Float64(i), 1.0, 1.0)
        i += 1
    }
    world
}

func runEcsUpdates(world: EcsWorld, ticks: Int64): Unit {
    var t: Int64 = 0
    while (t < ticks) {
        world.update()
        t += 1
    }
}

func runOopUpdates(world: OopWorld, ticks: Int64): Unit {
    var t: Int64 = 0
    while (t < ticks) {
        world.update()
        t += 1
    }
}

@Test
class BenchmarkTests {
    @TestCase
    func benchUpdateOnly1000(): Unit {
        let ecs = buildEcsBench(1000)
        let oop = buildOopBench(1000)

        let ecsNs = measureNs({ => runEcsUpdates(ecs, 1) })
        let oopNs = measureNs({ => runOopUpdates(oop, 1) })

        println("bench update_only n=1000  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchUpdateOnly10000(): Unit {
        let ecs = buildEcsBench(10000)
        let oop = buildOopBench(10000)

        let ecsNs = measureNs({ => runEcsUpdates(ecs, 1) })
        let oopNs = measureNs({ => runOopUpdates(oop, 1) })

        println("bench update_only n=10000  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchManyTicks100x1000(): Unit {
        let ecs = buildEcsBench(1000)
        let oop = buildOopBench(1000)

        let ecsNs = measureNs({ => runEcsUpdates(ecs, 100) })
        let oopNs = measureNs({ => runOopUpdates(oop, 100) })

        println("bench many_ticks n=1000 ticks=100  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchManyTicks300x1000(): Unit {
        let ecs = buildEcsBench(1000)
        let oop = buildOopBench(1000)

        let ecsNs = measureNs({ => runEcsUpdates(ecs, 300) })
        let oopNs = measureNs({ => runOopUpdates(oop, 300) })

        println("bench many_ticks n=1000 ticks=300  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchManyTicks1000x1000(): Unit {
        let ecs = buildEcsBench(1000)
        let oop = buildOopBench(1000)

        let ecsNs = measureNs({ => runEcsUpdates(ecs, 1000) })
        let oopNs = measureNs({ => runOopUpdates(oop, 1000) })

        println("bench many_ticks n=1000 ticks=1000  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchBuildAndUpdate1000(): Unit {
        let ecsNs = measureNs({
            =>
            let world = buildEcsBench(1000)
            runEcsUpdates(world, 1)
        })
        let oopNs = measureNs({
            =>
            let world = buildOopBench(1000)
            runOopUpdates(world, 1)
        })

        println("bench build_and_update n=1000  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchBuildAndUpdate10000(): Unit {
        let ecsNs = measureNs({
            =>
            let world = buildEcsBench(10000)
            runEcsUpdates(world, 1)
        })
        let oopNs = measureNs({
            =>
            let world = buildOopBench(10000)
            runOopUpdates(world, 1)
        })

        println("bench build_and_update n=10000  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }
}
