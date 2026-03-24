# ecs-framework-cangjie

A minimal ECS (Entity Component System) framework in Cangjie, with a performance comparison against an equivalent OOP implementation.

## Project Structure

```
src/
  main.cj                        — package ecsFramework — demo entry point

  framework/                     — package ecsFramework.framework — reusable ECS core
    framework.cj                 — package stub (required by cjpm)
    entity.cj                    — Entity type (id + generation)
    sparse.cj                    — SparseSet<T> storage + ISparseSet interface
    view.cj                      — View1<A>, View2<A,B>, View3<A,B,C> iterators
    registry.cj                  — Registry: entity lifecycle, component pools, view factories

  scenario/                      — package ecsFramework.scenario — concrete components and worlds
    scenario.cj                  — package stub (required by cjpm)
    components.cj                — Position, Velocity, Health structs
    ecs_world.cj                 — EcsWorld: high-level ECS movement scenario
    oop_world.cj                 — OopWorld: equivalent OOP scenario

  test/                          — package ecsFramework.test — tests and benchmarks
    test.cj                      — package stub (required by cjpm)
    test_view.cj                 — unit tests for view<>
    test_correctness.cj          — correctness tests: ECS vs OOP produce identical results
    bench.cj                     — performance benchmarks: ECS vs OOP
```

## Build

```bash
cjpm build
```

## Run demo

```bash
cjpm run
```

## Run tests (unit + correctness + benchmarks)

```bash
cjpm test --show-all-output
```

The `--show-all-output` flag is needed to see benchmark `println` output even for passing tests.

### Run specific test suites

```bash
cjpm test --filter ViewTests --show-all-output
cjpm test --filter CorrectnessTests --show-all-output
cjpm test --filter BenchmarkTests --show-all-output
```

## view<> API

`Registry` exposes three view factory methods:

```cangjie
registry.view1<A>()           // iterate entities with component A
registry.view2<A, B>()        // iterate entities with both A and B
registry.view3<A, B, C>()     // iterate entities with all three components
```

Each view has an `each` method that accepts a closure:

```cangjie
registry.view2<Position, Velocity>().each({ eid, pos, vel =>
    // pos: Position, vel: Velocity, eid: Int64 (entity id)
})
```

### Strategy

`view2<A, B>` iterates the smaller of the two pools and checks membership in the other — O(min(|A|, |B|)) iterations with O(1) membership checks via the sparse array.

## ECS movement scenario

```cangjie
let world = EcsWorld()
world.addObject(x, y, vx, vy)  // creates entity with Position + Velocity
world.update()                  // runs: pos.x += vel.vx; pos.y += vel.vy
```

## OOP equivalent

```cangjie
let world = OopWorld()
world.addObject(x, y, vx, vy)  // creates GameObject with x, y, vx, vy
world.update()                  // runs: obj.x += obj.vx; obj.y += obj.vy
```

## Benchmark output format

Each benchmark prints a line like:

```
bench update_only n=1000  ECS: 12345 ns  OOP: 9876 ns
```

### Benchmark scenarios

| Scenario | Description |
|---|---|
| `benchUpdateOnly1000` | Single update tick, 1 000 entities |
| `benchUpdateOnly10000` | Single update tick, 10 000 entities |
| `benchManyTicks100x1000` | 100 ticks, 1 000 entities |
| `benchManyTicks300x1000` | 300 ticks, 1 000 entities |
| `benchManyTicks1000x1000` | 1 000 ticks, 1 000 entities |
| `benchBuildAndUpdate1000` | Build world + 1 tick, 1 000 entities |
| `benchBuildAndUpdate10000` | Build world + 1 tick, 10 000 entities |

## Package layout rules (cjpm)

Each subdirectory must have at least one `.cj` file with the matching `package` declaration. The stub files (`framework.cj`, `scenario.cj`, `test.cj`) satisfy this requirement. Package names follow the path: `ecsFramework.framework`, `ecsFramework.scenario`, `ecsFramework.test`.
