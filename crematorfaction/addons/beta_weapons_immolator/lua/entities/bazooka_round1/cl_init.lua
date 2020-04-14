include("shared.lua")

	function ENT:Initialize()
		self.SmokeTimer = CurTime() + 0.1 --keeps the smoke out of your face when firing
	end

	function ENT:Draw()
		self.Entity:DrawModel()
	end
	--Smoke effect, shamelessly stolen from dear Garry: 
	--   <_<   >_>   :D   XD   :P   >:D
	function ENT:Think() 
		self.SmokeTimer = self.SmokeTimer or 0 
		if ( self.SmokeTimer > CurTime() ) then return end 
		self.SmokeTimer = CurTime() + 0.005 
		local vOffset = self.Entity:LocalToWorld( vector_origin ) + Vector( math.Rand( -3, 3 ), math.Rand( -3, 3 ), math.Rand( -3, 3 ) ) 
		local vNormal = (vOffset - self.Entity:GetPos()):GetNormalized() 
		local emitter = self:GetEmitter( vOffset, false ) 
		local particle = emitter:Add( "particles/smokey", vOffset ) 
			particle:SetVelocity( vNormal * math.Rand( 5, 15 ) ) 
			particle:SetDieTime( 4.0 ) 
			particle:SetStartAlpha( math.Rand( 75, 200 ) ) 
			particle:SetStartSize( math.Rand( 20, 36 ) ) 
			particle:SetEndSize( math.Rand( 24, 48 ) ) 
			particle:SetRoll( math.Rand( -0.2, 0.2 ) ) 
			particle:SetColor( 200, 200, 210 ) 
	end 
	
	function ENT:GetEmitter( Pos, b3D ) 
		if ( self.Emitter ) then	 
			if ( self.EmitterIs3D == b3D && self.EmitterTime > CurTime() ) then 
				return self.Emitter 
			end 
		end 
		self.Emitter = ParticleEmitter( Pos, b3D ) 
		self.EmitterIs3D = b3D 
		self.EmitterTime = CurTime() + 2 
		return self.Emitter 
	end  