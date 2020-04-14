/*-----------------------------
       RPG Rocket SENT
	by Pac_187
--------------------------------*/

-------some settings-------
local Breakgibs = 8
-------------------------------

ENT.IsRPG7Warhead = true

AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

local RocketSound = Sound( "Missile.Accelerate" )

function ENT:Initialize()

 
    self.Entity:SetModel( "models/Weapons/W_missile_closed.mdl" )
	
    self.Entity:PhysicsInit( SOLID_VPHYSICS )
    self.Entity:SetMoveType(  MOVETYPE_VPHYSICS )   
    self.Entity:SetSolid( SOLID_VPHYSICS )
	self.SpawnTime = CurTime()
	self.HitCounter = 0
 
    self.PhysObj = self.Entity:GetPhysicsObject()
    if (self.PhysObj:IsValid()) then
		self.PhysObj:EnableGravity( false )
		self.PhysObj:EnableDrag( false ) 
		self.PhysObj:SetMass(30)
        self.PhysObj:Wake()
    end
		
	self.Entity:EmitSound( RocketSound )
	util.PrecacheSound( "explode_4" )
	for i=1,3 do
	util.PrecacheSound( "physics/metal/metal_computer_impact_bullet"..i..".wav" )
	end
	util.PrecacheModel( "models/props_debris/metal_panelshard01a.mdl" )
	util.PrecacheModel( "models/props_debris/metal_panelshard01b.mdl" )
	util.PrecacheModel( "models/props_debris/metal_panelshard01c.mdl" )
	util.PrecacheModel( "models/props_debris/metal_panelshard01d.mdl" )
   
end
 
 
function ENT:Think() 
local phys = self.Entity:GetPhysicsObject()
local ang = self.Entity:GetForward() * 10000
local upang = self.Entity:GetUp() * math.Rand(700,1000) * (math.sin(CurTime()*10))
local rightang = self.Entity:GetRight() * math.Rand(700,1000) * (math.cos(CurTime()*10))
local force
if self.SpawnTime + 0.5 < CurTime() then
force = ang + upang + rightang
else
force = ang
end
if not self.HitSomething then
phys:ApplyForceCenter(force)
end
if self.HitCounter > 1 then
	self.Entity:EmitSound( "explode_4" )
	self:Explosion()
	self.Entity:Remove()
end
end

crapgibs = {}
crapgibs[1] = "models/props_debris/metal_panelshard01a.mdl"
crapgibs[2] = "models/props_debris/metal_panelshard01b.mdl"
crapgibs[3] = "models/props_debris/metal_panelshard01c.mdl"
crapgibs[4] = "models/props_debris/metal_panelshard01d.mdl"


function ENT:myGibs()

for i=1, Breakgibs do
	local gibs = ents.Create( "prop_physics" )
		gibs:SetModel( crapgibs[ math.random( 1, 4 ) ] )
		gibs:SetPos( self.Entity:GetPos() + Vector( math.random( -100, 100 ), math.random( -100, 100 ), math.random( -100, 100 ) ) ) 
		gibs:Spawn()
		gibs:Activate()
		gibs:Ignite( math.random( 6, 12), 0 )
		gibs:Fire( "kill", "", math.random( 6, 12) )
		
		local physObj = gibs:GetPhysicsObject()
		physObj:SetMass( 50 )
		
	local zfire = ents.Create( "env_fire_trail" )
		zfire:SetPos( gibs:GetPos() )
		zfire:SetParent( gibs )
		zfire:Spawn()
		zfire:Activate()
end

end


function ENT:Explosion()
 	util.BlastDamage( self.Entity, self.Entity:GetOwner(), self.Entity:GetPos(), 200, 500 )
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
	util.Effect( "Explosion", effectdata )			 -- Explosion effect
	util.Effect( "HelicopterMegaBomb", effectdata )	 -- Big flame
	
	local explo = ents.Create( "env_explosion" )
		explo:SetOwner( self.Owner )
		explo:SetPos( self.Entity:GetPos() )
		explo:SetKeyValue( "iMagnitude", "50" )
//		explo:SetKeyValue( "iRadiusOverride", "400" )
		explo:Spawn()
		explo:Activate()
		explo:Fire( "Explode", "", 0 )
	
	
	local shake = ents.Create( "env_shake" )
		shake:SetOwner( self.Owner )
		shake:SetPos( self.Entity:GetPos() )
		shake:SetKeyValue( "amplitude", "2000" )	-- Power of the shake
		shake:SetKeyValue( "radius", "900" )	-- Radius of the shake
		shake:SetKeyValue( "duration", "5" )	-- Time of shake
		shake:SetKeyValue( "frequency", "255" )	-- How har should the screenshake be
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
	
	local physExplo = ents.Create( "env_physexplosion" )
	    physExplo:SetOwner( self.Owner )
        physExplo:SetPos( self.Entity:GetPos() )
        physExplo:SetKeyValue( "Magnitude", "1000" )	-- Power of the Physicsexplosion
        physExplo:SetKeyValue( "radius", "1000" )	-- Radius of the explosion
        physExplo:SetKeyValue( "spawnflags", "19" )
        physExplo:Spawn()
        physExplo:Fire( "Explode", "", 0.02 )
		
	local ar2Explo = ents.Create( "env_ar2explosion" )
		ar2Explo:SetOwner( self.Owner )
		ar2Explo:SetPos( self.Entity:GetPos() )
		ar2Explo:Spawn()
		ar2Explo:Activate()
		ar2Explo:Fire( "Explode", "", 0 )
		
	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 350 ) ) do
		if v:IsValid() and v:IsPlayer() then return end
		v:Ignite( 10, 0 )
	end
	
	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 250 ) ) do
		v:Fire( "EnableMotion", "", math.random( 0, 0.5 ) )
	end
	
	self:myGibs()	
		
end

function ENT:PhysicsCollide( data, physobj ) 
if data.HitEntity:IsWorld() then
self.HitCounter = 1
end
if not data.HitEntity:IsWorld() and self.HitCounter < 1 then
self.Entity:SetPos(self.Entity:GetPos()+(self.Entity:GetForward()*50))
self.Entity:GetPhysicsObject():SetVelocity(data.OurOldVelocity )
local ang = data.OurOldVelocity:GetNormal()
ang = ang:Angle()
self.Entity:SetAngles(ang) 
self.Entity:EmitSound("physics/metal/metal_computer_impact_bullet"..math.Round(math.Rand(1,3),0)..".wav",500)
end		
		self.HitCounter = self.HitCounter + 1
end

function ENT:OnRemove()
	self.Entity:StopSound( RocketSound )
end

