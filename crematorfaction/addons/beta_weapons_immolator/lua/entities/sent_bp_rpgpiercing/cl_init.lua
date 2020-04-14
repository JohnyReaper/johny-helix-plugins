ENT.Spawnable			= false
ENT.AdminSpawnable		= false

include( "shared.lua" )


function ENT:Think()
	local effectdata = EffectData() 
 		effectdata:SetOrigin( self.Entity:LocalToWorld( Vector(0,0,self.Entity:OBBMins().z) ) ) 
 		effectdata:SetAngles( Angle(self.Entity:GetForward()) ) 
 		effectdata:SetScale( .5 ) 
 	util.Effect( "MuzzleEffect", effectdata ) 

self.SmokeTimer = self.SmokeTimer or 0
	if ( self.SmokeTimer > CurTime() ) then return end
	
	self.SmokeTimer = CurTime() + 0.005

	local vOffset = self.Entity:LocalToWorld( Vector(0,0,self.Entity:OBBMins().z) )

	local vNormal = (vOffset - self.Entity:GetPos()):GetNormalized()

	local emitter = ParticleEmitter( vOffset )
	
		local particle = emitter:Add( "particles/smokey", vOffset )
			particle:SetVelocity( vNormal * math.Rand( 10, 20 ) )
			particle:SetDieTime( 1.0 )
			particle:SetStartAlpha( math.Rand( 100, 150 ) )
			particle:SetStartSize( math.Rand( 5, 10 ) )
			particle:SetEndSize( math.Rand( 20, 50 ) )
			particle:SetRoll( math.Rand( -0.2, 0.2 ) )
			particle:SetColor( 160, 160, 160 )
				
	emitter:Finish()
	
end
