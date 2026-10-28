local _, addonTable = ...

--- KillDetection.lua
-- Retail and WoW Forever have no combat log, so kills of tracked NPCs are read from PARTY_KILL (the player's and
-- the group's killing blows) and UNIT_DIED (a pet's killing blow, which fires no PARTY_KILL).
-- Inside instances unit identities are hidden; there only the loot window's corpse GUIDs are readable (see OnLootReady).
local KillDetection = {}

-- Upvalues
local R = Rarity

-- Lua APIs
local pairs = _G.pairs
local pcall = _G.pcall
local strsplit = _G.strsplit
local tonumber = _G.tonumber
local type = _G.type

-- WOW APIs
local CreateFrame = _G.CreateFrame
local C_Timer = _G.C_Timer
local GetTime = _G.GetTime
local IsInGroup = _G.IsInGroup
local IsInInstance = _G.IsInInstance
local IsInRaid = _G.IsInRaid
local UnitGUID = _G.UnitGUID
local UnitIsTapDenied = _G.UnitIsTapDenied
local UnitTokenFromGUID = _G.UnitTokenFromGUID

-- Constants
local PRUNE_INTERVAL_SECONDS = 60
local NAMEPLATE_KEEP_SECONDS = 300 -- A DoT can kill a mob well after its nameplate is gone
local COUNTED_KILL_KEEP_SECONDS = 1800 -- Must outlast the time a corpse can still be looted
local PET_LEFT_KEEP_SECONDS = 60
local PET_KILL_SETTLE_SECONDS = 0.5 -- Gives PARTY_KILL time to reject a pet kill that belongs to someone else

-- Locals
local initialized = false
local lastPruneTime = 0
local nameplateCache = {} -- GUID -> { tapDenied, removedAt }
local countedKills = {} -- GUID -> time the kill was counted
local rejectedKills = {} -- GUID -> time PARTY_KILL named someone else's blow
local petTarget = nil
local petLeft = {} -- GUID -> time the pet switched away from it

local function IsSecret(value)
	return issecretvalue ~= nil and issecretvalue(value) == true
end

-- A secret GUID can't be compared or used as a table key without a hard error, so it must never leave here
local function ReadGUID(unitToken)
	local guid = UnitGUID(unitToken)
	if IsSecret(guid) then
		return nil
	end
	return guid
end

-- The NPC ID of a creature that Rarity tracks NPC-based items for, otherwise nil
local function GetTrackedNpcID(guid)
	if guid == nil or IsSecret(guid) or type(guid) ~= "string" then
		return nil
	end

	local unitType, _, _, _, _, npcID = strsplit("-", guid)
	if unitType ~= "Creature" and unitType ~= "Vehicle" then
		return nil
	end

	npcID = tonumber(npcID)
	if not npcID or not R.npcs or not R.npcs[npcID] then
		return nil
	end

	return npcID
end

local function ReadTapDenied(unitToken)
	if not unitToken or IsSecret(unitToken) then
		return nil
	end

	local ok, isTapDenied = pcall(UnitIsTapDenied, unitToken)
	if not ok or IsSecret(isTapDenied) then
		return nil
	end

	return isTapDenied and true or false
end

-- Landing the killing blow on a mob that a stranger tagged earns no loot, so it can't count as an attempt.
-- Read live while the client still has a token for the mob, otherwise from the last reading taken while it was visible.
-- Nil means nothing is known (the kill is kept, since the killing blow is already ours).
local function IsTaggedBySomeoneElse(guid)
	if UnitTokenFromGUID then
		local isTapDenied = ReadTapDenied(UnitTokenFromGUID(guid))
		if isTapDenied ~= nil then
			return isTapDenied
		end
	end

	local entry = nameplateCache[guid]
	if entry then
		return entry.tapDenied
	end

	return nil
end

local function IsGroupMember(guid)
	local prefix, numUnits
	if IsInRaid() then
		prefix, numUnits = "raid", 40
	elseif IsInGroup() then
		prefix, numUnits = "party", 4
	else
		return false
	end

	for i = 1, numUnits do
		if ReadGUID(prefix .. i) == guid then
			return true
		end
	end

	return false
