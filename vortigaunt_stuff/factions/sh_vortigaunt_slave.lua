
FACTION.name = "Enslaved Vortigaunt"
FACTION.description = "--."
FACTION.color = Color(0, 120, 0)
FACTION.models = {"models/vortigaunt_slave.mdl"}
FACTION.weapons = {"swep_vortigaunt_sweep"}
FACTION.isDefault = false
FACTION.isGloballyRecognized = false

function FACTION:OnTransfered(client)
	local character = client:GetCharacter()

	character:SetModel(self.models[1])
end

FACTION_ENSLAVEDVORTIGAUNT = FACTION.index
