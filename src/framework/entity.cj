package ecsFramework.framework

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

    const init(packed: Int64) {
        this.inner = packed
    }

    static func make(pos: Int64, gen: Int64): Entity {
        Entity((gen << POS_BITS) | (pos & POS_MASK))
    }

    public prop id: Int64 {
        get() {
            inner & POS_MASK
        }
    }
    public prop gen: Int64 {
        get() {
            (inner >> POS_BITS) & POS_MASK
        }
    }

    public func isValid(): Bool {
        inner != INVALID
    }
    const func genEq(rhs: Entity): Bool {
        ((inner & GEN_MASK) ^ rhs.inner) < POS_MAX
    }
}
