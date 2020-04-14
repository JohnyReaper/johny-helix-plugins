 AddCSLuaFile("cl_init.lua")
 AddCSLuaFile("shared.lua")

 include("shared.lua")
  
  	function ENT:Initialize()
		util.PrecacheSound("weapons/stinger_flyloop1.wav")
		self.Entity:SetModel("models/ML_Grenade.mdl")
		self.Entity:SetMoveType(MOVETYPE_FLYGRAVITY)
		self.Entity:SetGravity(0.3)
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.ExpireTime = CurTime() + 3
		self.Entity:EmitSound("Missile.Ignite")
		return true
	end
	
	function ENT:Think()
	
		self.Entity:SetAngles( self.Entity:GetVelocity():Angle() )
		
		if self.ExpireTime and (CurTime() > self.ExpireTime) then
			--Msg("Expired!\n")
			self.Entity:SetGravity(2)
			self.ExpireTime = nil
		end
		
	end
	
	function cbt_conehcgexplode(position, direction, radius, coneang, damage, pierce) --deals hollow charge explosion damage within a cone
		local targets = ents.FindInSphere( position, radius)
		local ndir = direction:GetNormal() --Normal of direction
		local mindot = math.cos(math.rad(coneang*0.5)) --minimum dot-product, this is used to define the cone
		for _,i in pairs(targets) do
			local hitat = i:NearestPoint( position )
			local hitvec = (hitat - position):GetNormal()
			local dot = ndir:Dot(hitvec)
			if dot > mindot then
				--Msg("Dealing conical damage...\n")
				cbt_dealhcghit( i, damage, pierce, hitat, hitat)
			end
		end
	end
	
	function ENT:Touch(ent)
		if ent:GetPhysicsObject():IsValid() or ent:IsWorld() or ent:IsPlayer() or ent:IsNPC() then
			local pos = self.Entity:GetPos()
			local vn = self.Entity:GetVelocity():GetNormal()
			local fx = EffectData()
				fx:SetOrigin(pos)
			if ent:IsWorld() or ent:IsPlayer() or ent:IsNPC() then
				util.BlastDamage(self.Entity, self:GetOwner(), pos, 256, 50)
				util.Effect("Explosion", fx) --Explode weakly into the world, no GCOMBAT damage
			else
				local hit = cbt_dealhcghit(ent, 200, 10, pos, pos)
				if hit and (hit > 0) then
					cbt_conehcgexplode( pos+vn*12, vn, 96, 60, 200, 6 ) --If we've pierced the armor, then damage the underlying stuff with explosion-type damage
					util.BlastDamage(self.Entity, self:GetOwner(), pos, 384, 75)  --Explode strongly, do GCOMBAT damage as well
					util.Effect("explosion", fx)
					util.ScreenShake( pos, 7, 3, 1, 512 ) -- shakes the target on a direct hit
				else
					--Msg("Bazooka shell Deflected!\n")
					local gib = ents.Create("prop_physics_override")
						gib:SetModel("models/weapons/w_missile_launch.mdl")
						gib:SetPos(pos - vn)
						gib:SetAngles(self.Entity:GetAngles())
						gib:PhysicsInit(SOLID_VPHYSICS)
						gib:SetCollisionGroup(COLLISION_GROUP_WEAPON)
						gib:Spawn()
						gib:Activate()
						local gibphys = gib:GetPhysicsObject()
						if gibphys:IsValid() then
							gibphys:SetMass(50)
							gibphys:SetVelocity(vn*1800)
						end
						--Set a delete timer for the gib prop
						timer.Simple(3, 
						function() 
							if gib:IsValid() then gib:Remove() end
						end )
				end
			end
			--self.Entity:StopSound("weapons/rpg/rocket1.wav")	--handled in shared OnRemove
			self.Entity:Remove()
		end
	end