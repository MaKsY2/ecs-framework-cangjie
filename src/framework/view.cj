package ecsFramework.framework

public class View1<A> where A <: Component<A> {
    public init() {}

    public func each(f: (Int64, A) -> Unit): Unit {
        var i: Int64 = A.denseSize() - 1
        while (i >= 0) {
            let eid = A.denseEntityAt(i)
            f(eid, A.denseValueAt(i))
            i -= 1
        }
    }
}

public class View2<A, B> where A <: Component<A>, B <: Component<B> {
    public init() {}

    public func each(f: (Int64, A, B) -> Unit): Unit {
        if (A.denseSize() <= B.denseSize()) {
            var i: Int64 = A.denseSize() - 1
            while (i >= 0) {
                let eid = A.denseEntityAt(i)
                if (B.hasById(eid)) {
                    f(eid, A.denseValueAt(i), B.getById(eid))
                }
                i -= 1
            }
        } else {
            var i: Int64 = B.denseSize() - 1
            while (i >= 0) {
                let eid = B.denseEntityAt(i)
                if (A.hasById(eid)) {
                    f(eid, A.getById(eid), B.denseValueAt(i))
                }
                i -= 1
            }
        }
    }
}

public class View3<A, B, C> where A <: Component<A>, B <: Component<B>, C <: Component<C> {
    public init() {}

    func minPool(): Int64 {
        let sa = A.denseSize()
        let sb = B.denseSize()
        let sc = C.denseSize()
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
            var i: Int64 = A.denseSize() - 1
            while (i >= 0) {
                let eid = A.denseEntityAt(i)
                if (B.hasById(eid) && C.hasById(eid)) {
                    f(eid, A.denseValueAt(i), B.getById(eid), C.getById(eid))
                }

                i -= 1
            }
        } else if (lead == 1) {
            var i: Int64 = B.denseSize() - 1
            while (i >= 0) {
                let eid = B.denseEntityAt(i)
                if (A.hasById(eid) && C.hasById(eid)) {
                    f(eid, A.getById(eid), B.denseValueAt(i), C.getById(eid))
                }
                i -= 1
            }
        } else {
            var i: Int64 = C.denseSize() - 1
            while (i >= 0) {
                let eid = C.denseEntityAt(i)
                if (A.hasById(eid) && B.hasById(eid)) {
                    f(eid, A.getById(eid), B.getById(eid), C.denseValueAt(i))
                }
                i -= 1
            }
        }
    }
}
