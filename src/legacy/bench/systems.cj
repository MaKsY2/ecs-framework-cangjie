package ecsFramework.legacy.bench

import ecsmacros.*
import ecsFramework.framework.*

public let DT: Float64 = 0.016

public func kernel12(seed: Float64): Float64 {
    var v = seed
    var i: Int64 = 0
    while (i < 12) {
        v = v * 0.9999999 + 0.5
        i += 1
    }
    v
}

public let s1Group = OwnGroup2<Pos, Vel>()
public let s1mGroup = OwnGroup2<Pm, Vm>()
public let s4Group = OwnGroup2<Hp4, Burn4>()
public let s5Group = OwnGroup3<H5, A5, D5>()

@System
public func s1Move(q: Query2<Mut<Pos>, Vel>): Unit {
    @EachG2[Pos, pi, Vel, vi, eid, s1Group](
        let v = Vel.denseValueAt(vi)
        let p = Pos.denseValueAt(pi)
        Pos.denseSetAt(pi, Pos(p.x + v.vx * DT, p.y + v.vy * DT))
    )
}

@System
public func s1mMove(q: Query2<Mut<Pm>, Vm>): Unit {
    @EachG2[Pm, pi, Vm, vi, eid, s1mGroup](
        let v = Vm.denseValueAt(vi)
        let p = Pm.denseValueAt(pi)
        Pm.denseSetAt(pi, Pm(kernel12(p.x + v.vx * DT), p.y + v.vy * DT))
    )
}

@System
public func s2k0(q: Query2<Mut<C0>, In2>): Unit {
    @Each2[C0, ci, In2, ii, eid](
        C0.denseSetAt(ci, C0(C0.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k1(q: Query2<Mut<C1>, In2>): Unit {
    @Each2[C1, ci, In2, ii, eid](
        C1.denseSetAt(ci, C1(C1.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k2(q: Query2<Mut<C2>, In2>): Unit {
    @Each2[C2, ci, In2, ii, eid](
        C2.denseSetAt(ci, C2(C2.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k3(q: Query2<Mut<C3>, In2>): Unit {
    @Each2[C3, ci, In2, ii, eid](
        C3.denseSetAt(ci, C3(C3.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k4(q: Query2<Mut<C4>, In2>): Unit {
    @Each2[C4, ci, In2, ii, eid](
        C4.denseSetAt(ci, C4(C4.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k5(q: Query2<Mut<C5>, In2>): Unit {
    @Each2[C5, ci, In2, ii, eid](
        C5.denseSetAt(ci, C5(C5.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k6(q: Query2<Mut<C6>, In2>): Unit {
    @Each2[C6, ci, In2, ii, eid](
        C6.denseSetAt(ci, C6(C6.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k7(q: Query2<Mut<C7>, In2>): Unit {
    @Each2[C7, ci, In2, ii, eid](
        C7.denseSetAt(ci, C7(C7.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k8(q: Query2<Mut<C8>, In2>): Unit {
    @Each2[C8, ci, In2, ii, eid](
        C8.denseSetAt(ci, C8(C8.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k9(q: Query2<Mut<C9>, In2>): Unit {
    @Each2[C9, ci, In2, ii, eid](
        C9.denseSetAt(ci, C9(C9.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k10(q: Query2<Mut<C10>, In2>): Unit {
    @Each2[C10, ci, In2, ii, eid](
        C10.denseSetAt(ci, C10(C10.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s2k11(q: Query2<Mut<C11>, In2>): Unit {
    @Each2[C11, ci, In2, ii, eid](
        C11.denseSetAt(ci, C11(C11.denseValueAt(ci).v * 0.999 + In2.denseValueAt(ii).v))
    )
}

@System
public func s3a(q: Query1<Mut<Ka>>): Unit {
    @Each1[Ka, i, eid](
        let k = Ka.denseValueAt(i)
        Ka.denseSetAt(i, Ka(k.x + k.v * DT, k.v))
    )
}

@System
public func s3b(q: Query1<Mut<Kb>>): Unit {
    @Each1[Kb, i, eid](
        let k = Kb.denseValueAt(i)
        Kb.denseSetAt(i, Kb(k.x * 0.999 + k.v, k.v))
    )
}

@System
public func s3c(q: Query1<Mut<Kc>>): Unit {
    @Each1[Kc, i, eid](
        let k = Kc.denseValueAt(i)
        Kc.denseSetAt(i, Kc(k.x + k.v * k.v * DT, k.v))
    )
}

@System
public func s3d(q: Query1<Mut<Kd>>): Unit {
    @Each1[Kd, i, eid](
        let k = Kd.denseValueAt(i)
        Kd.denseSetAt(i, Kd(k.x + (k.v - k.x) * 0.1, k.v))
    )
}

@System
public func s4Burn(q: Query2<Mut<Hp4>, Burn4>): Unit {
    @EachG2[Hp4, hi, Burn4, bi, eid, s4Group](
        Hp4.denseSetAt(hi, Hp4(Hp4.denseValueAt(hi).v - Burn4.denseValueAt(bi).v))
    )
}

@System
public func s5Damage(q: Query3<Mut<H5>, A5, D5>): Unit {
    @EachG3[H5, hi, A5, ai, D5, di, eid, s5Group](
        var raw = D5.denseValueAt(di).v - A5.denseValueAt(ai).v
        if (raw < 0.0) {
            raw = 0.0
        }
        H5.denseSetAt(hi, H5(H5.denseValueAt(hi).v - raw * 0.01))
    )
}

@System
public func s6Move(q: Query1<Mut<P6>>): Unit {
    @Each1[P6, i, eid](
        P6.denseSetAt(i, P6(P6.denseValueAt(i).x + 1.0))
    )
}

@System
public func s6Ttl(q: Query1<Mut<T6>>): Unit {
    @Each1[T6, i, eid](
        T6.denseSetAt(i, T6(T6.denseValueAt(i).ttl - 1))
    )
}