end

-- Loot rights are shared with the group, so a group member's killing blow is an attempt for the player as well
local function IsOurKiller(attackerGUID)
	if not attackerGUID then
		return false
	end

	return attackerGUID == ReadGUID("player") or IsGroupMember(attackerGUID)
end

local function NotePetTarget()
	local guid = ReadGUID("pettarget")
	if guid and not GetTrackedNpcID(guid) then
		guid = nil
	end

	if petTarget and petTarget ~= guid then
		petLeft[petTarget] = GetTime()
	end
	petTarget = guid
end

-- Whether the player's pet is on this mob, or was moments ago (its death can arrive after the pet moved on)
local function PetWasOn(guid)
	if petTarget == guid or ReadGUID("pettarget") == guid then
		return true
	end

	local leftAt = petLeft[guid]
	return leftAt ~= nil and GetTime() - leftAt <= PET_LEFT_KEEP_SECONDS
end

local function Prune()
	local now = GetTime()
	if now - lastPruneTime < PRUNE_INTERVAL_SECONDS then
		return
	end
	lastPruneTime = now

	for guid, entry in pairs(nameplateCache) do
		if entry.removedAt and now - entry.removedAt > NAMEPLATE_KEEP_SECONDS then
			nameplateCache[guid] = nil
		end
	end
	for guid, countedAt in pairs(countedKills) do
		if now - countedAt > COUNTED_KILL_KEEP_SECONDS then
			countedKills[guid] = nil
		end
	end
	for guid, leftAt in pairs(petLeft) do
		if now - leftAt > PET_LEFT_KEEP_SECONDS then
			petLeft[guid] = nil
		end
	end
	for guid, rejectedAt in pairs(rejectedKills) do
		if now - rejectedAt > NAMEPLATE_KEEP_SECONDS then
			rejectedKills[guid] = nil
		end
	end
end

-- Adds the attempts for one kill, unless this corpse was already counted (by an earlier event or by looting it)
local function RecordKill(guid)
	if countedKills[guid] then
		return
	end

	local npcID = GetTrackedNpcID(guid)
	if not npcID then
		return
	end

	Prune()
	countedKills[guid] = GetTime()
	nameplateCache[guid] = nil

	if R.guids[guid] == true then
		R:Debug("Kill of NPC %d was already counted when its loot was opened", npcID)
		return
	end

	R:Debug("Detected kill of NPC %d (%s)", npcID, guid)
	R:AddNpcAttempts(npcID, false)
end

function KillDetection:OnNamePlateAdded(unitToken)
	if self:IsInsideInstance() or not unitToken or IsSecret(unitToken) then
		return
	end

	Prune()

	-- Cached while the unit is live and its tap status is readable; only tracked NPCs are worth the memory
	local guid = ReadGUID(unitToken)
	if GetTrackedNpcID(guid) then
		nameplateCache[guid] = { tapDenied = ReadTapDenied(unitToken) }
	end
end

function KillDetection:OnNamePlateRemoved(unitToken)
	if self:IsInsideInstance() or not unitToken or IsSecret(unitToken) then
		return
	end

	local guid = ReadGUID(unitToken)
	local entry = guid and nameplateCache[guid]
	if not entry then
		return
	end

	-- Deliberately kept: a DoT tick can still kill the mob after its nameplate left draw distance
	entry.removedAt = GetTime()
	local isTapDenied = ReadTapDenied(unitToken)
	if isTapDenied ~= nil then
		entry.tapDenied = isTapDenied
	end
end

function KillDetection:OnPartyKill(attackerGUID, targetGUID)
	-- The payload is secret inside instances, and comparing a secret GUID can't be caught with pcall
	if self:IsInsideInstance() then
		return
	end
	if IsSecret(attackerGUID) or IsSecret(targetGUID) or not targetGUID then
		return
	end

	if not IsOurKiller(attackerGUID) or IsTaggedBySomeoneElse(targetGUID) then
		-- Rules out a pet kill that UNIT_DIED may be holding for this death
		rejectedKills[targetGUID] = GetTime()
		return
	end

	RecordKill(targetGUID)
