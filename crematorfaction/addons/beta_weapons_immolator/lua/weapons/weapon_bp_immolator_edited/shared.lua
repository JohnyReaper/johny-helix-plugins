if SERVER then

	AddCSLuaFile( "shared.lua" )

	SWEP.HoldType        			= "smg"
end

if CLIENT then

language.Add("weapon_immolator", "Immolator")

SWEP.Category 		= "HL2 Cremator Sweps"
SWEP.PrintName = "Immolator (Beam) EDITED"
SWEP.Slot = 5
SWEP.SlotPos = 6
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true
SWEP.ViewModelFOV = 58
SWEP.ViewModelFlip = false
SWEP.DrawWeaponInfoBox	= false
SWEP.WepSelectIcon = surface.GetTextureID("HUD/swepicons/weapon_immolator") 
SWEP.BounceWeaponIcon = false 

end

// Code by CrazyBubba64
// Modifications by BattlePope
------------------------------ Only admin can spawn / everyone can spawn -------------------
SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true
-----------------------------------------------------------------------------------------------------------

-----------------------------------------------------------------------------------------------------------
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
-----------------------------------------------------------------------------------------------------------

game.AddAmmoType( { name = "bp_immolator" } )
if ( CLIENT ) then language.Add( "bp_immolator_ammo", "Plasma" ) end

-----------------------------------------------------------------------------------------------------------

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo		= "none"
SWEP.Primary.Damage		= 1
SWEP.Primary.Recoil		= 0
SWEP.Secondary.Ammo		= "none"
-----------------------------------------------------------------------------------------------------------


-----------------------------------------------About model----------------------------------------------------------------
SWEP.ViewModel				= "models/weapons/v_cremato2.mdl"
SWEP.WorldModel				= ""
SWEP.HoldType        			= "smg"
---------------------------------------------------------------------------------------------------------------------------------

SWEP.Sound = Sound ("weapons/1immolator/plasma_shoot.wav")

SWEP.Volume = 7
SWEP.Influence = 0

SWEP.LastSoundRelease = 0
SWEP.RestartDelay = 0
SWEP.RandomEffectsDelay = 0.2

function SWEP:Initialize()
		self:SetWeaponHoldType(self.HoldType)
	end
function SWEP:Precache()
end

function SWEP:PrimaryAttack()
	if self:IsUnderWater() then return end
	-- if (!SERVER) then return end
	-- if ( self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0 ) then

    local tr, vm, muzzle, attach//, effectdata
    
    
    
    tr = { }
    
    tr.start = self.Owner:GetShootPos( )
    tr.filter = self.Owner
    tr.endpos = tr.start + self.Owner:GetAimVector( ) * 4096
    tr.mins = Vector( ) * -2
    tr.maxs = Vector( ) * 2
    
    tr = util.TraceHull( tr )
	
	local tr, vm, muzzle, attach//, effectdata
	vm = self.Owner:GetViewModel()
	local trace = self.Owner:GetEyeTrace()
	local hit = trace.HitPos
	attach = self.Owner:LookupAttachment("muzzle")
	-- print(self.Owner:LookupAttachment("muzzle"))
	vstr = tostring(self.Weapon)
	local MuzzlePos = self.Owner:GetShootPos() + (self.Owner:GetRight() * 8) + (self.Owner:GetUp() * -24) + (self.Owner:GetForward() * 40)
	self:lase(vstr, attach, MuzzlePos, hit, 1)
	self:lase(vstr, attach, MuzzlePos, hit, 0)
	self.Owner:ViewPunch( Angle( math.random(-.01, .01), math.random(-.01, .01), math.random(-.01, .01) ) )
	-- self:TakePrimaryAmmo( 1 )
	self:ShootEffects()
 
 -- else
 -- self:EndSound()
	-- end
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:Think()
	if SERVER then

		self.LastFrame = self.LastFrame or CurTime()
		self.LastRandomEffects = self.LastRandomEffects or 0		
		if self.Owner:KeyDown (IN_ATTACK) and self.LastSoundRelease + self.RestartDelay < CurTime() then
			if not self.SoundObject then
				self:CreateSound()

			end
			self.SoundObject:PlayEx(5, 100)
			
			self.Volume = math.Clamp (self.Volume + CurTime() - self.LastFrame, 0, 2)
			self.Influence = math.Clamp (self.Influence + (CurTime() - self.LastFrame) / 2, 0, 1)
			
			self.SoundPlaying = true

		else
		
			if self.SoundObject and self.SoundPlaying then

				self.SoundObject:FadeOut (0.8)			
				self.SoundPlaying = false
				self.LastSoundRelease = CurTime()
				self.Volume = 0
				self.Influence = 0
				self:Idle()	
			end

		end
		self:MovingEffect()
		if not self.Owner:Alive() then
		self:EndSound()
		end
		self.LastFrame = CurTime()
		self.Weapon:SetNWBool ("on", self.SoundPlaying)
			end
		end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim(ACT_VM_DRAW);
	self:SetNextPrimaryFire( CurTime() + self:SequenceDuration())
	self:SetNextSecondaryFire( CurTime() + self:SequenceDuration())
	self:NextThink( CurTime() + self:SequenceDuration() )
	self:Idle()
   return true
end

function SWEP:MovingEffect()
	local runSpeed = ix.config.Get("runSpeed")
	local walkSpeed = ix.config.Get("walkSpeed")

	if self.Owner:KeyDown (IN_ATTACK) and self.Owner:Alive() then
		self.Owner:SetWalkSpeed(6)
		self.Owner:SetRunSpeed(6)
	else
		self.Owner:SetWalkSpeed(walkSpeed)
		self.Owner:SetRunSpeed(runSpeed)
	end

