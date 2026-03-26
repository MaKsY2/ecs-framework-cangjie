package ecsFramework.scenario

public enum EntityType {
    | Moving
    | Combat
    | Armored
    | Projectile
}

public struct EntityParams {
    public var x: Float64
    public var y: Float64
    public var vx: Float64
    public var vy: Float64
    public var hp: Float64
    public var dmg: Float64
    public var armor: Float64
    public var lifetime: Float64
    public var teamId: Int64

    public init(x: Float64, y: Float64, vx: Float64, vy: Float64, hp: Float64, dmg: Float64, armor: Float64, lifetime: Float64, teamId: Int64) {
        this.x = x
        this.y = y
        this.vx = vx
        this.vy = vy
        this.hp = hp
        this.dmg = dmg
        this.armor = armor
        this.lifetime = lifetime
        this.teamId = teamId
    }
}

public enum SystemType {
    | Movement
    | Lifetime
    | Combat
    | Cleanup
}

public interface IWorld {
    func createEntity(entityType: EntityType, params: EntityParams): Unit
    
    func update(systemType: SystemType): Unit
    
    func countEntities(): Int64
}
