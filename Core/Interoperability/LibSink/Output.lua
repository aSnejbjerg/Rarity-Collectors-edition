local Output = {}

function Output:DisplayText(text, icon)
	-- Arguments: text, r, g, b, font, size, outline, sticky, location, icon (though most appear to be useless?)
	-- Note: Provide r,g,b as float, i.e., in the interval [0.0, 1.0]
	if not text or text == "" then
		return
	end

	local displayText = text
	if icon then
		displayText = "|T" .. icon .. ":15:15:0:0:64:64:4:60:4:60|t " .. displayText
	end

	if DEFAULT_CHAT_FRAME and DEFAULT_CHAT_FRAME.AddMessage then
		DEFAULT_CHAT_FRAME:AddMessage(displayText, 1, 1, 1)
	end
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
