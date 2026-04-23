package ecsFramework

import std.time.*
import ecsFramework.bench.*
import ecsFramework.bench.ecs.*
import ecsFramework.bench.oop.*

main(): Int64 {
    let start = DateTime.now()

    twoComponentsOOP()

    let end = DateTime.now()
    println("Elapsed: ${(end - start).toNanoseconds()}")

    return 0
}

// OOP Elapsed: 0.00383715 sec
// ECS Elapsed: 0.25954009 sec 

// ECS Elapsed: 0.08669605 sec
// OOP Elapsed: 0.00046389 sec 
