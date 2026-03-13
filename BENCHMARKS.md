# ECS vs OOP Benchmarks

This document describes the benchmark suite for comparing the Entity Component System (ECS) implementation against a traditional Object-Oriented Programming (OOP) baseline.

## Overview

The benchmark suite measures performance across four key scenarios:

1. **Dense Update** - All entities have both Position and Velocity components
2. **Selective Query** - Only 50% of entities have Velocity (tests sparse iteration)
3. **Create/Destroy** - Measures structural changes (entity creation and destruction)
4. **Mixed Frame** - Simulates a realistic game frame with updates, creates, and destroys

## Architecture

### ECS Implementation

The ECS uses a **SparseSet** data structure for component storage:

- **Dense arrays** store actual component data contiguously in memory
- **Sparse array** provides O(1) lookup from entity ID to dense index
- Components are stored separately by type
- Iteration happens over dense arrays for cache efficiency

Key files:
- [`src/sparse.cj`](src/sparse.cj:5) - SparseSet implementation
- [`src/registry.cj`](src/registry.cj:6) - Entity management
- [`src/entity.cj`](src/entity.cj:3) - Entity with generation tracking

### OOP Baseline

The OOP implementation uses a simple approach:

- Single `OopEntity` class with all fields
- `ArrayList<OopEntity>` for storage
- Direct iteration over the array
- Boolean flag for optional components

This represents a fair, non-degraded OOP approach without artificial overhead.

## Benchmark Scenarios

### 1. Dense Update

**Scenario**: All entities have Position + Velocity. Update position based on velocity.

**ECS Strategy**:
```
posPool = getPool<Position>()
velPool = getPool<Velocity>()

for i in 0..posPool.denseSize():
    entityId = posPool.denseEntityAt(i)
    pos = posPool.denseValueAt(i)
    vel = velPool.get(entityId)
    
    pos.x += vel.x * dt
    pos.y += vel.y * dt
    
    posPool.setDenseValueAt(i, pos)
```

**OOP Strategy**:
```
for entity in entities:
    entity.px += entity.vx * dt
    entity.py += entity.vy * dt
```

**What it measures**: Cache efficiency of dense iteration vs object-based iteration.

### 2. Selective Query

**Scenario**: All entities have Position, but only 50% have Velocity.

**ECS Strategy**:
```
Iterate over velPool (smaller set)
For each entity with velocity:
    Look up position
    Update position
```

**OOP Strategy**:
```
for entity in entities:
    if entity.hasVelocity:
        entity.px += entity.vx * dt
        entity.py += entity.vy * dt
```

**What it measures**: ECS advantage when querying sparse component combinations.

### 3. Create/Destroy

**Scenario**: Create N entities, destroy 10%, recreate 10%, repeat.

**ECS Strategy**:
- Uses free list for entity ID reuse
- Generation counter prevents use-after-free
- Swap-remove from dense arrays

**OOP Strategy**:
- Swap-remove from ArrayList
- Simple and direct

**What it measures**: Structural change overhead.

### 4. Mixed Frame

**Scenario**: Simulates one game frame:
- Update all Position + Velocity
- Destroy 1% of entities
- Create 1% new entities

**What it measures**: Realistic workload combining all operations.

## Running Benchmarks

### Build and Run

```bash
cjpm build
cjpm run
```

### Expected Output

```
=== ECS vs OOP Benchmarks ===

--- Size: 1000 entities ---

1. Dense Update (all entities have Position + Velocity):
  ECS Dense Update: avg=XXXns
  OOP Dense Update: avg=XXXns

2. Selective Query (50% have Velocity):
  ECS Selective: avg=XXXns
  OOP Selective: avg=XXXns

3. Create/Destroy:
  ECS Create/Destroy: avg=XXXns
  OOP Create/Destroy: avg=XXXns

4. Mixed Frame:
  ECS Mixed Frame: avg=XXXns
  OOP Mixed Frame: avg=XXXns
```

## Interpreting Results

### When ECS Should Win

1. **Dense Update**: ECS should be competitive or slightly better due to cache-friendly dense iteration
2. **Selective Query**: ECS should win significantly when iterating over sparse component combinations
3. **Mixed Frame**: ECS should show benefits in realistic scenarios

### When OOP Might Win

1. **Create/Destroy**: OOP might be faster for simple structural changes
2. **Dense Update**: If all entities have all components, OOP's simplicity might compete

### Fair Comparison Principles

✅ **What we DO**:
- Measure actual work (dense iteration, component access)
- Use deterministic data
- Accumulate checksums to prevent dead code elimination
- Warm up before measurement
- Use equivalent algorithms

❌ **What we DON'T do**:
- Call `getPool<T>()` in hot loops
- Use artificial OOP overhead (virtual methods, deep hierarchies)
- Compare different amounts of work
- Measure registry lookup overhead as "ECS performance"

## Implementation Details

### Critical Performance Paths

**ECS Hot Loop** (correct):
```cj
let posPool = registry.getPool<Position>()  // ONCE before loop
let velPool = registry.getPool<Velocity>()  // ONCE before loop

for i in 0..posPool.denseSize():
    // Direct dense array access - this is what we measure
    let pos = posPool.denseValueAt(i)
    let vel = velPool.get(entityId)
    // ... update ...
```

**ECS Hot Loop** (WRONG - don't do this):
```cj
for entity in entities:
    // This measures HashMap lookup, not ECS benefits!
    let pos = registry.getComponent<Position>(entity)
    let vel = registry.getComponent<Velocity>(entity)
```

### Preventing Compiler Optimizations

All benchmarks accumulate results into a global `sink` variable:

```cj
public var sink: Int64 = 0

// In benchmark:
acc += Int64(pos.x + pos.y)
sink = acc  // Prevents dead code elimination
```

## Profiling (Optional)

If `cjprof` is available:

```bash
# Build with profiling
cjpm build --release

# Run with profiler
cjprof record ./target/ecsFramework

# View report
cjprof report
cjprof report -F flamegraph
```

Look for:
- Hot paths in dense iteration
- Cache miss patterns
- Time spent in component access vs business logic

## Test Sizes

The benchmarks run with three entity counts:
- **1,000** - Small scale, good for quick iteration
- **10,000** - Medium scale, typical for many games
- **100,000** - Large scale, stress test

## Conclusion

This benchmark suite provides an honest comparison between ECS and OOP approaches. The goal is not to prove "ECS is always better" but to understand:

1. **Where ECS wins**: Sparse queries, cache-friendly iteration
2. **Where OOP competes**: Simple scenarios, all entities have all components
3. **Real-world performance**: Mixed workloads that combine multiple operations

Use these results to make informed architectural decisions based on your specific use case.