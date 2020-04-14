

function EFFECT:Init(data)
	
	self.WeaponEnt = data:GetEntity()
	self.Attachment = data:GetAttachment()
	
	self.Position = self:GetTracerShootPos(data:GetOrigin(), self.WeaponEnt, self.Attachment)
	self.Forward = data:GetNormal()
	self.Angle = self.Forward:Angle()
	self.Right = self.Angle:Right()
	
	local AddVel = self.WeaponEnt:GetOwner():GetVelocity()
	
	local emitter = ParticleEmitter(self.Position)
		

	for i=1,3 do 
		local particle = emitter:Add("particle/particle_smokegrenade", self.Position)
		particle:SetVelocity(50*i*self.Forward + 8*VectorRand() + AddVel)
		particle:SetDieTime(math.Rand(1.5,2))
		particle:SetStartAlpha(math.Rand(70,90))
		particle:SetStartSize(math.random(2,3)*i)
		particle:SetEndSize(math.Rand(7,10)*i)
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(200,200,200)
		particle:SetAirResistance(140)
	end
	
	for i=1,10 do 
		local ang = self.Right:Angle()
		ang:RotateAroundAxis(self.Forward, math.Rand(0,360))
		ang = ang:Forward()
		local particle = emitter:Add("particle/particle_smokegrenade", self.Position + ang*3)
		particle:SetVelocity(math.Rand(25,40)*ang + 4*VectorRand() + AddVel)
		particle:SetDieTime(math.Rand(1.5,2))
		particle:SetStartAlpha(math.Rand(60,80))
		particle:SetStartSize(math.random(2,3))
		particle:SetEndSize(math.Rand(15,20))
		particle:SetRoll(math.Rand(180,480))
		particle:SetRollDelta(math.Rand(-1,1))
		particle:SetColor(200,200,200)
		particle:SetAirResistance(140)
	end

	emitter:Finish()

end


function EFFECT:Think()

	return false
	
end


function EFFECT:Render()

	
end



