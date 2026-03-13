package ecsFramework

import std.collection.*

public class SparseSet<T> {
    private let NPOS: Int64 = -1
    private var denseEntities: ArrayList<Int64> = ArrayList<Int64>()
    private var sparse: ArrayList<Int64> = ArrayList<Int64>()
    private var denseData: ArrayList<T> = ArrayList<T>()

    public init() {}

    public func denseSize(): Int64 {
        denseEntities.size
    }

    public func denseEntityAt(i: Int64): Int64 {
        denseEntities[i]
    }

    public func denseValueAt(i: Int64): T {
        denseData[i]
    }

    public func setDenseValueAt(i: Int64, value: T): Unit {
        denseData[i] = value
    }

    public func has(entityId: Int64): Bool {
        if (entityId >= sparse.size) {
            return false
        }
        let denseIdx = sparse[entityId]
        denseIdx != NPOS && denseIdx < denseEntities.size && denseEntities[denseIdx] == entityId
    }

    public func add(entityId: Int64, value: T): Unit {
        while (sparse.size <= entityId) {
            sparse.add(NPOS)
        }
        
        let denseIdx = denseEntities.size
        sparse[entityId] = denseIdx
        denseEntities.add(entityId)
        denseData.add(value)
    }

    public func get(entityId: Int64): T {
        let denseIdx = sparse[entityId]
        denseData[denseIdx]
    }

    public func tryGet(entityId: Int64): ?T {
        if (!has(entityId)) {
            return None
        }
        Some(get(entityId))
    }

    public func set(entityId: Int64, value: T): Unit {
        if (!has(entityId)) {
            throw Exception("Entity does not have component")
        }
        let denseIdx = sparse[entityId]
        denseData[denseIdx] = value
    }

    public func remove(entityId: Int64): Unit {
        if (!has(entityId)) {
            return
        }

        let denseIdx = sparse[entityId]
        let lastIdx = denseEntities.size - 1

        if (denseIdx != lastIdx) {
            let movedEntityId = denseEntities[lastIdx]
            denseEntities[denseIdx] = movedEntityId
            denseData[denseIdx] = denseData[lastIdx]
            sparse[movedEntityId] = denseIdx
        }

        denseEntities.remove(lastIdx..lastIdx + 1)
        denseData.remove(lastIdx..lastIdx + 1)
        sparse[entityId] = NPOS
    }

    public func onEntityDestroyed(entityId: Int64): Unit {
        remove(entityId)
    }

    public func clear(): Unit {
        denseEntities.clear()
        denseData.clear()
        for (i in 0..sparse.size) {
            sparse[i] = NPOS
        }
    }
}