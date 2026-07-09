package ecsFramework.bench

import std.collection.*
import std.math.*
import ecsmacros.*
import ecsFramework.framework.*

func sumPool<T>(pick: (T) -> Float64): Float64 where T <: Component<T> {
    var s: Float64 = 0.0
    var i: Int64 = 0
    let n = T.denseSize()
    while (i < n) {
        s += pick(T.denseValueAt(i))
        i += 1
    }
    s
}

func checkLine(name: String, oopChk: Float64, ecsChk: Float64): Unit {
    let status = if (checksumOk(oopChk, ecsChk)) {
        "OK"
    } else {
        "FAIL"
    }
    println("  chk ${pad(name, 14)} oop=${fmt2(oopChk)}  ecs=${fmt2(ecsChk)}  ${status}")
}

func scenarioS1(rows: ArrayList<BenchRow>): Unit {
    let n: Int64 = 200000
    let frames: Int64 = 40

    let vxOf: (Int64) -> Float64 = {i => Float64((i % 7) - 3) * 0.25}
    let vyOf: (Int64) -> Float64 = {i => Float64((i % 5) - 2) * 0.25}

    let contiguous = Array<Obj1>(n, {i => Obj1(0.0, 0.0, vxOf(i), vyOf(i))})
    let scattered = Array<Obj1>(n, {i => Obj1(0.0, 0.0, vxOf(i), vyOf(i))})
    shuffleInPlace(scattered, Rng(42))

    let w = World()
    s1Group.activate()
    var i: Int64 = 0
    while (i < n) {
        let e = w.create()
        w.add<Pos>(e, Pos(0.0, 0.0)).add<Vel>(e, Vel(vxOf(i), vyOf(i)))
        i += 1
    }
    w.addSystem(s1Move_system)

    let oopC = benchMs(frames, {=> oopFrameS1(contiguous)})
    let oopS = benchMs(frames, {=> oopFrameS1(scattered)})
    let ecs = benchMs(frames, {=> w.tick()})

    rows.add(BenchRow("s1_iter_contig", oopC, ecs, "200k, pos+=vel*dt"))
    rows.add(BenchRow("s1_iter_shuffled", oopS, ecs, "same, OOP refs shuffled"))

    var oopChk: Float64 = 0.0
    for (o in contiguous) {
        oopChk += o.px + o.py
    }
    checkLine("s1", oopChk, sumPool<Pos>({p => p.x + p.y}))
}

func scenarioS1m(rows: ArrayList<BenchRow>): Unit {
    let n: Int64 = 100000
    let frames: Int64 = 40

    let objs = Array<Obj1>(n, {i => Obj1(0.0, 0.0, Float64((i % 7) - 3) * 0.25, Float64((i % 5) - 2) * 0.25)})

    let w = World()
    s1mGroup.activate()
    var i: Int64 = 0
    while (i < n) {
        let e = w.create()
        w.add<Pm>(e, Pm(0.0, 0.0)).add<Vm>(e, Vm(Float64((i % 7) - 3) * 0.25, Float64((i % 5) - 2) * 0.25))
        i += 1
    }
    w.addSystem(s1mMove_system)

    let oop = benchMs(frames, {=> oopFrameS1m(objs)})
    let ecs = benchMs(frames, {=> w.tick()})
    rows.add(BenchRow("s1m_iter_kernel12", oop, ecs, "100k, 12-step FP kernel"))

    var oopChk: Float64 = 0.0
    for (o in objs) {
        oopChk += o.px + o.py
    }
    checkLine("s1m", oopChk, sumPool<Pm>({p => p.x + p.y}))
}

