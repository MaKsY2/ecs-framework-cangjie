macro package ecsmacros

import std.ast.*

public macro System(input: Tokens): Tokens {
    match (parseDecl(input)) {
        case fd: FuncDecl =>
            if (fd.funcParams.size > 0) {
                diagReport(
                    DiagReportLevel.ERROR,
                    input,
                    "`@System` func must have no parameters; iterate with @Each / @EachG inside the body",
                    "example: @System public func moveSystem(): Unit { @Each2[Position, pi, Velocity, vi, eid](...) }"
                )
                return input
            }
            let fnIdent = fd.identifier
            let wrapperIdent = Token(IDENTIFIER, "_${fd.identifier.value}_Wrapper")
            let instanceIdent = Token(IDENTIFIER, "${fd.identifier.value}_system")
            return quote(
                $(input)

                class $(wrapperIdent) <: System {
                    public override func run(): Unit { $(fnIdent)() }
                }

                public let $(instanceIdent): System = $(wrapperIdent)()
            )
        case _ =>
            diagReport(
                DiagReportLevel.ERROR,
                input,
                "`@System` must be applied to a func",
                "example: @System public func moveSystem(): Unit { ... }"
            )
            return input
    }
}
