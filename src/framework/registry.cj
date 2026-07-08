package ecsFramework.framework

public class Registry {
    private var entities: Array<Entity>
    private var entitiesSize: Int64
    private var availableCnt: Int64
    private var nextPos: Int64

    public init() {
        entities = Array<Entity>()
        entitiesSize = 0
        availableCnt = 0
        nextPos = 0
    }

    public func alive(e: Entity): Bool {
        let pos = e.id
        if (pos >= entitiesSize) {
            return false
        }
        entities[pos].genEq(e)
    }

    public func createEntity(): Entity {
        if (availableCnt > 0) {
            let pos = nextPos
            let recycled = entities[pos]
            nextPos = recycled.id
            availableCnt -= 1
            let e = Entity.make(pos, recycled.gen)
            entities[pos] = e
            return e
        }
        let pos = entitiesSize
        ensureCapacity(pos)
        let e = Entity.make(pos, 0)
        entities[pos] = e
        entitiesSize = pos + 1
        return e
    }

    public func entityOf(id: Int64): Entity {
        if (id < 0 || id >= entitiesSize) {
            return Entity()
        }
        Entity.make(id, entities[id].gen)
    }

    public func destroyEntity(e: Entity): Unit {
        if (!alive(e)) {
            return
        }
        let pos = e.id
        entities[pos] = Entity.make(nextPos, e.gen + 1)
        nextPos = pos
        availableCnt += 1
    }

    public func addComponent<T>(entity: Entity, component: T): Unit where T <: Component<T> {
        if (!alive(entity)) {
            return
        }
        T.add(entity, component)
    }

    public func hasComponent<T>(entity: Entity): Bool where T <: Component<T> {
        if (!alive(entity)) {
            return false
        }
        T.has(entity)
    }

    public func getComponent<T>(entity: Entity): T where T <: Component<T> {
        T.get(entity)
    }

    public func removeComponent<T>(entity: Entity): Unit where T <: Component<T> {
        if (!alive(entity)) {
            return
        }
        T.remove(entity)
    }

    private func ensureCapacity(pos: Int64): Unit {
        if (pos < entities.size) {
            return
        }
        let newCap = if (entities.size == 0) {
            16
        } else {
            entities.size * 2
        }
        let bigger = Array<Entity>(newCap, repeat: Entity())
        entities.copyTo(bigger, 0, 0, entitiesSize)
        entities = bigger
    }
}
