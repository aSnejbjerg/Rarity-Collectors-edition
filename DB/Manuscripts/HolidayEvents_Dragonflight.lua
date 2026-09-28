local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_DRAGONFLIGHT then
	return {}
end

local holidayEventManuscriptsDragonflight = {
-- Love is in the Air
	["Renewed Proto-Drake: Love Armor"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Renewed Proto-Drake: Love Armor"],
		itemId = 211812,
		items = { 54537 },
		questId = { 79088 },
		chance = 100,
		holidayEvents = CONSTANTS.HolidayEvents["Love is in the Air"],
		groupSize = 5,
		equalOdds = true,
		sourceText = L["Can be contained in Heart-Shaped Box, rewarded for defeating the World Event Dungeon during Love is in the Air."],
		lockDungeonId = 288,
		coords = { { m = 310, x = 40.8, y = 52.6, i = true } },
	},
-- Midsummer Fire Festival
	["Cliffside Wylderdrake: Midsummer Fire Festival Armor"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Cliffside Wylderdrake: Midsummer Fire Festival Armor"],
		itemId = 224163,
		items = { 117394 },
		questId = { 82741 },
		chance = 100,
		holidayEvents = CONSTANTS.HolidayEvents["Midsummer Fire Festival"],
		groupSize = 5,
		equalOdds = true,
		sourceText = L["Can be contained in the Satchel of Chilled Goods, rewarded for defeating the World Event Dungeon during the Midsummer Fire Festival."],
		lockDungeonId = 286,
		coords = { { m = 265, x = 31.2, y = 50.8, i = true, n = L["Ahune"] } },
	},
-- Brewfest
	["Renewed Proto-Drake: Brewfest Armor"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Renewed Proto-Drake: Brewfest Armor"],
		itemId = 208742,
		items = { 117393 },
		questId = { 77774 },
		chance = 100,
		holidayEvents = CONSTANTS.HolidayEvents["Brewfest"],
		groupSize = 5,
		equalOdds = true,
		sourceText = L["Can be contained in Keg-Shaped Treasure Chest, rewarded for defeating the World Event Dungeon during Brewfest."],
		lockDungeonId = 287,
		coords = { { m = 242, x = 46.6, y = 60, i = true } },
	},
-- Hallow's End
	["Windborne Velocidrake: Hallow's End Armor"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Windborne Velocidrake: Hallow's End Armor"],
		itemId = 208680,
		items = { 209024 },
		questId = { 77725 },
		chance = 100,
		holidayEvents = CONSTANTS.HolidayEvents["Hallow's End"],
		groupSize = 5,
		equalOdds = true,
		sourceText = L["Can be contained in Loot-Filled Pumpkin, rewarded for defeating the World Event Dungeon during Hallow's End."],
		lockDungeonId = 285,
		coords = { { m = 435, i = true } },
	},
-- Winter Veil
	["Highland Drake: Winter Veil Armor"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.MANUSCRIPT,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Highland Drake: Winter Veil Armor"],
		itemId = 210432,
		items = { 116762 },
		questId = { 78371 },
		chance = 100,
		holidayEvents = CONSTANTS.HolidayEvents["Feast of Winter Veil"],
		coords = { { m = 87, x = 33.2, y = 67.8 }, { m = 25, x = 42.4, y = 41 }, { m = 86, x = 54.4, y = 77 } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.manuscripts, holidayEventManuscriptsDragonflight)
return holidayEventManuscriptsDragonflight
