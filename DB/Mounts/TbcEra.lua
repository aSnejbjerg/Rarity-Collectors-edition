local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if LE_EXPANSION_BURNING_CRUSADE > LE_EXPANSION_WRATH_OF_THE_LICH_KING then
	return {}
end

local tbceraMounts = {
	["Amani War Bear"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.TBC,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Amani War Bear"],
		spellId = 43688,
		itemId = 33809,
		items = { 186672 },
		chance = 10,
		coords = { { 0, 0 } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.mounts, tbceraMounts)
return tbceraMounts
