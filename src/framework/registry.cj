package ecsFramework.framework

import ecsmacros.*
import std.collection.*

public class Registry {
    var gens: ArrayList<Int64>
    var freeList: ArrayList<Int64>

    public init() {
        gens = ArrayList<Int64>()
        freeList = ArrayList<Int64>()
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

    public func view1<A>(): View1<A> where A <: Component<A> {
        View1<A>()
    }

    public func view2<A, B>(): View2<A, B> where A <: Component<A>, B <: Component<B> {
        View2<A, B>()
    }

    public func view3<A, B, C>(): View3<A, B, C> where A <: Component<A>, B <: Component<B>, C <: Component<C> {
        View3<A, B, C>()
    }
}
