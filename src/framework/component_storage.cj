package ecsFramework.framework

public interface IComponentStorage<T> {
    func add(entity: Entity, value: T): Unit
    func get(entity: Entity): T
    func has(entity: Entity): Bool
    func remove(entity: Entity): Unit

    func getById(entityId: Int64): T
    func hasById(entityId: Int64): Bool
    func removeById(entityId: Int64): Unit

    func denseSize(): Int64
    func denseEntityAt(i: Int64): Int64
    func denseValueAt(i: Int64): T
}
