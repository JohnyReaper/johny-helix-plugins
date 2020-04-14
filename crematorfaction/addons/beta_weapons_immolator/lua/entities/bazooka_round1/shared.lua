ENT.Type = "anim"
ENT.Base = "base_gmodentity"
  
ENT.PrintName = "Bazooka Round"
ENT.Author = "ZeroPoint"
ENT.Contact = "limemaverick@bellsouth.net"
ENT.Purpose = "Pounding the crap out of some poor bastard"
ENT.Instructions = "SENT of Mystery" 
 
ENT.Spawnable = false
ENT.AdminSpawnable = false


function ENT:OnRemove()
	self.Entity:StopSound("Missile.Ignite")
end


	