func scenarioS2(rows: ArrayList<BenchRow>): Unit {
    let n: Int64 = 40000
    let frames: Int64 = 30

    let inOf: (Int64) -> Float64 = {i => Float64(i % 7) * 0.5 + 1.0}
    let objs = Array<Obj2>(n, {i => Obj2(inOf(i))})

    let w = World()
    var i: Int64 = 0
    while (i < n) {
        let e = w.create()
        w
            .add<In2>(e, In2(inOf(i)))
            .add<C0>(e, C0(0.0)).add<C1>(e, C1(0.0)).add<C2>(e, C2(0.0))
            .add<C3>(e, C3(0.0)).add<C4>(e, C4(0.0)).add<C5>(e, C5(0.0))
            .add<C6>(e, C6(0.0)).add<C7>(e, C7(0.0)).add<C8>(e, C8(0.0))
            .add<C9>(e, C9(0.0)).add<C10>(e, C10(0.0)).add<C11>(e, C11(0.0))
        i += 1
    }
    w
        .addSystem(s2k0_system).addSystem(s2k1_system).addSystem(s2k2_system)
        .addSystem(s2k3_system).addSystem(s2k4_system).addSystem(s2k5_system)
        .addSystem(s2k6_system).addSystem(s2k7_system).addSystem(s2k8_system)
        .addSystem(s2k9_system).addSystem(s2k10_system).addSystem(s2k11_system)

    let oop = benchMs(frames, {=> oopFrameS2(objs)})
    let ecs = benchMs(frames, {=> w.tick()})
    rows.add(BenchRow("s2_many_systems", oop, ecs, "40k x 12 systems"))

    var oopChk: Float64 = 0.0
    for (o in objs) {
        oopChk += o.c0 + o.c1 + o.c2 + o.c3 + o.c4 + o.c5 + o.c6 + o.c7 + o.c8 + o.c9 + o.c10 + o.c11
    }
    var ecsChk: Float64 = 0.0
    ecsChk += sumPool<C0>({c => c.v}) + sumPool<C1>({c => c.v}) + sumPool<C2>({c => c.v})
    ecsChk += sumPool<C3>({c => c.v}) + sumPool<C4>({c => c.v}) + sumPool<C5>({c => c.v})
    ecsChk += sumPool<C6>({c => c.v}) + sumPool<C7>({c => c.v}) + sumPool<C8>({c => c.v})
    ecsChk += sumPool<C9>({c => c.v}) + sumPool<C10>({c => c.v}) + sumPool<C11>({c => c.v})
    checkLine("s2", oopChk, ecsChk)
}

func scenarioS3(rows: ArrayList<BenchRow>): Unit {
    let n: Int64 = 100000
    let frames: Int64 = 50

    let x0: (Int64) -> Float64 = {i => Float64(i % 11)}
    let v0: (Int64) -> Float64 = {i => Float64(i % 13) * 0.5 - 3.0}

    let objs = Array<Shape3>(n, {
        i =>
        let kind = i % 4
        if (kind == 0) {
            ShapeA(x0(i), v0(i))
        } else if (kind == 1) {
            ShapeB(x0(i), v0(i))
        } else if (kind == 2) {
            ShapeC(x0(i), v0(i))
        } else {
            ShapeD(x0(i), v0(i))
        }
    })
    shuffleInPlace(objs, Rng(7))

    let w = World()
    var i: Int64 = 0
    while (i < n) {
        let e = w.create()
        let kind = i % 4
        if (kind == 0) {
            w.add<Ka>(e, Ka(x0(i), v0(i)))
        } else if (kind == 1) {
            w.add<Kb>(e, Kb(x0(i), v0(i)))
        } else if (kind == 2) {
            w.add<Kc>(e, Kc(x0(i), v0(i)))
        } else {
            w.add<Kd>(e, Kd(x0(i), v0(i)))
        }
        i += 1
    }
    w.addSystem(s3a_system).addSystem(s3b_system).addSystem(s3c_system).addSystem(s3d_system)

    let oop = benchMs(frames, {=> oopFrameS3(objs)})
    let ecs = benchMs(frames, {=> w.tick()})
    rows.add(BenchRow("s3_polymorphic", oop, ecs, "100k, 4 kinds, OOP virtual"))

    var oopChk: Float64 = 0.0
    for (o in objs) {
        oopChk += o.x
    }
    var ecsChk: Float64 = 0.0
    ecsChk += sumPool<Ka>({k => k.x}) + sumPool<Kb>({k => k.x})
    ecsChk += sumPool<Kc>({k => k.x}) + sumPool<Kd>({k => k.x})
    checkLine("s3", oopChk, ecsChk)
}

func scenarioS4(rows: ArrayList<BenchRow>): Unit {
    let n: Int64 = 200000
    let frames: Int64 = 50

    let agents = Array<Agent4>(n, {_ => Agent4(1.0e6, 1.0)})

    let w = World()
    s4Group.activate()
    var i: Int64 = 0
    while (i < n) {
        let e = w.create()
        w.add<Hp4>(e, Hp4(1.0e6)).add<Burn4>(e, Burn4(1.0))
        i += 1
    }
    w.addSystem(s4Burn_system)

    for (s in [1, 4, 20, 100]) {
        var k: Int64 = 0
        while (k < n) {
            agents[k].onFire = (k % s == 0)
            if (k % s != 0) {
                Burn4.removeById(k)
            }
            k += 1
        }

        let subset = (n - 1) / s + 1
        let pct = fmt2(Float64(subset) * 100.0 / Float64(n))
        let oop = benchMs(frames, {=> oopFrameS4(agents)})
        let ecs = benchMs(frames, {=> w.tick()})
        rows.add(BenchRow("s4_burn_${pct}pct", oop, ecs, "200k total, ${subset} on fire"))
    }

    var oopChk: Float64 = 0.0
    for (o in agents) {
        oopChk += o.hp
    }
    checkLine("s4", oopChk, sumPool<Hp4>({h => h.v}))
}

