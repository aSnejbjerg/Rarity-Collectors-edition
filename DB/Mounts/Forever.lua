local addonName, addonTable = ...

if 
	WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
	or WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
	or WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
	or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
then
	return {}
end

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

local foreverMounts = {
	["Deathcharger's Reins"] = { -- TODO Get the correct MapID
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Deathcharger's Reins"],
		spellId = 17481,
		itemId = 13335,
		npcs = { 99999 },
		tooltipNpcs = { 45412 },
		chance = 100,
		statisticId = { 1097 },
		bonusSatchel = true,
		blackMarket = true,
		coords = { { m = 317, x = 38.6, y = 20, i = true } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.mounts, foreverMounts)
return foreverMounts
