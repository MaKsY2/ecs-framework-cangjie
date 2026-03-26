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

@Test
class BenchmarkTests {
    @TestCase
    func benchSelectiveProcessing(): Unit {
        let ecsWorld = EcsWorld()
        let oopWorld = OopWorld()

        var i: Int64 = 0
        while (i < 1000) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Moving, params)
            oopWorld.createEntity(EntityType.Moving, params)
            i += 1
        }

        i = 0
        while (i < 200) {
            let params = EntityParams(Float64(i), Float64(i), 2.0, 2.0, 0.0, 10.0, 0.0, 100.0, 0)
            ecsWorld.createEntity(EntityType.Projectile, params)
            oopWorld.createEntity(EntityType.Projectile, params)
            i += 1
        }

        let ecsNs = measureNs({ =>
            ecsWorld.update(SystemType.Movement)
            ecsWorld.update(SystemType.Lifetime)
        })

        let oopNs = measureNs({ =>
            oopWorld.update(SystemType.Movement)
            oopWorld.update(SystemType.Lifetime)
        })

        println("bench selective_processing (1000 moving + 200 projectiles)  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchMultipleSystemsOnSubsets(): Unit {
        let ecsWorld = EcsWorld()
        let oopWorld = OopWorld()

        var i: Int64 = 0
        while (i < 500) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Moving, params)
            oopWorld.createEntity(EntityType.Moving, params)
            i += 1
        }

        i = 0
        while (i < 100) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 100.0, 10.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Combat, params)
            oopWorld.createEntity(EntityType.Combat, params)
            i += 1
        }

        i = 0
        while (i < 100) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 150.0, 0.0, 20.0, 0.0, 1)
            ecsWorld.createEntity(EntityType.Armored, params)
            oopWorld.createEntity(EntityType.Armored, params)
            i += 1
        }

        i = 0
        while (i < 300) {
            let params = EntityParams(Float64(i), Float64(i), 2.0, 2.0, 0.0, 5.0, 0.0, 50.0, 0)
            ecsWorld.createEntity(EntityType.Projectile, params)
            oopWorld.createEntity(EntityType.Projectile, params)
            i += 1
        }

        let ecsNs = measureNs({ =>
            ecsWorld.update(SystemType.Movement)
            ecsWorld.update(SystemType.Lifetime)
            ecsWorld.update(SystemType.Combat)
            ecsWorld.update(SystemType.Cleanup)
        })

        let oopNs = measureNs({ =>
            oopWorld.update(SystemType.Movement)
            oopWorld.update(SystemType.Lifetime)
            oopWorld.update(SystemType.Combat)
            oopWorld.update(SystemType.Cleanup)
        })

        println("bench multiple_systems (500 moving + 100 combat + 100 armored + 300 projectiles)  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchSparseComponentAccess(): Unit {
        let ecsWorld = EcsWorld()
        let oopWorld = OopWorld()

        var i: Int64 = 0
        while (i < 2000) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Moving, params)
            oopWorld.createEntity(EntityType.Moving, params)
            i += 1
        }

        i = 0
        while (i < 50) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 100.0, 10.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Combat, params)
            oopWorld.createEntity(EntityType.Combat, params)
            i += 1
        }

        i = 0
        while (i < 50) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 150.0, 0.0, 30.0, 0.0, 1)
            ecsWorld.createEntity(EntityType.Armored, params)
            oopWorld.createEntity(EntityType.Armored, params)
            i += 1
        }

        let ecsNs = measureNs({ =>
            ecsWorld.update(SystemType.Combat)
        })

        let oopNs = measureNs({ =>
            oopWorld.update(SystemType.Combat)
        })

        println("bench sparse_component_access (2000 entities, only 100 with combat components)  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchDynamicEntityLifecycle(): Unit {
        let ecsWorld = EcsWorld()
        let oopWorld = OopWorld()

        var i: Int64 = 0
        while (i < 500) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Moving, params)
            oopWorld.createEntity(EntityType.Moving, params)
            i += 1
        }

        let ecsNs = measureNs({ =>
            var j: Int64 = 0
            while (j < 100) {
                let params = EntityParams(Float64(j), Float64(j), 2.0, 2.0, 0.0, 10.0, 0.0, 10.0, 0)
                ecsWorld.createEntity(EntityType.Projectile, params)
                j += 1
            }
            
            var tick: Int64 = 0
            while (tick < 15) {
                ecsWorld.update(SystemType.Movement)
                ecsWorld.update(SystemType.Lifetime)
                tick += 1
            }
        })

        let oopNs = measureNs({ =>
            var j: Int64 = 0
            while (j < 100) {
                let params = EntityParams(Float64(j), Float64(j), 2.0, 2.0, 0.0, 10.0, 0.0, 10.0, 0)
                oopWorld.createEntity(EntityType.Projectile, params)
                j += 1
            }
            
            var tick: Int64 = 0
            while (tick < 15) {
                oopWorld.update(SystemType.Movement)
                oopWorld.update(SystemType.Lifetime)
                tick += 1
            }
        })

        println("bench dynamic_entity_lifecycle (500 base + 100 projectiles with 15 ticks)  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }

    @TestCase
    func benchMixedWorkload(): Unit {
        let ecsWorld = EcsWorld()
        let oopWorld = OopWorld()

        var i: Int64 = 0
        while (i < 300) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 0.0, 0.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Moving, params)
            oopWorld.createEntity(EntityType.Moving, params)
            i += 1
        }

        i = 0
        while (i < 100) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 100.0, 15.0, 0.0, 0.0, 0)
            ecsWorld.createEntity(EntityType.Combat, params)
            oopWorld.createEntity(EntityType.Combat, params)
            i += 1
        }

        i = 0
        while (i < 100) {
            let params = EntityParams(Float64(i), Float64(i), 1.0, 1.0, 200.0, 0.0, 25.0, 0.0, 1)
            ecsWorld.createEntity(EntityType.Armored, params)
            oopWorld.createEntity(EntityType.Armored, params)
            i += 1
        }

        let ecsNs = measureNs({ =>
            var tick: Int64 = 0
            while (tick < 10) {
                var j: Int64 = 0
                while (j < 20) {
                    let params = EntityParams(Float64(j), Float64(j), 3.0, 3.0, 0.0, 8.0, 0.0, 5.0, 0)
                    ecsWorld.createEntity(EntityType.Projectile, params)
                    j += 1
                }
                
                ecsWorld.update(SystemType.Movement)
                ecsWorld.update(SystemType.Lifetime)
                ecsWorld.update(SystemType.Combat)
                ecsWorld.update(SystemType.Cleanup)
                tick += 1
            }
        })

        let oopNs = measureNs({ =>
            var tick: Int64 = 0
            while (tick < 10) {
                var j: Int64 = 0
                while (j < 20) {
                    let params = EntityParams(Float64(j), Float64(j), 3.0, 3.0, 0.0, 8.0, 0.0, 5.0, 0)
                    oopWorld.createEntity(EntityType.Projectile, params)
                    j += 1
                }
                
                oopWorld.update(SystemType.Movement)
                oopWorld.update(SystemType.Lifetime)
                oopWorld.update(SystemType.Combat)
                oopWorld.update(SystemType.Cleanup)
                tick += 1
            }
        })

        println("bench mixed_workload (300 moving + 100 combat + 100 armored + dynamic projectiles, 10 ticks)  ECS: ${ecsNs} ns  OOP: ${oopNs} ns")
    }
}
