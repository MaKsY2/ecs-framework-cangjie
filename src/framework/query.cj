package ecsFramework.framework

import std.collection.*

public interface Access {
    func reads(): Array<String>
    func writes(): Array<String>
}

public interface QueryParam<H> {
    static func paramName(): String
    static func paramIsWrite(): Bool
    static func paramDenseSize(): Int64
    static func paramEntityAt(i: Int64): Int64
    static func paramHas(eid: Int64): Bool
    // Build a handle for a joined (secondary) component, located by entity id.
    static func paramHandle(eid: Int64): H
    // Build a handle for the leading component, located directly by dense index.
    static func paramHandleAt(i: Int64): H
}

/**
 * Write handle to a component. It stores the *dense index* of the element, not
 * the entity id, so `get`/`set` are a single direct array access — no
 * entity-id -> sparse -> dense translation on every read and write, and no
 * `Registry` reference to carry around. Both accessors are `@Frozen` so they
 * specialize and inline into the system body under `-O2`.
 */
public struct Mut<T> where T <: Component<T> {
    private let di: Int64

    public init(di: Int64) {
        this.di = di
    }

    @Frozen
    public func get(): T {
        T.denseValueAt(di)
    }

    @Frozen
    public func set(value: T): Unit {
        T.denseSetAt(di, value)
    }
}

extend<T> Mut<T> <: QueryParam<Mut<T>> where T <: Component<T> {
    public static func paramName(): String {
        T.name()
    }
    public static func paramIsWrite(): Bool {
        true
    }
    @Frozen
    public static func paramDenseSize(): Int64 {
        T.denseSize()
    }
    @Frozen
    public static func paramEntityAt(i: Int64): Int64 {
        T.denseEntityAt(i)
    }
    @Frozen
    public static func paramHas(eid: Int64): Bool {
        T.hasById(eid)
    }
    @Frozen
    public static func paramHandle(eid: Int64): Mut<T> {
        Mut<T>(T.denseIndexOf(eid))
    }
    @Frozen
    public static func paramHandleAt(i: Int64): Mut<T> {
        Mut<T>(i)
    }
}

public class Query1<P> <: Access where P <: QueryParam<P> {
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

    @Frozen
    public func each(reg: Registry, cb: (Int64, P) -> Unit): Unit {
        var i: Int64 = P.paramDenseSize() - 1
        while (i >= 0) {
            let eid = P.paramEntityAt(i)
            cb(eid, P.paramHandleAt(i))
            i -= 1
        }
    }
}

public class Query2<P, Q> <: Access where P <: QueryParam<P>, Q <: QueryParam<Q> {
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

    @Frozen
    public func each(reg: Registry, cb: (Int64, P, Q) -> Unit): Unit {
        let sp = P.paramDenseSize()
        let sq = Q.paramDenseSize()
        if (sp <= sq) {
            var i: Int64 = sp - 1
            while (i >= 0) {
                let eid = P.paramEntityAt(i)
                if (Q.paramHas(eid)) {
                    cb(eid, P.paramHandleAt(i), Q.paramHandle(eid))
                }
                i -= 1
            }
        } else {
            var i: Int64 = sq - 1
            while (i >= 0) {
                let eid = Q.paramEntityAt(i)
                if (P.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid), Q.paramHandleAt(i))
                }
                i -= 1
            }
        }
    }
}

public class Query3<P, Q, R> <: Access
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

    @Frozen
    public func each(reg: Registry, cb: (Int64, P, Q, R) -> Unit): Unit {
        let lead = minLead()
        if (lead == 0) {
            var i: Int64 = P.paramDenseSize() - 1
            while (i >= 0) {
                let eid = P.paramEntityAt(i)
                if (Q.paramHas(eid) && R.paramHas(eid)) {
                    cb(eid, P.paramHandleAt(i), Q.paramHandle(eid), R.paramHandle(eid))
                }
                i -= 1
            }
        } else if (lead == 1) {
            var i: Int64 = Q.paramDenseSize() - 1
            while (i >= 0) {
                let eid = Q.paramEntityAt(i)
                if (P.paramHas(eid) && R.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid), Q.paramHandleAt(i), R.paramHandle(eid))
                }
                i -= 1
            }
        } else {
            var i: Int64 = R.paramDenseSize() - 1
            while (i >= 0) {
                let eid = R.paramEntityAt(i)
                if (P.paramHas(eid) && Q.paramHas(eid)) {
                    cb(eid, P.paramHandle(eid), Q.paramHandle(eid), R.paramHandleAt(i))
                }
                i -= 1
            }
        }
    }
}
