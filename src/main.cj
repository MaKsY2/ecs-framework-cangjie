package ecsFramework

import ecsmacros.*

@Component
public struct Position {
    public var x: Float64 = 0.0
    public var y: Float64 = 0.0
}

main(): Int64 {
    let e = Entity()
    Position.add(e, Position(1.0, 2.0))

    if (Position.has(e)) {
        let p = Position.get(e)
        println(p.x)
        println(p.y)
    }

    Position.remove(e)
    return 0
}
