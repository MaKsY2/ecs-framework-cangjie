package ecsFramework

import ecsFramework.framework.*
import ecsFramework.tests.*

main(): Int64 {
    let reg = Registry()

    let e1 = reg.createEntity()
    let e2 = reg.createEntity()
    let e3 = reg.createEntity()

    reg.addComponent<Position>(e1, Position(10.0, 20.0))
    reg.addComponent<Velocity>(e1, Velocity(1.0, 2.0))
    reg.addComponent<Health>(e1, Health(100))
    reg.addComponent<Armor>(e1, Armor(5))
    reg.addComponent<Team>(e1, Team(1))

    reg.addComponent<Position>(e2, Position(30.0, 40.0))
    reg.addComponent<Velocity>(e2, Velocity(3.0, 4.0))
    reg.addComponent<Health>(e2, Health(80))
    reg.addComponent<Team>(e2, Team(2))

    reg.addComponent<Position>(e3, Position(50.0, 60.0))
    reg.addComponent<Health>(e3, Health(60))
    reg.addComponent<Armor>(e3, Armor(2))
    reg.addComponent<Team>(e3, Team(1))

    println("=== get/has test ===")
    if (reg.hasComponent<Position>(e1)) {
        let p = reg.getComponent<Position>(e1)
        println("e1 Position = (${p.x}, ${p.y})")
    }

    println("=== view1<Position> ===")
    let v1 = reg.view1<Position>()
    v1.each({
        eid, pos => println("eid=${eid}, pos=(${pos.x}, ${pos.y})")
    })

    println("=== view2<Position, Velocity> ===")
    let v2 = reg.view2<Position, Velocity>()
    v2.each({
        eid, pos, vel => println("eid=${eid}, pos=(${pos.x}, ${pos.y}), vel=(${vel.vx}, ${vel.vy})")
    })

    println("=== view3<Health, Armor, Team> ===")
    let v3 = reg.view3<Health, Armor, Team>()
    v3.each({
        eid, hp, armor, team => println("eid=${eid}, hp=${hp.hp}, armor=${armor.value}, team=${team.teamId}")
    })

    println("=== remove test ===")
    reg.removeComponent<Position>(e1)
    println("e1 has Position = ${reg.hasComponent<Position>(e1)}")

    return 0
}
