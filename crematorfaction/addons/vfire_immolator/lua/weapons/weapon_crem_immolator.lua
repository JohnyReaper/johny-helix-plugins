
AddCSLuaFile()
AddCSLuaFile("effects/vfirethrower_jet.lua")
AddCSLuaFile("effects/vfirethrower_jet2.lua")

if SERVER then
	resource.AddWorkshop("1525572545")
end

SWEP.PrintName = "vFire Immolator"
SWEP.Purpose = "To set things on fire!"
SWEP.Category = "HL2 Cremator Sweps"
SWEP.Instructions = "Shoot fire to burn things!"

SWEP.Slot = 5
SWEP.SlotPos = 35
SWEP.Weight = 1

SWEP.DrawAmmo = false

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true

SWEP.DrawWeaponInfoBox = false
SWEP.Spawnable = true

SWEP.ViewModel = "Models/weapons/v_cremato2.mdl"
SWEP.ViewModelFOV = 55
SWEP.WorldModel = ""
SWEP.HoldType = "smg"

SWEP.m_WeaponDeploySpeed = 2


-- Default values are for single player
SWEP.ShootInterval = 0.03
SWEP.ShootLife = 2
SWEP.ShootFeed = 0.5

-- Decrease load on the server by increasing shoot interval and increasing size to make up for it
if !game.SinglePlayer() then
	SWEP.ShootInterval = 0.07
	SWEP.ShootLife = 2.15
	SWEP.ShootFeed = 1
end


SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Shooting")
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)
	if SERVER then
		self:SetShooting(false)
	end

	if CLIENT then
		self.a = 0
	end
end

function SWEP:Equip()
end

function SWEP:EquipAmmo(ply)
end

function SWEP:Deploy()
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())

	self:EmitSound("weapons/vfirethrower/deploy.wav", 80, math.random(80, 120))
	
	return true
end

-- We don't have a model attachment :( so we're using this function to retreive the approximated shoot position
-- for every view case
function SWEP:GetShootPosition()
	local pos
	local ang

	if CLIENT then -- We're drawing the view model
		if LocalPlayer() == self:GetOwner() and GetViewEntity() == LocalPlayer() then

			local vm = LocalPlayer():GetViewModel()
			pos, ang = vm:GetBonePosition(0)
			pos = pos
				+ ang:Forward() * -3 -- Left
				+ ang:Right() * 10 -- Down
				+ ang:Up() * 20 -- Forward

		else -- We're drawing the world model

			local ply = self:GetOwner()
			
			if !self.flameThrowerHand then
				self.flameThrowerHand = ply:LookupAttachment("muzzle")
			end

			local handData = ply:GetAttachment(self.flameThrowerHand)

			ang = handData.Ang
			pos = handData.Pos
				+ ang:Forward()
				+ ang:Right()
				+ ang:Up()
		end
	end

	if SERVER then -- Mainly used for positioning our fire balls

		pos = self:GetOwner():GetShootPos()
		ang = self:GetOwner():EyeAngles()
		pos = pos
			+ ang:Forward() * 1
			+ ang:Right() * 8
			+ ang:Up() * -20

	end

	return pos
end

function SWEP:ShootFire()

	if !self:GetShooting() then

		self:SetShooting(true)

		local effectdata = EffectData()
		effectdata:SetEntity(self)
		util.Effect("vfirethrower_jet2", effectdata, true, true)

	end

	if SERVER then

		local life = math.Rand(4, 8) * self.ShootLife
		local owner = self:GetOwner()

		-- Determine how far forward we should spawn the fireball (we wish to extend it by default for animation purposes)
		local forwardBoost = math.Rand(30, 60)
		local frac = owner:GetEyeTrace().Fraction
		-- We're looking into an obstacle, spawn the fireball exactly on the barrel
		if frac < 0.001245 then
			forwardBoost = 1
		end

		local forward = self:GetOwner():EyeAngles():Forward()
		local pos = self:GetShootPosition() + forward * forwardBoost
		local vel = forward * math.Rand(900, 1000)
		local feedCarry = math.Rand(3, 8) * self.ShootFeed
		CreateVFireBall(life, feedCarry, pos, vel, owner)
	end

end

function SWEP:PrimaryAttack()

	if self:GetNextPrimaryFire() > CurTime() then return end

	if IsFirstTimePredicted() then

		self:ShootFire()
		-- self.Owner:SetAnimation( PLAYER_ATTACK1 )
		
		if SERVER then

			if (self.Owner:KeyPressed(IN_ATTACK) || !self.Sound) then
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)

				self.Sound = CreateSound(self.Owner, Sound("weapons/vfirethrower/fire.wav"))
			end

			if (self.Sound) then self.Sound:PlayEx(1, math.random(80, 110)) end

		end
	end
	
	self:SetNextPrimaryFire(CurTime() + self.ShootInterval)
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

function SWEP:PlayCloseSound()
	self:EmitSound("weapons/vfirethrower/close.wav", 80, math.random(90, 110))
end

function SWEP:Think()

	if CLIENT then
		local target = 0
		if self:GetShooting() then
			target = 2
		end
		self.a = Lerp(FrameTime() * 3, self.a, target)
		return
	end

	if self:GetNextSecondaryFire() > CurTime() then return end

	if (self.Owner:KeyReleased(IN_ATTACK) || (!self.Owner:KeyDown(IN_ATTACK) && self.Sound)) then
	
		self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)

		if (self.Sound) then
			self.Sound:Stop()
			self.Sound = nil
			self:PlayCloseSound()
			if (!game.SinglePlayer()) then self:CallOnClient("PlayCloseSound", "") end
		end

		self:SetShooting(false)

		self:SetNextPrimaryFire(CurTime() + self:SequenceDuration())
		self:SetNextSecondaryFire(CurTime() + self:SequenceDuration())

	end
end

function SWEP:Holster(weapon)
	if (CLIENT) then return end

	if (self.Sound) then
		self.Sound:Stop()
		self.Sound = nil
	end

	self:EmitSound("weapons/vfirethrower/undeploy.wav", 80, math.random(90, 110))
	
	return true
end


if (SERVER) then return end

SWEP.WepSelectIcon = Material("vfirethrower_icon.png")

function SWEP:GetViewModelPosition(pos, ang)
	pos = pos
		+ ang:Forward()
		+ ang:Right()
		+ ang:Up()

	ang:RotateAroundAxis(ang:Right(), self.a)

	return pos, ang
end

function SWEP:DrawWorldModel()
	
	local ply = self:GetOwner()

	if !IsValid(ply) then
		-- No one is holding the weapon, draw it regularly and bail
		self:DrawModel()
		return
	end

	if !self.flameThrowerHand then
		self.flameThrowerHand = ply:LookupAttachment("anim_attachment_rh")
	end

	local handData = ply:GetAttachment(self.flameThrowerHand)

	if !handData then
		-- We don't have our data for some reason, draw and bail
		self:DrawModel()
		return
	else
		-- We have our data, proceed as normal
		local ang = handData.Ang
		local pos = handData.Pos
			+ ang:Forward() * 11
			+ ang:Right() * 0.3
			+ ang:Up() * -7

		self:SetRenderOrigin(pos)
		self:SetRenderAngles(ang)
		self:DrawModel()
	end
end

function SWEP:DrawWeaponSelection(x, y, w, h, a)
	surface.SetDrawColor(255, 255, 255, a)
	surface.SetMaterial(self.WepSelectIcon)
	
	local size = math.min(w, h) - 32
	surface.DrawTexturedRect(x + w / 2 - size / 2, y + h * 0.05, size, size)
end
