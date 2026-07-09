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
    static func paramEntitiesRaw(): Array<Int64>
    static func paramSparseRaw(): Array<Int64>
    static func paramHandleAt(i: Int64): H
}

public struct Mut<T> where T <: Component<T> {
    private let denseIndex: Int64

    public init(denseIndex: Int64) {
        this.denseIndex = denseIndex
    }

    @Frozen
    public func get(): T {
        T.denseValueAt(denseIndex)
    }

    @Frozen
    public func set(value: T): Unit {
        T.denseSetAt(denseIndex, value)
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
    public static func paramEntitiesRaw(): Array<Int64> {
        T.rawEntities()
    }

    @Frozen
    public static func paramSparseRaw(): Array<Int64> {
        T.rawSparse()
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
    public func each(cb: (Int64, P) -> Unit): Unit {
        let count = P.paramDenseSize()
        let pEntities = P.paramEntitiesRaw()
        var i: Int64 = 0
        while (i < count) {
            cb(pEntities[i], P.paramHandleAt(i))
            i += 1
        }
    }
}

public class Query2<P, Q> <: Access where P <: QueryParam<P>, Q <: QueryParam<Q> {
    public init() {}

    public func reads(): Array<String> {
        let r = ArrayList<String>()
        if (!P.paramIsWrite()) {
            r.add(P.paramName())
        }
        if (!Q.paramIsWrite()) {
            r.add(Q.paramName())
        }
        r.toArray()
    }

    public func writes(): Array<String> {
        let w = ArrayList<String>()
        if (P.paramIsWrite()) {
            w.add(P.paramName())
        }
        if (Q.paramIsWrite()) {
            w.add(Q.paramName())
        }
        w.toArray()
    }

    @Frozen
    public func each(cb: (Int64, P, Q) -> Unit): Unit {
        let pCount = P.paramDenseSize()
        let qCount = Q.paramDenseSize()
        let pEntities = P.paramEntitiesRaw()
        let qEntities = Q.paramEntitiesRaw()
        if (pCount <= qCount) {
            let qSparse = Q.paramSparseRaw()
            let qSparseLen = qSparse.size
            var i: Int64 = 0
            while (i < pCount) {
                let eid = pEntities[i]
                let qIndex = if (qEntities[i] == eid) {
                    i
                } else if (eid < qSparseLen) {
                    qSparse[eid]
                } else {
                    -1
                }
                if (qIndex >= 0) {
                    cb(eid, P.paramHandleAt(i), Q.paramHandleAt(qIndex))
                }
                i += 1
            }
        } else {
            let pSparse = P.paramSparseRaw()
            let pSparseLen = pSparse.size
            var i: Int64 = 0
            while (i < qCount) {
                let eid = qEntities[i]
                let pIndex = if (pEntities[i] == eid) {
                    i
                } else if (eid < pSparseLen) {
                    pSparse[eid]
                } else {
                    -1
                }
                if (pIndex >= 0) {
                    cb(eid, P.paramHandleAt(pIndex), Q.paramHandleAt(i))
                }
                i += 1
            }
        }
    }

    @Frozen
    public func eachIdx(cb: (Int64, Int64, Int64) -> Unit): Unit {
        let pCount = P.paramDenseSize()
        let qCount = Q.paramDenseSize()
        let pEntities = P.paramEntitiesRaw()
        let qEntities = Q.paramEntitiesRaw()
        if (pCount <= qCount) {
            let qSparse = Q.paramSparseRaw()
            let qSparseLen = qSparse.size
            var i: Int64 = 0
            while (i < pCount) {
                let eid = pEntities[i]
                let qIndex = if (qEntities[i] == eid) {
                    i
                } else if (eid < qSparseLen) {
                    qSparse[eid]
                } else {
                    -1
                }
                if (qIndex >= 0) {
                    cb(eid, i, qIndex)
                }
                i += 1
            }
        } else {
            let pSparse = P.paramSparseRaw()
            let pSparseLen = pSparse.size
            var i: Int64 = 0
            while (i < qCount) {
                let eid = qEntities[i]
                let pIndex = if (pEntities[i] == eid) {
                    i
                } else if (eid < pSparseLen) {
                    pSparse[eid]
                } else {
                    -1
                }
                if (pIndex >= 0) {
                    cb(eid, pIndex, i)
                }
                i += 1
            }
        }
    }
}

public class Query3<P, Q, R> <: Access where P <: QueryParam<P>, Q <: QueryParam<Q>, R <: QueryParam<R> {
    public init() {}

    public func reads(): Array<String> {
        let r = ArrayList<String>()
        if (!P.paramIsWrite()) {
            r.add(P.paramName())
        }
        if (!Q.paramIsWrite()) {
            r.add(Q.paramName())
        }
        if (!R.paramIsWrite()) {
            r.add(R.paramName())
        }
        r.toArray()
    }

    public func writes(): Array<String> {
        let w = ArrayList<String>()
        if (P.paramIsWrite()) {
            w.add(P.paramName())
        }
        if (Q.paramIsWrite()) {
            w.add(Q.paramName())
        }
        if (R.paramIsWrite()) {
            w.add(R.paramName())
        }
        w.toArray()
    }
}
