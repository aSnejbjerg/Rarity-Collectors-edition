local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_MISTS_OF_PANDARIA or WOW_PROJECT_ID == WOW_PROJECT_MAINLINE  then
	return {}
end

local moperaMounts = {
	-- MoP Classic Exclusives
	["Reins of the Celestial Riding Crane"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 200,
		name = L["Reins of the Celestial Riding Crane"],
		itemId = 248741,
		items = { 248666, 276086 },
		spellId = 1247591,
		coords = { { 0, 0 } },
	},
	["Reins of the Black Riding Yak"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the Black Riding Yak"],
		itemId = 87786,
		items = { 248666, 276086 },
		spellId = 127209,
		coords = { { 0, 0 } },
	},
	["Reins of the Brown Riding Yak"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the Brown Riding Yak"],
		itemId = 87787,
		items = { 248666, 276086 },
		spellId = 127213,
		coords = { { 0, 0 } },
	},
	["Reins of the White Riding Yak"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the White Riding Yak"],
		itemId = 84753,
		items = { 248666, 276086 },
		spellId = 123182,
		coords = { { 0, 0 } },
	},
	["Reins of the Orange Water Strider"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the Orange Water Strider"],
		itemId = 87792,
		items = { 248666, 276086 },
		spellId = 127272,
		coords = { { 0, 0 } },
	},
	["Reins of the Golden Water Strider"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the Golden Water Strider"],
		itemId = 87794,
		items = { 248666, 276086 },
		spellId = 127278,
		coords = { { 0, 0 } },
	},
	["Reins of the Jade Water Strider"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the Jade Water Strider"],
		itemId = 87793,
		items = { 248666, 276086 },
		spellId = 127274,
		coords = { { 0, 0 } },
	},
	["Reins of the Crimson Water Strider"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the Crimson Water Strider"],
		itemId = 87791,
		items = { 248666, 276086 },
		spellId = 127271,
		coords = { { 0, 0 } },
	},
	["Reins of the Jungle Riding Crane"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MOP,
		type = CONSTANTS.ITEM_TYPES.MOUNT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		name = L["Reins of the Jungle Riding Crane"],
		itemId = 87784,
		items = { 248666, 276086 },
		spellId = 127178,
		coords = { { 0, 0 } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.mounts, moperaMounts)
return moperaMounts