end	

function SWEP:ShootEffects()
self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self.Owner:MuzzleFlash()	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
end

function SWEP:IsUnderWater()
	if self:WaterLevel() < 3 then
		return false
	else
		if SERVER then
			--local pos = self:GetPos()+Vector(0,0,50)
			local pos = (self.Owner:GetShootPos() + self.Owner:GetAimVector()*40)-Vector(0,0,25)
			tes = ents.Create( "point_tesla" )
			tes:SetPos( pos )
			tes:SetKeyValue( "m_SoundName", "DoSpark" )
			tes:SetKeyValue( "texture", "sprites/laserbeam.spr" )
			tes:SetKeyValue( "m_Color", "255 180 180" )
			tes:SetKeyValue("rendercolor", "255 180 180")
			tes:SetKeyValue( "m_flRadius", "100" )
			tes:SetKeyValue( "beamcount_max", "10" )
			tes:SetKeyValue( "thick_min", "5" )
			tes:SetKeyValue( "thick_max", "10" )
			tes:SetKeyValue( "lifetime_min", "0.1" )
			tes:SetKeyValue( "lifetime_max", "0.3" )
			tes:SetKeyValue( "interval_min", "0.1" )
			tes:SetKeyValue( "interval_max", "0.2" )
			tes:Spawn()
			tes:Fire( "DoSpark", "", 0 )
			tes:Fire( "DoSpark", "", 0.1 )
			tes:Fire( "DoSpark", "", 0.2 )
			tes:Fire( "DoSpark", "", 0.3 )
			tes:Fire( "kill", "", 0.3 )
			local hitdie = ents.Create("point_hurt"); --This is what kills stuff
			hitdie:SetKeyValue("Damage",100)
			hitdie:SetKeyValue("DamageRadius",100)
			hitdie:SetKeyValue("DamageType","SHOCK")
			hitdie:SetParent( self.Owner )
			hitdie:SetPos( pos )
			hitdie:Spawn();
			hitdie:Fire("hurt","",0.1); -- ACTIVATE THE POINT_HURT
			hitdie:Fire("kill","",1.2);
		end
		self:EmitSound("ambient/energy/weld"..math.random(1,2)..".wav")
		self:EmitSound("weapons/gauss/electro"..math.random(1,3)..".wav")
		self:SetNextPrimaryFire(CurTime()+0.8)
		self:SetNextSecondaryFire(CurTime()+0.8)
		return true
	end
end

function SWEP:lase(par, stat, from, to, noise)
	if SERVER then
	 
	entItem = ents.Create ("info_target")
	realName = "entItem"..tostring(self.Owner:GetName())
		entItem:SetKeyValue("targetname", realName)
	entItem:Spawn()
	beam = ents.Create("env_laser")
		beam:SetKeyValue("renderamt", "255")
		beam:SetKeyValue("rendercolor", "0 255 0")
		beam:SetKeyValue("texture", "sprites/laserbeam.spr")
		beam:SetKeyValue("TextureScroll", "14")
		beam:SetKeyValue("targetname", "beam" )
		beam:SetKeyValue("renderfx", "2")
		beam:SetKeyValue("width", "1")
		beam:SetKeyValue("dissolvetype", "-1")
		beam:SetKeyValue("EndSprite", "")
		beam:SetKeyValue("LaserTarget", realName)//"entItem")
		beam:SetKeyValue("TouchType", "2")
		beam:SetKeyValue("NoiseAmplitude", noise)
	beam:Spawn()
	tent = ents.Create("point_tesla")
	tent:SetKeyValue("texture","sprites/laserbeam.spr")
	tent:SetKeyValue("m_Color","0 255 0 255")
	tent:SetKeyValue("m_flRadius","150")
	tent:SetKeyValue("beamcount_min","20")
	tent:SetKeyValue("beamcount_max","50")
	tent:SetKeyValue("lifetime_min","0.05")
	tent:SetKeyValue("lifetime_max","0.06")
	tent:SetKeyValue("interval_min","0.1")
	tent:SetKeyValue("interval_max","0.35")
	tent:SetPos(to)
	tent:Spawn()
	tent:Activate()
	tent:Fire("TurnOn","",0)
	aoe = ents.Create("env_beam")
		aoe:SetKeyValue("renderamt", "255")
		aoe:SetKeyValue("rendercolor", "0 255 0")
		aoe:SetKeyValue("life", "0")
		aoe:SetKeyValue("radius", "32")
		aoe:SetKeyValue("LightningStart", "entItem")
		aoe:SetKeyValue("StrikeTime", "0.05")
		aoe:SetKeyValue("damage", "12")
		aoe:SetKeyValue("NoiseAmplitude", "7")
		aoe:SetKeyValue("texture", "sprites/laserbeam.spr")
		aoe:SetKeyValue("dissolvetype", "2")
	aoe:Fire("TurnOn", "", 0.01)
	aoe:SetPos(to)
	aoe:Fire("kill", "", 0.11)
	beam:Fire("TurnOn", "", 0.01)
	beam:Fire("kill", "", 0.11)
	entItem:Fire("kill", "", 0.11)
	tent:Fire("Kill","",0.11)
	entItem:SetPos(to)
	beam:SetPos(from)
	end
end

function SWEP:CreateSound ()
	self.SoundObject = CreateSound (self.Weapon, self.Sound)
	self.SoundObject:Play()
end

function SWEP:Holster() self:EndSound() return true end
function SWEP:OwnerChanged() self:EndSound() end

function SWEP:EndSound ()
	if self.SoundObject then
		self.SoundObject:Stop()
	end
end

function SWEP:OnRemove()
	self:EndSound()
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