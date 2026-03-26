package ecsFramework.scenario

import ecsFramework.framework.*
import std.collection.*

public class EcsWorld <: IWorld {
    public var registry: Registry

    public init() {
        registry = Registry()
    }

    public func createEntity(entityType: EntityType, params: EntityParams): Unit {
        let e = registry.createEntity()
        
        match (entityType) {
            case Moving =>
                registry.addComponent<Position>(e, Position(params.x, params.y))
                registry.addComponent<Velocity>(e, Velocity(params.vx, params.vy))
            
            case Combat =>
                registry.addComponent<Position>(e, Position(params.x, params.y))
                registry.addComponent<Velocity>(e, Velocity(params.vx, params.vy))
                registry.addComponent<Health>(e, Health(params.hp))
                registry.addComponent<Damage>(e, Damage(params.dmg))
                registry.addComponent<Team>(e, Team(params.teamId))
            
            case Armored =>
                registry.addComponent<Position>(e, Position(params.x, params.y))
                registry.addComponent<Velocity>(e, Velocity(params.vx, params.vy))
                registry.addComponent<Health>(e, Health(params.hp))
                registry.addComponent<Armor>(e, Armor(params.armor))
                registry.addComponent<Team>(e, Team(params.teamId))
            
            case Projectile =>
                registry.addComponent<Position>(e, Position(params.x, params.y))
                registry.addComponent<Velocity>(e, Velocity(params.vx, params.vy))
                registry.addComponent<Damage>(e, Damage(params.dmg))
                registry.addComponent<Lifetime>(e, Lifetime(params.lifetime))
        }
    }

    public func update(systemType: SystemType): Unit {
        match (systemType) {
            case Movement =>
                updateMovement()
            case Lifetime =>
                updateLifetime()
            case Combat =>
                applyDamageToArmored()
            case Cleanup =>
                removeDeadEntities()
        }
    }

    func updateMovement(): Unit {
        let v = registry.view2<Position, Velocity>()
        v.each({ eid, pos, vel =>
            let newPos = Position(pos.x + vel.vx, pos.y + vel.vy)
            registry.getPool<Position>().add(eid, newPos)
        })
    }

    func updateLifetime(): Unit {
        let v = registry.view1<Lifetime>()
        let toDestroy = ArrayList<Entity>()
        
        v.each({ eid, lifetime =>
            let newLifetime = lifetime.remaining - 1.0
            if (newLifetime <= 0.0) {
                toDestroy.add(Entity(eid, 0))
            } else {
                registry.getPool<Lifetime>().add(eid, Lifetime(newLifetime))
            }
        })

        for (e in toDestroy) {
            registry.destroyEntity(e)
        }
    }

    func applyDamageToArmored(): Unit {
        let attackers = registry.view2<Damage, Team>()
        let defenders = registry.view3<Health, Armor, Team>()

        attackers.each({ atkId, dmg, atkTeam =>
            defenders.each({ defId, hp, armor, defTeam =>
                if (atkTeam.teamId != defTeam.teamId) {
                    let actualDmg = dmg.dmg * (1.0 - armor.armor * 0.01)
                    let newHp = hp.hp - actualDmg
                    registry.getPool<Health>().add(defId, Health(newHp))
                }
            })
        })
    }

    func removeDeadEntities(): Unit {
        let v = registry.view1<Health>()
        let toDestroy = ArrayList<Entity>()
        
        v.each({ eid, hp =>
            if (hp.hp <= 0.0) {
                toDestroy.add(Entity(eid, 0))
            }
        })

        for (e in toDestroy) {
            registry.destroyEntity(e)
        }
    }

    public func countEntities(): Int64 {
        registry.getPool<Position>().denseSize()
    }
}
