package ecsFramework.bench

import ecsmacros.*
import ecsFramework.framework.*

@Component
public struct Pos {
    public var x: Float64
    public var y: Float64
    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

@Component
public struct Vel {
    public var vx: Float64
    public var vy: Float64
    public init(vx: Float64, vy: Float64) {
        this.vx = vx
        this.vy = vy
    }
}

@Component
public struct Pm {
    public var x: Float64
    public var y: Float64
    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

@Component
public struct Vm {
    public var vx: Float64
    public var vy: Float64
    public init(vx: Float64, vy: Float64) {
        this.vx = vx
        this.vy = vy
    }
}

@Component
public struct In2 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C0 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C1 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C2 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C3 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C4 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C5 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C6 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C7 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C8 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C9 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C10 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct C11 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct Ka {
    public var x: Float64
    public var v: Float64
    public init(x: Float64, v: Float64) {
        this.x = x
        this.v = v
    }
}

@Component
public struct Kb {
    public var x: Float64
    public var v: Float64
    public init(x: Float64, v: Float64) {
        this.x = x
        this.v = v
    }
}

@Component
public struct Kc {
    public var x: Float64
    public var v: Float64
    public init(x: Float64, v: Float64) {
        this.x = x
        this.v = v
    }
}

@Component
public struct Kd {
    public var x: Float64
    public var v: Float64
    public init(x: Float64, v: Float64) {
        this.x = x
        this.v = v
    }
}

@Component
public struct Hp4 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct Burn4 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct H5 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct A5 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct D5 {
    public var v: Float64
    public init(v: Float64) {
        this.v = v
    }
}

@Component
public struct P6 {
    public var x: Float64
    public init(x: Float64) {
        this.x = x
    }
}

@Component
public struct T6 {
    public var ttl: Int64
    public init(ttl: Int64) {
        this.ttl = ttl
    }
}
