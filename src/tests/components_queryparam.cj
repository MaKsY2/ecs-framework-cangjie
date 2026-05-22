package ecsFramework.tests

import ecsFramework.framework.*

extend Position <: QueryParam<Position> {
    public static func paramName(): String {
        Position.name()
    }
    public static func paramIsWrite(): Bool {
        false
    }
    public static func paramDenseSize(): Int64 {
        Position.denseSize()
    }
    public static func paramEntityAt(i: Int64): Int64 {
        Position.denseEntityAt(i)
    }
    public static func paramHas(eid: Int64): Bool {
        Position.hasById(eid)
    }
    public static func paramHandle(eid: Int64, _: Registry): Position {
        Position.getById(eid)
    }
}

extend Velocity <: QueryParam<Velocity> {
    public static func paramName(): String {
        Velocity.name()
    }
    public static func paramIsWrite(): Bool {
        false
    }
    public static func paramDenseSize(): Int64 {
        Velocity.denseSize()
    }
    public static func paramEntityAt(i: Int64): Int64 {
        Velocity.denseEntityAt(i)
    }
    public static func paramHas(eid: Int64): Bool {
        Velocity.hasById(eid)
    }
    public static func paramHandle(eid: Int64, _: Registry): Velocity {
        Velocity.getById(eid)
    }
}

extend Health <: QueryParam<Health> {
    public static func paramName(): String {
        Health.name()
    }
    public static func paramIsWrite(): Bool {
        false
    }
    public static func paramDenseSize(): Int64 {
        Health.denseSize()
    }
    public static func paramEntityAt(i: Int64): Int64 {
        Health.denseEntityAt(i)
    }
    public static func paramHas(eid: Int64): Bool {
        Health.hasById(eid)
    }
    public static func paramHandle(eid: Int64, _: Registry): Health {
        Health.getById(eid)
    }
}

extend Armor <: QueryParam<Armor> {
    public static func paramName(): String {
        Armor.name()
    }
    public static func paramIsWrite(): Bool {
        false
    }
    public static func paramDenseSize(): Int64 {
        Armor.denseSize()
    }
    public static func paramEntityAt(i: Int64): Int64 {
        Armor.denseEntityAt(i)
    }
    public static func paramHas(eid: Int64): Bool {
        Armor.hasById(eid)
    }
    public static func paramHandle(eid: Int64, _: Registry): Armor {
        Armor.getById(eid)
    }
}

extend Damage <: QueryParam<Damage> {
    public static func paramName(): String {
        Damage.name()
    }
    public static func paramIsWrite(): Bool {
        false
    }
    public static func paramDenseSize(): Int64 {
        Damage.denseSize()
    }
    public static func paramEntityAt(i: Int64): Int64 {
        Damage.denseEntityAt(i)
    }
    public static func paramHas(eid: Int64): Bool {
        Damage.hasById(eid)
    }
    public static func paramHandle(eid: Int64, _: Registry): Damage {
        Damage.getById(eid)
    }
}

extend Team <: QueryParam<Team> {
    public static func paramName(): String {
        Team.name()
    }
    public static func paramIsWrite(): Bool {
        false
    }
    public static func paramDenseSize(): Int64 {
        Team.denseSize()
    }
    public static func paramEntityAt(i: Int64): Int64 {
        Team.denseEntityAt(i)
    }
    public static func paramHas(eid: Int64): Bool {
        Team.hasById(eid)
    }
    public static func paramHandle(eid: Int64, _: Registry): Team {
        Team.getById(eid)
    }
}
