package ecsFramework.framework

public class ComponentPool<T> <: IComponentStorage<T> {
    private let sparse = SparseSet<T>()

    public func add(entity: Entity, value: T): Unit {
        sparse.add(entity.id, value)
    }

    public func get(entity: Entity): T {
        sparse.get(entity.id)
    }

    public func has(entity: Entity): Bool {
        sparse.has(entity.id)
    }

    public func remove(entity: Entity): Unit {
        sparse.remove(entity.id)
    }

    public func getById(entityId: Int64): T {
        sparse.get(entityId)
    }

    public func hasById(entityId: Int64): Bool {
        sparse.has(entityId)
    }

    public func removeById(entityId: Int64): Unit {
        sparse.remove(entityId)
    }

    public func denseSize(): Int64 {
        sparse.denseSize()
    }

    public func denseEntityAt(i: Int64): Int64 {
        sparse.denseEntityAt(i)
    }

    public func denseValueAt(i: Int64): T {
        sparse.denseValueAt(i)
    }
}
