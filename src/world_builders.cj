package ecsFramework

import std.collection.*

public class EcsWorld {
    public var registry: Registry
    public var posPool: SparseSet<Position>
    public var velPool: SparseSet<Velocity>
    public var entities: ArrayList<Entity>

    public init() {
        this.registry = Registry()
        this.posPool = SparseSet<Position>()
        this.velPool = SparseSet<Velocity>()
        this.entities = ArrayList<Entity>()
    }
}

public func buildEcsWorldDense(n: Int64): EcsWorld {
    let world = EcsWorld()
    
    var i: Int64 = 0
    while (i < n) {
        let entity = world.registry.createEntity()
        world.entities.add(entity)
        
        let px = Float64(i % 1000)
        let py = Float64(i / 1000)
        let vx = 1.0
        let vy = 0.5
        
        world.posPool.add(entity.id, Position(px, py))
        world.velPool.add(entity.id, Velocity(vx, vy))
        
        i += 1
    }
    
    world
}

public func buildEcsWorldSelective(n: Int64): EcsWorld {
    let world = EcsWorld()
    
    var i: Int64 = 0
    while (i < n) {
        let entity = world.registry.createEntity()
        world.entities.add(entity)
        
        let px = Float64(i % 1000)
        let py = Float64(i / 1000)
        
        world.posPool.add(entity.id, Position(px, py))
        
        if (i % 2 == 0) {
            let vx = 1.0
            let vy = 0.5
            world.velPool.add(entity.id, Velocity(vx, vy))
        }
        
        i += 1
    }
    
    world
}

public func buildOopWorldDense(n: Int64): ArrayList<OopEntity> {
    let world = ArrayList<OopEntity>()
    
    var i: Int64 = 0
    while (i < n) {
        let px = Float64(i % 1000)
        let py = Float64(i / 1000)
        let vx = 1.0
        let vy = 0.5
        
        world.add(OopEntity(px, py, vx, vy, true))
        i += 1
    }
    
    world
}

public func buildOopWorldSelective(n: Int64): ArrayList<OopEntity> {
    let world = ArrayList<OopEntity>()
    
    var i: Int64 = 0
    while (i < n) {
        let px = Float64(i % 1000)
        let py = Float64(i / 1000)
        let vx = 1.0
        let vy = 0.5
        let hasVel = (i % 2 == 0)
        
        world.add(OopEntity(px, py, vx, vy, hasVel))
        i += 1
    }
    
    world
}