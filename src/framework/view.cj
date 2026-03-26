package ecsFramework.framework

public class View1<A> {
    let poolA: SparseSet<A>

    public init(poolA: SparseSet<A>) {
        this.poolA = poolA
    }

    public func each(f: (Int64, A) -> Unit): Unit {
        var i: Int64 = poolA.denseSize() - 1
        while (i >= 0) {
            let eid = poolA.denseEntityAt(i)
            f(eid, poolA.denseValueAt(i))
            i -= 1
        }
    }
}

public class View2<A, B> {
    let poolA: SparseSet<A>
    let poolB: SparseSet<B>

    public init(poolA: SparseSet<A>, poolB: SparseSet<B>) {
        this.poolA = poolA
        this.poolB = poolB
    }

    public func each(f: (Int64, A, B) -> Unit): Unit {
        if (poolA.denseSize() <= poolB.denseSize()) {
            var i: Int64 = poolA.denseSize() - 1
            while (i >= 0) {
                let eid = poolA.denseEntityAt(i)
                if (poolB.has(eid)) {
                    f(eid, poolA.denseValueAt(i), poolB.get(eid))
                }
                i -= 1
            }
        } else {
            var i: Int64 = poolB.denseSize() - 1
            while (i >= 0) {
                let eid = poolB.denseEntityAt(i)
                if (poolA.has(eid)) {
                    f(eid, poolA.get(eid), poolB.denseValueAt(i))
                }
                i -= 1
            }
        }
    }
}

public class View3<A, B, C> {
    let poolA: SparseSet<A>
    let poolB: SparseSet<B>
    let poolC: SparseSet<C>

    public init(poolA: SparseSet<A>, poolB: SparseSet<B>, poolC: SparseSet<C>) {
        this.poolA = poolA
        this.poolB = poolB
        this.poolC = poolC
    }

    func minPool(): Int64 {
        let sa = poolA.denseSize()
        let sb = poolB.denseSize()
        let sc = poolC.denseSize()
        if (sa <= sb && sa <= sc) {
            return 0
        } else if (sb <= sc) {
            return 1
        } else {
            return 2
        }
    }

    public func each(f: (Int64, A, B, C) -> Unit): Unit {
        let lead = minPool()
        if (lead == 0) {
            var i: Int64 = poolA.denseSize() - 1
            while (i >= 0) {
                let eid = poolA.denseEntityAt(i)
                if (poolB.has(eid) && poolC.has(eid)) {
                    f(eid, poolA.denseValueAt(i), poolB.get(eid), poolC.get(eid))
                }
                i -= 1
            }
        } else if (lead == 1) {
            var i: Int64 = poolB.denseSize() - 1
            while (i >= 0) {
                let eid = poolB.denseEntityAt(i)
                if (poolA.has(eid) && poolC.has(eid)) {
                    f(eid, poolA.get(eid), poolB.denseValueAt(i), poolC.get(eid))
                }
                i -= 1
            }
        } else {
            var i: Int64 = poolC.denseSize() - 1
            while (i >= 0) {
                let eid = poolC.denseEntityAt(i)
                if (poolA.has(eid) && poolB.has(eid)) {
                    f(eid, poolA.get(eid), poolB.get(eid), poolC.denseValueAt(i))
                }
                i -= 1
            }
        }
    }
}
