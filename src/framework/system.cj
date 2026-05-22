package ecsFramework.framework

public open class System {
    public init() {}

    public open func name(): String {
        "UnnamedSystem"
    }

    public open func structural(): Bool {
        false
    }

    public open func run(_: SystemContext): Unit {}
}
