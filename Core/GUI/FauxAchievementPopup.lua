local addonName, addonTable = ...
local CONSTANTS = addonTable.constants

-- WOW API
local GetItemInfo = _G.C_Item.GetItemInfo
local TextureKitConstants = _G.TextureKitConstants
local GetAchievementInfo = _G.GetAchievementInfo

-- Rarity API
local R = Rarity
local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
local projectId = _G.WOW_PROJECT_ID
local isModernProject = projectId ~= nil
	and (projectId == _G.WOW_PROJECT_MAINLINE or projectId == _G.WOW_PROJECT_CAMELOT)

-- Fake achievement popup stuff
local function RarityAchievementAlertFrame_SetUp(frame, itemId, attempts)
	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
		GetItemInfo(itemId)
	if itemName == nil then
		return
	end
	if itemTexture == nil then
		itemTexture = [[Interface\Icons\INV_Misc_PheonixPet_01]]
	end

	-- The following code is adapted from Blizzard's AchievementAlertFrame_SetUp function found in FrameXML\AlertFrameSystems.lua [introduced in 7.0]

	local displayName = frame.Name
	local shieldPoints = frame.Shield.Points
	local shieldIcon = frame.Shield.Icon
	local unlocked = frame.Unlocked
	local oldCheevo = frame.OldAchievement

	displayName:SetText(itemName)

	AchievementShield_SetPoints(0, shieldPoints, GameFontNormal, GameFontNormalSmall)

	if frame.guildDisplay or frame.oldCheevo then
		frame.oldCheevo = nil
		shieldPoints:Show()
		shieldIcon:Show()
		oldCheevo:Hide()
		frame.guildDisplay = nil
		frame:SetHeight(88)
		frame:SetHeight(104)
		local background = frame.Background
		background:SetTexture("Interface\\AchievementFrame\\UI-Achievement-Alert-Background")
		background:SetTexCoord(0, 0.605, 0, 0.703)
		background:SetPoint("TOPLEFT", 0, 0)
		background:SetPoint("BOTTOMRIGHT", 0, 0)
		local iconBorder = frame.Icon.Overlay
		iconBorder:SetAtlas("ui-achievement-guild-iconframe", TextureKitConstants.UseAtlasSize)
		iconBorder:SetPoint("CENTER", -1, 2)
		frame.Icon:SetPoint("TOPLEFT", -26, 16)
		displayName:SetPoint("BOTTOMLEFT", 72, 36)
		displayName:SetPoint("BOTTOMRIGHT", -60, 36)
		frame.Shield:SetPoint("TOPRIGHT", -10, -13)
		shieldPoints:SetPoint("CENTER", 7, 2)
		shieldPoints:SetVertexColor(1, 1, 1)
		shieldIcon:SetTexCoord(0, 0.5, 0, 0.45)
		unlocked:SetPoint("TOP", 7, -23)
		frame.GuildName:Hide()
		frame.GuildBorder:Hide()
		frame.GuildBanner:Hide()
		frame.glow:SetAtlas("ui-achievement-guild-glow", TextureKitConstants.UseAtlasSize)
		frame.shine:SetAtlas("ui-achievement-guild-shine", TextureKitConstants.UseAtlasSize)
		frame.shine:SetPoint("BOTTOMLEFT", 0, 8)
	end

	shieldIcon:SetAtlas("UI-Achievement-Shield-NoPoints", TextureKitConstants.UseAtlasSize)

	frame.Icon.Texture:SetTexture(itemTexture)
	frame:EnableMouse(false) -- Make achievement toast unclickable

	if attempts == nil or attempts <= 0 then
		attempts = 1
	end
	-- It's a quick 'n' dirty fix, but that's probably the least of our worries here...
	local item = Rarity.db.profile.groups.mounts[itemName]
		or Rarity.db.profile.groups.pets[itemName]
		or Rarity.db.profile.groups.items[itemName]
		or Rarity.db.profile.groups.user[itemName]
	if item and item.method and item.method == CONSTANTS.DETECTION_METHODS.COLLECTION then
		unlocked:SetText(L["Collection Complete"])
	else
		if attempts == 1 then
			unlocked:SetText(L["Obtained On Your First Attempt"])
		else
			unlocked:SetText(format(L["Obtained After %d Attempts"], attempts))
		end
	end
	Rarity:ScheduleTimer(
		function()
			-- Put the achievement frame back to normal when we're done
			unlocked:SetText(ACHIEVEMENT_UNLOCKED)
			frame:EnableMouse(true)
		end,
		10000 -- Give it enough time to fade out properly
	)

	frame.id = itemId
	return true
end

local FUNCTION_NEVER = function()
	return false
