package ecsFramework

import ecsFramework.scenario.*

main(): Int64 {
    let world = EcsWorld()

    var i: Int64 = 0
    while (i < 5) {
        world.addObject(Float64(i), Float64(i) * 2.0, 1.0, 0.5)
        i += 1
    }

    println("Before update: sumX=${world.sumX()} sumY=${world.sumY()}")

    world.update()

    println("After update:  sumX=${world.sumX()} sumY=${world.sumY()}")

    return 0
}
