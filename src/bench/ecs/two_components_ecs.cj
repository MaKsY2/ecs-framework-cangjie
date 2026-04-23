package ecsFramework.bench.ecs

import ecsFramework.bench.*
import ecsFramework.framework.*

public func twoComponentsECS(): Unit {
    let registry = Registry()
    let entitties = Array<Int64>()

    for (i in 0..10000) {
        let e = registry.createEntity()
        entitties.fill(e.id)
        registry.addComponent(e, Velocity(0.0, 0.0))
        registry.addComponent(e, Position(0.0, 0.0))
    }

    for (e in entitties) {
        registry.mutComponent<Position>(e, {pos => Position(pos.x + 1.0, pos.y + 1.0)})
    }
}
