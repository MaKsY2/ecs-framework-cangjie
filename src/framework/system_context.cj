package ecsFramework.framework

public class SystemContext {
    private let reg: Registry
    private let isStructural: Bool
    private let systemName: String

    public init(
        reg: Registry,
        structural: Bool,
        systemName: String
    ) {
        this.reg = reg
        this.isStructural = structural
        this.systemName = systemName
    }

    private func assertStructural(op: String): Unit {
        if (!isStructural) {
            throw Exception(
                "System '${systemName}' performed structural op '${op}' but structural() returned false"
            )
        }
    }

    public func registry(): Registry {
        reg
    }

    public func entityOf(id: Int64): Entity {
        reg.entityOf(id)
    }

    public func create(): Entity {
        assertStructural("create")
        reg.createEntity()
    }

    public func destroy(entity: Entity): Unit {
        assertStructural("destroy")
        reg.destroyEntity(entity)
    }

    public func add<T>(entity: Entity, value: T): Unit where T <: Component<T> {
        assertStructural("add")
        reg.addComponent<T>(entity, value)
    }

    public func remove<T>(entity: Entity): Unit where T <: Component<T> {
        assertStructural("remove")
        reg.removeComponent<T>(entity)
    }
}
