package ecsFramework

import ecsmacros.*
import ecsFramework.framework.*

// A small "game world" demo showing the everyday API:
//   @Component  — declare a component (a plain struct).
//   @System     — declare a system; iterate with the @Each / @EachG macros.
//   World       — create entities, attach components, run systems, read back.

@Component
public struct Position {
    public var x: Float64
    public var y: Float64
    public init(x: Float64, y: Float64) {
        this.x = x
        this.y = y
    }
}

@Component
public struct Velocity {
    public var dx: Float64
    public var dy: Float64
    public init(dx: Float64, dy: Float64) {
        this.dx = dx
        this.dy = dy
    }
}

@Component
public struct Health {
    public var hp: Int64
    public init(hp: Int64) {
        this.hp = hp
    }
}

@Component
public struct Poison {
    public var perTick: Int64
    public init(perTick: Int64) {
        this.perTick = perTick
    }
}

let movers = OwnGroup2<Position, Velocity>()

@System
public func movement(q: Query2<Mut<Position>, Velocity>): Unit {
    @EachG2[Position, pi, Velocity, vi, eid, movers](
        let p = Position.denseValueAt(pi)
        let v = Velocity.denseValueAt(vi)
        Position.denseSetAt(pi, Position(p.x + v.dx, p.y + v.dy))
    )
}

@System
public func poisonTick(q: Query2<Mut<Health>, Poison>): Unit {
    @Each2[Health, hi, Poison, pi, eid](
        let h = Health.denseValueAt(hi)
        Health.denseSetAt(hi, Health(h.hp - Poison.denseValueAt(pi).perTick))
    )
}

func spawnActor(w: World, x: Float64, y: Float64, dx: Float64, dy: Float64, hp: Int64, poison: Int64): Entity {
    let e = w.create()
    w.add<Position>(e, Position(x, y)).add<Velocity>(e, Velocity(dx, dy)).add<Health>(e, Health(hp))
    if (poison > 0) {
        w.add<Poison>(e, Poison(poison))
    }
    e
}

main(): Int64 {
    let world = World()
    movers.activate()

    let hero = spawnActor(world, 0.0, 0.0, 1.0, 0.5, 100, 5)
    let goblin = spawnActor(world, 10.0, 0.0, -1.0, 0.0, 30, 0)

    let wall = world.create()
    world.add<Position>(wall, Position(5.0, 5.0)).add<Health>(wall, Health(1000))

    let ghost = world.create()
    world.add<Health>(ghost, Health(50)).add<Poison>(ghost, Poison(3))

    world.addSystem(movement_system).addSystem(poisonTick_system)

    let ticks = 5
    world.run(ticks)

    println("After ${ticks} ticks:")
    printActor(world, "hero  ", hero)
    printActor(world, "goblin", goblin)
    printActor(world, "wall  ", wall)
    println("  ghost   hasPosition=${world.has<Position>(ghost)}  hp=${world.get<Health>(ghost).hp}")

    var alive = 0
    @Each1[Health, hi, eid](
        if (Health.denseValueAt(hi).hp > 0) {
            alive += 1
        }
    )
    println("entities still alive: ${alive}")
    0
}

func printActor(w: World, label: String, e: Entity): Unit {
    let p = w.get<Position>(e)
    println("  ${label}  pos=(${p.x}, ${p.y})  hp=${w.get<Health>(e).hp}")
}
