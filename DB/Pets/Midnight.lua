local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if not LE_EXPANSION_MIDNIGHT or LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_MIDNIGHT then
	return {}
end

local midnightPets = {
	["Nova"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 5,
		creatureId = 264892,
		name = L["Nova"],
		itemId = 264892,
		items = { 267299 },
		spellId = 1272755,
		coords = { { m = CONSTANTS.UIMAPIDS.SLAYERS_RISE } },
	},
	["Princess Bloodshed"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		chance = 100,
		creatureId = 258281,
		name = L["Princess Bloodshed"],
		itemId = 265609,
		npcs = { 255348 },
		spellId = 1276430,
		coords = { { m = CONSTANTS.UIMAPIDS.EVERSONG_WOODS_MIDNIGHT } },
	},
	["Bubbly Snapling"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.FISHING,
		name = L["Bubbly Snapling"],
		itemId = 260942,
		npcs = { 256201 },
		spellId = 1267090,
		chance = 500,
		coords = {
			{ m = CONSTANTS.UIMAPIDS.EVERSONG_WOODS_MIDNIGHT },
			{ m = CONSTANTS.UIMAPIDS.ZUL_AMAN_MIDNIGHT },
			{ m = CONSTANTS.UIMAPIDS.VOIDSTORM },
			{ m = CONSTANTS.UIMAPIDS.HARANDAR },
		},
		zones = {
			tostring(CONSTANTS.UIMAPIDS.EVERSONG_WOODS_MIDNIGHT),
			tostring(CONSTANTS.UIMAPIDS.ZUL_AMAN_MIDNIGHT),
			tostring(CONSTANTS.UIMAPIDS.VOIDSTORM),
			tostring(CONSTANTS.UIMAPIDS.HARANDAR),
		},
	},
	["Ominous Dominus"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 100,
		creatureId = 256265,
		name = L["Ominous Dominus"],
		itemId = 262391,
		items = { 618495 },
		spellId = 1268687,
		sourceText = L["This pet drops from the spawned or summoned versions of Nullaeus in regular delve runs. NOT from the Nemesis delve."],
		coords = { { 0,0 } },
	},
	["Wriggling Capybara"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 300,
		creatureId = 262786,
		name = L["Wriggling Capybara"],
		itemId = 270988,
		items = { 270247, 271221, 270932 },
		spellId = 1288378,
		coords = {
			{ m = CONSTANTS.UIMAPIDS.EVERSONG_WOODS_MIDNIGHT },
			{ m = CONSTANTS.UIMAPIDS.ZUL_AMAN_MIDNIGHT },
		},
	},
	["Curious Lynx Kitten"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		chance = 300,
		creatureId = 262788,
		name = L["Curious Lynx Kitten"],
		itemId = 270990,
		items = { 270247, 271221, 270932 },
		spellId = 1288381,
		coords = {
			{ m = CONSTANTS.UIMAPIDS.EVERSONG_WOODS_MIDNIGHT },
			{ m = CONSTANTS.UIMAPIDS.ZUL_AMAN_MIDNIGHT },
		},
	},
	["Overloaded Manaling"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		chance = 100,
		creatureId = 262066,
		name = L["Overloaded Manaling"],
		itemId = 269999,
		npcs = { 259971 },
		spellId = 1287339,
		coords = { { m = CONSTANTS.UIMAPIDS.RITUAL_SITES_MIDNIGHT } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.pets, midnightPets)
return midnightPets
