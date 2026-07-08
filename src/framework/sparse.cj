package ecsFramework.framework

public interface ISparseSet {
    mut func onEntityDestroyed(index: Int64): Unit
}

/**
 * Sparse set backed by raw `Array<T>` (not `ArrayList`).
 *
 * Why raw arrays: `ArrayList` indexing goes through a bounds-checked wrapper and
 * its `remove(at:)` always runs `copyTo` + `zeroValue` + a version bump — fixed
 * per-call overhead the ECS pays on every component access and every structural
 * edit. Here the dense storage is a plain `Array<T>` with a manual `count`, so
 * the hot accessors are a single memory load, and removal is an O(1) swap-pop
 * (no shifting, no version churn).
 *
 * The per-tick accessors are `@Frozen` so that, under `-O2`, their bodies are
 * exported and can be specialized + inlined into callers in other packages
 * (the components and systems live in a different package than the framework).
 * That collapses the whole `system -> Query.each -> Mut -> Component -> pool ->
 * sparse -> array` chain down to direct array math.
 */
public class SparseSet<T> <: ISparseSet {
    public static let NPOS: Int64 = -1

    // Dense storage: parallel arrays packed in [0, count). Capacity (`.size`)
    // grows geometrically and may exceed `count`.
    private var denseData: Array<T>
    private var denseEntities: Array<Int64>
    private var count: Int64

    // sparse[entityId] -> dense index, or NPOS. Every slot in [0, sparse.size)
    // is initialized to NPOS, so `sparse.size` is the usable length directly.
    private var sparse: Array<Int64>

    public init() {
        denseData = Array<T>()
        denseEntities = Array<Int64>()
        count = 0
        sparse = Array<Int64>()
    }

    @Frozen
    public func denseSize(): Int64 {
        count
    }

    @Frozen
    public func denseEntityAt(i: Int64): Int64 {
        denseEntities[i]
    }

    @Frozen
    public func denseValueAt(i: Int64): T {
        denseData[i]
    }

    @Frozen
    public func denseSetAt(i: Int64, value: T): Unit {
        denseData[i] = value
    }

    /** Dense index of an entity already known to be present. */
    @Frozen
    public func denseIndexOf(entityId: Int64): Int64 {
        sparse[entityId]
    }

    @Frozen
    public func has(entityId: Int64): Bool {
        if (entityId < 0 || entityId >= sparse.size) {
            return false
        }
        sparse[entityId] != NPOS
    }

    @Frozen
    public func get(entityId: Int64): T {
        denseData[sparse[entityId]]
    }

    @Frozen
    public func set(entityId: Int64, value: T): Unit {
        if (has(entityId)) {
            denseData[sparse[entityId]] = value
        }
    }

    public func add(entityId: Int64, value: T): Unit {
        if (entityId < 0) {
            return
        }
        ensureSparse(entityId)

        let existing = sparse[entityId]
        if (existing != NPOS) {
            denseData[existing] = value
            return
        }

        ensureDenseCapacity()
        let di = count
        denseData[di] = value
        denseEntities[di] = entityId
        sparse[entityId] = di
        count = di + 1
    }

    public func remove(entityId: Int64): Unit {
        if (!has(entityId)) {
            return
        }

        let di = sparse[entityId]
        let last = count - 1

        // Swap-pop: move the last live element into the hole, then drop the tail.
        if (di != last) {
            let moved = denseEntities[last]
            denseData[di] = denseData[last]
            denseEntities[di] = moved
            sparse[moved] = di
        }

        // Release any references the tail slot held (cheap write for value types).
        denseData[last] = unsafe { zeroValue<T>() }
        sparse[entityId] = NPOS
        count = last
    }

    public func onEntityDestroyed(index: Int64): Unit {
        remove(index)
    }

    private func ensureSparse(entityId: Int64): Unit {
        if (entityId < sparse.size) {
            return
        }
        var newCap = if (sparse.size == 0) { 16 } else { sparse.size * 2 }
        while (newCap <= entityId) {
            newCap *= 2
        }
        let bigger = Array<Int64>(newCap, repeat: NPOS)
        sparse.copyTo(bigger, 0, 0, sparse.size)
        sparse = bigger
    }

    private func ensureDenseCapacity(): Unit {
        if (count < denseData.size) {
            return
        }
        let newCap = if (denseData.size == 0) { 16 } else { denseData.size * 2 }

        let nd = Array<T>(newCap, repeat: unsafe { zeroValue<T>() })
        denseData.copyTo(nd, 0, 0, count)
        denseData = nd

        let ne = Array<Int64>(newCap, repeat: 0)
        denseEntities.copyTo(ne, 0, 0, count)
        denseEntities = ne
    }
}
