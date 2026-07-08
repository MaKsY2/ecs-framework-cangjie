package ecsFramework.legacy.tests

import std.collection.*
import ecsmacros.*
import ecsFramework.framework.*

@System
public func moveSystem(q: Query2<Mut<Position>, Velocity>): Unit {
    @Each2[Position, pi, Velocity, vi, eid](
        let p = Position.denseValueAt(pi)
        let vel = Velocity.denseValueAt(vi)
        Position.denseSetAt(pi, Position(p.x + vel.vx, p.y + vel.vy))
    )
}

@System
public func damageSystem(q: Query3<Mut<Health>, Armor, Damage>): Unit {
    @Each3[Health, hi, Armor, ai, Damage, di, eid](
        var raw = Damage.denseValueAt(di).amount - Armor.denseValueAt(ai).value
        if (raw < 0) {
            raw = 0
        }
        Health.denseSetAt(hi, Health(Health.denseValueAt(hi).hp - raw))
    )
}

@System
public func cleanupSystem(q: Query1<Health>): Unit {
    let dead = ArrayList<Int64>()
    @Each1[Health, hi, eid](
        if (Health.denseValueAt(hi).hp <= 0) {
            dead.add(eid)
        }
    )
    for (eid in dead) {
        Health.removeById(eid)
        Position.removeById(eid)
        Velocity.removeById(eid)
        Armor.removeById(eid)
        Team.removeById(eid)
        Damage.removeById(eid)
    }
}
