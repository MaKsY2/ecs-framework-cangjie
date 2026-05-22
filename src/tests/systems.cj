package ecsFramework.tests

import std.collection.*
import ecsmacros.*
import ecsFramework.framework.*

@System
public func moveSystem(ctx: SystemContext): Unit {
    Query2<Mut<Position>, Velocity>().each(ctx.registry(), {
        _, pos, vel =>
        let p = pos.get()
        pos.set(Position(p.x + vel.vx, p.y + vel.vy))
    })
}

@System
public func damageSystem(ctx: SystemContext): Unit {
    Query3<Mut<Health>, Armor, Damage>().each(ctx.registry(), {
        _, hp, armor, dmg =>
        var raw = dmg.amount - armor.value
        if (raw < 0) {
            raw = 0
        }
        let cur = hp.get()
        hp.set(Health(cur.hp - raw))
    })
}

@System[structural]
public func cleanupSystem(ctx: SystemContext): Unit {
    let toDestroy = ArrayList<Int64>()
    Query1<Health>().each(ctx.registry(), {
        eid, hp =>
        if (hp.hp <= 0) {
            toDestroy.add(eid)
        }
    })

    var i: Int64 = 0
    while (i < toDestroy.size) {
        let e = ctx.entityOf(toDestroy[i])
        ctx.remove<Health>(e)
        ctx.remove<Position>(e)
        ctx.remove<Velocity>(e)
        ctx.remove<Armor>(e)
        ctx.remove<Team>(e)
        ctx.remove<Damage>(e)
        ctx.destroy(e)
        i += 1
    }
}
