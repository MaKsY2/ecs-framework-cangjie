package macrotest

import ecsmacros.*

public interface ComponentMeta {
    static prop COMPONENT_ID: Int64
}

@Component[1]
public struct Position {
    public var x: Float64 = 0.0
    public var y: Float64 = 0.0
}

func acceptComponent<T>(x: T): Unit where T <: ComponentMeta {}

main(): Int64 {
    let p = Position()
    acceptComponent<Position>(p)
    println(Position.COMPONENT_ID)
    return 0
}
