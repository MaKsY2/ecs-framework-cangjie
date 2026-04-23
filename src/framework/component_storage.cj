package ecsFramework.framework

public interface IComponentStorage<T> {
    func add(entity: Entity, value: T): Unit
    func get(entity: Entity): T
    func has(entity: Entity): Bool
    func remove(entity: Entity): Unit
}
