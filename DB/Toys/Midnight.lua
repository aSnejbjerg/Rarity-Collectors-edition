local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if not LE_EXPANSION_MIDNIGHT or LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_MIDNIGHT then
	return {}
end

local midnightToys = {
	["Saptor Salve"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.ITEM,
		method = CONSTANTS.DETECTION_METHODS.NPC,
		name = L["Saptor Salve"],
		itemId = 268728,
		tooltipNpcs = { 247676 },
		npcs = { 99999 },
		statisticId = { 61661 },
		groupSize = 5,
		equalOdds = true,
		chance = 20,
		instanceDifficulties = { [CONSTANTS.INSTANCE_DIFFICULTIES.MYTHIC_DUNGEON] = true },
		coords = { { m = CONSTANTS.UIMAPIDS.BLINDING_VALE, i = true } },
	},
	["Cosmic Ritual Stone"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.ITEM,
		method = CONSTANTS.DETECTION_METHODS.BOSS,
		name = L["Cosmic Ritual Stone"],
		itemId = 264672,
		chance = 25,
		npcs = { 99999 },
		tooltipNpcs = { 240432 },
		lockBossName = "Fallen-King Salhadaar",
		statisticId = { 61287, 61284, 61285, 61286 },
		instanceDifficulties = {
			[CONSTANTS.INSTANCE_DIFFICULTIES.NORMAL_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.HEROIC_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.MYTHIC_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.LFR] = true,
		},
		coords = { { i = true, m = CONSTANTS.UIMAPIDS.VOIDSPIRE } },
		groupSize = 25,
		equalOdds = true,
	},
	["Madcap Redcap"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.ITEM,
		method = CONSTANTS.DETECTION_METHODS.BOSS,
		name = L["Madcap Redcap"],
		itemId = 264313,
		chance = 25,
		npcs = { 99999 },
		tooltipNpcs = { 254176 },
		lockBossName = "Rotmire",
		statisticId = { 63233, 63234, 63235, 63236 },
		instanceDifficulties = {
			[CONSTANTS.INSTANCE_DIFFICULTIES.NORMAL_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.HEROIC_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.MYTHIC_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.LFR] = true,
		},
		coords = { { i = true, m = CONSTANTS.UIMAPIDS.SPOREFALL } },
		groupSize = 25,
		equalOdds = true,
	},
	["Mycomancer's Hearthspore"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.MIDNIGHT,
		type = CONSTANTS.ITEM_TYPES.ITEM,
		method = CONSTANTS.DETECTION_METHODS.BOSS,
		name = L["Mycomancer's Hearthspore"],
		itemId = 264367,
		chance = 25,
		npcs = { 99999 },
		tooltipNpcs = { 254176 },
		lockBossName = "Rotmire",
		statisticId = { 63233, 63234, 63235, 63236 },
		instanceDifficulties = {
			[CONSTANTS.INSTANCE_DIFFICULTIES.NORMAL_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.HEROIC_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.MYTHIC_RAID] = true,
			[CONSTANTS.INSTANCE_DIFFICULTIES.LFR] = true,
		},
		coords = { { i = true, m = CONSTANTS.UIMAPIDS.SPOREFALL } },
		groupSize = 25,
		equalOdds = true,
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.toys, midnightToys)
return midnightToys
