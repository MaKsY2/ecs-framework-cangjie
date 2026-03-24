package ecsFramework.test

import std.unittest.*
import std.unittest.testmacro.*
import std.collection.*
import ecsFramework.framework.*
import ecsFramework.scenario.*

@Test
class ViewTests {
    @TestCase
    func testView2EmptyRegistry(): Unit {
        let reg = Registry()
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 0)
    }

    @TestCase
    func testView2OnlyPositionNotReturned(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 0)
    }

    @TestCase
    func testView2BothComponentsReturned(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 1)
    }

    @TestCase
    func testView2ReturnsCorrectComponents(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(10.0, 20.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        let gotX = ArrayList<Float64>([0.0])
        let gotVx = ArrayList<Float64>([0.0])
        reg.view2<Position, Velocity>().each({ _, pos, vel =>
            gotX[0] = pos.x
            gotVx[0] = vel.vx
        })
        @Expect(gotX[0], 10.0)
        @Expect(gotVx[0], 3.0)
    }

    @TestCase
    func testView2WithExtraComponentStillReturned(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        reg.addComponent<Health>(e, Health(100.0))
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 1)
    }

    @TestCase
    func testView2MultipleMixedEntities(): Unit {
        let reg = Registry()
        let e1 = reg.createEntity()
        reg.addComponent<Position>(e1, Position(1.0, 0.0))

        let e2 = reg.createEntity()
        reg.addComponent<Position>(e2, Position(2.0, 0.0))
        reg.addComponent<Velocity>(e2, Velocity(1.0, 0.0))

        let e3 = reg.createEntity()
        reg.addComponent<Position>(e3, Position(3.0, 0.0))
        reg.addComponent<Velocity>(e3, Velocity(1.0, 0.0))

        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 2)
    }

    @TestCase
    func testView2NoDuplicates(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 1)
    }

    @TestCase
    func testView2AfterRemoveComponentNotReturned(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        reg.removeComponent<Velocity>(e)
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 0)
    }

    @TestCase
    func testView2AfterAddMissingComponentReturned(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 0)

        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        count[0] = 0
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 1)
    }

    @TestCase
    func testView2AllEntitiesFound(): Unit {
        let reg = Registry()
        var i: Int64 = 0
        while (i < 10) {
            let e = reg.createEntity()
            reg.addComponent<Position>(e, Position(Float64(i), 0.0))
            reg.addComponent<Velocity>(e, Velocity(1.0, 0.0))
            i += 1
        }
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 10)
    }

    @TestCase
    func testView2AfterDestroyEntityNotReturned(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        reg.destroyEntity(e)
        let count = ArrayList<Int64>([0])
        reg.view2<Position, Velocity>().each({ _, _, _ => count[0] += 1 })
        @Expect(count[0], 0)
    }

    @TestCase
    func testView1Basic(): Unit {
        let reg = Registry()
        let e1 = reg.createEntity()
        reg.addComponent<Position>(e1, Position(1.0, 2.0))
        let e2 = reg.createEntity()
        reg.addComponent<Position>(e2, Position(3.0, 4.0))
        let count = ArrayList<Int64>([0])
        reg.view1<Position>().each({ _, _ => count[0] += 1 })
        @Expect(count[0], 2)
    }

    @TestCase
    func testView3ThreeComponents(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        reg.addComponent<Health>(e, Health(100.0))
        let count = ArrayList<Int64>([0])
        reg.view3<Position, Velocity, Health>().each({ _, _, _, _ => count[0] += 1 })
        @Expect(count[0], 1)
    }

    @TestCase
    func testView3MissingOneComponent(): Unit {
        let reg = Registry()
        let e = reg.createEntity()
        reg.addComponent<Position>(e, Position(1.0, 2.0))
        reg.addComponent<Velocity>(e, Velocity(3.0, 4.0))
        let count = ArrayList<Int64>([0])
        reg.view3<Position, Velocity, Health>().each({ _, _, _, _ => count[0] += 1 })
        @Expect(count[0], 0)
    }
}
