package ecsFramework.framework

public class World {
    private let reg: Registry
    private let sch: Scheduler

    public init() {
        this.reg = Registry()
        this.sch = Scheduler()
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
        sch.add(s)
        this
    }

    public func tick(): Unit {
        sch.tick(reg)
    }

    public func run(ticks: Int64): Unit {
        var t: Int64 = 0
        while (t < ticks) {
            sch.tick(reg)
            t += 1
        }
    }

    public func registry(): Registry {
        reg
    }
}
