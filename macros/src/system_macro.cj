macro package ecsmacros

import std.ast.*

public macro System(attrs: Tokens, input: Tokens): Tokens {
    expandSystem(attrs, input)
}

public macro System(input: Tokens): Tokens {
    expandSystem(Tokens(), input)
}

func expandSystem(attrs: Tokens, input: Tokens): Tokens {
    var isStructural = false
    for (t in attrs) {
        if (t.kind == IDENTIFIER && t.value == "structural") {
            isStructural = true
        }
    }

    match (parseDecl(input)) {
        case fd: FuncDecl =>
            let funcName = fd.identifier.value
            let wrapperIdent = Token(IDENTIFIER, "_${funcName}_Wrapper")
            let instanceIdent = Token(IDENTIFIER, "${funcName}_system")
            let nameLit = Token(STRING_LITERAL, funcName)
            let funcIdent = fd.identifier

            let structuralBody = if (isStructural) {
                quote(true)
            } else {
                quote(false)
            }

            return quote(
                $(input)

                class $(wrapperIdent) <: System {
                    public init() { super() }
                    public override func name(): String { $(nameLit) }
                    public override func structural(): Bool { $(structuralBody) }
                    public override func run(ctx: SystemContext): Unit {
                        $(funcIdent)(ctx)
                    }
                }

                public let $(instanceIdent): System = $(wrapperIdent)()
            )
        case _ =>
            diagReport(
                DiagReportLevel.ERROR,
                input,
                "`@System` must be applied to a func",
                "example: @System public func moveSystem(ctx: SystemContext): Unit { ... }"
            )
            return input
    }
}
