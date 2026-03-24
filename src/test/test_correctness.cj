package ecsFramework.test

import std.unittest.*
import std.unittest.testmacro.*
import ecsFramework.scenario.*

@Test
class CorrectnessTests {
    func buildEcsWorld(n: Int64): EcsWorld {
        let world = EcsWorld()
        var i: Int64 = 0
        while (i < n) {
            world.addObject(Float64(i), Float64(i) * 2.0, 1.0, 0.5)
            i += 1
        }
        world
    }

    func buildOopWorld(n: Int64): OopWorld {
        let world = OopWorld()
        var i: Int64 = 0
        while (i < n) {
            world.addObject(Float64(i), Float64(i) * 2.0, 1.0, 0.5)
            i += 1
        }
        world
    }

    @TestCase
    func testOneTick10(): Unit {
        let ecs = buildEcsWorld(10)
        let oop = buildOopWorld(10)
        ecs.update()
        oop.update()
        @Expect(ecs.size(), oop.size())
        @Expect(ecs.sumX(), oop.sumX())
        @Expect(ecs.sumY(), oop.sumY())
    }

    @TestCase
    func testOneTick100(): Unit {
        let ecs = buildEcsWorld(100)
        let oop = buildOopWorld(100)
        ecs.update()
        oop.update()
        @Expect(ecs.size(), oop.size())
        @Expect(ecs.sumX(), oop.sumX())
        @Expect(ecs.sumY(), oop.sumY())
    }

    @TestCase
    func testOneTick1000(): Unit {
        let ecs = buildEcsWorld(1000)
        let oop = buildOopWorld(1000)
        ecs.update()
        oop.update()
        @Expect(ecs.size(), oop.size())
        @Expect(ecs.sumX(), oop.sumX())
        @Expect(ecs.sumY(), oop.sumY())
    }

    @TestCase
    func testMultipleTicks10(): Unit {
        let ecs = buildEcsWorld(10)
        let oop = buildOopWorld(10)
        var tick: Int64 = 0
        while (tick < 10) {
            ecs.update()
            oop.update()
            tick += 1
        }
        @Expect(ecs.size(), oop.size())
        @Expect(ecs.sumX(), oop.sumX())
        @Expect(ecs.sumY(), oop.sumY())
    }

    @TestCase
    func testMultipleTicks100(): Unit {
        let ecs = buildEcsWorld(100)
        let oop = buildOopWorld(100)
        var tick: Int64 = 0
        while (tick < 100) {
            ecs.update()
            oop.update()
            tick += 1
        }
        @Expect(ecs.size(), oop.size())
        @Expect(ecs.sumX(), oop.sumX())
        @Expect(ecs.sumY(), oop.sumY())
    }

    @TestCase
    func testMultipleTicks1000(): Unit {
        let ecs = buildEcsWorld(1000)
        let oop = buildOopWorld(1000)
        var tick: Int64 = 0
        while (tick < 100) {
            ecs.update()
            oop.update()
            tick += 1
        }
        @Expect(ecs.size(), oop.size())
        @Expect(ecs.sumX(), oop.sumX())
        @Expect(ecs.sumY(), oop.sumY())
    }

    @TestCase
    func testInitialStateNoUpdate(): Unit {
        let ecs = buildEcsWorld(50)
        let oop = buildOopWorld(50)
        @Expect(ecs.size(), oop.size())
        @Expect(ecs.sumX(), oop.sumX())
        @Expect(ecs.sumY(), oop.sumY())
    }
}
