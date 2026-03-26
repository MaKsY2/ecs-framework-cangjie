package ecsFramework.scenario

import ecsFramework.framework.*
import std.collection.*

public class EcsWorld <: IWorld {
    public var registry: Registry
    var positionPool: SparseSet<Position>
    var velocityPool: SparseSet<Velocity>
    var healthPool: SparseSet<Health>
    var damagePool: SparseSet<Damage>
    var armorPool: SparseSet<Armor>
    var lifetimePool: SparseSet<Lifetime>
    var teamPool: SparseSet<Team>
    
    var movementView: View2<Position, Velocity>
    var lifetimeView: View1<Lifetime>
    var attackersView: View2<Damage, Team>
    var defendersView: View3<Health, Armor, Team>
    var healthView: View1<Health>

    public init() {
        registry = Registry()
        
        positionPool = registry.getPool<Position>("Position")
        velocityPool = registry.getPool<Velocity>("Velocity")
        healthPool = registry.getPool<Health>("Health")
        damagePool = registry.getPool<Damage>("Damage")
        armorPool = registry.getPool<Armor>("Armor")
        lifetimePool = registry.getPool<Lifetime>("Lifetime")
        teamPool = registry.getPool<Team>("Team")
        
        movementView = View2<Position, Velocity>(positionPool, velocityPool)
        lifetimeView = View1<Lifetime>(lifetimePool)
        attackersView = View2<Damage, Team>(damagePool, teamPool)
        defendersView = View3<Health, Armor, Team>(healthPool, armorPool, teamPool)
        healthView = View1<Health>(healthPool)
    }

    public func createEntity(entityType: EntityType, params: EntityParams): Unit {
        let e = registry.createEntity()
        
        match (entityType) {
            case Moving =>
                registry.addComponent<Position>(e, "Position", Position(params.x, params.y))
                registry.addComponent<Velocity>(e, "Velocity", Velocity(params.vx, params.vy))
            
            case Combat =>
                registry.addComponent<Position>(e, "Position", Position(params.x, params.y))
                registry.addComponent<Velocity>(e, "Velocity", Velocity(params.vx, params.vy))
                registry.addComponent<Health>(e, "Health", Health(params.hp))
                registry.addComponent<Damage>(e, "Damage", Damage(params.dmg))
                registry.addComponent<Team>(e, "Team", Team(params.teamId))
            
            case Armored =>
                registry.addComponent<Position>(e, "Position", Position(params.x, params.y))
                registry.addComponent<Velocity>(e, "Velocity", Velocity(params.vx, params.vy))
                registry.addComponent<Health>(e, "Health", Health(params.hp))
                registry.addComponent<Armor>(e, "Armor", Armor(params.armor))
                registry.addComponent<Team>(e, "Team", Team(params.teamId))
            
            case Projectile =>
                registry.addComponent<Position>(e, "Position", Position(params.x, params.y))
                registry.addComponent<Velocity>(e, "Velocity", Velocity(params.vx, params.vy))
                registry.addComponent<Damage>(e, "Damage", Damage(params.dmg))
                registry.addComponent<Lifetime>(e, "Lifetime", Lifetime(params.lifetime))
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
            movementView.each({ eid, pos, vel =>
                positionPool.update(eid, { p => Position(p.x + vel.vx, p.y + vel.vy) })
            })
        }

    func updateLifetime(): Unit {
            let toDestroy = ArrayList<Entity>()
            
            lifetimeView.each({ eid, lifetime =>
                let newRemaining = lifetime.remaining - 1.0
                if (newRemaining <= 0.0) {
                    toDestroy.add(Entity(eid, 0))
                } else {
                    lifetimePool.update(eid, { _ => Lifetime(newRemaining) })
                }
            })
    
            registry.destroyEntities(toDestroy)
        }
    
        func applyDamageToArmored(): Unit {
            attackersView.each({ atkId, dmg, atkTeam =>
                defendersView.each({ defId, hp, armor, defTeam =>
                    if (atkTeam.teamId != defTeam.teamId) {
                        let actualDmg = dmg.dmg * (1.0 - armor.armor * 0.01)
                        healthPool.update(defId, { h => Health(h.hp - actualDmg) })
                    }
                })
            })
        }

    func removeDeadEntities(): Unit {
        let toDestroy = ArrayList<Entity>()
        
        healthView.each({ eid, hp =>
            if (hp.hp <= 0.0) {
                toDestroy.add(Entity(eid, 0))
            }
        })

        registry.destroyEntities(toDestroy)
    }

    public func countEntities(): Int64 {
        positionPool.denseSize()
    }
}
