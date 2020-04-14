include('particletrace.lua')
AddCSLuaFile( "particletrace.lua" )

local sndAttackLoop = Sound("fire_large")
local sndSprayLoop = Sound("ambient.steam01")
local sndAttackStop = Sound("ambient/_period.wav")
local sndIgnite = Sound("PropaneTank.Burst")

if (SERVER) then

	AddCSLuaFile( "shared.lua" )
	SWEP.Weight				= 5
	SWEP.AutoSwitchTo		= false
	SWEP.AutoSwitchFrom		= false
	


end

if ( CLIENT ) then

	SWEP.DrawAmmo			= true
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 58
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	SWEP.Category 		= "HL2 Cremator Sweps"
	SWEP.PrintName			= "Immolator (Fire) EDITED"			
	SWEP.Author				= "Valve"
	SWEP.Slot				= 5
	SWEP.SlotPos			= 7

	SWEP.WepSelectIcon = surface.GetTextureID("HUD/swepicons/weapon_immolator") 
	SWEP.BounceWeaponIcon = false 	
	SWEP.DrawWeaponInfoBox	= false

end
SWEP.HoldType			= "smg"
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "Models/weapons/v_cremato2.mdl"
SWEP.WorldModel			= ""

SWEP.Primary.Recoil			= 0
SWEP.Primary.Damage			= 20
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= 0.

game.AddAmmoType( { name = "bp_flame" } )
if ( CLIENT ) then language.Add( "bp_flame_ammo", "Petroleum Gas" ) end

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 3
SWEP.Secondary.NumShots		= 1
SWEP.Secondary.Cone			= 0.02
SWEP.Secondary.Delay			= 0.

SWEP.Secondary.ClipSize		= 1
SWEP.Secondary.DefaultClip	= 1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"


function SWEP:Initialize()

	self:SetWeaponHoldType(self.HoldType)
	self.EmittingSound = false
	util.PrecacheModel("models/player/charple01.mdl")

end

function SWEP:Reload()
end

function SWEP:Think()
	if self.Owner:KeyReleased(IN_ATTACK) or self.Owner:KeyReleased(IN_ATTACK2) then
		self:StopSounds()
	end

end

