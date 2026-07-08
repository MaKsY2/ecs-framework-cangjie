package ecsFramework.legacy

import std.collection.*
import std.sync.*
import ecsFramework.framework.*

public class Scheduler {
    private let systems: ArrayList<System>
    private let workerCount: Int64

    private var graphBuilt: Bool = false
    private var deps: Array<Int64> = Array<Int64>()
    private var successors: Array<ArrayList<Int64>> = Array<ArrayList<Int64>>()

    public init() {
        this(4)
    }

    public init(workerCount: Int64) {
        this.systems = ArrayList<System>()
        this.workerCount = if (workerCount < 1) {
            1
        } else {
            workerCount
        }
    }

    public func add(s: System): Unit {
        systems.add(s)
        graphBuilt = false
    }

    public func count(): Int64 {
        systems.size
    }

    private func conflict(i: Int64, j: Int64): Bool {
        let a = systems[i]
        let b = systems[j]
        if (a.structural() || b.structural()) {
            return true
        }
        let aw = a.writes()
        let bw = b.writes()
        if (intersects(aw, b.reads()) || intersects(aw, bw) || intersects(bw, a.reads())) {
            return true
        }
        false
    }

    private func intersects(xs: Array<String>, ys: Array<String>): Bool {
        if (xs.size == 0 || ys.size == 0) {
            return false
        }
        let set = HashSet<String>()
        for (x in xs) {
            set.add(x)
        }
        for (y in ys) {
            if (set.contains(y)) {
                return true
            }
        }
        false
    }

    private func buildGraph(): Unit {
        let n = systems.size
        deps = Array<Int64>(n, repeat: 0)
        successors = Array<ArrayList<Int64>>(n, {_ => ArrayList<Int64>()})
        var i = 0
        while (i < n) {
            var j = 0
            while (j < i) {
                if (conflict(i, j)) {
                    deps[i] += 1
                    successors[j].add(i)
                }
                j += 1
            }
            i += 1
        }
        graphBuilt = true
    }

    public func tick(reg: Registry): Unit {
        if (!graphBuilt) {
            buildGraph()
        }
        let n = systems.size
        if (n == 0) {
            return
        }

        let remaining = ArrayList<Int64>()
        let ready = ArrayList<Int64>()
        var i = 0
        while (i < n) {
            remaining.add(deps[i])
            if (deps[i] == 0) {
                ready.add(i)
            }
            i += 1
        }
        let completed = AtomicInt64(0)
        let mtx = Mutex()
        let cond = synchronized(mtx) {
            mtx.condition()
        }

        let workers = ArrayList<Future<Unit>>()
        var w = 0
        let wc = if (workerCount < n) {
            workerCount
        } else {
            n
        }
        while (w < wc) {
            let f: Future<Unit> = spawn {
                while (true) {
                    var id = -1
                    synchronized(mtx) {
                        while (ready.isEmpty() && completed.load() < n) {
                            cond.wait()
                        }
                        if (completed.load() >= n) {
                            return
                        }
                        id = ready.remove(at: ready.size - 1)
                    }

                    let s = systems[id]
                    s.run()

                    synchronized(mtx) {
                        for (k in successors[id]) {
                            remaining[k] = remaining[k] - 1
                            if (remaining[k] == 0) {
                                ready.add(k)
                            }
                        }
                        completed.fetchAdd(1)
                        cond.notifyAll()
                    }
                }
            }
            workers.add(f)
            w += 1
        }

        for (f in workers) {
            f.get()
        }
    }

    public func tickSequential(reg: Registry): Unit {
        var i: Int64 = 0
        while (i < systems.size) {
            systems[i].run()
            i += 1
        }
    }
}