func scenarioS5(rows: ArrayList<BenchRow>): Unit {
    let n: Int64 = 100000
    let frames: Int64 = 50

    let armorOf: (Int64) -> Float64 = {i => Float64(i % 10)}
    let dmgOf: (Int64) -> Float64 = {i => Float64(i % 13)}

    let objs = Array<Obj5>(n, {i => Obj5(1000.0, armorOf(i), dmgOf(i))})

    let w = World()
    s5Group.activate()
    var i: Int64 = 0
    while (i < n) {
        let e = w.create()
        w.add<H5>(e, H5(1000.0)).add<A5>(e, A5(armorOf(i))).add<D5>(e, D5(dmgOf(i)))
        i += 1
    }
    w.addSystem(s5Damage_system)

    let oop = benchMs(frames, {=> oopFrameS5(objs)})
    let ecs = benchMs(frames, {=> w.tick()})
    rows.add(BenchRow("s5_join3", oop, ecs, "100k, 3-comp join"))

    var oopChk: Float64 = 0.0
    for (o in objs) {
        oopChk += o.hp
    }
    checkLine("s5", oopChk, sumPool<H5>({h => h.v}))
}

class CounterBox {
    public var v: Int64
    public init(v: Int64) {
        this.v = v
    }
}

func scenarioS6(rows: ArrayList<BenchRow>): Unit {
    let n: Int64 = 100000
    let frames: Int64 = 30
    let spawnTtl: Int64 = 50

    let list = ArrayList<Obj6>()
    var i: Int64 = 0
    while (i < n) {
        list.add(Obj6(Float64(i % 97), (i % 50) + 1))
        i += 1
    }

    let w = World()
    i = 0
    while (i < n) {
        let e = w.create()
        w.add<P6>(e, P6(Float64(i % 97))).add<T6>(e, T6((i % 50) + 1))
        i += 1
    }
    w.addSystem(s6Move_system).addSystem(s6Ttl_system)

    let oopCounter = CounterBox(n)
    let oop = benchMs(frames, {=> oopCounter.v = oopFrameS6(list, oopCounter.v, spawnTtl)})

    let ecsCounter = CounterBox(n)
    let deadIds = ArrayList<Int64>()
    let ecsFrame: () -> Unit = {
        =>
        w.tick()
        deadIds.clear()
        @Each1[T6, i, eid](
            if (T6.denseValueAt(i).ttl <= 0) {
                deadIds.add(eid)
            }
        )
        for (id in deadIds) {
            P6.removeById(id)
            T6.removeById(id)
            w.destroy(w.entityOf(id))
        }
        var k: Int64 = 0
        while (k < deadIds.size) {
            let e = w.create()
            w.add<P6>(e, P6(Float64(ecsCounter.v % 97))).add<T6>(e, T6(spawnTtl))
            ecsCounter.v += 1
            k += 1
        }
    }
    let ecs = benchMs(frames, ecsFrame)
    rows.add(BenchRow("s6_churn", oop, ecs, "100k, ~2k spawn/kill per frame"))

    var oopChk: Float64 = 0.0
    for (o in list) {
        oopChk += o.x + Float64(o.ttl)
    }
    let ecsChk = sumPool<P6>({p => p.x}) + sumPool<T6>({t => Float64(t.ttl)})
    checkLine("s6", oopChk, ecsChk)
}

public func runBenchmarks(): Unit {
    println("ECS vs OOP — single-threaded benchmark suite")
    println("  method: 1 warmup + median of 3 runs per measurement")
    println("")

    let rows = ArrayList<BenchRow>()
    scenarioS1(rows)
    scenarioS1m(rows)
    scenarioS2(rows)
    scenarioS3(rows)
    scenarioS4(rows)
    scenarioS5(rows)
    scenarioS6(rows)

    println("")
    println("  ${pad("scenario", 22)}${pad("OOP ms", 12)}${pad("ECS ms", 12)}${pad("ECS speedup", 13)}notes")
    println("  ${pad("--------", 22)}${pad("------", 12)}${pad("------", 12)}${pad("-----------", 13)}-----")
    var logSum: Float64 = 0.0
    for (r in rows) {
        println(
            "  ${pad(r.name, 22)}${pad(fmt2(r.oopMs), 12)}${pad(fmt2(r.ecsMs), 12)}${pad("${fmt2(r.speedup())}x", 13)}${r.note}")
        logSum += log(r.speedup())
    }
    let geomean = exp(logSum / Float64(rows.size))
    println("")
    println("  geomean ECS speedup vs OOP: ${fmt2(geomean)}x")
    println("")
    for (r in rows) {
        println("RESULT ${r.name} oop=${fmt2(r.oopMs)} ecs=${fmt2(r.ecsMs)} speedup=${fmt2(r.speedup())}")
    }
    println("RESULT geomean speedup=${fmt2(geomean)}")
}
