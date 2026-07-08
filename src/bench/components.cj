package ecsFramework.bench

import ecsmacros.*
import ecsFramework.framework.*

@Component
public struct Input {
    public var v: Float64
    public init() { this.v = 0.0 }
    public init(v: Float64) { this.v = v }
}

extend Input <: QueryParam<Input> {
    public static func paramName(): String { Input.name() }
    public static func paramIsWrite(): Bool { false }
    @Frozen public static func paramDenseSize(): Int64 { Input.denseSize() }
    @Frozen public static func paramEntityAt(i: Int64): Int64 { Input.denseEntityAt(i) }
    @Frozen public static func paramHas(eid: Int64): Bool { Input.hasById(eid) }
    @Frozen public static func paramHandle(eid: Int64): Input { Input.getById(eid) }
    @Frozen public static func paramHandleAt(i: Int64): Input { Input.denseValueAt(i) }
}

@Component
public struct Acc0 {
    public var v: Float64
    public init() { this.v = 0.0 }
    public init(v: Float64) { this.v = v }
}

@Component
public struct Acc1 {
    public var v: Float64
    public init() { this.v = 0.0 }
    public init(v: Float64) { this.v = v }
}

@Component
public struct Acc2 {
    public var v: Float64
    public init() { this.v = 0.0 }
    public init(v: Float64) { this.v = v }
}

@Component
public struct Acc3 {
    public var v: Float64
    public init() { this.v = 0.0 }
    public init(v: Float64) { this.v = v }
}

@Component
public struct Hp {
    public var v: Float64
    public init() { this.v = 0.0 }
    public init(v: Float64) { this.v = v }
}

@Component
public struct Burn {
    public var v: Float64
    public init() { this.v = 0.0 }
    public init(v: Float64) { this.v = v }
}

extend Burn <: QueryParam<Burn> {
    public static func paramName(): String { Burn.name() }
    public static func paramIsWrite(): Bool { false }
    @Frozen public static func paramDenseSize(): Int64 { Burn.denseSize() }
    @Frozen public static func paramEntityAt(i: Int64): Int64 { Burn.denseEntityAt(i) }
    @Frozen public static func paramHas(eid: Int64): Bool { Burn.hasById(eid) }
    @Frozen public static func paramHandle(eid: Int64): Burn { Burn.getById(eid) }
    @Frozen public static func paramHandleAt(i: Int64): Burn { Burn.denseValueAt(i) }
}
