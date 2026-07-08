package ecsFramework.framework

import std.collection.*

public open class System {
    public init() {}

    public open func name(): String {
        "UnnamedSystem"
    }

    public open func structural(): Bool {
        false
    }

    public open func access(): Array<Access> {
        Array<Access>()
    }

    public open func run(_: SystemContext): Unit {}

    public func reads(): Array<String> {
        collect { a => a.reads() }
    }

    public func writes(): Array<String> {
        collect { a => a.writes() }
    }

    private func collect(pick: (Access) -> Array<String>): Array<String> {
        let seen = HashSet<String>()
        let out = ArrayList<String>()
        for (a in access()) {
            for (name in pick(a)) {
                if (seen.add(name)) {
                    out.add(name)
                }
            }
        }
        out.toArray()
    }
}
