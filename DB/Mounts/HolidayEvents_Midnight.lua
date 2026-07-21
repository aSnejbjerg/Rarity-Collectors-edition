local addonName, addonTable = ...

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local CONSTANTS = addonTable.constants

if not LE_EXPANSION_MIDNIGHT or LE_EXPANSION_LEVEL_CURRENT < LE_EXPANSION_MIDNIGHT then
	return {}
end

local holidayEventMountsMidnight = {
	["Sun Festival's Painted Roc"] = {
        cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
        type = CONSTANTS.ITEM_TYPES.MOUNT,
        method = CONSTANTS.DETECTION_METHODS.USE,
        name = L["Sun Festival's Painted Roc"],
        spellId = 1298439,
        itemId = 275464,
        items = { 54536, 117394 },
        chance = 200,
        groupSize = 5,
        equalOdds = true,
        sourceText = L["Can be contained in the Satchel of Chilled Goods, rewarded for defeating the World Event Dungeon during the Midsummer Fire Festival."],
        lockDungeonId = 286,
		holidayEvents = CONSTANTS.HolidayEvents["Midsummer Fire Festival"],
        coords = { { m = 265, x = 31.2, y = 50.8, i = true, n = L["Ahune"] } },
    },
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.mounts, holidayEventMountsMidnight)
return holidayEventMountsMidnight
