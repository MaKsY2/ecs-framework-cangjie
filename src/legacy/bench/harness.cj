package ecsFramework.legacy.bench

import std.time.*

public func timeOnceMs(frames: Int64, frame: () -> Unit): Float64 {
    let t0 = MonoTime.now()
    var i: Int64 = 0
    while (i < frames) {
        frame()
        i += 1
    }
    let t1 = MonoTime.now()
    Float64((t1 - t0).toNanoseconds()) / 1.0e6
}

public func benchMs(frames: Int64, frame: () -> Unit): Float64 {
    timeOnceMs(frames, frame)
    let a = timeOnceMs(frames, frame)
    let b = timeOnceMs(frames, frame)
    let c = timeOnceMs(frames, frame)
    median3(a, b, c)
}

func median3(a: Float64, b: Float64, c: Float64): Float64 {
    if ((a <= b && b <= c) || (c <= b && b <= a)) {
        return b
    }
    if ((b <= a && a <= c) || (c <= a && a <= b)) {
        return a
    }
    c
}

public func fmt2(x: Float64): String {
    let neg = x < 0.0
    let ax = if (neg) { -x } else { x }
    let scaled = Int64(ax * 100.0 + 0.5)
    let intPart = scaled / 100
    let frac = scaled % 100
    let fracStr = if (frac < 10) {
        "0${frac}"
    } else {
        "${frac}"
    }
    if (neg) {
        "-${intPart}.${fracStr}"
    } else {
        "${intPart}.${fracStr}"
    }
}

public func pad(s: String, width: Int64): String {
    var out = s
    while (out.size < width) {
        out = out + " "
    }
    out
}

public func absF(x: Float64): Float64 {
    if (x < 0.0) { -x } else { x }
}

public func checksumOk(a: Float64, b: Float64): Bool {
    absF(a - b) <= 1.0e-6 * (absF(a) + absF(b) + 1.0)
}

public class Rng {
    private var seed: Int64

    public init(seed: Int64) {
        this.seed = if (seed <= 0) { 1 } else { seed % 2147483647 }
    }

    public func next(): Int64 {
        seed = (seed * 48271) % 2147483647
        seed
    }

    public func below(n: Int64): Int64 {
        next() % n
    }
}

public func shuffleInPlace<T>(a: Array<T>, rng: Rng): Unit {
    var i: Int64 = a.size - 1
    while (i > 0) {
        let j = rng.below(i + 1)
        let tmp = a[i]
        a[i] = a[j]
        a[j] = tmp
        i -= 1
    }
}

public class BenchRow {
    public let name: String
    public let oopMs: Float64
    public let ecsMs: Float64
    public let note: String

    public init(name: String, oopMs: Float64, ecsMs: Float64, note: String) {
        this.name = name
        this.oopMs = oopMs
        this.ecsMs = ecsMs
        this.note = note
    }

    public func speedup(): Float64 {
        oopMs / ecsMs
    }
}
