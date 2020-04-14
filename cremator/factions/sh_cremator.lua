
FACTION.name = "Cremator"
FACTION.description = "--."
FACTION.color = Color(0, 150, 0)
FACTION.pay = 10
FACTION.models = {"models/cremator.mdl"}
FACTION.weapons = {"weapon_crem_immolator"} -- uncomment this if you using vfire
-- FACTION.weapons = {"weapon_bp_flamethrower_edited", "weapon_bp_immolator_edited"} -- uncomment, if you using hl2 beta weapons
FACTION.isDefault = false
FACTION.isGloballyRecognized = true
FACTION.runSounds = {[0] = "npc/cremator/foot1.wav", [1] = "npc/cremator/foot2.wav", [2] = "npc/cremator/foot3.wav"}


function FACTION:GetDefaultName(client)
	return "UU-CREMATOR." .. Schema:ZeroNumber(math.random(1, 99999), 5), true
end

function FACTION:OnTransfered(client)
	local character = client:GetCharacter()

	character:SetName(self:GetDefaultName())
	character:SetModel(self.models[1])
end

FACTION_CREMATOR = FACTION.index
