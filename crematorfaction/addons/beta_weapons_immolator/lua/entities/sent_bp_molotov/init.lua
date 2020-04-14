AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()
	self.Entity:SetModel("models/weapons/w_molot0v.mdl")
	
	util.PrecacheSound( "mtov_break1" )
	util.PrecacheSound( "mtov_break2" )
	util.PrecacheSound( "mtov_flame1" )
	util.PrecacheSound( "mtov_flame2" )
	util.PrecacheSound( "mtov_flame3" )
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	
	local zfire = ents.Create( "env_fire_trail" )
		zfire:SetPos( self.Entity:GetPos() )
		zfire:SetParent( self.Entity )
		zfire:Spawn()
		zfire:Activate()
	
end

function ENT:Think() 
end



function ENT:Explosion()
 	util.BlastDamage( self.Entity, self.Entity:GetOwner(), self.Entity:GetPos(), 200, 500 )
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
	util.Effect( "HelicopterMegaBomb", effectdata )	 -- Big flame
	
	local shake = ents.Create( "env_shake" )
		shake:SetOwner( self.Owner )
		shake:SetPos( self.Entity:GetPos() )
		shake:SetKeyValue( "amplitude", "700" )	-- Power of the shake
		shake:SetKeyValue( "radius", "800" )	-- Radius of the shake
		shake:SetKeyValue( "duration", "1" )	-- Time of shake
		shake:SetKeyValue( "frequency", "100" )	-- How har should the screenshake be
		shake:SetKeyValue( "spawnflags", "4" )	-- Spawnflags( In Air )
		shake:Spawn()
		shake:Activate()
		shake:Fire( "StartShake", "", 0 )
	
	local physExplo = ents.Create( "env_physexplosion" )
	    physExplo:SetOwner( self.Owner )
        physExplo:SetPos( self.Entity:GetPos() )
        physExplo:SetKeyValue( "Magnitude", "40" )	-- Power of the Physicsexplosion
        physExplo:SetKeyValue( "radius", "300" )	-- Radius of the explosion
        physExplo:SetKeyValue( "spawnflags", "19" )
        physExplo:Spawn()
        physExplo:Fire( "Explode", "", 0.02 )	
	
	for i=1, 12 do
		local fire = ents.Create( "env_fire" )
			fire:SetPos( self.Entity:GetPos() + Vector( math.random( -100, 100 ), math.random( -100, 100 ), 0 ) )
			fire:SetKeyValue( "health", math.random( 10, 15 ) )
			fire:SetKeyValue( "firesize", "30" )
			fire:SetKeyValue( "fireattack", "8" )
			fire:SetKeyValue( "damagescale", "2.0" )
			fire:SetKeyValue( "StartDisabled", "0" )
			fire:SetKeyValue( "firetype", "0" )
			fire:SetKeyValue( "spawnflags", "132" )
			fire:Spawn()
			fire:Fire( "StartFire", "", 0.2 )
	end
	
	for i=1, 8 do
		local sparks = ents.Create( "env_spark" )
			sparks:SetPos( self.Entity:GetPos() + Vector( math.random( -40, 40 ), math.random( -40, 40 ), math.random( -40, 40 ) ) )
			sparks:SetKeyValue( "MaxDelay", "0" )
			sparks:SetKeyValue( "Magnitude", "2" )
			sparks:SetKeyValue( "TrailLength", "3" )
			sparks:SetKeyValue( "spawnflags", "0" )
			sparks:Spawn()
			sparks:Fire( "SparkOnce", "", 0 )
	end			
			
	for k, v in pairs ( ents.FindInSphere( self.Entity:GetPos(), 350 ) ) do
		if v:IsValid() and v:IsPlayer() then return end
		v:Ignite( 10, 0 )
	end
	
end

function ENT:PhysicsCollide( data, physobj ) 
	util.Decal("Scorch", data.HitPos + data.HitNormal , data.HitPos - data.HitNormal) 
	self.Entity:EmitSound("weapons/1molotov/mtov_break" .. math.random( 1,2 ) .. ".wav")
	self.Entity:EmitSound("weapons/1molotov/mtov_flame" .. math.random( 2,3 ) .. ".wav")
	self:Explosion()
	self.Entity:Remove()
end


