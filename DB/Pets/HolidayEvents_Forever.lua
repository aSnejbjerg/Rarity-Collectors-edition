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

local holidayEventPetsForever = {
	["Green Helper Box"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Green Helper Box"],
		spellId = 26533,
		itemId = 21301,
		items = { 21310 },
		chance = 4,
		creatureId = 15698,
		sourceText = L["Available starting December 25th"],
		holidayEvents = CONSTANTS.HolidayEvents["Feast of Winter Veil"],
		questId = { 8768 },
		coords = {
			zoneOverride = L["Greatfather Winter's Tree"],
			{ m = 87, x = 33.5, y = 66 },
			{ m = 86, x = 49.3, y = 78.4 },
		},
		christmasOnly = true,
	},
	["Jingling Bell"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Jingling Bell"],
		spellId = 26529,
		itemId = 21308,
		items = { 21310 },
		chance = 4,
		creatureId = 15706,
		sourceText = L["Available starting December 25th"],
		holidayEvents = CONSTANTS.HolidayEvents["Feast of Winter Veil"],
		coords = {
			zoneOverride = L["Greatfather Winter's Tree"],
			{ m = 87, x = 33.5, y = 66 },
			{ m = 86, x = 49.3, y = 78.4 },
		},
		questId = { 8768 },
		christmasOnly = true,
	},
	["Red Helper Box"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Red Helper Box"],
		spellId = 26541,
		itemId = 21305,
		items = { 21310 },
		chance = 4,
		creatureId = 15705,
		sourceText = L["Available starting December 25th"],
		holidayEvents = CONSTANTS.HolidayEvents["Feast of Winter Veil"],
		questId = { 8768 },
		coords = {
			zoneOverride = L["Greatfather Winter's Tree"],
			{ m = 87, x = 33.5, y = 66 },
			{ m = 86, x = 49.3, y = 78.4 },
		},
		christmasOnly = true,
	},
	["Snowman Kit"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Snowman Kit"],
		spellId = 26045,
		itemId = 21309,
		items = { 21310 },
		chance = 4,
		creatureId = 15710,
		sourceText = L["Available starting December 25th"],
		holidayEvents = CONSTANTS.HolidayEvents["Feast of Winter Veil"],
		questId = { 8768 },
		coords = {
			zoneOverride = L["Greatfather Winter's Tree"],
			{ m = 87, x = 33.5, y = 66 },
			{ m = 86, x = 49.3, y = 78.4 },
		},
		christmasOnly = true,
	},
	-- Forever additions start here
	["Truesilver Shafted Arrow"] = {
		cat = CONSTANTS.ITEM_CATEGORIES.HOLIDAY,
		type = CONSTANTS.ITEM_TYPES.PET,
		method = CONSTANTS.DETECTION_METHODS.USE,
		name = L["Truesilver Shafted Arrow"],
		spellId = 27570,
		itemId = 22235,
		items = {
			-- Stormwind / Ogrimmar
			21981, -- Storm Gift
			21975, -- Storm Pledge
			22164, -- Org Gift
			22156, -- Org Pledge
			-- Ironforge / Thunder Bluff
			21980, -- Iron Gift
			22154, -- Iron Pledge
			22165, -- TB Gift
			22158, -- TB Pledge
			-- Darnassus / Undercity
			21979, -- Darn Gift
			22155, -- Darn Pledge
			22166, -- UC Gift
			22157, -- UC Pledge
		},
		chance = 100,
		creatureId = 16085,
		sourceText = L["Available once an hour from Gifts/Pledges by interacting with city guards wearing either perfume or cologne and handing them a Love Token."],
		holidayEvents = CONSTANTS.HolidayEvents["Love is in the Air"],
		coords = { { m = 310, x = 40.8, y = 52.6, i = true } },
	},
}

Rarity.ItemDB.MergeItems(Rarity.ItemDB.pets, holidayEventPetsForever)
return holidayEventPetsForever
