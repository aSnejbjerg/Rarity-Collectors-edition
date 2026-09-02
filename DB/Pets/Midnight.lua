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
		zones = { "2395", "2437", "2405", "2413" },
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
		coords = { { m = 0 } },
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
if CONSTANTS.WOW_INTERFACE_VER < CONSTANTS.PATCH_INTERFACE_VERSIONS.MIDNIGHT.CURSE_OF_ULATEK then
	Rarity.ItemDB.MergeItems(Rarity.ItemDB.pets, midnightPets)
	return midnightPets
end
midnightPets["Lil' Mon"] = {
	cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
	type = CONSTANTS.ITEM_TYPES.PET,
	method = CONSTANTS.DETECTION_METHODS.NPC,
	name = L["Lil' Mon"],
	itemId = 280540,
	creatureId = 271772,
	spellId = 1309175,
	npcs = { 256631 },
	chance = 500,
	sourceText = L["Dropped off a rare named Big Mon"],
	coords = { { m = CONSTANTS.UIMAPIDS.COILED_ISLES } },
}
midnightPets["Pale Hexscale"] = {
	cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
	type = CONSTANTS.ITEM_TYPES.PET,
	method = CONSTANTS.DETECTION_METHODS.SPECIAL,
	name = L["Pale Hexscale"],
	creatureId = 269712,
	itemId = 278572,
	spellId = 1305199,
	chance = 33,
	npcs = { 258928 },
	tooltipNpcs = { 258928 },
	sourceText = L["Dropped by the prey boss named Ral'kala"],
	coords = { { m = CONSTANTS.UIMAPIDS.COILED_ISLES } },
}
midnightPets["Poison Dart Frog"] = {
	cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
	type = CONSTANTS.ITEM_TYPES.PET,
	method = CONSTANTS.DETECTION_METHODS.SPECIAL,
	name = L["Poison Dart Frog"],
	creatureId = 271106,
	itemId = 280178,
	spellId = 1307875,
	chance = 100,
	sourceText = L["This pet can only drop at Zul'jarra's Forces Renown 9."],
	coords = { { m = CONSTANTS.UIMAPIDS.COILED_ISLES } },
}
midnightPets["Cauldron Concoction"] = {
	cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
	type = CONSTANTS.ITEM_TYPES.PET,
	method = CONSTANTS.DETECTION_METHODS.USE,
	name = L["Cauldron Concoction"],
	creatureId = 271163,
	itemId = 280189,
	items = { 277937 },
	spellId = 1307902,
	chance = 300,
	sourceText = L["This pet is a rare drop from any of Ofi the Sly's mysterious concoctions."],
	coords = { { m = CONSTANTS.UIMAPIDS.COILED_ISLES } },
}
midnightPets["Vibrant Venomfang"] = {
	cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
	type = CONSTANTS.ITEM_TYPES.PET,
	method = CONSTANTS.DETECTION_METHODS.USE,
	name = L["Vibrant Venomfang"],
	creatureId = 267689,
	itemId = 276234,
	items = { 275899, 277137 },
	spellId = 1299089,
	chance = 50,
	sourceText = L["Drops from the Wiggling version of the Venom-Soaked Satchel, a rare alternative drop from completing Curse Surges."],
	coords = { { m = CONSTANTS.UIMAPIDS.COILED_ISLES } },
}
midnightPets["Soulcoil Remnant"] = {
	cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
	type = CONSTANTS.ITEM_TYPES.PET,
	method = CONSTANTS.DETECTION_METHODS.BOSS,
	name = L["Soulcoil Remnant"],
	creatureId = 269501,
	itemId = 280305,
	spellId = 1304581,
	chance = 25,
	npcs = { 99999 },
	tooltipNpcs = { 259927 },
	lockBossName = "Nek'zali the Soulcoiler",
	statisticId = { 63533, 63534, 63535, 63536 },
	instanceDifficulties = {
		[CONSTANTS.INSTANCE_DIFFICULTIES.NORMAL_RAID] = true,
		[CONSTANTS.INSTANCE_DIFFICULTIES.HEROIC_RAID] = true,
		[CONSTANTS.INSTANCE_DIFFICULTIES.MYTHIC_RAID] = true,
		[CONSTANTS.INSTANCE_DIFFICULTIES.LFR] = true,
	},
	coords = { { i = true, m = CONSTANTS.UIMAPIDS.VENOMOUS_ABYSS } },
	groupSize = 25,
	equalOdds = true,
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.pets, midnightPets)
return midnightPets
