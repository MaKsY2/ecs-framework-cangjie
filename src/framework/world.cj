package ecsFramework.framework

import std.collection.*

public class World {
    private let reg: Registry
    private let systems: ArrayList<System>

    public init() {
        this.reg = Registry()
        this.systems = ArrayList<System>()
    }

    public func create(): Entity {
        reg.createEntity()
    }

    public func destroy(e: Entity): Unit {
        reg.destroyEntity(e)
    }

    public func alive(e: Entity): Bool {
        reg.alive(e)
    }

    public func add<T>(e: Entity, value: T): World where T <: Component<T> {
        reg.addComponent<T>(e, value)
        this
    }

    public func remove<T>(e: Entity): Unit where T <: Component<T> {
        reg.removeComponent<T>(e)
    }

    public func get<T>(e: Entity): T where T <: Component<T> {
        reg.getComponent<T>(e)
    }

    public func has<T>(e: Entity): Bool where T <: Component<T> {
        reg.hasComponent<T>(e)
    }

    public func addSystem(s: System): World {
        systems.add(s)
        this
    }

    public func tick(): Unit {
        var i: Int64 = 0
        while (i < systems.size) {
            systems[i].run()
            i += 1
        }
    }

    public func run(ticks: Int64): Unit {
        var t: Int64 = 0
        while (t < ticks) {
            tick()
            t += 1
        }
    }

    public func registry(): Registry {
        reg
    }
}
