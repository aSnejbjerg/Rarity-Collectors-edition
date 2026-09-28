local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_WAR_WITHIN then
	return {}
end
local TheWarWithinManuscripts = {
	-- Nemesis Delve Manuscripts
	["Delver's Dirigible Schematic: Void"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.TWW,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.ENCOUNTER,
		encounter = {
			2985, 2987, -- Zekvir, not sure which one is "??" difficulty
		},
		name = L["Delver's Dirigible Schematic: Void"],
		itemId = 225542,
		npcs = { 221427 },
		questId = { 83308 },
		chance = 50,
		coords = { { m = CONSTANTS.UIMAPIDS.ZEKVIRS_LAIR, i = true } }, -- Add to sharedconstants, 2348
	},
	["Delver's Gob-Trotter Schematic: Gold"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.TWW,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.ENCOUNTER,
		encounter = {
			3126, 3138, -- The Underpin, not sure which one is "??" difficulty
		},
		name = L["Delver's Gob-Trotter Schematic: Gold"],
		itemId = 233196,
		npcs = { 236626 },
		questId = { 86296 },
		chance = 50,
		coords = { { m = CONSTANTS.UIMAPIDS.DEMOLITION_DOME, i = true } }, -- Add to sharedconstants, either 2425 or 2426
	},
	["Delver's Mana-Skimmer Schematic: Hyperdrive"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.TWW,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.ENCOUNTER,
		encounter = {
			3325, 3326, -- Nexus-Princess Kyveza, not sure which one is "??" difficulty
		},
		name = L["Delver's Mana-Skimmer Schematic: Hyperdrive"],
		itemId = 238182,
		npcs = { 244753 },
		questId = { 88819 },
		chance = 50,
		coords = { { m = CONSTANTS.UIMAPIDS.VOIDRAZOR_SANCTUARY, i = true } }, -- Add to sharedconstants, 2484
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.manuscripts, TheWarWithinManuscripts)
return TheWarWithinManuscripts
