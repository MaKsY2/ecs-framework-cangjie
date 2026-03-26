package ecsFramework.framework

public struct Entity {
    public let id: Int64
    public let gen: Int64

    public init() {
        this.id = -1
        this.gen = -1
    }

    public init(id: Int64, gen: Int64) {
        this.id = id
        this.gen = gen
    }

    public func isValid(): Bool {
        id >= 0 && gen >= 0
    }
}
