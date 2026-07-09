package ecsFramework.bench

import std.collection.*

public class Obj1 {
    public var px: Float64
    public var py: Float64
    public let vx: Float64
    public let vy: Float64

    public init(px: Float64, py: Float64, vx: Float64, vy: Float64) {
        this.px = px
        this.py = py
        this.vx = vx
        this.vy = vy
    }
}

public func oopFrameS1(objs: Array<Obj1>): Unit {
    for (o in objs) {
        o.px += o.vx * DT
        o.py += o.vy * DT
    }
}

public func oopFrameS1m(objs: Array<Obj1>): Unit {
    for (o in objs) {
        o.px = kernel12(o.px + o.vx * DT)
        o.py += o.vy * DT
    }
}

public class Obj2 {
    public let input: Float64
    public var c0: Float64 = 0.0
    public var c1: Float64 = 0.0
    public var c2: Float64 = 0.0
    public var c3: Float64 = 0.0
    public var c4: Float64 = 0.0
    public var c5: Float64 = 0.0
    public var c6: Float64 = 0.0
    public var c7: Float64 = 0.0
    public var c8: Float64 = 0.0
    public var c9: Float64 = 0.0
    public var c10: Float64 = 0.0
    public var c11: Float64 = 0.0

    public init(input: Float64) {
        this.input = input
    }
}

public func oopFrameS2(objs: Array<Obj2>): Unit {
    for (o in objs) { o.c0 = o.c0 * 0.999 + o.input }
    for (o in objs) { o.c1 = o.c1 * 0.999 + o.input }
    for (o in objs) { o.c2 = o.c2 * 0.999 + o.input }
    for (o in objs) { o.c3 = o.c3 * 0.999 + o.input }
    for (o in objs) { o.c4 = o.c4 * 0.999 + o.input }
    for (o in objs) { o.c5 = o.c5 * 0.999 + o.input }
    for (o in objs) { o.c6 = o.c6 * 0.999 + o.input }
    for (o in objs) { o.c7 = o.c7 * 0.999 + o.input }
    for (o in objs) { o.c8 = o.c8 * 0.999 + o.input }
    for (o in objs) { o.c9 = o.c9 * 0.999 + o.input }
    for (o in objs) { o.c10 = o.c10 * 0.999 + o.input }
    for (o in objs) { o.c11 = o.c11 * 0.999 + o.input }
}

public open class Shape3 {
    public var x: Float64
    public let v: Float64

    public init(x: Float64, v: Float64) {
        this.x = x
        this.v = v
    }

    public open func update(): Unit {}
}

public class ShapeA <: Shape3 {
    public init(x: Float64, v: Float64) {
        super(x, v)
    }
    public override func update(): Unit {
        x += v * DT
    }
}

public class ShapeB <: Shape3 {
    public init(x: Float64, v: Float64) {
        super(x, v)
    }
    public override func update(): Unit {
        x = x * 0.999 + v
    }
}

public class ShapeC <: Shape3 {
    public init(x: Float64, v: Float64) {
        super(x, v)
    }
    public override func update(): Unit {
        x += v * v * DT
    }
}

public class ShapeD <: Shape3 {
    public init(x: Float64, v: Float64) {
        super(x, v)
    }
    public override func update(): Unit {
        x += (v - x) * 0.1
    }
}

public func oopFrameS3(objs: Array<Shape3>): Unit {
    for (o in objs) {
        o.update()
    }
}

public class Agent4 {
    public var hp: Float64
    public var onFire: Bool
    public let burn: Float64

    public init(hp: Float64, burn: Float64) {
        this.hp = hp
        this.burn = burn
        this.onFire = false
    }
}

public func oopFrameS4(objs: Array<Agent4>): Unit {
    for (o in objs) {
        if (o.onFire) {
            o.hp -= o.burn
        }
    }
}

public class Obj5 {
    public var hp: Float64
    public let armor: Float64
    public let dmg: Float64

    public init(hp: Float64, armor: Float64, dmg: Float64) {
        this.hp = hp
        this.armor = armor
        this.dmg = dmg
    }
}

public func oopFrameS5(objs: Array<Obj5>): Unit {
    for (o in objs) {
        var raw = o.dmg - o.armor
        if (raw < 0.0) {
            raw = 0.0
        }
        o.hp -= raw * 0.01
    }
}

public class Obj6 {
    public var x: Float64
    public var ttl: Int64

    public init(x: Float64, ttl: Int64) {
        this.x = x
        this.ttl = ttl
    }
}

public func oopFrameS6(list: ArrayList<Obj6>, spawnCounter: Int64, spawnTtl: Int64): Int64 {
    for (o in list) {
        o.x += 1.0
    }
    for (o in list) {
        o.ttl -= 1
    }
    var died: Int64 = 0
    var i: Int64 = 0
    while (i < list.size) {
        if (list[i].ttl <= 0) {
            list[i] = list[list.size - 1]
            list.remove(at: list.size - 1)
            died += 1
        } else {
            i += 1
        }
    }
    var c = spawnCounter
    var k: Int64 = 0
    while (k < died) {
        list.add(Obj6(Float64(c % 97), spawnTtl))
        c += 1
        k += 1
    }
    c
}
