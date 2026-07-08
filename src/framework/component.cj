package ecsFramework.framework

public interface Component<T> {
    static func name(): String

    static func add(entity: Entity, value: T): Unit
    static func get(entity: Entity): T
    static func has(entity: Entity): Bool
    static func remove(entity: Entity): Unit

    static func getById(entityId: Int64): T
    static func setById(entityId: Int64, value: T): Unit
    static func hasById(entityId: Int64): Bool
    static func removeById(entityId: Int64): Unit

    static func denseSize(): Int64
    static func denseEntityAt(i: Int64): Int64
    static func denseValueAt(i: Int64): T
    static func denseSetAt(i: Int64, value: T): Unit
    static func denseIndexOf(entityId: Int64): Int64
    static func tryIndexOf(entityId: Int64): Int64

    static func rawEntities(): Array<Int64>
    static func rawSparse(): Array<Int64>

    static func swapDense(i: Int64, j: Int64): Unit
    static func registerHooks(onAdd: (Int64) -> Unit, onRemove: (Int64) -> Unit): Unit
}
