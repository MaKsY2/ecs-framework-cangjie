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
}
