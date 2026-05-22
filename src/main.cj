package ecsFramework

import ecsFramework.framework.*
import ecsFramework.tests.*

func dumpState(w: World): Unit {
    println("WORLD STATE:")
    Query2<Position, Health>().each(w.registry(), {
        eid, pos, hp => println("eid=${eid} pos=(${pos.x}, ${pos.y}) hp=${hp.hp}")
    })
}

main(): Int64 {
    let w = World()

    let e1 = w.create()
    w
        .add<Position>(e1, Position(0.0, 0.0))
        .add<Velocity>(e1, Velocity(1.0, 0.5))
        .add<Health>(e1, Health(100))
        .add<Armor>(e1, Armor(2))
        .add<Damage>(e1, Damage(10))
        .add<Team>(e1, Team(1))

    let e2 = w.create()
    w
        .add<Position>(e2, Position(100.0, 100.0))
        .add<Velocity>(e2, Velocity(-1.0, 0.0))
        .add<Health>(e2, Health(30))
        .add<Armor>(e2, Armor(0))
        .add<Damage>(e2, Damage(15))
        .add<Team>(e2, Team(2))

    let e3 = w.create()
    w.add<Position>(e3, Position(50.0, 50.0)).add<Health>(e3, Health(50)).add<Team>(e3, Team(1))

    w.addSystem(moveSystem_system).addSystem(damageSystem_system).addSystem(cleanupSystem_system)

    dumpState(w)

    let ticks: Int64 = 5
    var t: Int64 = 0
    while (t < ticks) {
        w.tick()
        println("============ after tick ${t + 1} ============")
        dumpState(w)
        t += 1
    }

    return 0
}
