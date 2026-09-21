local Output = {}

local pendingMessages = {}

function Output:DisplayText(text, icon)
	-- Arguments: text, r, g, b, font, size, outline, sticky, location, icon (though most appear to be useless?)
	-- Note: Provide r,g,b as float, i.e., in the interval [0.0, 1.0]
	if not text or text == "" then
		return
	end

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

	for _, message in ipairs(pendingMessages) do
		Rarity:Pour(message.text, nil, nil, nil, nil, nil, nil, nil, nil, message.icon)
	end

	table.wipe(pendingMessages)
end

function Output:GetOptionsTable()
	return Rarity:GetSinkAce3OptionsDataTable()
end

function Output:Setup()
	self:AssignSavedVariables()
	self:DefineLegacyFunctions()
end

function Output:AssignSavedVariables()
	Rarity:SetSinkStorage(Rarity.db.profile)
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
