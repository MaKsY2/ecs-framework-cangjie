package ecsFramework.scenario

import ecsFramework.framework.*

public class EcsWorld {
    public var registry: Registry

    public init() {
        registry = Registry()
    }

    public func addObject(x: Float64, y: Float64, vx: Float64, vy: Float64): Unit {
        let e = registry.createEntity()
        registry.addComponent<Position>(e, Position(x, y))
        registry.addComponent<Velocity>(e, Velocity(vx, vy))
    }

    public func update(): Unit {
        let v = registry.view2<Position, Velocity>()
        v.each({ eid, pos, vel =>
            let newPos = Position(pos.x + vel.vx, pos.y + vel.vy)
            registry.getPool<Position>().add(eid, newPos)
        })
    }

    public func sumX(): Float64 {
        var s: Float64 = 0.0
        let pool = registry.getPool<Position>()
        var i: Int64 = 0
        while (i < pool.denseSize()) {
            s += pool.denseValueAt(i).x
            i += 1
        }
        s
    }

    public func sumY(): Float64 {
        var s: Float64 = 0.0
        let pool = registry.getPool<Position>()
        var i: Int64 = 0
        while (i < pool.denseSize()) {
            s += pool.denseValueAt(i).y
            i += 1
        }
        s
    }

    public func size(): Int64 {
        registry.getPool<Position>().denseSize()
    }
}
