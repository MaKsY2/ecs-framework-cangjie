package ecsFramework.framework

public interface Component<T> {
    static func add(entity: Entity, value: T): Unit
    static func get(entity: Entity): T
    static func has(entity: Entity): Bool
    static func remove(entity: Entity): Unit

    static func getById(entityId: Int64): T
    static func hasById(entityId: Int64): Bool
    static func removeById(entityId: Int64): Unit

    static func denseSize(): Int64
    static func denseEntityAt(i: Int64): Int64
    static func denseValueAt(i: Int64): T
}