function SWEP:PrimaryAttack()
-- if ( self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then
	local curtime = CurTime()
	local InRange = false

	self.Weapon:SetNextSecondaryFire( curtime + 0.8 )
	self.Weapon:SetNextPrimaryFire( curtime + self.Primary.Delay )
	-- self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	if self.Owner:WaterLevel() > 1 then 
	self:StopSounds() 
	return end
	
	if not self.EmittingSound then
		self.Weapon:EmitSound(sndAttackLoop)
		self.EmittingSound = true
	end
	
	self.Owner:MuzzleFlash()
	-- self:TakePrimaryAmmo(1)
	
	-- if SERVER then
		local PlayerVel = self.Owner:GetVelocity()
		local PlayerPos = self.Owner:GetShootPos()
		local PlayerAng = self.Owner:GetAimVector()
		
		local trace = {}
		trace.start = PlayerPos
		trace.endpos = PlayerPos + (PlayerAng*4096)
		trace.filter = self.Owner
		
		local traceRes = util.TraceLine(trace)
		local hitpos = traceRes.HitPos
		
		local jetlength = (hitpos - PlayerPos):Length()
		if jetlength > 568 then jetlength = 568 end
		if jetlength < 6 then jetlength = 6 end
		
		if self.Owner:Alive() then
			local effectdata = EffectData()
			effectdata:SetOrigin( hitpos )
			effectdata:SetEntity( self.Weapon )
			-- effectdata:SetStart( PlayerPos )
			effectdata:SetStart( PlayerPos + PlayerAng:Up() * -40 + PlayerAng:Right() * 15 + self.Owner:GetForward() * 40 )
			effectdata:SetNormal( PlayerAng )
			effectdata:SetScale( jetlength )
			-- effectdata:SetAttachment( self.Owner:LookupAttachment("muzzle") )
			effectdata:SetAttachment(1)
			util.Effect( "bp_flamepuffs", effectdata )
		end

		if self.DoShoot then

			local ptrace = {}
			ptrace.startpos = PlayerPos + PlayerAng:GetNormalized()*16
			local ang = (traceRes.HitPos - ptrace.startpos):GetNormalized()
			ptrace.func = burndamage
			ptrace.movetype = MOVETYPE_FLY
			ptrace.velocity = ang*728 + 0.5*PlayerVel
			ptrace.model = "none"
			ptrace.filter = {self.Owner}
			ptrace.killtime = (jetlength + 16)/ptrace.velocity:Length()
			ptrace.runonkill = false
			ptrace.collisionsize = 14
			ptrace.worldcollide = true
			ptrace.owner = self.Owner
			ptrace.name = "flameparticle"
			ParticleTrace(ptrace)
			
			self.DoShoot = false
			else
			self.DoShoot = true
		end
	-- end
end

function SWEP:SecondaryAttack()
if ( self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then

	local curtime = CurTime()

	self.Weapon:SetNextSecondaryFire( curtime + self.Primary.Delay )
	self.Weapon:SetNextPrimaryFire( curtime + 1 )
	
	if self.Owner:WaterLevel() > 1 then 
	self:StopSounds() 
	return end
	
	if not self.EmittingSound then
		self.Weapon:EmitSound(sndSprayLoop)
		self.EmittingSound = true
	end
	
	self:TakePrimaryAmmo(1)
	
	local PlayerVel = self.Owner:GetVelocity()
	local PlayerPos = self.Owner:GetShootPos()
	local PlayerAng = self.Owner:GetAimVector()
	
	local trace = {}
	trace.start = PlayerPos
	trace.endpos = PlayerPos + (PlayerAng*4096)
	trace.filter = self.Owner
	
	local traceRes = util.TraceLine(trace)
	local hitpos = traceRes.HitPos
	
	local jetlength = (hitpos - PlayerPos):Length()
	
		if jetlength > 568 then 
		jetlength = 568
		elseif self.DoShoot then
	
		local normal = traceRes.HitNormal

			if traceRes.HitNonWorld then
				local hitent = traceRes.Entity
				local enttype = hitent:GetClass()
				if hitent:IsNPC() or hitent:IsPlayer() or enttype == "prop_physics" or enttype == "prop_vehicle" then
					local hitenttable = hitent:GetTable()
					hitenttable.FuelLevel = hitenttable.FuelLevel or 0
					hitenttable.FuelLevel = hitenttable.FuelLevel + 1
					util.Decal("BeerSplash", hitpos + normal, hitpos - normal )
				end
			elseif Vector(0,0,1):Dot(normal) > 0.25 then --Garry's idea XD
				if SERVER then
					local fire = ents.Create("sent_firecontroller") --Make an ignitable fire.
					fire:SetPos(hitpos + normal*16)
					fire:SetOwner(self.Owner)
					fire:Spawn()
				end
				util.Decal("BeerSplash", hitpos + normal, hitpos - normal )
			end
			
			if SERVER then
				for key,found in pairs(ents.FindInSphere(hitpos,32)) do
					local foundname = found:GetName()
					
					if found:GetClass() == "entityflame"
					or found:GetName() == "BurningFire"
					or found:GetName() == "flameparticle" then --If we hapen to be blowing napalm near an open flame...
					
					explode(self.Owner,PlayerPos) --Then blow ourselves up.

						for i=1,7 do --Spawn some fires near our charred, lifeless corpse.
							local fire = ents.Create("env_fire")
							local randvec = Vector(math.random(-150,150),math.random(-150,150),0)

							fire:SetKeyValue("StartDisabled","0")
							fire:SetKeyValue("health",math.random(29,31))
							fire:SetKeyValue("firesize",math.random(64,72))
							fire:SetKeyValue("fireattack","2")
							fire:SetKeyValue("ignitionpoint","0")
							fire:SetKeyValue("damagescale","35")
							fire:SetKeyValue("spawnflags",2 + 4 + 128)
							
							fire:SetPos(PlayerPos + randvec)
							fire:SetOwner(self.Owner)
							fire:Spawn()
							fire:Fire("StartFire","","0")
						end
					
					break
					
					end
			
				end
				
			end
			
		self.DoShoot = false
		else
		self.DoShoot = true
		end

	if jetlength < 6 then jetlength = 6 end

	local effectdata = EffectData()
	effectdata:SetEntity( self.Weapon )
	effectdata:SetStart( PlayerPos )
	effectdata:SetNormal( PlayerAng )
	effectdata:SetScale( jetlength )
	effectdata:SetAttachment( 1 )
	util.Effect( "bp_gaspuffs", effectdata )
	
	end
end


HumanModels = {

"models/Humans/",
"models/player/",
"models/zombie",
"[Pp]olice.mdl",
"[Ss]oldier",
"[Aa]lyx.mdl",
"[Bb]arney.mdl",
"[Bb]reen.mdl",
"[Ee]li.mdl",
"[Mm]onk.mdl",
"[Kk]leiner.mdl",
"[Mm]ossman.mdl",
"[Oo]dessa.mdl",
"[Gg]man"

}

function IsHumanoid(ent)

if ent:IsPlayer() then return true end

local entmodel = ent:GetModel()

	for k,model in pairs(HumanModels) do
		if string.find(entmodel,model) ~= nil then
		return true end
	end
	
	return false
	
end

function explode(ent,pos)

	pos.z = pos.z - 64

	Immolate(ent,pos)
	
	local boom = ents.Create("env_explosion")
	boom:SetKeyValue("iMagnitude","384")
	boom:SetPos(pos)
	boom:SetOwner(ent)
	boom:Spawn()
	
	boom:Fire("Explode","","0")

	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "bp_explosion_large", effectdata )
	

end

function Immolate(ent,pos)

pos = pos or ent:GetPos()


	if SERVER then
		ent:SetModel("models/Humans/Charple01.mdl")
		
		if ent:IsPlayer() then
			ent:Kill()
		else
			ent:Fire("sethealth","0","0")
		end
	end
	
	local effectdata = EffectData()
	effectdata:SetOrigin( pos )
	util.Effect( "bp_immolate", effectdata )


end

function burndamage(ptres)

	local hitent = ptres.activator
	if hitent:WaterLevel() > 0 then return end

	local ttime = ptres.time
	if ttime == 0 then ttime = 0.1 end --Division by zero is bad! D :
	
	local damage = math.ceil(3/ttime)
	if damage > 15 then damage = 15 end
	
	local radius = math.ceil(256*ttime)
	if radius < 16 then radius = 16 end
	

	local healthpercent = 3
	local isnpc = hitent:IsNPC()
	local enthealth = 1
	local enttable = hitent:GetTable()
	
	if isnpc or hitent:IsPlayer() then
	enthealth = hitent:Health()
	healthpercent = math.ceil(enthealth/5)
	end
	
	local fuel = enttable.FuelLevel
	if fuel and fuel > 0 then
	
	ptres.caller:EmitSound(sndIgnite)
	enttable.FuelLevel = 0
	
	local entpos = hitent:GetPos()
	local boompos = entpos
	boompos.z = boompos.z + hitent:BoundingRadius()/2
	local damagemult = 4*fuel
	local radiusmult = radius + fuel
	
	local effectdata = EffectData()
	effectdata:SetOrigin( entpos )
	effectdata:SetEntity( hitent )
	effectdata:SetStart( entpos )
	effectdata:SetNormal( Vector(0,0,1) )
	effectdata:SetScale( 10 )
	util.Effect( "HelicopterMegaBomb", effectdata )
	
		if damagemult < enthealth then
			hitent:Ignite(math.Rand(7,11),0)
			hitent:SetHealth(24 + damagemult)
			util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, boompos, radiusmult, damagemult)
		elseif IsHumanoid(hitent) then
			Immolate(hitent,entpos)
			else
			
			util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, boompos, radiusmult, damagemult)
			hitent:SetHealth(0)

		end
		
	else
	
	util.BlastDamage(ptres.owner:GetActiveWeapon(), ptres.owner, ptres.particlepos, radius, damage)

		local reverselottery = math.random(0,healthpercent)
		if reverselottery == 1 then --it's your lucky day!
		hitent:Ignite(math.Rand(7,11),0)
			if isnpc and enthealth < 32 and hitent:GetMaxHealth() > 24 then
			hitent:SetHealth(32) --So we can watch 'em BURN!  >:D
			end
		end
	end
