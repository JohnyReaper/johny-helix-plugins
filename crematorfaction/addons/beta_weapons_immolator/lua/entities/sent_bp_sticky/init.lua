AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include("shared.lua")

ENT.Model = "models/weapons/glueblob.mdl"

ENT.ExplosionSound = Sound("weapons/1sticky/explode5.wav")

ENT.BaseDamage = 120
ENT.DamageRandomize = 0.1
ENT.MaxDamageRampUp = 0.15
ENT.MaxDamageFalloff = 0.5
ENT.DamageModifier = 1

ENT.CritDamageMultiplier = 3

function ENT:Crit()
    return self.critical
end

function ENT:CalculateDamage2(hitpos, srcpos)
    local dist, falloff, damage
    local src, hit, crit
    
    if self.GetPos and self:GetPos() then
        src = srcpos or self:GetPos()
        hit = hitpos
        crit = (self.Crit and self:Crit())
    else
        src = self.Src
        hit = self.HitPos
        crit = self.Crit
    end
    
    if hit then
        dist = src:Distance(hit)
        falloff = math.Clamp((dist / 512)-1, -1, 1)
        
        if falloff>0 then falloff = falloff * (self.MaxDamageFalloff or 0)
        else falloff = falloff * (self.MaxDamageRampUp or 0)
        end
    else
        falloff = 0
    end
    
    if self.DamageRandomize then
        damage = math.random(self.BaseDamage * (1-self.DamageRandomize), self.BaseDamage * (1+self.DamageRandomize))
    else
        damage = self.BaseDamage
    end
    
    return (self.DamageModifier or 1) * 120 * (1 - falloff)
end

function ENT:CalculateDamage(ownerpos)
    return self.CalculateDamage2(self:GetPos(), ownerpos)
end

function ENT:Initialize()
    self:SetModel(self.Model)
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_CUSTOM)
    self:SetHealth(1)
    self:SetMoveCollide(MOVECOLLIDE_FLY_SLIDE)
    
    local phys = self.Entity:GetPhysicsObject()
    if phys:IsValid() then
        phys:Wake()
        phys:SetMass(10)
    end
    
    self.ai_sound = ents.Create("ai_sound")
    self.ai_sound:SetPos(self:GetPos())
    self.ai_sound:SetKeyValue("volume", "80")
    self.ai_sound:SetKeyValue("duration", "8")
    self.ai_sound:SetKeyValue("soundtype", "8")
    self.ai_sound:SetParent(self)
    self.ai_sound:Spawn()
    self.ai_sound:Activate()
    self.ai_sound:Fire("EmitAISound", "", 0.5)
    
    self.NextReady = CurTime() + 0.92
    self.NextNoFalloff = CurTime() + 5
    
    local effect = "red"
    
end

function ENT:OnRemove()
    self.ai_sound:Remove()
    if self.particle_timer and self.particle_timer:IsValid() then self.particle_timer:Remove() end
end

function ENT:Think()
    if self.NextReady and CurTime()>=self.NextReady then    
        self.Ready = true
        self.NextReady = nil
    end
    
    if self.NextNoFalloff and CurTime()>=self.NextNoFalloff then
        self.MaxDamageRampUp = 0
        self.MaxDamageFalloff = 0
        self.NextNoFalloff = nil
    end
end

function ENT:Explode( )


end

function ENT:Explode()

	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self.Entity:GetPos( ) )
	ent:Spawn()
	ent:Activate()
	ent:SetKeyValue("iMagnitude", 0);
	ent:SetKeyValue("iRadiusOverride", 0)
	self.Dead = true
	ent:Fire("explode", "", 0)
	self.Entity:Remove()
    
    local owner = self:GetOwner()
    if not owner or not owner:IsValid() then owner = self end
    
    local range = 180
    local damage = self:CalculateDamage(owner:GetPos()+Vector(0,0,1))
    
    self.OwnerDamage = 0.9
    self.ResultDamage = damage
    
    util.BlastDamage(self, owner, self:GetPos(), range, damage)
    
    self:Fire("kill", "", 0.01)
end

function ENT:PhysicsCollide(data, physobj)
    if data.HitEntity and data.HitEntity:IsWorld() and not self.Detached then
        self:GetPhysicsObject():EnableMotion(false)
        self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
    end
end