package ecsFramework

import std.collection.*
import std.reflect.*

public class Registry {
    var indexFinder: HashMap<TypeInfo, Int64>
    var pools: ArrayList<?ISparseSet>
    var gens: ArrayList<Int64>
    var freeList: ArrayList<Int64>
    var nextTypeId: Int64

    public init() {
        indexFinder = HashMap<TypeInfo, Int64>()
        pools = ArrayList<?ISparseSet>()
        gens = ArrayList<Int64>()
        freeList = ArrayList<Int64>()
        nextTypeId = 0
    }
    func ensurePoolsSize(id: Int64): Unit {
        while (pools.size <= id) {
            pools.add(None)
        }
    }

    func typeId<T>(): Int64 {
        let t = TypeInfo.of<T>()
        let got: ?Int64 = indexFinder.get(t)
        match (got) {
            case Some(typeId) => typeId
            case None =>
                let typeId = nextTypeId
                nextTypeId += 1
                indexFinder.add(t, typeId)
                typeId
        }
    }

    public func getPool<T>(): SparseSet<T> {
        let id = typeId<T>()
        ensurePoolsSize(id)

        let slot: ?ISparseSet = pools[id]
        match (slot) {
            case Some(p) =>
                let casted: ?SparseSet<T> = p as SparseSet<T>
                match (casted) {
                    case Some(ss) => ss
                    case None =>
                        // exception ???????????????????????????
                        SparseSet<T>()
                }

            case None =>
                let p = SparseSet<T>()
                pools[id] = Some(p)
                p
        }
    }

    public func alive(e: Entity): Bool {
        if (e.id < 0) {
            return false
        }
        if (e.id >= gens.size) {
            return false
        }
        gens[e.id] == e.gen
    }

    public func createEntity(): Entity {
        if (freeList.size > 0) {
            let id = freeList.remove(at: freeList.size - 1)
            Entity(id, gens[id])
        } else {
            let id: Int64 = gens.size
            gens.add(0)
            Entity(id, 0)
        }
    }

    public func destroyEntity(entity: Entity): Unit {
        if (!alive(entity)) {
            return
        }

        for (slot in pools) {
            match (slot) {
                case Some(p) => p.onEntityDestroyed(entity.id)
                case None => ()
            }
        }

        gens[entity.id] = gens[entity.id] + 1
        freeList.add(entity.id)
    }

    public func addComponent<T>(entity: Entity, component: T): Unit {
        if (!alive(entity)) {
            return
        }
        let p = getPool<T>()
        p.add(entity.id, component)
    }

    public func hasComponent<T>(entity: Entity): Bool {
        if (!alive(entity)) {
            return false
        }
        let p = getPool<T>()
        p.has(entity.id)
    }

    public func getComponent<T>(entity: Entity): T {
        let p = getPool<T>()
        p.get(entity.id)
    }

    public func removeComponent<T>(entity: Entity): Unit {
        if (!alive(entity)) {
            return
        }
        let p = getPool<T>()
        p.remove(entity.id)
    }
}
