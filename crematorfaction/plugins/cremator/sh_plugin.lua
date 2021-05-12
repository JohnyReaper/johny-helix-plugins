PLUGIN.name = "Cremator Faction"
PLUGIN.author = "JohnyReaper"
PLUGIN.description = "Adds playable Cremator faction."

-- Animations, yay!
ix.anim.cremator = {
	normal = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_RUN] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		attack = ACT_RANGE_ATTACK1_LOW,
	},
	smg = { -- hold type for immolator
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_RUN] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		attack = ACT_RANGE_ATTACK1_LOW,
	},
	physgun = { 
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_RUN] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		attack = ACT_RANGE_ATTACK1_LOW,
	},
	pistol = {
		[ACT_MP_STAND_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_CROUCH_IDLE] = {ACT_IDLE, ACT_IDLE},
		[ACT_MP_RUN] = {ACT_WALK, ACT_WALK},
		[ACT_MP_CROUCHWALK] = {ACT_WALK, ACT_WALK},
		[ACT_MP_WALK] = {ACT_WALK, ACT_WALK},
		attack = ACT_RANGE_ATTACK1_LOW,
	},
}

ix.anim.SetModelClass("models/cremator.mdl", "cremator")
ALWAYS_RAISED["weapon_crem_immolator"] = true
ALWAYS_RAISED["weapon_bp_flamethrower_edited"] = true
ALWAYS_RAISED["weapon_bp_immolator_edited"] = true

local CHAR = ix.meta.character

function CHAR:IsCremator()
	local faction = self:GetFaction()
	return faction == FACTION_CREMATOR
end


function PLUGIN:PlayerDeath(client)

	if client:GetModel() == "models/cremator.mdl" or client:GetCharacter():IsCremator() then
		client:StopSound("npc/cremator/amb_loop.wav")
	end
	
end

if SERVER then
	function PLUGIN:PlayerFootstep(client, position, foot, soundName, volume)

		if client:GetCharacter():IsCremator() then
		    local factionTable = ix.faction.Get(client:Team())

		    if (factionTable.walkSounds and (client:IsRunning())) then
		    	client:EmitSound(factionTable.walkSounds[foot])
		        return true
		    elseif (factionTable.walkSounds )then--and (!client:IsRunning())) then
		        client:EmitSound(factionTable.walkSounds[foot], 75, 100, 0.3, CHAN_AUTO )
		        return true
		    
		    end
		end
	end
end

function PLUGIN:GetPlayerPainSound(client)
	if (client:GetModel() == "models/cremator.mdl") or client:GetCharacter():IsCremator() then
		local PainCremator = {
			"npc/cremator/amb1.wav",
			"npc/cremator/amb2.wav",
			"npc/cremator/amb3.wav",
		}
		local crem_pain = table.Random(PainCremator)
		return crem_pain
	end
end

function PLUGIN:GetPlayerDeathSound(client)
	if (client:GetModel() == "models/cremator.mdl") or client:GetCharacter():IsCremator() then
		local crem_die = "npc/cremator/crem_die.wav"

		for k, v in ipairs(player.GetAll()) do
			if (v:IsCombine()) then
				v:EmitSound(crem_die)
			end
		end

		return crem_die
	end
end


function PLUGIN:PostPlayerLoadout(client) 

	if (client:GetCharacter():IsCremator()) then
		client:SetMaxHealth(150)
		client:SetHealth(150)
		client:SetArmor(150)

	end		

end

function PLUGIN:PlayerSpawn( client )

    if (client:GetModel() == "models/cremator.mdl") or client:GetCharacter():IsCremator() then
    client:EmitSound( "npc/cremator/amb_loop.wav", 70, 100, 0.6, CHAN_AUTO )
    else
	client:StopSound("npc/cremator/amb_loop.wav")

	end

end


function PLUGIN:PlayerUseDoor(client, door)
	if (client:GetCharacter():IsCremator()) then
		if (!door:HasSpawnFlags(256) and !door:HasSpawnFlags(1024)) then
			door:Fire("open")
		end
	end
end

