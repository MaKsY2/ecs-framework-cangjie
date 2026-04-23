package ecsFramework.bench

public struct Position {
    public var x: Float64
    public var y: Float64

    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

public struct Velocity {
    public var vx: Float64
    public var vy: Float64

    public init(vx: Float64, vy: Float64) {
        this.vx = vx
        this.vy = vy
    }
}