end
local IsInPetBattle = C_PetBattles and C_PetBattles.IsInBattle or FUNCTION_NEVER

local RarityAchievementAlertSystem =
	AlertFrame:AddQueuedAlertFrameSubSystem("AchievementAlertFrameTemplate", RarityAchievementAlertFrame_SetUp, 2, 6)
RarityAchievementAlertSystem:SetCanShowMoreConditionFunc(function()
	return not IsInPetBattle()
end)

-- ElvUI skin integration
local function SkinRarityAchievementAlert(frame, itemId)
	if not GetItemInfo(itemId) then
		return
	end

	if not frame.rarityElvUISkinned then
		frame:CreateBackdrop("Transparent")
		frame.backdrop:ClearAllPoints()
		frame.backdrop:SetPoint("TOPLEFT", frame.Background, "TOPLEFT", -2, -6)
		frame.backdrop:SetPoint("BOTTOMRIGHT", frame.Background, "BOTTOMRIGHT", -2, 6)

		frame.glow:Kill()
		frame.shine:Kill()
		frame.GuildBanner:Kill()
		frame.GuildBorder:Kill()
		frame.Icon.Overlay:Kill()
		frame.Icon:CreateBackdrop()
		frame.Icon.backdrop:SetOutside(frame.Icon.Texture)
		frame.rarityElvUISkinned = true
	end

	frame.Background:SetTexture(nil)
	frame.Unlocked:FontTemplate(nil, 12)
	frame.Unlocked:SetTextColor(1, 1, 1)
	frame.Name:FontTemplate(nil, 12)
	frame.Icon.Texture:SetTexCoords()
	frame.Icon.Texture:ClearAllPoints()
	frame.Icon.Texture:SetPoint("LEFT", frame, "LEFT", 7, 0)
end

local elvUI = _G.ElvUI and _G.ElvUI[1]
if elvUI and type(elvUI.GetModule) == "function" then
	local skins = elvUI:GetModule("Skins", true)
	if skins and type(skins.AddCallbackForAddon) == "function" then
		skins:AddCallbackForAddon(addonName, "RarityAchievementAlert", function()
			_G.hooksecurefunc(RarityAchievementAlertSystem, "setUpFunction", SkinRarityAchievementAlert)
		end, nil, nil, nil, "alertframes")
	end
end

--EllesmereUI skin integration
local ellesmereUI = _G.EllesmereUI
if ellesmereUI and type(ellesmereUI.RegisterSkin) == "function" then
	ellesmereUI.RegisterSkin(addonName, function(skin)
		_G.hooksecurefunc(RarityAchievementAlertSystem, "setUpFunction", function(frame, itemId)
			if not GetItemInfo(itemId) then
				return
			end

			skin.Shell(frame, { noTopBar = true })
			frame.Background:SetTexture(nil)
			frame.glow:SetTexture(nil)
			frame.shine:SetTexture(nil)
			frame.Icon.Overlay:SetTexture(nil)
			frame.Shield:SetAlpha(0)
			frame.Icon.Texture:ClearAllPoints()
			frame.Icon.Texture:SetPoint("LEFT", frame, "LEFT", 10, 0)
			skin.SquareIcon(frame.Icon.Texture, frame.Icon)
			skin.Font(frame.Unlocked, 1, 1, 1)
			skin.Font(frame.Name)
		end)
	end)
end

