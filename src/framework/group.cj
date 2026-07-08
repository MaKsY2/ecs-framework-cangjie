package ecsFramework.framework

public class OwnGroup2<A, B> where A <: Component<A>, B <: Component<B> {
    private var count: Int64 = 0
    private var active: Bool = false

    public init() {}

    public func activate(): Unit {
        if (active) {
            return
        }
        active = true
        A.registerHooks({eid => onAdd(eid)}, {eid => onRemove(eid)})
        B.registerHooks({eid => onAdd(eid)}, {eid => onRemove(eid)})

        count = 0
        var i: Int64 = 0
        let denseCount = A.denseSize()
        while (i < denseCount) {
            onAdd(A.denseEntityAt(i))
            i += 1
        }
    }

    private func onAdd(eid: Int64): Unit {
        if (!A.hasById(eid) || !B.hasById(eid)) {
            return
        }
        let indexA = A.denseIndexOf(eid)
        if (indexA < count) {
            return
        }
        A.swapDense(indexA, count)
        B.swapDense(B.denseIndexOf(eid), count)
        count += 1
    }

    private func onRemove(eid: Int64): Unit {
        if (!A.hasById(eid) || !B.hasById(eid)) {
            return
        }
        let indexA = A.denseIndexOf(eid)
        if (indexA >= count) {
            return
        }
        let last = count - 1
        A.swapDense(indexA, last)
        B.swapDense(B.denseIndexOf(eid), last)
        count -= 1
    }

    @Frozen
    public func size(): Int64 {
        count
    }
}

public class OwnGroup3<A, B, C> where A <: Component<A>, B <: Component<B>, C <: Component<C> {
    private var count: Int64 = 0
    private var active: Bool = false

    public init() {}

    public func activate(): Unit {
        if (active) {
            return
        }
        active = true
        A.registerHooks({eid => onAdd(eid)}, {eid => onRemove(eid)})
        B.registerHooks({eid => onAdd(eid)}, {eid => onRemove(eid)})
        C.registerHooks({eid => onAdd(eid)}, {eid => onRemove(eid)})

        count = 0
        var i: Int64 = 0
        let denseCount = A.denseSize()
        while (i < denseCount) {
            onAdd(A.denseEntityAt(i))
            i += 1
        }
    }

    private func onAdd(eid: Int64): Unit {
        if (!A.hasById(eid) || !B.hasById(eid) || !C.hasById(eid)) {
            return
        }
        let indexA = A.denseIndexOf(eid)
        if (indexA < count) {
            return
        }
        A.swapDense(indexA, count)
        B.swapDense(B.denseIndexOf(eid), count)
        C.swapDense(C.denseIndexOf(eid), count)
        count += 1
    }

    private func onRemove(eid: Int64): Unit {
        if (!A.hasById(eid) || !B.hasById(eid) || !C.hasById(eid)) {
            return
        }
        let indexA = A.denseIndexOf(eid)
        if (indexA >= count) {
            return
        }
        let last = count - 1
        A.swapDense(indexA, last)
        B.swapDense(B.denseIndexOf(eid), last)
        C.swapDense(C.denseIndexOf(eid), last)
        count -= 1
    }

    @Frozen
    public func size(): Int64 {
        count
    }
}
