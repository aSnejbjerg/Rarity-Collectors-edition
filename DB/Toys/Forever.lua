local addonName, addonTable = ...

if WOW_PROJECT_ID == WOW_PROJECT_MAINLINE
	or WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
	or WOW_PROJECT_ID == WOW_PROJECT_MISTS_CLASSIC
	or WOW_PROJECT_ID == WOW_PROJECT_BURNING_CRUSADE_CLASSIC
then
	return {}
end

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

local foreverToys = {
	["Piccolo of the Flaming Fire"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.ITEM,
		isToy = true,
		method = CONSTANTS.DETECTION_METHODS.ENCOUNTER,
		encounters = {
			473, -- Hearthsinger Forresten
		},
		name = L["Piccolo of the Flaming Fire"],
		itemId = 13379,
		npcs = { 10558 },
		chance = 4,
		coords = { { m = 317, i = true } },
	},
	["Orb of Deception"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.ITEM,
		isToy = true,
		method = CONSTANTS.DETECTION_METHODS.ZONE,
		name = L["Orb of Deception"],
		itemId = 1973,
		chance = 10000,
		zones = { "25" },
		sourceText = L["Can drop from any Lvl 58+ Enemy. Cannot be tracked by Rarity inside instances."],
		coords = {
			{ m = 1423 },
			{ m = 1452 },
			{ m = 1451 },
		},
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.toys, foreverToys)
return foreverToys
