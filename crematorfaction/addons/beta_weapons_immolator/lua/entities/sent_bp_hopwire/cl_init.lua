ENT.RenderGroup 	= RENDERGROUP_BOTH

include('shared.lua')

function ENT:Initialize()

	self.Refraction = Material( "sprites/heatwave" )
	self.Glow = Material( "sprites/light_glow02_add" )

end

function ENT:Draw()

	self.BaseClass.Draw( self )

end

function ENT:DrawTranslucent()

	if self.Entity:GetNetworkedBool( "Active" ) then

	local vOffset = self.Entity:GetPos()
	local vPlayerEyes = LocalPlayer():EyePos()
	local vDiff = (vOffset - vPlayerEyes):GetNormalized()

	render.SetMaterial( self.Glow )	
	local color = Color( 70, 180, 255, 255 )
	render.DrawSprite( vOffset - vDiff * 2, 22, 22, color )

	render.DrawSprite( vOffset + vDiff * 4, 24, 24, color )
	render.DrawSprite( vOffset + vDiff * 4, 26, 26, color )

	end
end

function ENT:Think()
end
