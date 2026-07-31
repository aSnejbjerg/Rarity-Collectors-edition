local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if LE_EXPANSION_LEVEL_CURRENT > LE_EXPANSION_WRATH_OF_THE_LICH_KING then
	return {}
end

local classiceraMounts = {
	["Swift Zulian Tiger"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Swift Zulian Tiger"],
		spellId = 24252,
		itemId = 19902,
		npcs = { 14509 },
		chance = 200,
		coords = { { 0,0 } },
	},
	["Swift Razzashi Raptor"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Swift Razzashi Raptor"],
		spellId = 24242,
		itemId = 19872,
		npcs = { 11382 },
		chance = 200,
		coords = { { 0,0 } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.mounts, classiceraMounts)
return classiceraMounts
