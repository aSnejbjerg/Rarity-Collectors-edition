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

local foreverPets = {
	["Cat Carrier (Black Tabby)"] = { -- NOTE / TODO: MIGHT NEED TO REVISIT LATER, DALARAN SHIELD IS KINDA GONE ON FOREVER, MIGHT HAVE DIFFERENT SOURCE UNDATAMINED
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Cat Carrier (Black Tabby)"],
		spellId = 10675,
		itemId = 8491,
		npcs = { 2271, 2358, 2272 },
		chance = 10000,
		creatureId = 7383,
		blackMarket = true,
		coords = { { m = 1416, x = 20.6, y = 82.8  } },
	},
	["Dark Whelpling"] = { -- NOTE: ADJUSTED
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Dark Whelpling"],
		spellId = 10695,
		itemId = 10822,
		npcs = { 2725, 4324 },
		chance = 1000,
		creatureId = 7543,
		blackMarket = true,
		coords = {
			{ m = 15, x = 29.6, y = 44.2 },
			{ m = 15, x = 71.8, y = 47.6 },
			{ m = 15, x = 11.2, y = 41.0 },
			{ m = 70, x = 47.6, y = 69.8 },
		},
	},
	["Disgusting Oozeling"] = { -- NOTE: ADJUSTED, POSSIBLY MORE SPAWNS IN NEW ZONES, TODO LATER
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Disgusting Oozeling"],
		spellId = 25162,
		itemId = 20769,
		items = { 20768 },
		chance = 85,
		creatureId = 15429,
		blackMarket = true,
		tooltipNpcs = {
			-- Felwood
			7092, -- Tainted Ooze
			7093, -- Vile Ooze
			-- EP
			8607, -- Rotting Sludge
			8606, -- Living Decay
			-- Ungoro
			6557, -- Primal Ooze
			9477, -- Cloned Ooze
			6559, -- Glutinous Ooze
			-- WP
			12387, -- Large Vile Slime
			1808, -- Devouring Ooze
			1806, -- Vile Slime
		},
		coords = {
			{ m = 77 },
			{ m = 22 },
			{ m = 23 },
			{ m = 78 },
		},
	},
	["Parrot Cage (Green Wing Macaw)"] = { -- Not trackable, secret values in instances (deadmines in this case)
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Parrot Cage (Green Wing Macaw)"],
		spellId = 10683,
		itemId = 8492,
		npcs = { 48522 },
		chance = 33,
		creatureId = 7387,
		blackMarket = true,
		coords = { { m = 291, x = 55, y = 39.6, i = true } },
	},
	["Parrot Cage (Hyacinth Macaw)"] = { -- NOTE: ADJUSTED
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Parrot Cage (Hyacinth Macaw)"],
		spellId = 10682,
		itemId = 8494,
		npcs = { 1565, 4506, 1564, 4505, 1563, 1653 },
		chance = 10000,
		creatureId = 7391,
		blackMarket = true,
		coords = { { m = 1434, x = 29.6, y = 81.6  } },
	},
	["Tiny Crimson Whelpling"] = { -- NOTE: ADJUSTED
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Tiny Crimson Whelpling"],
		spellId = 10697,
		itemId = 8499,
		npcs = { 1042, 1069, 1044 },
		chance = 10000,
		creatureId = 7544,
		blackMarket = true,
		coords = { { m = CONSTANTS.UIMAPIDS.WETLANDS, x = 62.6, y = 41.6  } },
	},
	["Emerald Whelpling"] = { -- NOTE: ADJUSTED
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Emerald Whelpling"],
		spellId = 10698,
		itemId = 8498,
		npcs = { 740 },
		chance = 1000,
		creatureId = 7545,
		blackMarket = true,
		coords = { { m = CONSTANTS.UIMAPIDS.SWAMP_OF_SORROWS, x = 14.6, y = 62.6 } },
	},
	["Cat Carrier (Siamese)"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.CLASSIC,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.ENCOUNTER,
		encounter = {
			165, -- Cookie
		},
		name = L["Cat Carrier (Siamese)"],
		chance = 5,
		creatureId = 7380,
		itemId = 8490,
		npcs = { 645 },
		spellId = 10677,
		coords = { { m = CONSTANTS.UIMAPIDS.DEADMINES } },
	},
	-- WoW Forever exclusives start here
	["Tallstrider Hatchling"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.FOREVER,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Tallstrider Hatchling"],
		spellId = 1315267,
		itemId = 284176,
		npcs = { 2172 },
		chance = 20,
		creatureId = 274334,
		blackMarket = true,
		sourceText = L["This pet drops from the Tallstrider Matriarch in Darkshore."],
		coords = { { m = CONSTANTS.UIMAPIDS.FOREVER_DARKSHORE, x = 37.6, y = 90.6 } },
	},
	["Baby Crocolisk"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.FOREVER,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Baby Crocolisk"],
		spellId = 1312880,
		itemId = 282047,
		npcs = { 3581 },
		chance = 20,
		creatureId = 273391,
		blackMarket = true,
		sourceText = L["This pet drops from the Sewer Beast in Stormwind."],
		coords = { { m = CONSTANTS.UIMAPIDS.FOREVER_STORMWIND_CITY, x = 48.6, y = 61.6 } },
	},
	["Musical Gustjumper"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.FOREVER,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Musical Gustjumper"],
		spellId = 1281641,
		itemId = 268109,
		npcs = { 3581 },
		chance = 1,
		creatureId = 259842,
		sourceText = L["This pet requires you to /sing to a circle of frogs."],
		coords = { { m = CONSTANTS.UIMAPIDS.ZEPHRAS_ISLE, x = 51.6, y = 72.6 } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.pets, foreverPets)
return foreverPets
