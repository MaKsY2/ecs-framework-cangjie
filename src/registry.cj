package ecsFramework

import std.collection.*

public class Registry {
    private var gens: ArrayList<Int64> = ArrayList<Int64>()
    private var freeList: ArrayList<Int64> = ArrayList<Int64>()
    private var nextId: Int64 = 0

    public init() {}

    public func createEntity(): Entity {
        let id: Int64
        let gen: Int64

        if (freeList.size > 0) {
            let lastIdx = freeList.size - 1
            id = freeList[lastIdx]
            freeList.remove(lastIdx..lastIdx + 1)
            gen = gens[id]
        } else {
            id = nextId
            nextId += 1
            gens.add(0)
            gen = 0
        }

        Entity(id, gen)
    }

    public func destroyEntity(entity: Entity): Unit {
        if (!alive(entity)) {
            return
        }

        gens[entity.id] += 1
        freeList.add(entity.id)
    }

    public func alive(entity: Entity): Bool {
        if (entity.id >= gens.size) {
            return false
        }
        gens[entity.id] == entity.gen
    }
}