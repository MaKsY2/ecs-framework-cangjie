package ecsFramework.scenario

import std.collection.*

public class GameObject {
    public var x: Float64
    public var y: Float64
    public var vx: Float64
    public var vy: Float64
    public var hp: Float64
    public var dmg: Float64
    public var armor: Float64
    public var lifetime: Float64
    public var teamId: Int64
    public var hasHealth: Bool
    public var hasDamage: Bool
    public var hasArmor: Bool
    public var hasLifetime: Bool
    public var hasTeam: Bool

    public init(x: Float64, y: Float64, vx: Float64, vy: Float64) {
        this.x = x
        this.y = y
        this.vx = vx
        this.vy = vy
        this.hp = 0.0
        this.dmg = 0.0
        this.armor = 0.0
        this.lifetime = 0.0
        this.teamId = 0
        this.hasHealth = false
        this.hasDamage = false
        this.hasArmor = false
        this.hasLifetime = false
        this.hasTeam = false
    }
}

public class OopWorld <: IWorld {
    var objects: ArrayList<GameObject>

    public init() {
        objects = ArrayList<GameObject>()
    }

    public func createEntity(entityType: EntityType, params: EntityParams): Unit {
        let obj = GameObject(params.x, params.y, params.vx, params.vy)
        
        match (entityType) {
            case Moving =>
                ()
            
            case Combat =>
                obj.hp = params.hp
                obj.dmg = params.dmg
                obj.teamId = params.teamId
                obj.hasHealth = true
                obj.hasDamage = true
                obj.hasTeam = true
            
            case Armored =>
                obj.hp = params.hp
                obj.armor = params.armor
                obj.teamId = params.teamId
                obj.hasHealth = true
                obj.hasArmor = true
                obj.hasTeam = true
            
            case Projectile =>
                obj.dmg = params.dmg
                obj.lifetime = params.lifetime
                obj.hasDamage = true
                obj.hasLifetime = true
        }
        
        objects.add(obj)
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
        for (obj in objects) {
            obj.x += obj.vx
            obj.y += obj.vy
        }
    }

    func updateLifetime(): Unit {
        var i: Int64 = objects.size - 1
        while (i >= 0) {
            let obj = objects[i]
            if (obj.hasLifetime) {
                obj.lifetime -= 1.0
                if (obj.lifetime <= 0.0) {
                    objects.remove(at: i)
                }
            }
            i -= 1
        }
    }

    func applyDamageToArmored(): Unit {
        for (attacker in objects) {
            if (attacker.hasDamage && attacker.hasTeam) {
                for (defender in objects) {
                    if (defender.hasHealth && defender.hasArmor && defender.hasTeam) {
                        if (attacker.teamId != defender.teamId) {
                            let actualDmg = attacker.dmg * (1.0 - defender.armor * 0.01)
                            defender.hp -= actualDmg
                        }
                    }
                }
            }
        }
    }

    func removeDeadEntities(): Unit {
        var i: Int64 = objects.size - 1
        while (i >= 0) {
            let obj = objects[i]
            if (obj.hasHealth && obj.hp <= 0.0) {
                objects.remove(at: i)
            }
            i -= 1
        }
    }

    public func countEntities(): Int64 {
        objects.size
    }
}
