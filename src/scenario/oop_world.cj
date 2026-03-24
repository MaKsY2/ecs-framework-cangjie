package ecsFramework.scenario

import std.collection.*

public class GameObject {
    public var x: Float64
    public var y: Float64
    public var vx: Float64
    public var vy: Float64

    public init(x: Float64, y: Float64, vx: Float64, vy: Float64) {
        this.x = x
        this.y = y
        this.vx = vx
        this.vy = vy
    }
}

public class OopWorld {
    var objects: ArrayList<GameObject>

    public init() {
        objects = ArrayList<GameObject>()
    }

    public func addObject(x: Float64, y: Float64, vx: Float64, vy: Float64): Unit {
        objects.add(GameObject(x, y, vx, vy))
    }

    public func update(): Unit {
        for (obj in objects) {
            obj.x += obj.vx
            obj.y += obj.vy
        }
    }

    public func sumX(): Float64 {
        var s: Float64 = 0.0
        for (obj in objects) {
            s += obj.x
        }
        s
    }

    public func sumY(): Float64 {
        var s: Float64 = 0.0
        for (obj in objects) {
            s += obj.y
        }
        s
    }

    public func size(): Int64 {
        objects.size
    }
}
