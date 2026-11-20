-- WOW API
local GetMapInfo = C_Map.GetMapInfo
local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetInstanceInfo = GetInstanceInfo

-- Streamlined interface for working with Blizzard's UI map system (world map, zone queries, etc.)
local MapInfo = {}

-- Helper function (to look up map names more easily)
-- Returns the localized map name, or nil if the uiMapID is invalid
function MapInfo.GetMapNameByID(uiMapID)
	local UiMapDetails = GetMapInfo(uiMapID)
	return UiMapDetails and UiMapDetails.name
end

function MapInfo.GetCurrentLocationID()
	local uiMapID = GetBestMapForUnit("player")
	if uiMapID then
		return uiMapID, false
	end

	return select(8, GetInstanceInfo()), true
end

function MapInfo.IsItemAllowedInCurrentLocation(item)
	if not item or not item.instanceID then
		return true
	end

	local locationID, isInstanceID = MapInfo.GetCurrentLocationID()
	if not isInstanceID then
		return true
	end

	return locationID == item.instanceID
end

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
function MapInfo.GetLocalizedMapNamesForItem(item)
	local zones = item.zones or {}
	local mapNames = {}

	for index, zoneID in ipairs(zones) do
		local mapID = tonumber(zoneID)
		if not mapID then -- Zone or subzone name (not an actual ID)
			table.insert(mapNames, zoneID)
		else
			local mapName = MapInfo.GetMapNameByID(mapID) or L["Unknown"]
			local prefix = mapName
			local suffix = format(" (%s)", zoneID)
			table.insert(mapNames, prefix .. suffix)
		end
	end

	return mapNames
end

Rarity.MapInfo = MapInfo
