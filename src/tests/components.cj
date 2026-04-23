package ecsFramework.tests

import ecsmacros.*
import ecsFramework.framework.*

@Component
public struct Position {
    public var x: Float64
    public var y: Float64

    public init() {
        this.x = 0.0
        this.y = 0.0
    }

    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

@Component
public struct Velocity {
    public var vx: Float64
    public var vy: Float64

    public init() {
        this.vx = 0.0
        this.vy = 0.0
    }

    public init(vx: Float64, vy: Float64) {
        this.vx = vx
        this.vy = vy
    }
}

@Component
public struct Health {
    public var hp: Int64

    public init() {
        this.hp = 100
    }

    public init(hp: Int64) {
        this.hp = hp
    }
}

@Component
public struct Armor {
    public var value: Int64

    public init() {
        this.value = 0
    }

    public init(value: Int64) {
        this.value = value
    }
}

@Component
public struct Team {
    public var teamId: Int64

    public init() {
        this.teamId = 0
    }

    public init(teamId: Int64) {
        this.teamId = teamId
    }
}
