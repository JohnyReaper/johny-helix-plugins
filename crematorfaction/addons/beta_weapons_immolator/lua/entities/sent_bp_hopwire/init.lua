AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Activate1( )
	if self.Used then return false end

	self.Entity:GetPhysicsObject():ApplyForceCenter( Vector(0,0,1) * 800 );

	table.insert(self.TraceIgnoreEnts, self.Entity)
	//table.insert(self.TraceIgnoreEnts, self.Entity:GetOwner( ))

	util.PrecacheSound( "buttons/combine_button3.wav" )
	self.Entity:EmitSound("buttons/combine_button3.wav", 100, 100)

	timer.Create( "jump_timer"..tostring(self.Entity), 0.5, 1, function() self:MakeRope2() end )
	//timer.Simple( 0.5, self.MakeRope, self )

	self.Entity:SetNetworkedBool( "Active", true )
	self.Used = true
end

function ENT:TryActivate( )

	local vectmp = self.Entity:GetPhysicsObject( ):GetVelocity( )
	if (vectmp.z > -100) then
		self:Activate1( )
	else
		self.TryActivating = true
	end

end

function ENT:Freeze( )

	self.Entity:SetMoveType( MOVETYPE_NONE )

end

function ENT:MakeRope2( )

	timer.Create( "rope_timer"..tostring(self.Entity), 0.1, self.NumRopes, function() self:MakeRope() end )
	timer.Create( "rope_timer2"..tostring(self.Entity), 0.1 * self.NumRopes + 0.1, 1, function() self:Freeze() end )

end

function ENT:MakeRope( )
	self.RopeCalls = 1

	if self.RopeCalls > self.NumRopes + self.RopeCallOverflow then
		self:Explode( )
		return
	end

	local trace = {}
	trace.start = self.Entity:GetPos( )
	trace.endpos = trace.start + (Vector( math.random(-10000,10000)/10000, math.random(-10000,10000)/10000, math.random(-10000,10000)/10000 ) * 256)
	trace.filter = self.TraceIgnoreEnts
	local traceRes = util.TraceLine(trace)

	//Msg("start: "..tostring(trace.start).."\n")
	//Msg("end: "..tostring(trace.endpos).."\n")
	//Msg("hit: "..tostring(traceRes.HitPos).."\n")
	//Msg("\n")

	//some protection stuff
	if traceRes.HitNonWorld || traceRes.HitSky || traceRes.HitNoDraw then
		if traceRes.Entity:IsValid( ) then
			if traceRes.Entity:GetClass( ) == "hopwire" then
				table.insert(self.TraceIgnoreEnts, traceRes.Entity)
				self.RopeCalls = self.RopeCalls - 1
			end
		end
		self:MakeRope( )
		return
	elseif !traceRes.Hit then
		self.RopeCalls = self.RopeCalls - 1
		self:MakeRope( )
		return
	end

	//the hit object
	local ent1 = traceRes.Entity
	local bone1 = traceRes.PhysicsBone
	local pos1 = traceRes.HitPos

	//self
	local ent2 = self.Entity
	local bone2 = 0
	local pos2 = self.Entity:GetPos()

	local PropDiameter = 3
	local Distance = ( pos1-pos2 ):Length()
	local Subtract = 5

	if Distance - PropDiameter < Subtract then //spaz-out fix
		Subtract = Distance - PropDiameter
	end

	//local newLength = Distance-Subtract

	//local constraint, rope = constraint.Elastic( ent1, ent2, bone1, bone2, pos1, pos2:GetNormal(), 12000, 0, 0, "cable/physbeam", 3, false )
	//constraint:Fire("SetSpringLength", newLength, 0)
	//if (rope) then rope:Fire("SetLength", 1, 0) end

	local constraint, rope = constraint.Rope( ent1, ent2, bone1, bone2, pos1, pos2:GetNormal(), Distance, -Subtract, 0, 3, "cable/physbeam", true )

	self.Entity:EmitSound("items/flashlight1.wav", 100, 100)

	self.RopeCount = self.RopeCount + 1

	self.RopePositions[self.RopeCount] = pos1
