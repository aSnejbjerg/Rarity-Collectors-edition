-- Externals
local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")

-- WOW API
local GetBestMapForUnit = C_Map.GetBestMapForUnit
local GetInstanceInfo = GetInstanceInfo

-- Rarity API
local Colorize = Rarity.Utils.String.Colorize
local Count = Rarity.Utils.Table.Count
local GetMapNameByID = Rarity.MapInfo.GetMapNameByID

local format = format
local type = type
local pairs = pairs

-- Constants
local green = Rarity.Enum.Colors.Green
local gray = Rarity.Enum.Colors.Gray

local Waypoints = {}

function Waypoints:GetZoneInfoForItem(item)
	local zoneInfo = {
		zoneText = self:GetZoneTextForItem(item),
		inMyZone = self:IsItemInCurrentZone(item),
		zoneColor = (self:IsItemInCurrentZone(item) and green) or gray,
		numZones = self:GetNumZonesForItem(item),
	}
	return zoneInfo
end

function Waypoints:GetZoneTextForItem(item)
	if not self:HasItemWaypoints(item) then
		return ""
	end

	if item.coords.zoneOverride ~= nil then
		return item.coords.zoneOverride
	end

	local numZones = self:GetNumZonesForItem(item)
	if numZones == 1 then
		for _, waypointData in pairs(item.coords) do
			if type(waypointData) == "table" and (waypointData.m ~= nil or waypointData.instanceID ~= nil) then
				return self:GetZoneNameForWaypoint(waypointData) or ""
			end
		end
		return ""
	end

	if not self:IsItemInCurrentZone(item) then
		return format(L["%d |4zone:zones;"], numZones)
	end

	local currentZone = GetBestMapForUnit("player")
	local currentInstanceID = select(8, GetInstanceInfo())
	if currentInstanceID then
		for _, waypointData in pairs(item.coords) do
			if type(waypointData) == "table" and waypointData.instanceID == currentInstanceID then
				return (self:GetZoneNameForWaypoint(waypointData) or "")
					.. " "
					.. Colorize(format("+%d", numZones - 1), gray)
			end
		end
	end
	-- TBD: Why use gray if it'll be overridden with green due to being in the current zone?
	return GetMapNameByID(currentZone) .. " " .. Colorize(format("+%d", numZones - 1), gray)
end

function Waypoints:GetZoneNameForWaypoint(waypointData)
	if waypointData.zoneName ~= nil then
		return waypointData.zoneName
	end

	if waypointData.m ~= nil then
		return GetMapNameByID(waypointData.m)
	end

	local instanceName, _, _, _, _, _, _, instanceID = GetInstanceInfo()
	if waypointData.instanceID == instanceID then
		return instanceName
	end
end

function Waypoints:IsItemInCurrentZone(item)
	if not self:HasItemWaypoints(item) then
		return false
	end -- We don't know for sure, but the effect is the same

	local mapIDs = self:GetMapsForItem(item) or {}
	local currentZone = GetBestMapForUnit("player")
	local currentInstanceID = select(8, GetInstanceInfo())
	return mapIDs[currentZone] or self:GetInstanceIDsForItem(item)[currentInstanceID]
end

function Waypoints:GetNumZonesForItem(item)
	local mapIDs = self:GetMapsForItem(item) or {}
	local instanceIDs = self:GetInstanceIDsForItem(item)
	return Count(mapIDs) + Count(instanceIDs)
end

function Waypoints:HasItemWaypoints(item)
	-- Is valid waypoint entry
	-- TBD: Use DB schema validation logic for this? No need to reinvent the wheel
	local hasWaypointsEntry = (item.coords ~= nil and type(item.coords) == "table")
	if not hasWaypointsEntry then
		return false
	end

	-- Has at least one assigned map or instance ID
	for waypointID, waypointData in pairs(item.coords) do
		if
			type(waypointData) == "table"
			and (waypointData.m ~= nil or waypointData.instanceID ~= nil)
		then
			return true
		end
	end

	return false
end

function Waypoints:GetFirstMapForItem(item)
	if not self:HasItemWaypoints(item) then
		return
	end

	for waypointID, waypointData in pairs(item.coords) do
		local mapID = waypointData.m
		if mapID then -- Skip those that don't have a mapID (not sure if that actually exists?)
			return mapID
		end
	end
end

function Waypoints:GetMapsForItem(item)
	if not self:HasItemWaypoints(item) then
		return
	end

	local waypointMapIDs = {}
	for waypointID, waypointData in pairs(item.coords) do
		local mapID = type(waypointData) == "table" and waypointData.m
		if mapID then
			waypointMapIDs[mapID] = true
		end
	end

	return waypointMapIDs
end

function Waypoints:GetInstanceIDsForItem(item)
	local waypointInstanceIDs = {}
	if not self:HasItemWaypoints(item) then
		return waypointInstanceIDs
	end

	for _, waypointData in pairs(item.coords) do
		local instanceID = type(waypointData) == "table" and waypointData.instanceID
		if instanceID then
			waypointInstanceIDs[instanceID] = true
		end
	end

	return waypointInstanceIDs
end

Rarity.Waypoints = Waypoints