end

function KillDetection:OnUnitDied(guid)
	if self:IsInsideInstance() or IsSecret(guid) or not guid then
		return
	end

	-- Fires for every death nearby; the player's own killing blows already arrived as PARTY_KILL
	if countedKills[guid] or not GetTrackedNpcID(guid) then
		return
	end
	if IsTaggedBySomeoneElse(guid) or not PetWasOn(guid) then
		return
	end

	local function settle()
		if not rejectedKills[guid] then
			RecordKill(guid)
		end
	end

	if C_Timer and C_Timer.After then
		C_Timer.After(PET_KILL_SETTLE_SECONDS, settle)
	else
		settle()
	end
end

function KillDetection:OnUnitTarget(unitToken)
	if self:IsInsideInstance() or not unitToken or IsSecret(unitToken) then
		return
	end

	if unitToken == "pet" then
		NotePetTarget()
	end
end

-- Whether this client lacks the combat log (retail, WoW Forever) and therefore needs the event-based detection
function KillDetection:IsSupported()
	local projectID = _G.WOW_PROJECT_ID
	local isMainline = projectID ~= nil and _G.WOW_PROJECT_MAINLINE ~= nil and projectID == _G.WOW_PROJECT_MAINLINE
	local isForever = projectID ~= nil and _G.WOW_PROJECT_CAMELOT ~= nil and projectID == _G.WOW_PROJECT_CAMELOT
	return isMainline or isForever or type(_G.CombatLogGetCurrentEventInfo) ~= "function"
end

function KillDetection:IsInsideInstance()
	if not IsInInstance then
		return false
	end

	local _, instanceType = IsInInstance()
	return instanceType ~= nil and instanceType ~= "none"
end

-- Inside instances the game hides which unit is targeted; the loot window's corpse GUIDs are still readable
function KillDetection:IsIdentityRestricted()
	return self:IsSupported() and self:IsInsideInstance()
end

-- Whether a kill of this corpse was already counted by an event (loot windows must not count it again)
function KillDetection:WasKillCounted(guid)
	if guid == nil or IsSecret(guid) then
		return false
	end

	return countedKills[guid] ~= nil
end

function KillDetection:Initialize()
	if initialized then
		return
	end
	initialized = true

	if not self:IsSupported() then
		R:Debug("Kill detection is not needed on this client (the combat log is available)")
		return
	end

	local frame = CreateFrame("Frame")
	local handlers = {
		NAME_PLATE_UNIT_ADDED = self.OnNamePlateAdded,
		NAME_PLATE_UNIT_REMOVED = self.OnNamePlateRemoved,
		PARTY_KILL = self.OnPartyKill,
		UNIT_DIED = self.OnUnitDied,
		UNIT_TARGET = self.OnUnitTarget,
	}
	frame:SetScript("OnEvent", function(_, event, ...)
		local handler = handlers[event]
		if handler then
			handler(KillDetection, ...)
		end
	end)

	-- RegisterEvent raises on an event the client doesn't know, which must not take the rest of the addon down
	local function registerEvent(event)
		local ok, registered = pcall(frame.RegisterEvent, frame, event)
		return ok and registered ~= false
	end

	-- Without PARTY_KILL nothing says whose kill it was, and counting every death nearby would credit strangers' kills
	if not registerEvent("PARTY_KILL") then
		R:Debug("Kill detection is disabled (PARTY_KILL is not available); attempts are only counted from loot windows")
		return
	end

	registerEvent("NAME_PLATE_UNIT_ADDED")
	registerEvent("NAME_PLATE_UNIT_REMOVED")

	if registerEvent("UNIT_DIED") then
		-- The pet only: registered for every unit it would fire for each nameplate in a busy zone
		pcall(frame.RegisterUnitEvent, frame, "UNIT_TARGET", "pet")
	end

	R:Debug("Kill detection is active (PARTY_KILL, pet kills from UNIT_DIED)")
end

Rarity.KillDetection = KillDetection
return KillDetection