end

function ENT:CheckRope( )
	for i=1, self.RopeCount do
		local trace = {}
		trace.start = self.Entity:GetPos( )
		trace.endpos = self.RopePositions[i]
		trace.filter = self.TraceIgnoreEnts
		local traceRes = util.TraceLine(trace)

		if traceRes.HitNonWorld then
			if traceRes.Entity:GetClass( ) == "hopwire" then
				table.insert(self.TraceIgnoreEnts, traceRes.Entity)
				return
			end
			self:Explode( )
			return
		end
	end
end

function ENT:KillTimers( )

	if timer.Exists("kill_timer"..tostring(self.Entity)) then
		timer.Remove("kill_timer"..tostring(self.Entity))
	end

	if timer.Exists("kill_timer2"..tostring(self.Entity)) then
		timer.Remove("kill_timer2"..tostring(self.Entity))
	end

	if timer.Exists("activate_timer"..tostring(self.Entity)) then
		timer.Remove("activate_timer"..tostring(self.Entity))
	end

	if timer.Exists("activate_timer2"..tostring(self.Entity)) then
		timer.Remove("activate_timer2"..tostring(self.Entity))
	end

	if timer.Exists("jump_timer"..tostring(self.Entity)) then
		timer.Remove("jump_timer"..tostring(self.Entity))
	end

	if timer.Exists("rope_timer"..tostring(self.Entity)) then
		timer.Remove("rope_timer"..tostring(self.Entity))
	end

	if timer.Exists("rope_timer2"..tostring(self.Entity)) then
		timer.Remove("rope_timer2"..tostring(self.Entity))
	end

	if timer.Exists("hurt_timer"..tostring(self.Entity)) then
		timer.Remove("hurt_timer"..tostring(self.Entity))
	end

end

function ENT:Explode( )

	self:KillTimers( )

	local ent = ents.Create( "env_explosion" )
	ent:SetPos( self.Entity:GetPos( ) )
	ent:Spawn()
	ent:Activate()
	ent:SetKeyValue("iMagnitude", 110);
	ent:SetKeyValue("iRadiusOverride", 400)
	self.Dead = true//bug fix maby?
	ent:Fire("explode", "", 0)
	self.Entity:Remove()

end

function ENT:OnRemove( )

	self:KillTimers( )

end

function ENT:Think( )
	if self.Used then
		self:CheckRope( )
	else
		if self.TryActivating then
			local vectmp = self.Entity:GetPhysicsObject( ):GetVelocity( )
			if vectmp.z > -100 then
				timer.Create( "activate_timer2"..tostring(self.Entity), 1, 1, function() self:Activate1() end )
				self.TryActivating = false
			end
		end
	end
end

function ENT:OnTakeDamage( dmg )
	if !self.Dead && !dmg:IsFallDamage() then
		self.Dead = true
		timer.Create( "hurt_timer"..tostring(self.Entity), ( math.random(25) / 100 ), 1, function() self:Explode() end )
		//timer.Simple( 0.15, self.Explode, self )
	end
end

function ENT:Initialize()

	//self.Entity:SetModel( "models/dav0r/hoverball.mdl" )
	//self.Entity:SetModel( "models/props_junk/watermelon01.mdl" )
	self.Entity:SetModel( "models/weapons/w_hopwire.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end

	self.Used = false
	self.Dead = false
	self.NumRopes = 7
	self.RopeCount = 0
	self.RopeCalls = 0
	self.RopeCallOverflow = 20
	self.RopePositions = { }
	self.TraceIgnoreEnts = { }
	self.TryActivating = false

	self.Entity:SetNetworkedBool( "Active", false )

	timer.Create( "activate_timer"..tostring(self.Entity), 1.75, 1, function() self:TryActivate() end )

end
