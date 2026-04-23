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

                extend $(ty) {
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
