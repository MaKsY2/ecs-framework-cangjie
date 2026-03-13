package ecsFramework

public struct Position {
    public var x: Float64
    public var y: Float64

    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

public struct Velocity {
    public let x: Float64
    public let y: Float64

    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

public class OopEntity {
    public var px: Float64
    public var py: Float64
    public var vx: Float64
    public var vy: Float64
    public var hasVelocity: Bool

    public init(px: Float64, py: Float64, vx: Float64, vy: Float64, hasVelocity: Bool) {
        this.px = px
        this.py = py
        this.vx = vx
        this.vy = vy
        this.hasVelocity = hasVelocity
    }
}