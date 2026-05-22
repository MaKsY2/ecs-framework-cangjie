package ecsFramework.framework

import std.collection.*

public interface QueryParam<H> {
    static func paramName(): String
    static func paramIsWrite(): Bool
    static func paramDenseSize(): Int64
    static func paramEntityAt(i: Int64): Int64
    static func paramHas(eid: Int64): Bool
    static func paramHandle(eid: Int64, reg: Registry): H
}

public class Mut<T> where T <: Component<T> {
    private let eid: Int64
    private let reg: Registry

    public init(eid: Int64, reg: Registry) {
        this.eid = eid
        this.reg = reg
    }

    public func get(): T {
        T.getById(eid)
    }

    public func set(value: T): Unit {
        let e = reg.entityOf(eid)
        if (!reg.alive(e)) {
            return
        }
        T.add(e, value)
    }
}

extend<T> Mut<T> <: QueryParam<Mut<T>> where T <: Component<T> {
    public static func paramName(): String {
        T.name()
    }
    public static func paramIsWrite(): Bool {
        true
    }
    public static func paramDenseSize(): Int64 {
        T.denseSize()
    }
    public static func paramEntityAt(i: Int64): Int64 {
        T.denseEntityAt(i)
    }
    public static func paramHas(eid: Int64): Bool {
        T.hasById(eid)
    }
    public static func paramHandle(eid: Int64, reg: Registry): Mut<T> {
        Mut<T>(eid, reg)
    }
}

public class Query1<P> where P <: QueryParam<P> {
    public init() {}

    public func reads(): Array<String> {
        if (P.paramIsWrite()) {
            Array<String>()
        } else {
            [P.paramName()]
        }
    }

    public func writes(): Array<String> {
        if (P.paramIsWrite()) {
            [P.paramName()]
        } else {
            Array<String>()
        }
    }

    public func each(reg: Registry, cb: (Int64, P) -> Unit): Unit {
        var i: Int64 = P.paramDenseSize() - 1
        while (i >= 0) {
            let eid = P.paramEntityAt(i)
            cb(eid, P.paramHandle(eid, reg))
            i -= 1
        }
    }
}

public class Query2<P, Q> where P <: QueryParam<P>, Q <: QueryParam<Q> {
    public init() {}

    public func reads(): Array<String> {
        let r = ArrayList<String>()
        if (!P.paramIsWrite()) { r.add(P.paramName()) }
        if (!Q.paramIsWrite()) { r.add(Q.paramName()) }
        r.toArray()
    }

    public func writes(): Array<String> {
        let w = ArrayList<String>()
        if (P.paramIsWrite()) { w.add(P.paramName()) }
        if (Q.paramIsWrite()) { w.add(Q.paramName()) }
        w.toArray()
    }

    public func each(reg: Registry, cb: (Int64, P, Q) -> Unit): Unit {
        if (P.paramDenseSize() <= Q.paramDenseSize()) {
            var i: Int64 = P.paramDenseSize() - 1
            while (i >= 0) {
                let eid = P.paramEntityAt(i)
                if (Q.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid, reg), Q.paramHandle(eid, reg))
                }
                i -= 1
            }
        } else {
            var i: Int64 = Q.paramDenseSize() - 1
            while (i >= 0) {
                let eid = Q.paramEntityAt(i)
                if (P.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid, reg), Q.paramHandle(eid, reg))
                }
                i -= 1
            }
        }
    }
}

public class Query3<P, Q, R>
    where P <: QueryParam<P>, Q <: QueryParam<Q>, R <: QueryParam<R> {
    public init() {}

    public func reads(): Array<String> {
        let r = ArrayList<String>()
        if (!P.paramIsWrite()) { r.add(P.paramName()) }
        if (!Q.paramIsWrite()) { r.add(Q.paramName()) }
        if (!R.paramIsWrite()) { r.add(R.paramName()) }
        r.toArray()
    }

    public func writes(): Array<String> {
        let w = ArrayList<String>()
        if (P.paramIsWrite()) { w.add(P.paramName()) }
        if (Q.paramIsWrite()) { w.add(Q.paramName()) }
        if (R.paramIsWrite()) { w.add(R.paramName()) }
        w.toArray()
    }

    private func minLead(): Int64 {
        let sp = P.paramDenseSize()
        let sq = Q.paramDenseSize()
        let sr = R.paramDenseSize()
        if (sp <= sq && sp <= sr) { return 0 }
        if (sq <= sr) { return 1 }
        return 2
    }

    public func each(reg: Registry, cb: (Int64, P, Q, R) -> Unit): Unit {
        let lead = minLead()
        if (lead == 0) {
            var i: Int64 = P.paramDenseSize() - 1
            while (i >= 0) {
                let eid = P.paramEntityAt(i)
                if (Q.paramHas(eid) && R.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid, reg), Q.paramHandle(eid, reg), R.paramHandle(eid, reg))
                }
                i -= 1
            }
        } else if (lead == 1) {
            var i: Int64 = Q.paramDenseSize() - 1
            while (i >= 0) {
                let eid = Q.paramEntityAt(i)
                if (P.paramHas(eid) && R.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid, reg), Q.paramHandle(eid, reg), R.paramHandle(eid, reg))
                }
                i -= 1
            }
        } else {
            var i: Int64 = R.paramDenseSize() - 1
            while (i >= 0) {
                let eid = R.paramEntityAt(i)
                if (P.paramHas(eid) && Q.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid, reg), Q.paramHandle(eid, reg), R.paramHandle(eid, reg))
                }
                i -= 1
            }
        }
    }
}
