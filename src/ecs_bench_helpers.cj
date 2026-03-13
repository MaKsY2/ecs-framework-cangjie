package ecsFramework

public var sink: Int64 = 0

public func runEcsDenseUpdate(world: EcsWorld, frames: Int64): Int64 {
    var acc: Int64 = 0
    let dt = 0.016
    
    var f: Int64 = 0
    while (f < frames) {
        var i: Int64 = 0
        while (i < world.posPool.denseSize()) {
            let entityId = world.posPool.denseEntityAt(i)
            
            if (world.velPool.has(entityId)) {
                var p = world.posPool.denseValueAt(i)
                let v = world.velPool.get(entityId)
                
                p.x = p.x + v.x * dt
                p.y = p.y + v.y * dt
                
                world.posPool.setDenseValueAt(i, p)
                acc += Int64(p.x + p.y)
            }
            
            i += 1
        }
        f += 1
    }
    
    sink = acc
    acc
}

public func runEcsSelectiveUpdate(world: EcsWorld, frames: Int64): Int64 {
    var acc: Int64 = 0
    let dt = 0.016
    
    var f: Int64 = 0
    while (f < frames) {
        var i: Int64 = 0
        while (i < world.velPool.denseSize()) {
            let entityId = world.velPool.denseEntityAt(i)
            let v = world.velPool.denseValueAt(i)
            
            if (world.posPool.has(entityId)) {
                var p = world.posPool.get(entityId)
                
                p.x = p.x + v.x * dt
                p.y = p.y + v.y * dt
                
                world.posPool.set(entityId, p)
                acc += Int64(p.x + p.y)
            }
            
            i += 1
        }
        f += 1
    }
    
    sink = acc
    acc
}

public func runEcsCreateDestroy(n: Int64, rounds: Int64): Int64 {
    var acc: Int64 = 0
    let world = EcsWorld()
    
    var r: Int64 = 0
    while (r < rounds) {
        var i: Int64 = 0
        while (i < n) {
            let entity = world.registry.createEntity()
            world.entities.add(entity)
            
            let px = Float64(i % 100)
            let py = Float64(i / 100)
            world.posPool.add(entity.id, Position(px, py))
            world.velPool.add(entity.id, Velocity(1.0, 0.5))
            
            acc += entity.id
            i += 1
        }
        
        let toDestroy = n / 10
        var d: Int64 = 0
        while (d < toDestroy && world.entities.size > 0) {
            let lastIdx = world.entities.size - 1
            let entity = world.entities[lastIdx]
            world.registry.destroyEntity(entity)
            world.posPool.onEntityDestroyed(entity.id)
            world.velPool.onEntityDestroyed(entity.id)
            world.entities.remove(lastIdx..lastIdx + 1)
            acc += 1
            d += 1
        }
        
        r += 1
    }
    
    sink = acc
    acc
}

public func runEcsMixedFrame(n: Int64, frames: Int64): Int64 {
    let world = buildEcsWorldDense(n)
    var acc: Int64 = 0
    let dt = 0.016
    
    var f: Int64 = 0
    while (f < frames) {
        var i: Int64 = 0
        while (i < world.posPool.denseSize()) {
            let entityId = world.posPool.denseEntityAt(i)
            
            if (world.velPool.has(entityId)) {
                var p = world.posPool.denseValueAt(i)
                let v = world.velPool.get(entityId)
                
                p.x = p.x + v.x * dt
                p.y = p.y + v.y * dt
                
                world.posPool.setDenseValueAt(i, p)
                acc += Int64(p.x + p.y)
            }
            
            i += 1
        }
        
        let toDestroy = n / 100
        var d: Int64 = 0
        while (d < toDestroy && world.entities.size > 0) {
            let lastIdx = world.entities.size - 1
            let entity = world.entities[lastIdx]
            world.registry.destroyEntity(entity)
            world.posPool.onEntityDestroyed(entity.id)
            world.velPool.onEntityDestroyed(entity.id)
            world.entities.remove(lastIdx..lastIdx + 1)
            d += 1
        }
        
        var c: Int64 = 0
        while (c < toDestroy) {
            let entity = world.registry.createEntity()
            world.entities.add(entity)
            world.posPool.add(entity.id, Position(0.0, 0.0))
            world.velPool.add(entity.id, Velocity(1.0, 0.5))
            c += 1
        }
        
        f += 1
    }
    
    sink = acc
    acc
}