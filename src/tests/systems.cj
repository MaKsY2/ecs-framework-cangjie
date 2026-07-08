package ecsFramework.tests

import std.collection.*
import ecsmacros.*
import ecsFramework.framework.*

@System
public func moveSystem(ctx: SystemContext, q: Query2<Mut<Position>, Velocity>): Unit {
    q.each(ctx.registry(), {
        _, pos, vel =>
        let p = pos.get()
        pos.set(Position(p.x + vel.vx, p.y + vel.vy))
    })
}

@System
public func damageSystem(ctx: SystemContext, q: Query3<Mut<Health>, Armor, Damage>): Unit {
    q.each(ctx.registry(), {
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
public func cleanupSystem(ctx: SystemContext, q: Query1<Health>): Unit {
    let toDestroy = ArrayList<Int64>()
    q.each(ctx.registry(), {
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
