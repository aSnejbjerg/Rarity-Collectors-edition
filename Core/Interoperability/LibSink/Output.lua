local Output = {}

local pendingMessages = {}
local SendChatMessage = _G.SendChatMessage
local isModernProject = _G.WOW_PROJECT_ID ~= nil
	and (
		(_G.WOW_PROJECT_MAINLINE ~= nil and _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE)
		or (_G.WOW_PROJECT_CAMELOT ~= nil and _G.WOW_PROJECT_ID == _G.WOW_PROJECT_CAMELOT)
	)

local modernSinks = {
	Emote = { name = "Emote", channel = "EMOTE" },
	Party = { name = "Party", channel = "PARTY" },
	Instance = { name = "Instance", channel = "INSTANCE_CHAT" },
	Raid = { name = "Raid", channel = "RAID" },
}

local function CreateChatOutput(channel)
	return function(_, text)
		SendChatMessage(text, channel)
	end
end

local function EnforceAllowedOutput()
	local selectedOutput = Rarity.db.profile.sink20OutputSink
	if (isModernProject and selectedOutput == "Channel") or (not isModernProject and modernSinks[selectedOutput]) then
		Rarity.db.profile.sink20OutputSink = "ChatFrame"
	end
end

function Output:DisplayText(text, icon)
	-- Arguments: text, r, g, b, font, size, outline, sticky, location, icon (though most appear to be useless?)
	-- Note: Provide r,g,b as float, i.e., in the interval [0.0, 1.0]
	if not text or text == "" then
		return
	end

	EnforceAllowedOutput()

	-- Delay output until combat lockdown ends to avoid protected function errors.
	if InCombatLockdown() then
		table.insert(pendingMessages, { text = text, icon = icon })
		return
	end

	-- Use user-decided channels via Rarity:Pour
	Rarity:Pour(text, nil, nil, nil, nil, nil, nil, nil, nil, icon)
end

function Output:FlushPendingMessages()
	if InCombatLockdown() then
		return
	end

	EnforceAllowedOutput()

	for _, message in ipairs(pendingMessages) do
		Rarity:Pour(message.text, nil, nil, nil, nil, nil, nil, nil, nil, message.icon)
	end

	table.wipe(pendingMessages)
end

function Output:GetOptionsTable()
	local options = Rarity:GetSinkAce3OptionsDataTable()
	local filteredOptions = {}
	for key, value in pairs(options) do
		filteredOptions[key] = value
	end

	filteredOptions.args = {}
	for key, value in pairs(options.args) do
		local isVersionSpecificOutput = key == "Channel" or modernSinks[key] ~= nil
		local shouldShowOption = not isVersionSpecificOutput
			or (isModernProject and modernSinks[key])
			or (not isModernProject and key == "Channel")
		if isModernProject and key == "ScrollArea" then
			shouldShowOption = false
		end
		if shouldShowOption then
			filteredOptions.args[key] = value
		end
	end

	return filteredOptions
end

function Output:Setup()
	if isModernProject then
		for shortName, sink in pairs(modernSinks) do
			Rarity:RegisterSink(
				shortName,
				sink.name,
				"Send output to " .. sink.name .. " chat.",
				CreateChatOutput(sink.channel)
			)
		end
	end
	self:AssignSavedVariables()
	self:DefineLegacyFunctions()
end

function Output:AssignSavedVariables()
	Rarity:SetSinkStorage(Rarity.db.profile)
	EnforceAllowedOutput()
end

function Output:DefineLegacyFunctions()
	-- LibSink still tries to call a non-existent Blizzard function sometimes [TBD: Is this still relevant?]
	if not CombatText_StandardScroll then
		CombatText_StandardScroll = 0
	end

	if not UIERRORS_HOLD_TIME then
		UIERRORS_HOLD_TIME = 2
	end

	if not CombatText_AddMessage then
		CombatText_AddMessage = function(text, _, r, g, b, sticky, _)
			UIErrorsFrame:AddMessage(text, r, g, b, 1, UIERRORS_HOLD_TIME)
		end
	end
end

Rarity.Output = Output
