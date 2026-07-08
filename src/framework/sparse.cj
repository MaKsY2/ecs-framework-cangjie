package ecsFramework.framework

public interface ISparseSet {
    mut func onEntityDestroyed(index: Int64): Unit
}

public class SparseSet<T> <: ISparseSet {
    public static let NPOS: Int64 = -1

    private var denseData: Array<T>
    private var denseEntities: Array<Int64>
    private var count: Int64

    private var sparse: Array<Int64>

    public init() {
        denseData = Array<T>()
        denseEntities = Array<Int64>()
        count = 0
        sparse = Array<Int64>()
    }

    @Frozen
    public func denseSize(): Int64 {
        count
    }

    @Frozen
    public func denseEntityAt(i: Int64): Int64 {
        denseEntities[i]
    }

    @Frozen
    public func denseValueAt(i: Int64): T {
        denseData[i]
    }

    @Frozen
    public func denseSetAt(i: Int64, value: T): Unit {
        denseData[i] = value
    }

    @Frozen
    public func denseIndexOf(entityId: Int64): Int64 {
        sparse[entityId]
    }

    @Frozen
    public func tryIndexOf(entityId: Int64): Int64 {
        if (entityId < 0 || entityId >= sparse.size) {
            return NPOS
        }
        sparse[entityId]
    }

    @Frozen
    public func rawEntities(): Array<Int64> {
        denseEntities
    }

    @Frozen
    public func rawSparse(): Array<Int64> {
        sparse
    }

    @Frozen
    public func has(entityId: Int64): Bool {
        if (entityId < 0 || entityId >= sparse.size) {
            return false
        }
        sparse[entityId] != NPOS
    }

    @Frozen
    public func get(entityId: Int64): T {
        denseData[sparse[entityId]]
    }

    @Frozen
    public func set(entityId: Int64, value: T): Unit {
        if (has(entityId)) {
            denseData[sparse[entityId]] = value
        }
    }

    public func add(entityId: Int64, value: T): Bool {
        if (entityId < 0) {
            return false
        }
        ensureSparse(entityId)

        let existing = sparse[entityId]
        if (existing != NPOS) {
            denseData[existing] = value
            return false
        }

        ensureDenseCapacity()
        let di = count
        denseData[di] = value
        denseEntities[di] = entityId
        sparse[entityId] = di
        count = di + 1
        true
    }

    public func swapDense(i: Int64, j: Int64): Unit {
        if (i == j) {
            return
        }
        let entityI = denseEntities[i]
        let entityJ = denseEntities[j]
        let tmp = denseData[i]
        denseData[i] = denseData[j]
        denseData[j] = tmp
        denseEntities[i] = entityJ
        denseEntities[j] = entityI
        sparse[entityI] = j
        sparse[entityJ] = i
    }

    public func remove(entityId: Int64): Unit {
        if (!has(entityId)) {
            return
        }

        let di = sparse[entityId]
        let last = count - 1

        if (di != last) {
            let moved = denseEntities[last]
            denseData[di] = denseData[last]
            denseEntities[di] = moved
            sparse[moved] = di
        }

        denseData[last] = unsafe { zeroValue<T>() }
        sparse[entityId] = NPOS
        count = last
    }

    public func onEntityDestroyed(index: Int64): Unit {
        remove(index)
    }

    private func ensureSparse(entityId: Int64): Unit {
        if (entityId < sparse.size) {
            return
        }
        var newCap = if (sparse.size == 0) {
            16
        } else {
            sparse.size * 2
        }
        while (newCap <= entityId) {
            newCap *= 2
        }
        let bigger = Array<Int64>(newCap, repeat: NPOS)
        sparse.copyTo(bigger, 0, 0, sparse.size)
        sparse = bigger
    }

    private func ensureDenseCapacity(): Unit {
        if (count < denseData.size) {
            return
        }
        let newCap = if (denseData.size == 0) {
            16
        } else {
            denseData.size * 2
        }

        let nd = Array<T>(newCap, repeat: unsafe { zeroValue<T>() })
        denseData.copyTo(nd, 0, 0, count)
        denseData = nd

        let ne = Array<Int64>(newCap, repeat: 0)
        denseEntities.copyTo(ne, 0, 0, count)
        denseEntities = ne
    }
}
