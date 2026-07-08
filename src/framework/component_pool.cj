package ecsFramework.framework

import std.collection.*

public class ComponentPool<T> <: IComponentStorage<T> {
    private let sparse = SparseSet<T>()

    private let addHooks = ArrayList<(Int64) -> Unit>()
    private let removeHooks = ArrayList<(Int64) -> Unit>()

    public func registerHooks(onAdd: (Int64) -> Unit, onRemove: (Int64) -> Unit): Unit {
        addHooks.add(onAdd)
        removeHooks.add(onRemove)
    }

    public func add(entity: Entity, value: T): Unit {
        if (sparse.add(entity.id, value) && addHooks.size > 0) {
            for (hook in addHooks) {
                hook(entity.id)
            }
        }
    }

    public func get(entity: Entity): T {
        sparse.get(entity.id)
    }

    public func has(entity: Entity): Bool {
        sparse.has(entity.id)
    }

    public func remove(entity: Entity): Unit {
        removeById(entity.id)
    }

    public func swapDense(i: Int64, j: Int64): Unit {
        sparse.swapDense(i, j)
    }

    @Frozen
    public func getById(entityId: Int64): T {
        sparse.get(entityId)
    }

    @Frozen
    public func setById(entityId: Int64, value: T): Unit {
        sparse.set(entityId, value)
    }

    @Frozen
    public func hasById(entityId: Int64): Bool {
        sparse.has(entityId)
    }

    public func removeById(entityId: Int64): Unit {
        if (removeHooks.size > 0 && sparse.has(entityId)) {
            for (hook in removeHooks) {
                hook(entityId)
            }
        }
        sparse.remove(entityId)
    }

    @Frozen
    public func denseSize(): Int64 {
        sparse.denseSize()
    }

    @Frozen
    public func denseEntityAt(i: Int64): Int64 {
        sparse.denseEntityAt(i)
    }

    @Frozen
    public func denseValueAt(i: Int64): T {
        sparse.denseValueAt(i)
    }

    @Frozen
    public func denseSetAt(i: Int64, value: T): Unit {
        sparse.denseSetAt(i, value)
    }

    @Frozen
    public func denseIndexOf(entityId: Int64): Int64 {
        sparse.denseIndexOf(entityId)
    }

    @Frozen
    public func tryIndexOf(entityId: Int64): Int64 {
        sparse.tryIndexOf(entityId)
    }

    @Frozen
    public func rawEntities(): Array<Int64> {
        sparse.rawEntities()
    }

    @Frozen
    public func rawSparse(): Array<Int64> {
        sparse.rawSparse()
    }
}
