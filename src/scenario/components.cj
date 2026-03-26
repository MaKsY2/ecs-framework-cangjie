package ecsFramework.scenario

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

public struct Health {
    public var hp: Float64

    public init(hp: Float64) {
        this.hp = hp
    }
}

public struct Damage {
    public var dmg: Float64

    public init(dmg: Float64) {
        this.dmg = dmg
    }
}

public struct Armor {
    public var armor: Float64

    public init(armor: Float64) {
        this.armor = armor
    }
}

public struct Lifetime {
    public var remaining: Float64

    public init(remaining: Float64) {
        this.remaining = remaining
    }
}

public struct Team {
    public var teamId: Int64

    public init(teamId: Int64) {
        this.teamId = teamId
    }
}

