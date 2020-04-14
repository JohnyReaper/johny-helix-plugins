AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local Rocket = {}
Rocket.Loop = Sound("Missile.Accelerate")
Rocket.Damage = 500
Rocket.Velocity = 1000
Rocket.Radius = 20
Rocket.Life = 10 -- To prevent rocket looping

function ENT:Initialize()

	self.model = "models/Weapons/W_missile_closed.mdl"
	self.Entity:SetModel( self.model ) 
 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()

	if (phys:IsValid()) then
		phys:Wake()
		phys:AddAngleVelocity(Vector(15,0,0))
	end
	
	self.DoomsDay = CurTime() + Rocket.Life
	self.Entity:EmitSound(Rocket.Loop)
	self.Active = false
	self.SpawnTime = CurTime()
	self.Dropped = false
end  

function ENT:PhysicsCollide( data, physobj )
	self:CreateExplosion()
end

function ENT:CreateExplosion()
	local effect = EffectData()
	effect:SetOrigin(self:GetPos())
	util.Effect("immolate", effect)
	local expl = ents.Create("env_explosion")
	expl:SetPos(self.Entity:GetPos())
	expl:SetKeyValue("iMagnitude",Rocket.Damage)
	expl:SetOwner(self.Entity:GetOwner())
	expl:Spawn()
	expl:Fire("explode","",0)
	self.Entity:Fire("kill", "", 0)
end


function ENT:OnTakeDamage( dmginfo )
	if dmginfo:IsExplosionDamage() then return end
	self.Entity:TakePhysicsDamage( dmginfo )
	
end

function ENT:KeyValue(key,value)
	self[key] = tonumber(value) or value
end

function ENT:SpawnFunction( ply, tr )

if ( !tr.Hit ) then return end

local SpawnPos = tr.HitPos + tr.HitNormal * 2
local ang = tr.HitNormal:Angle()
local ent = ents.Create( "sent_bp_jrocket" )
ent:SetPos( SpawnPos )
--ent:SetAngles(ang)
ent:Spawn()
ent:Activate()

return ent

end

function ENT:PhysicsSimulate( phys, deltatime )
   
	self.ShadowParams={}
	self.ShadowParams.secondstoarrive = 5
	self.ShadowParams.maxspeed = 200
	self.ShadowParams.pos = self:GetHeadPos(self.Target)
	self.ShadowParams.angle = self:Point(self.Target)
	self.ShadowParams.maxangular = 1000
	self.ShadowParams.maxangulardamp = 1
	self.ShadowParams.maxspeeddamp = 1
	self.ShadowParams.dampfactor = 0.8
	self.ShadowParams.teleportdistance = 0   
	self.ShadowParams.deltatime = deltatime
	
	phys:ComputeShadowControl(self.ShadowParams)

end 

function ENT:GetHeadPos(targetEnt)
	if !targetEnt or !targetEnt:IsValid() then return end
	local minp, maxp = targetEnt:WorldSpaceAABB( ) 
	local larp = targetEnt:WorldToLocal(maxp)
	local tarpos = targetEnt:GetPos() + Vector( 0, 0, larp.z * .75 )

	return tarpos
end

function ENT:Point(targetEnt)
	if !targetEnt or !targetEnt:IsValid() then return end
	local pos = self.Entity:GetPos()
	
	local ang = (self:GetHeadPos(targetEnt) - pos):Normalize()
	ang = Angle(ang)
	
	return ang
end

function ENT:Think()
	if !self.Target or !self.Target:IsValid() or (CurTime() > self.DoomsDay) and self.Entity:IsValid() or (self.Target:GetPos():Distance(self:GetPos()) < 100) then
		self:CreateExplosion()
	end
	if !self.Active and (CurTime() > (self.SpawnTime + .25)) then
		local phys = self:GetPhysicsObject()
		phys:ApplyForceCenter(self:GetForward() * 99*10^9)
		local effect = EffectData()
		effect:SetOrigin(self:GetPos())
		util.Effect("cball_bounce", effect)
		util.SpriteTrail( self, 0, Color( 255, 255, 255 ), false, 15, 0, 3, 1/(15+5)*0.5, "trails/smoke.vmt")
		self.Active = true
	end
	if self.Active then
		local effect = EffectData()
			effect:SetOrigin(self.Entity:GetPos())
			effect:SetAngles(self.Entity:GetAngles())
			effect:SetScale(.5)
		util.Effect("MuzzleEffect", effect)
		
		if (self:GetVelocity():Length() < 300) and !self.Dropped then
			self:SetAngles(self:Point(self.Target))
			self:StartMotionController()
			self.Dropped = true
		end
	end
	self:NextThink(CurTime())
end

function ENT:OnRemove()
	self.Entity:StopSound(Rocket.Loop)
end 