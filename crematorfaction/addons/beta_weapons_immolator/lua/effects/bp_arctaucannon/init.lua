function EFFECT:Init( data )
	self.EndPos = data:GetOrigin()
	self.Position = data:GetStart()
	self.Attachment = data:GetAttachment()
	self.WeaponEnt = data:GetEntity()
	local length = data:GetScale()
	local mag = data:GetMagnitude()

	self.StartPos = self:GetTracerShootPos( self.Position, self.WeaponEnt, self.Attachment )
	net.Start( "Taucannonlaser" )
	net.WriteEntity(LocalPlayer():GetActiveWeapon())
	net.WriteTable( {LocalPlayer(),self.StartPos,self.EndPos,mag}) 
	net.SendToServer()
	local asdf = EffectData()
	asdf:SetOrigin( self.EndPos )
	asdf:SetStart( self.StartPos )
	asdf:SetScale( length )	
	asdf:SetMagnitude(mag)
	util.Effect( "GaussTracer", asdf )
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render( )

end



