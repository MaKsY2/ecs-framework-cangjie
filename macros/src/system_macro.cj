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
            let fnName = fd.identifier.value
            let fnIdent = fd.identifier
            let wrapperIdent = Token(IDENTIFIER, "_${fnName}_Wrapper")
            let instanceIdent = Token(IDENTIFIER, "${fnName}_system")
            let nameLit = Token(STRING_LITERAL, fnName)
            let structuralLit = if (isStructural) { quote(true) } else { quote(false) }

            var accessElems = Tokens()
            var runArgs = quote(ctx)
            var idx = 0
            for (p in fd.funcParams) {
                if (idx >= 1) {
                    let qt = p.paramType.toTokens()
                    if (accessElems.size > 0) {
                        accessElems = accessElems + quote(,)
                    }
                    accessElems = accessElems + quote($(qt)())
                    runArgs = runArgs + quote(, $(qt)())
                }
                idx += 1
            }
            let accessBody = if (accessElems.size == 0) {
                quote(Array<Access>())
            } else {
                quote([$(accessElems)])
            }

            return quote(
                $(input)

                class $(wrapperIdent) <: System {
                    public override func name(): String { $(nameLit) }
                    public override func structural(): Bool { $(structuralLit) }
                    public override func access(): Array<Access> { $(accessBody) }
                    public override func run(ctx: SystemContext): Unit { $(fnIdent)($(runArgs)) }
                }

                public let $(instanceIdent): System = $(wrapperIdent)()
            )
        case _ =>
            diagReport(
                DiagReportLevel.ERROR,
                input,
                "`@System` must be applied to a func",
                "example: @System public func moveSystem(ctx: SystemContext, q: Query2<Mut<Position>, Velocity>): Unit { ... }"
            )
            return input
    }
}
