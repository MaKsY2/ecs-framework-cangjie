package ecsFramework.framework

/**
 * Entity handle packed into a single `Int64`:
 *
 *   bits  [0, 32)  -> position (index into the registry / sparse sets)
 *   bits [32, 64)  -> generation (bumped on destroy to invalidate stale handles)
 *
 * Packing keeps the handle a single register-sized value and lets liveness be a
 * couple of bitwise ops instead of two field compares — see `genEq`.
 */
public struct Entity {
    static const POS_BITS: Int64 = 32
    static const POS_MASK: Int64 = (1 << POS_BITS) - 1
    static const POS_MAX: Int64 = 1 << POS_BITS
    static const GEN_MASK: Int64 = !POS_MASK
    static const INVALID: Int64 = -1

    let inner: Int64

    public const init() {
        this.inner = INVALID
    }

    // Package-internal: build from an already-packed value, or from pos + gen.
    const init(packed: Int64) {
        this.inner = packed
    }

    static func make(pos: Int64, gen: Int64): Entity {
        Entity((gen << POS_BITS) | (pos & POS_MASK))
    }

    /** Position (low 32 bits) — the sparse-set / registry index. */
    public prop id: Int64 {
        get() {
            inner & POS_MASK
        }
    }

    /** Generation (high 32 bits). */
    public prop gen: Int64 {
        get() {
            (inner >> POS_BITS) & POS_MASK
        }
    }

    public func isValid(): Bool {
        inner != INVALID
    }

    /**
     * Liveness check, slightly faster than `this.gen == other.gen`.
     *
     * `this` is the registry's canonical entity for some position; `rhs` is the
     * handle being validated (already located at the same position). XOR-ing the
     * stored generation bits against the full `rhs` cancels the generation when
     * they match, leaving only `rhs`'s position bits, which are `< POS_MAX`. A
     * generation mismatch sets a bit at or above `POS_BITS`, so the result is
     * `>= POS_MAX`. One AND, one XOR, one compare — no branch, no second load.
     */
    const func genEq(rhs: Entity): Bool {
        ((inner & GEN_MASK) ^ rhs.inner) < POS_MAX
    }
}
