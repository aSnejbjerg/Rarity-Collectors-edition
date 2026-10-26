local TRACKED_NPC_ID = 12345
local UNTRACKED_NPC_ID = 99999

local state
local guidCounter = 0

local function newGUID(npcID)
	guidCounter = guidCounter + 1
	return string.format("Creature-0-1-2-3-%d-%010X", npcID or TRACKED_NPC_ID, guidCounter)
end

local function splitOnDash(separator, text)
	assert(separator == "-", "Only dashes are supported by this stub")
	local parts = {}
	for part in (text .. "-"):gmatch("(.-)%-") do
		parts[#parts + 1] = part
	end
	return unpack(parts)
end

-- The module captures these as upvalues when it is loaded, so they only need to exist while loading
local stubs = {
	strsplit = splitOnDash,
	CreateFrame = function()
		return {}
	end,
	C_Timer = {
		After = function(_, callback)
			state.timers[#state.timers + 1] = callback
		end,
	},
	GetTime = function()
		return state.now
	end,
	IsInGroup = function()
		return state.isInGroup
	end,
	IsInRaid = function()
		return state.isInRaid
	end,
	IsInInstance = function()
		return state.instanceType ~= "none", state.instanceType
	end,
	UnitGUID = function(unitToken)
		return state.units[unitToken]
	end,
	UnitIsTapDenied = function(unitToken)
		return state.tapDenied[unitToken]
	end,
	UnitTokenFromGUID = function(guid)
		return state.tokens[guid]
	end,
}

local previousGlobals = {}
for name, stub in pairs(stubs) do
	previousGlobals[name] = _G[name]
	_G[name] = stub
end
local KillDetection = loadfile("Core/KillDetection.lua")(_G.RARITY_ADDON_NAME, _G.RARITY_ADDON_TABLE)
for name in pairs(stubs) do
	_G[name] = previousGlobals[name]
end

local function flushTimers()
	local timers = state.timers
	state.timers = {}
	for _, callback in ipairs(timers) do
		callback()
	end
end

describe("KillDetection", function()
	local originalRarityFields = {}

	before(function()
		state = {
			now = 1000,
			instanceType = "none",
			isInGroup = false,
			isInRaid = false,
			units = { player = "Player-1-AAAAAAAA" },
			tokens = {},
			tapDenied = {},
			timers = {},
			attempts = {},
		}

		for _, field in ipairs({ "npcs", "guids", "AddNpcAttempts", "Debug" }) do
			originalRarityFields[field] = Rarity[field]
		end
		Rarity.npcs = { [TRACKED_NPC_ID] = {} }
		Rarity.guids = {}
		Rarity.Debug = function() end
		Rarity.AddNpcAttempts = function(_, npcID, requiresPickpocket)
			state.attempts[#state.attempts + 1] = { npcID = npcID, requiresPickpocket = requiresPickpocket }
		end
	end)

	describe("IsSupported", function()
		it("should be true on clients that lack the combat log", function()
			assertFalse(type(_G.CombatLogGetCurrentEventInfo) == "function") -- Not part of the test environment
			assertTrue(KillDetection:IsSupported())
		end)
	end)

	describe("OnPartyKill", function()
		it("should count a tracked NPC killed by the player", function()
			local guid = newGUID()
			KillDetection:OnPartyKill(state.units.player, guid)
			assertEquals(#state.attempts, 1)
			assertEquals(state.attempts[1].npcID, TRACKED_NPC_ID)
			assertEquals(state.attempts[1].requiresPickpocket, false)
			assertTrue(KillDetection:WasKillCounted(guid))
		end)

		it("should only count a corpse once", function()
			local guid = newGUID()
			KillDetection:OnPartyKill(state.units.player, guid)
			KillDetection:OnPartyKill(state.units.player, guid)
			assertEquals(#state.attempts, 1)
		end)

		it("should ignore NPCs that Rarity has no NPC-based items for", function()
			local guid = newGUID(UNTRACKED_NPC_ID)
			KillDetection:OnPartyKill(state.units.player, guid)
			assertEquals(#state.attempts, 0)
			assertFalse(KillDetection:WasKillCounted(guid))
		end)

		it("should ignore targets that aren't creatures", function()
			KillDetection:OnPartyKill(state.units.player, "Player-1-BBBBBBBB")
			assertEquals(#state.attempts, 0)
		end)

		it("should ignore killing blows landed by strangers", function()
			KillDetection:OnPartyKill("Player-1-CCCCCCCC", newGUID())
			assertEquals(#state.attempts, 0)
		end)

		it("should count a killing blow landed by a party member", function()
			state.isInGroup = true
			state.units.party1 = "Player-1-DDDDDDDD"
			KillDetection:OnPartyKill(state.units.party1, newGUID())
			assertEquals(#state.attempts, 1)
		end)

		it("should count a killing blow landed by a raid member", function()
			state.isInRaid = true
			state.units.raid17 = "Player-1-EEEEEEEE"
			KillDetection:OnPartyKill(state.units.raid17, newGUID())
			assertEquals(#state.attempts, 1)
		end)

		it("should ignore group members once the player has left the group", function()
			state.units.party1 = "Player-1-DDDDDDDD"
			KillDetection:OnPartyKill(state.units.party1, newGUID())
			assertEquals(#state.attempts, 0)
		end)

		it("should ignore mobs that someone outside the group tagged", function()
			local guid = newGUID()
			state.tokens[guid] = "nameplate3"
			state.tapDenied["nameplate3"] = true
			KillDetection:OnPartyKill(state.units.player, guid)
			assertEquals(#state.attempts, 0)
		end)

		it("should count mobs that the player tagged", function()
			local guid = newGUID()
			state.tokens[guid] = "nameplate3"
			state.tapDenied["nameplate3"] = false
			KillDetection:OnPartyKill(state.units.player, guid)
			assertEquals(#state.attempts, 1)
		end)

		it("should fall back to the tap status cached from the nameplate when the mob has no unit token", function()
			local guid = newGUID()
			state.tokens["nameplate4"] = nil
			state.units.nameplate4 = guid
			state.tapDenied["nameplate4"] = true
			KillDetection:OnNamePlateAdded("nameplate4")
			KillDetection:OnNamePlateRemoved("nameplate4")
			KillDetection:OnPartyKill(state.units.player, guid)
			assertEquals(#state.attempts, 0)
		end)

		it("should not add attempts for a corpse whose loot was already counted", function()
			local guid = newGUID()
			Rarity.guids[guid] = true
			KillDetection:OnPartyKill(state.units.player, guid)
			assertEquals(#state.attempts, 0)
			assertTrue(KillDetection:WasKillCounted(guid))
		end)

		it("should ignore kills inside instances, where the payload is hidden", function()
			state.instanceType = "party"
			KillDetection:OnPartyKill(state.units.player, newGUID())
			assertEquals(#state.attempts, 0)
		end)
	end)

	describe("OnUnitDied", function()
		it("should count a tracked NPC that the player's pet was fighting", function()
			local guid = newGUID()
			state.units.pettarget = guid
			KillDetection:OnUnitDied(guid)
			assertEquals(#state.attempts, 0) -- Waits briefly for a PARTY_KILL that may claim it for someone else
			flushTimers()
			assertEquals(#state.attempts, 1)
		end)

		it("should count a pet kill whose PARTY_KILL already arrived and counted it", function()
			local guid = newGUID()
			state.units.pettarget = guid
			KillDetection:OnPartyKill(state.units.player, guid)
			KillDetection:OnUnitDied(guid)
			flushTimers()
			assertEquals(#state.attempts, 1)
		end)

		it("should count a mob that the pet switched away from moments ago", function()
			local guid = newGUID()
			state.units.pettarget = guid
			KillDetection:OnUnitTarget("pet")
			state.units.pettarget = nil
			KillDetection:OnUnitTarget("pet")
			state.now = state.now + 5
			KillDetection:OnUnitDied(guid)
			flushTimers()
			assertEquals(#state.attempts, 1)
		end)

		it("should not count a mob that the pet abandoned a long time ago", function()
			local guid = newGUID()
			state.units.pettarget = guid
			KillDetection:OnUnitTarget("pet")
			state.units.pettarget = nil
			KillDetection:OnUnitTarget("pet")
			state.now = state.now + 120
			KillDetection:OnUnitDied(guid)
			flushTimers()
			assertEquals(#state.attempts, 0)
		end)

		it("should not count a death that PARTY_KILL attributed to someone else", function()
			local guid = newGUID()
			state.units.pettarget = guid
			KillDetection:OnUnitDied(guid)
			KillDetection:OnPartyKill("Player-1-CCCCCCCC", guid)
			flushTimers()
			assertEquals(#state.attempts, 0)
		end)

		it("should not count deaths that the player's pet had nothing to do with", function()
			local guid = newGUID()
			KillDetection:OnUnitDied(guid)
			flushTimers()
			assertEquals(#state.attempts, 0)
		end)

		it("should not count mobs that someone outside the group tagged", function()
			local guid = newGUID()
			state.units.pettarget = guid
			state.tokens[guid] = "nameplate5"
			state.tapDenied["nameplate5"] = true
			KillDetection:OnUnitDied(guid)
			flushTimers()
			assertEquals(#state.attempts, 0)
		end)

		it("should ignore NPCs that Rarity has no NPC-based items for", function()
			local guid = newGUID(UNTRACKED_NPC_ID)
			state.units.pettarget = guid
			KillDetection:OnUnitDied(guid)
			flushTimers()
			assertEquals(#state.attempts, 0)
		end)
	end)

	describe("IsIdentityRestricted", function()
		it("should be false outside of instances", function()
			assertFalse(KillDetection:IsIdentityRestricted())
		end)

		it("should be true inside instances", function()
			state.instanceType = "raid"
			assertTrue(KillDetection:IsIdentityRestricted())
		end)
	end)

	describe("WasKillCounted", function()
		it("should be false for corpses that weren't seen", function()
			assertFalse(KillDetection:WasKillCounted(newGUID()))
			assertFalse(KillDetection:WasKillCounted(nil))
		end)
	end)
end)
