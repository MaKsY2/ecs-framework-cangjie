# ECS Framework - Cangjie

A high-performance Entity Component System (ECS) implementation in Cangjie with comprehensive benchmarks comparing ECS vs OOP approaches.

## Features

- **SparseSet-based component storage** for O(1) access and cache-friendly iteration
- **Entity generation tracking** to prevent use-after-free bugs
- **Complete benchmark suite** with fair OOP comparison
- **Four benchmark scenarios**: Dense update, selective query, create/destroy, mixed frame

## Quick Start

### Build and Run Benchmarks

```bash
cjpm build
cjpm run
```

### Project Structure

```
src/
├── entity.cj              # Entity with ID and generation
├── registry.cj            # Entity lifecycle management
├── sparse.cj              # SparseSet<T> component storage
├── pool.cj                # Pool interface
├── components.cj          # Benchmark components (Position, Velocity, OopEntity)
├── world_builders.cj      # World creation for ECS and OOP
├── ecs_bench_helpers.cj   # ECS benchmark implementations
├── oop_bench_helpers.cj   # OOP benchmark implementations
└── main.cj                # Benchmark runner
```

## Core API

### Entity Management

```cj
let registry = Registry()
let entity = registry.createEntity()
registry.destroyEntity(entity)
let isAlive = registry.alive(entity)
```

### Component Storage (SparseSet)

```cj
let pool = SparseSet<Position>()

// Add component
pool.add(entityId, Position(10.0, 20.0))

// Check existence
if (pool.has(entityId)) { ... }

// Get component
let pos = pool.get(entityId)
let maybePos = pool.tryGet(entityId)  // Returns Option

// Update component
pool.set(entityId, Position(15.0, 25.0))

// Dense iteration (cache-friendly)
for i in 0..pool.denseSize():
    let entityId = pool.denseEntityAt(i)
    let value = pool.denseValueAt(i)
    // ... process ...
    pool.setDenseValueAt(i, updatedValue)

// Remove component
pool.remove(entityId)
```

## Benchmarks

See [BENCHMARKS.md](BENCHMARKS.md) for detailed documentation.

### Benchmark Scenarios

1. **Dense Update** - All entities have Position + Velocity
2. **Selective Query** - 50% of entities have Velocity (tests sparse iteration)
3. **Create/Destroy** - Entity lifecycle operations
4. **Mixed Frame** - Realistic game frame simulation

### Sample Output

```
=== ECS vs OOP Benchmarks ===

--- Size: 10000 entities ---

1. Dense Update (all entities have Position + Velocity):
  ECS Dense Update: avg=XXXns
  OOP Dense Update: avg=XXXns

2. Selective Query (50% have Velocity):
  ECS Selective: avg=XXXns
  OOP Selective: avg=XXXns
...
```

## Key Design Decisions

### Why SparseSet?

- **O(1) component access** via sparse array lookup
- **Dense iteration** for cache efficiency
- **Swap-remove** for O(1) deletion
- **Memory efficient** for sparse component distributions

### Fair OOP Comparison

The OOP baseline is intentionally simple and efficient:
- Single `OopEntity` class with all fields
- Direct `ArrayList` storage
- No artificial overhead (no deep hierarchies, virtual methods, etc.)

This ensures the comparison measures actual ECS benefits, not OOP anti-patterns.

### What We Measure

✅ **Correct** (what we measure):
- Dense array iteration performance
- Component access patterns
- Cache efficiency
- Structural change overhead

❌ **Incorrect** (what we avoid):
- Registry lookup overhead in hot loops
- Type system overhead
- Artificial OOP degradation

## Performance Tips

### ECS Hot Loop Pattern

```cj
// ✅ CORRECT: Get pools once before loop
let posPool = registry.getPool<Position>()
let velPool = registry.getPool<Velocity>()

for i in 0..posPool.denseSize():
    let pos = posPool.denseValueAt(i)
    let vel = velPool.get(entityId)
    // ... update ...
```

```cj
// ❌ WRONG: Don't call registry methods in hot loop
for entity in entities:
    let pos = registry.getComponent<Position>(entity)  // Slow!
    let vel = registry.getComponent<Velocity>(entity)  // Slow!
```

## Optional: Profiling

If `cjprof` is available:

```bash
cjpm build --release
cjprof record ./target/ecsFramework
cjprof report
cjprof report -F flamegraph
```

## License

MIT

## Contributing

Contributions welcome! Please ensure benchmarks remain fair and measure actual performance characteristics.