--LS: Toasts integration
local function GetLSToastsSettings()
	if
		not _G.C_AddOns
		or type(_G.C_AddOns.IsAddOnLoaded) ~= "function"
		or not _G.C_AddOns.IsAddOnLoaded("ls_Toasts")
	then
		return
	end

	local lsToasts = _G.ls_Toasts
	local engine = lsToasts and lsToasts[1]
	local config = lsToasts and lsToasts[2]
	local profile = config and config.db and config.db.profile
	if not (engine and type(engine.GetToast) == "function" and profile and profile.layouts and profile.types) then
		return
	end

	local editMode = _G.C_EditMode
	local layoutInfo = editMode and editMode.GetLayouts and editMode.GetLayouts()
	local layoutName
	if layoutInfo and layoutInfo.activeLayout then
		local presetNames = {}
		for _, preset in ipairs({
			{ "EDIT_MODE_MODERN_SYSTEM_MAP", "Modern" },
			{ "EDIT_MODE_CLASSIC_SYSTEM_MAP", "Classic" },
			{ "EDIT_MODE_GAMEPAD_SYSTEM_MAP", "Gamepad" },
		}) do
			if _G[preset[1]] then
				presetNames[#presetNames + 1] = preset[2]
			end
		end
		local index = layoutInfo.activeLayout
		local customLayout = layoutInfo.layouts and layoutInfo.layouts[index - #presetNames]
		layoutName = presetNames[index] or (customLayout and customLayout.layoutName)
	end
	if not layoutName then
		return
	end

	local layout = profile.layouts[layoutName]
	local achievement = profile.types.achievement
	local anchor = layout and layout.types and layout.types.achievement
	if not (achievement and anchor and layout.anchors and layout.anchors[anchor]) then
		return
	end
	return engine, achievement, anchor
end

local function ShowLSToast(itemName, itemTexture, attempts, item)
	local engine, achievement, anchor = GetLSToastsSettings()
	if not engine then
		return false
	end

	local toast = engine:GetToast()
	if item.method == CONSTANTS.DETECTION_METHODS.COLLECTION then
		toast.Title:SetText(L["Collection Complete"])
	elseif not attempts or attempts <= 1 then
		toast.Title:SetText(L["First Attempt!"])
	else
		toast.Title:SetText(format(L["Obtained:%d Attempts"], attempts))
	end
	toast.Text:SetText(itemName)
	toast.Icon:SetTexture(itemTexture)
	toast.IconBorder:Show()
	toast._data.event = "RARITY_ITEM_FOUND"
	toast._data.vfx = achievement.vfx
	toast:Spawn(anchor, achievement.dnd)
	return true
end

local pendingLSToasts = {}
local petBattleFrame

local function FlushPendingLSToasts()
	if IsInPetBattle() then
		_G.C_Timer.After(0.1, FlushPendingLSToasts)
		return
	end
	petBattleFrame:UnregisterEvent("PET_BATTLE_CLOSE")
	local pending = pendingLSToasts
	pendingLSToasts = {}
	for _, alert in ipairs(pending) do
		if not ShowLSToast(alert[2], alert[3], alert[4], alert[5]) then
			RarityAchievementAlertSystem:AddAlert(alert[1], alert[4])
		end
	end
end

local function QueueLSToast(itemId, itemName, itemTexture, attempts, item)
	if not IsInPetBattle() then
		return ShowLSToast(itemName, itemTexture, attempts, item)
	end
	if not GetLSToastsSettings() then
		return false
	end

	pendingLSToasts[#pendingLSToasts + 1] = { itemId, itemName, itemTexture, attempts, item }
	if not petBattleFrame then
		petBattleFrame = _G.CreateFrame("Frame")
		petBattleFrame:SetScript("OnEvent", function()
			_G.C_Timer.After(0, FlushPendingLSToasts)
		end)
	end
	petBattleFrame:RegisterEvent("PET_BATTLE_CLOSE")
	return true
end

local Output = Rarity.Output

-- test with: /run Rarity:ShowFoundAlert(32458, 5)
function R:ShowFoundAlert(itemId, attempts, item)
	local trackedItem = Rarity.Tracking:GetTrackedItem()
	if item == nil then
		item = trackedItem
	end

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
		GetItemInfo(itemId)
	if itemName == nil then
		return
	end -- Server doesn't know this item, we can't award it
	if itemTexture == nil then
		itemTexture = [[Interface\Icons\INV_Misc_PheonixPet_01]]
	end

	-- Output to the sink
	if self.db.profile.enableAnnouncements ~= false and item.announce ~= false then
		local s
		if item.method == CONSTANTS.DETECTION_METHODS.COLLECTION then
			s = format(L["%s: collection completed!"], itemName)
		else
			if attempts <= 1 then
				s = format(L["%s: Found on the first attempt!"], itemName)
			else
				s = format(L["%s: Found after %d attempts!"], itemName, attempts)
			end
		end
		Output:DisplayText(s, itemTexture)
	end

	-- The following code is adapted from Blizzard's AlertFrameMixin:OnEvent function found in FrameXML\AlertFrames.lua [heavily updated in 7.0]
	-- Presumably, this is now outdated (as of 9.0) so maybe copy/pasting it wasn't the best idea? :P

	if not AchievementFrame then
		AchievementFrame_LoadUI()
	end

	-- If option to generate achievement toast on item found is enabled, then generate the toast.
	if Rarity.db.profile.showAchievementToast then
		if not QueueLSToast(itemId, itemName, itemTexture, attempts, item) then
			RarityAchievementAlertSystem:AddAlert(itemId, attempts)
		end
		if isModernProject then
			PlaySoundFile(569143)
		else
			PlaySound(12891) -- UI_Alert_AchievementGained
		end
	end

	self:ScheduleTimer(function()
		-- Take a screenshot
		if Rarity.db.profile.takeScreenshot then
			if ActionStatus:IsShown() then
				ActionStatus:Hide()
			end
			Screenshot()
		end
	end, 2)
end
