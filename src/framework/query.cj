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
    static func paramTryIndexOf(eid: Int64): Int64
    static func paramEntitiesRaw(): Array<Int64>
    static func paramSparseRaw(): Array<Int64>
    static func paramHandle(eid: Int64): H
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
    public static func paramEntityAt(i: Int64): Int64 {
        T.denseEntityAt(i)
    }

    @Frozen
    public static func paramHas(eid: Int64): Bool {
        T.hasById(eid)
    }

    @Frozen
    public static func paramTryIndexOf(eid: Int64): Int64 {
        T.tryIndexOf(eid)
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
    public func each(cb: (Int64, P) -> Unit): Unit {
        let count = P.paramDenseSize()
        let pEntities = P.paramEntitiesRaw()
        var i: Int64 = 0
        while (i < count) {
            cb(pEntities[i], P.paramHandleAt(i))
            i += 1
        }
    }

    @Frozen
    public func eachIdx(cb: (Int64, Int64) -> Unit): Unit {
        let count = P.paramDenseSize()
        let pEntities = P.paramEntitiesRaw()
        var i: Int64 = 0
        while (i < count) {
            cb(pEntities[i], i)
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
        if (P.paramDenseSize() <= Q.paramDenseSize()) {
            eachLeadP<P, Q>(cb)
        } else {
            eachLeadQ<P, Q>(cb)
        }
    }

    @Frozen
    public func eachIdx(cb: (Int64, Int64, Int64) -> Unit): Unit {
        if (P.paramDenseSize() <= Q.paramDenseSize()) {
            eachIdxLeadP<P, Q>(cb)
        } else {
            eachIdxLeadQ<P, Q>(cb)
        }
    }
}

@Frozen
public func eachIdxLeadP<P, Q>(cb: (Int64, Int64, Int64) -> Unit): Unit where P <: QueryParam<P>, Q <: QueryParam<Q> {
    let pCount = P.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
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
}

@Frozen
public func eachIdxLeadQ<P, Q>(cb: (Int64, Int64, Int64) -> Unit): Unit where P <: QueryParam<P>, Q <: QueryParam<Q> {
    let qCount = Q.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
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

@Frozen
public func eachLeadP<P, Q>(cb: (Int64, P, Q) -> Unit): Unit where P <: QueryParam<P>, Q <: QueryParam<Q> {
    let pCount = P.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
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
}

@Frozen
public func eachLeadQ<P, Q>(cb: (Int64, P, Q) -> Unit): Unit where P <: QueryParam<P>, Q <: QueryParam<Q> {
    let qCount = Q.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
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

    private func minLead(): Int64 {
        let pCount = P.paramDenseSize()
        let qCount = Q.paramDenseSize()
        let rCount = R.paramDenseSize()
        if (pCount <= qCount && pCount <= rCount) {
            return 0
        }
        if (qCount <= rCount) {
            return 1
        }
        return 2
    }

    @Frozen
    public func each(cb: (Int64, P, Q, R) -> Unit): Unit {
        let lead = minLead()
        if (lead == 0) {
            eachLead3P<P, Q, R>(cb)
        } else if (lead == 1) {
            eachLead3Q<P, Q, R>(cb)
        } else {
            eachLead3R<P, Q, R>(cb)
        }
    }

    @Frozen
    public func eachIdx(cb: (Int64, Int64, Int64, Int64) -> Unit): Unit {
        let lead = minLead()
        if (lead == 0) {
            eachIdxLead3P<P, Q, R>(cb)
        } else if (lead == 1) {
            eachIdxLead3Q<P, Q, R>(cb)
        } else {
            eachIdxLead3R<P, Q, R>(cb)
        }
    }
}

@Frozen
public func eachIdxLead3P<P, Q, R>(cb: (Int64, Int64, Int64, Int64) -> Unit): Unit where P <: QueryParam<P>,
    Q <: QueryParam<Q>, R <: QueryParam<R> {
    let leadCount = P.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
    let rEntities = R.paramEntitiesRaw()
    let qSparse = Q.paramSparseRaw()
    let rSparse = R.paramSparseRaw()
    let qSparseLen = qSparse.size
    let rSparseLen = rSparse.size
    var i: Int64 = 0
    while (i < leadCount) {
        let eid = pEntities[i]
        let qIndex = if (qEntities[i] == eid) {
            i
        } else if (eid < qSparseLen) {
            qSparse[eid]
        } else {
            -1
        }
        if (qIndex >= 0) {
            let rIndex = if (rEntities[i] == eid) {
                i
            } else if (eid < rSparseLen) {
                rSparse[eid]
            } else {
                -1
            }
            if (rIndex >= 0) {
                cb(eid, i, qIndex, rIndex)
            }
        }
        i += 1
    }
}

@Frozen
public func eachIdxLead3Q<P, Q, R>(cb: (Int64, Int64, Int64, Int64) -> Unit): Unit where P <: QueryParam<P>,
    Q <: QueryParam<Q>, R <: QueryParam<R> {
    let leadCount = Q.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
    let rEntities = R.paramEntitiesRaw()
    let pSparse = P.paramSparseRaw()
    let rSparse = R.paramSparseRaw()
    let pSparseLen = pSparse.size
    let rSparseLen = rSparse.size
    var i: Int64 = 0
    while (i < leadCount) {
        let eid = qEntities[i]
        let pIndex = if (pEntities[i] == eid) {
            i
        } else if (eid < pSparseLen) {
            pSparse[eid]
        } else {
            -1
        }
        if (pIndex >= 0) {
            let rIndex = if (rEntities[i] == eid) {
                i
            } else if (eid < rSparseLen) {
                rSparse[eid]
            } else {
                -1
            }
            if (rIndex >= 0) {
                cb(eid, pIndex, i, rIndex)
            }
        }
        i += 1
    }
}

@Frozen
public func eachIdxLead3R<P, Q, R>(cb: (Int64, Int64, Int64, Int64) -> Unit): Unit where P <: QueryParam<P>,
    Q <: QueryParam<Q>, R <: QueryParam<R> {
    let leadCount = R.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
    let rEntities = R.paramEntitiesRaw()
    let pSparse = P.paramSparseRaw()
    let qSparse = Q.paramSparseRaw()
    let pSparseLen = pSparse.size
    let qSparseLen = qSparse.size
    var i: Int64 = 0
    while (i < leadCount) {
        let eid = rEntities[i]
        let pIndex = if (pEntities[i] == eid) {
            i
        } else if (eid < pSparseLen) {
            pSparse[eid]
        } else {
            -1
        }
        if (pIndex >= 0) {
            let qIndex = if (qEntities[i] == eid) {
                i
            } else if (eid < qSparseLen) {
                qSparse[eid]
            } else {
                -1
            }
            if (qIndex >= 0) {
                cb(eid, pIndex, qIndex, i)
            }
        }
        i += 1
    }
}

@Frozen
public func eachLead3P<P, Q, R>(cb: (Int64, P, Q, R) -> Unit): Unit where P <: QueryParam<P>, Q <: QueryParam<Q>,
    R <: QueryParam<R> {
    let leadCount = P.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
    let rEntities = R.paramEntitiesRaw()
    let qSparse = Q.paramSparseRaw()
    let rSparse = R.paramSparseRaw()
    let qSparseLen = qSparse.size
    let rSparseLen = rSparse.size
    var i: Int64 = 0
    while (i < leadCount) {
        let eid = pEntities[i]
        let qIndex = if (qEntities[i] == eid) {
            i
        } else if (eid < qSparseLen) {
            qSparse[eid]
        } else {
            -1
        }
        if (qIndex >= 0) {
            let rIndex = if (rEntities[i] == eid) {
                i
            } else if (eid < rSparseLen) {
                rSparse[eid]
            } else {
                -1
            }
            if (rIndex >= 0) {
                cb(eid, P.paramHandleAt(i), Q.paramHandleAt(qIndex), R.paramHandleAt(rIndex))
            }
        }
        i += 1
    }
}

@Frozen
public func eachLead3Q<P, Q, R>(cb: (Int64, P, Q, R) -> Unit): Unit where P <: QueryParam<P>, Q <: QueryParam<Q>,
    R <: QueryParam<R> {
    let leadCount = Q.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
    let rEntities = R.paramEntitiesRaw()
    let pSparse = P.paramSparseRaw()
    let rSparse = R.paramSparseRaw()
    let pSparseLen = pSparse.size
    let rSparseLen = rSparse.size
    var i: Int64 = 0
    while (i < leadCount) {
        let eid = qEntities[i]
        let pIndex = if (pEntities[i] == eid) {
            i
        } else if (eid < pSparseLen) {
            pSparse[eid]
        } else {
            -1
        }
        if (pIndex >= 0) {
            let rIndex = if (rEntities[i] == eid) {
                i
            } else if (eid < rSparseLen) {
                rSparse[eid]
            } else {
                -1
            }
            if (rIndex >= 0) {
                cb(eid, P.paramHandleAt(pIndex), Q.paramHandleAt(i), R.paramHandleAt(rIndex))
            }
        }
        i += 1
    }
}

@Frozen
public func eachLead3R<P, Q, R>(cb: (Int64, P, Q, R) -> Unit): Unit where P <: QueryParam<P>, Q <: QueryParam<Q>,
    R <: QueryParam<R> {
    let leadCount = R.paramDenseSize()
    let pEntities = P.paramEntitiesRaw()
    let qEntities = Q.paramEntitiesRaw()
    let rEntities = R.paramEntitiesRaw()
    let pSparse = P.paramSparseRaw()
    let qSparse = Q.paramSparseRaw()
    let pSparseLen = pSparse.size
    let qSparseLen = qSparse.size
    var i: Int64 = 0
    while (i < leadCount) {
        let eid = rEntities[i]
        let pIndex = if (pEntities[i] == eid) {
            i
        } else if (eid < pSparseLen) {
            pSparse[eid]
        } else {
            -1
        }
        if (pIndex >= 0) {
            let qIndex = if (qEntities[i] == eid) {
                i
            } else if (eid < qSparseLen) {
                qSparse[eid]
            } else {
                -1
            }
            if (qIndex >= 0) {
                cb(eid, P.paramHandleAt(pIndex), Q.paramHandleAt(qIndex), R.paramHandleAt(i))
            }
        }
        i += 1
    }
}
