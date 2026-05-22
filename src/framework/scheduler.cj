package ecsFramework.framework

import std.collection.*

public class Scheduler {
    private let systems: ArrayList<System>

    public init() {
        this.systems = ArrayList<System>()
    }

    public func add(s: System): Unit {
        systems.add(s)
    }

    public func count(): Int64 {
        systems.size
    }

    public func tick(reg: Registry): Unit {
        var i: Int64 = 0
        while (i < systems.size) {
            let s = systems[i]
            let ctx = SystemContext(reg, s.structural(), s.name())
            s.run(ctx)
            i += 1
        }
    }
}
