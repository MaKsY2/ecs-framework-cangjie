package ecsFramework.bench

import ecsmacros.*
import ecsFramework.framework.*

@System
public func acc0System(ctx: SystemContext, q: Query2<Mut<Acc0>, Input>): Unit {
    q.each(ctx.registry(), { _, acc, input => acc.set(Acc0(kernel(acc.get().v + input.v))) })
}

@System
public func acc1System(ctx: SystemContext, q: Query2<Mut<Acc1>, Input>): Unit {
    q.each(ctx.registry(), { _, acc, input => acc.set(Acc1(kernel(acc.get().v + input.v))) })
}

@System
public func acc2System(ctx: SystemContext, q: Query2<Mut<Acc2>, Input>): Unit {
    q.each(ctx.registry(), { _, acc, input => acc.set(Acc2(kernel(acc.get().v + input.v))) })
}

@System
public func acc3System(ctx: SystemContext, q: Query2<Mut<Acc3>, Input>): Unit {
    q.each(ctx.registry(), { _, acc, input => acc.set(Acc3(kernel(acc.get().v + input.v))) })
}

@System
public func burnSystem(ctx: SystemContext, q: Query2<Mut<Hp>, Burn>): Unit {
    q.each(ctx.registry(), { _, hp, burn => hp.set(Hp(hp.get().v - burn.v)) })
}
