package ecsFramework.framework

import std.collection.*

public interface ISparseSet {
    mut func onEntityDestroyed(index: Int64): Unit
}

public class SparseSet<T> <: ISparseSet {
    public static let NPOS: Int64 = -1

    public var denseEntities: ArrayList<Int64> = ArrayList<Int64>([])
    public var sparse: ArrayList<Int64> = ArrayList<Int64>([])
    public var denseData: ArrayList<T> = ArrayList<T>([])

    public init() {}

    public func denseSize(): Int64 {
        denseData.size
    }

    public func denseEntityAt(i: Int64): Int64 {
        denseEntities[i]
    }

    public func denseValueAt(i: Int64): T {
        denseData[i]
    }

    public func getDenseIndex(entityId: Int64): Int64 {
        sparse[entityId]
    }

    func ensureSparseSize(entityId: Int64): Unit {
        if (entityId < 0) {
            return
        }
        while (sparse.size <= entityId) {
            sparse.add(NPOS)
        }
    }

    public func has(entityId: Int64): Bool {
        if (entityId < 0) {
            return false
        }
        if (entityId >= sparse.size) {
            return false
        }
        return sparse[entityId] != NPOS
    }

    public func add(entityId: Int64, value: T): Unit {
        ensureSparseSize(entityId)

        if (has(entityId)) {
            let di = sparse[entityId]
            denseData[di] = value
            return
        }

        let di: Int64 = denseData.size
        denseEntities.add(entityId)
        denseData.add(value)
        sparse[entityId] = di
    }

    public func get(entityId: Int64): T {
        let di = sparse[entityId]
        denseData[di]
    }

    public func update(entityId: Int64, f: (T) -> T): Unit {
        let di = sparse[entityId]
        denseData[di] = f(denseData[di])
    }

    public func remove(entityId: Int64): Unit {
        if (!has(entityId)) {
            return
        }

        let di = sparse[entityId]
        let last: Int64 = denseData.size - 1

        if (di != last) {
            denseData[di] = denseData[last]
            let movedEntityId = denseEntities[last]
            denseEntities[di] = movedEntityId
            sparse[movedEntityId] = di
        }

        denseData.remove(at: denseData.size - 1)
        denseEntities.remove(at: denseEntities.size - 1)
        sparse[entityId] = NPOS
    }

    public func onEntityDestroyed(index: Int64): Unit {
        remove(index)
    }
}
