package ecsFramework

import std.collection.*
import std.reflect.*

public class Registry {
    var pools: HashMap<TypeInfo, UInt64> = HashMap<TypeInfo, UInt64>()

    public init() {}

    public func createEntity(): Entity {
        Entity()
    }

    public func destroyEntity(entity: Entity) {}

    public func addComponent<T>(component: T, entity: Entity) {}
}
