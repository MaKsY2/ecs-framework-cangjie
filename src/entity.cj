package ecsFramework

public struct Entity {
    let id: Int64
    let gen: Int64

    public init() {
        this.id = 0
        this.gen = 0
    }

    public init(id: Int64, gen: Int64) {
        this.id = id
        this.gen = gen
    }
}
