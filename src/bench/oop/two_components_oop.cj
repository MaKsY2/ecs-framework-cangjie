package ecsFramework.bench.oop

import ecsFramework.bench.*

public class User {
    var pos: Position
    var vx: Velocity

    public init() {
        pos = Position(0.0, 0.0)
        vx = Velocity(0.0, 0.0)
    }
}

public func twoComponentsOOP(): Unit {
    var users: Array<User> = []

    for (i in 0..10000) {
        users.fill(User())
    }

    for (u in users) {
        u.pos = Position(u.pos.x + 1.0, u.pos.y + 1.0)
        u.vx = Velocity(u.vx.vx + 1.0, u.vx.vy + 1.0)
    }
}
