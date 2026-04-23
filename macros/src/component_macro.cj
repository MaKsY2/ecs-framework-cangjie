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

                    public static func denseSize(): Int64 {
                        $(poolIdent).denseSize()
                    }

                    public static func denseEntityAt(i: Int64): Int64 {
                        $(poolIdent).denseEntityAt(i)
                    }

                    public static func denseValueAt(i: Int64): $(ty) {
                        $(poolIdent).denseValueAt(i)
                    }

                    public static func getById(entityId: Int64): $(ty) {
                        $(poolIdent).getById(entityId)
                    }

                    public static func hasById(entityId: Int64): Bool {
                        $(poolIdent).hasById(entityId)
                    }

                    public static func removeById(entityId: Int64): Unit {
                        $(poolIdent).removeById(entityId)
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
