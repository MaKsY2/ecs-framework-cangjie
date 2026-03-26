package ecsFramework

import ecsFramework.scenario.*

main(): Int64 {
    let world = EcsWorld()

    var i: Int64 = 0
    while (i < 5) {
        let params = EntityParams(Float64(i), Float64(i) * 2.0, 1.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0)
        world.createEntity(EntityType.Moving, params)
        i += 1
    }

    println("Before update: entities=${world.countEntities()}")

    world.update(SystemType.Movement)

    println("After update:  entities=${world.countEntities()}")

    return 0
}