end

function DeFlamitize(ply) 
   
ply:GetTable().FuelLevel = 0

if ply:IsOnFire() then
	ply:Extinguish()
end
   
end 
   
 hook.Add( "PlayerDeath", "deflame", DeFlamitize )


function SWEP:StopSounds()
	if self.EmittingSound then
		self.Weapon:StopSound(sndAttackLoop)
		self.Weapon:StopSound(sndSprayLoop)
		self.Weapon:EmitSound(sndAttackStop)
		self.EmittingSound = false
	end	
end


function SWEP:Holster()
	self:StopSounds()
	return true
end

function SWEP:OnRemove()
	self:StopSounds()
	return true
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
	self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
	self:Idle()
	return true
end

function SWEP:Holster( weapon )
	if ( CLIENT ) then return end

	self:StopIdle()
	
	return true
end

function SWEP:DoIdleAnimation()
	self:SendWeaponAnim( ACT_VM_IDLE )
end

function SWEP:DoIdle()
	self:DoIdleAnimation()

	timer.Adjust( "weapon_idle" .. self:EntIndex(), self:SequenceDuration(), 0, function()
		if ( !IsValid( self ) ) then timer.Destroy( "weapon_idle" .. self:EntIndex() ) return end

		self:DoIdleAnimation()
	end )
end

function SWEP:StopIdle()
	timer.Destroy( "weapon_idle" .. self:EntIndex() )
end

function SWEP:Idle()
	if ( CLIENT || !IsValid( self.Owner ) ) then return end
	timer.Create( "weapon_idle" .. self:EntIndex(), self:SequenceDuration() - 0.2, 1, function()
		if ( !IsValid( self ) ) then return end
		self:DoIdle()
	end )
end