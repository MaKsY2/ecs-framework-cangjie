package ecsFramework.framework

import std.collection.*

public class Registry {
    var componentRegistry: HashMap<String, Int64>
    var pools: ArrayList<?ISparseSet>
    var gens: ArrayList<Int64>
    var freeList: ArrayList<Int64>
    var entityComponents: ArrayList<ArrayList<Int64>>
    var nextComponentId: Int64

    public init() {
        componentRegistry = HashMap<String, Int64>()
        pools = ArrayList<?ISparseSet>()
        gens = ArrayList<Int64>()
        freeList = ArrayList<Int64>()
        entityComponents = ArrayList<ArrayList<Int64>>()
        nextComponentId = 0
    }

    func registerComponent(typeName: String): Int64 {
        let existing = componentRegistry.get(typeName)
        match (existing) {
            case Some(id) => id
            case None =>
                let id = nextComponentId
                nextComponentId += 1
                componentRegistry.add(typeName, id)
                while (pools.size <= id) {
                    pools.add(None)
                }
                id
        }
    }

    public func getPool<T>(typeName: String): SparseSet<T> {
        let id = registerComponent(typeName)

        let slot: ?ISparseSet = pools[id]
        match (slot) {
            case Some(p) =>
                let casted: ?SparseSet<T> = p as SparseSet<T>
                match (casted) {
                    case Some(ss) => ss
                    case None => SparseSet<T>()
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
            if (id >= entityComponents.size) {
                while (entityComponents.size <= id) {
                    entityComponents.add(ArrayList<Int64>())
                }
            } else {
                entityComponents[id].clear()
            }
            Entity(id, gens[id])
        } else {
            let id: Int64 = gens.size
            gens.add(0)
            entityComponents.add(ArrayList<Int64>())
            Entity(id, 0)
        }
    }

    public func destroyEntity(entity: Entity): Unit {
        if (!alive(entity)) {
            return
        }

        for (poolId in entityComponents[entity.id]) {
            let slot: ?ISparseSet = pools[poolId]
            match (slot) {
                case Some(p) => p.onEntityDestroyed(entity.id)
                case None => ()
            }
        }

        entityComponents[entity.id].clear()
        gens[entity.id] = gens[entity.id] + 1
        freeList.add(entity.id)
    }

    public func destroyEntities(entities: ArrayList<Entity>): Unit {
        for (entity in entities) {
            destroyEntity(entity)
        }
    }

    public func addComponent<T>(entity: Entity, typeName: String, component: T): Unit {
        if (!alive(entity)) {
            return
        }
        let componentId = registerComponent(typeName)
        let p = getPool<T>(typeName)
        p.add(entity.id, component)

        if (!entityComponents[entity.id].contains(componentId)) {
            entityComponents[entity.id].add(componentId)
        }
    }

    public func view1<A>(typeNameA: String): View1<A> {
        View1<A>(getPool<A>(typeNameA))
    }

    public func view2<A, B>(typeNameA: String, typeNameB: String): View2<A, B> {
        View2<A, B>(getPool<A>(typeNameA), getPool<B>(typeNameB))
    }

    public func view3<A, B, C>(typeNameA: String, typeNameB: String, typeNameC: String): View3<A, B, C> {
        View3<A, B, C>(getPool<A>(typeNameA), getPool<B>(typeNameB), getPool<C>(typeNameC))
    }
}
