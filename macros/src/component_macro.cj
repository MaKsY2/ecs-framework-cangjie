macro package ecsmacros

import std.ast.*

public macro Component(input: Tokens): Tokens {
    match (parseDecl(input)) {
        case sd: StructDecl =>
            let poolIdent = Token(IDENTIFIER, "_pool_${sd.identifier.value}")
            let ty = sd.identifier
            return quote(
                $(input)

                private let $(poolIdent) = ComponentPool<$(ty)>()

                extend $(ty) <: Component<$(ty)> {
                    public static func add(entity: Entity, value: $(ty)): Unit {
                        $(poolIdent).add(entity, value)
                    }

                    public static func get(entity: Entity): $(ty) {
                        $(poolIdent).get(entity)
                    }

                    public static func has(entity: Entity): Bool {
                        $(poolIdent).has(entity)
                    }

                    public static func remove(entity: Entity): Unit {
                        $(poolIdent).remove(entity)
                    }

                    @Frozen
                    public static func hasById(entityId: Int64): Bool {
                        $(poolIdent).hasById(entityId)
                    }

                    public static func removeById(entityId: Int64): Unit {
                        $(poolIdent).removeById(entityId)
                    }

                    @Frozen
                    public static func denseSize(): Int64 {
                        $(poolIdent).denseSize()
                    }

                    @Frozen
                    public static func denseEntityAt(i: Int64): Int64 {
                        $(poolIdent).denseEntityAt(i)
                    }

                    @Frozen
                    public static func denseValueAt(i: Int64): $(ty) {
                        $(poolIdent).denseValueAt(i)
                    }

                    @Frozen
                    public static func denseSetAt(i: Int64, value: $(ty)): Unit {
                        $(poolIdent).denseSetAt(i, value)
                    }

                    @Frozen
                    public static func denseIndexOf(entityId: Int64): Int64 {
                        $(poolIdent).denseIndexOf(entityId)
                    }

                    @Frozen
                    public static func rawEntities(): Array<Int64> {
                        $(poolIdent).rawEntities()
                    }

                    @Frozen
                    public static func rawSparse(): Array<Int64> {
                        $(poolIdent).rawSparse()
                    }

                    public static func swapDense(i: Int64, j: Int64): Unit {
                        $(poolIdent).swapDense(i, j)
                    }

                    public static func registerHooks(
                        onAdd: (Int64) -> Unit,
                        onRemove: (Int64) -> Unit
                    ): Unit {
                        $(poolIdent).registerHooks(onAdd, onRemove)
                    }
                }
            )

        case _ =>
            diagReport(
                DiagReportLevel.ERROR,
                input,
                "`@Component` can be applied only to struct",
                "example: @Component public struct Position { ... }"
            )
            return input
    }
}
