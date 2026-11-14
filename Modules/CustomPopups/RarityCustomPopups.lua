---
-- RarityCustomPopups.lua
-- Themed, Edit Mode movable "collected" popups for Rarity: Collector's Edition.
--
-- Standalone companion addon (lives next to the Rarity folder, like Rarity_Options):
--   * It does NOT modify any Rarity file, option or saved setting, so Rarity updates never touch it.
--   * It listens to Rarity's own "found" moment (Rarity:ShowFoundAlert, which Rarity fires when
--     the item is looted) through hooksecurefunc, so the attempt count is Rarity's real one.
--   * Position/scale/duration/sound/effects live in the in-game Edit Mode (via LibEditMode), saved in
--     its own saved variable (RarityCustomPopupsDB).
--   * Chat commands are added to Rarity's own /rarity (and /rare) command: "/rarity test", "/rarity help".
--   * Rarity's own achievement toast keeps working exactly as before (it is controlled by Rarity's
--     existing "Show achievement toast" option, which this addon never touches).

local addonName = ...

-- Some clients expose the retail Edit Mode API without reporting the retail project ID.
if not C_EditMode or not EditModeManagerFrame then
	return
end

local LEM = LibStub("LibEditMode", true)
if not LEM then
	return
end

-- Rarity is looked up through AceAddon (not the global) so this keeps working even if Rarity stops exporting it
local Rarity = LibStub("AceAddon-3.0"):GetAddon("Rarity", true)
if not Rarity then
	return
end

local L = LibStub("AceLocale-3.0"):GetLocale("Rarity")
-- Rarity exports its constants on the addon object; fall back to the (stable) literal values if that ever changes
local CONSTANTS = Rarity.CONSTANTS
	or {
		ITEM_TYPES = { MOUNT = "MOUNT", PET = "PET", ITEM = "ITEM" },
		DETECTION_METHODS = { COLLECTION = "COLLECTION" },
	}

local MEDIA = "Interface\\AddOns\\" .. addonName .. "\\Media\\"
local FALLBACK_ICON = [[Interface\Icons\INV_Misc_PheonixPet_01]] -- same fallback Rarity's own toast uses
local ACHIEVEMENT_SOUND_FILE = 569143 -- the achievement sound file Rarity's own toast plays on retail

local TYPES = {
	mount = { label = "Mount Collected", color = { 0.64, 0.21, 0.93 }, editName = "Rarity Popup: Mount" },
	pet = { label = "Pet Collected", color = { 0.20, 0.70, 1.00 }, editName = "Rarity Popup: Pet" },
	toy = { label = "Toy Collected", color = { 1.00, 0.82, 0.00 }, editName = "Rarity Popup: Toy / Item" },
}
local ORDER = { "mount", "pet", "toy" }

local DEFAULT_POS = {
	mount = { point = "TOP", x = 0, y = -180 },
	pet = { point = "TOP", x = 0, y = -270 },
	toy = { point = "TOP", x = 0, y = -360 },
}
local DEFAULT_SETTINGS = {
	enabled = true,
	scale = 1,
	duration = 5,
	sound = true,
	onLearn = false,
	effects = true,
	effectStyle = "all", -- "all" | "confetti" | "shine"
	intensity = 100, -- confetti amount in percent
}

local PREVIEW = {
	mount = { "Preview Mount", 345787 },
	pet = { "Preview Pet", 132834 },
	toy = { "Preview Toy / Item", 5524923 },
}

local db
local popups, state = {}, {}
local editing = false
local hooks = { found = false, chat = false } -- which Rarity hooks are attached (shown by /rarity popups debug)
local shown = {} -- "mount:123" / "pet:456" / "toy:789" => true, used to avoid duplicate popups on learn

local function Print(msg)
	print("|cff9966ffRarity Popups:|r " .. msg)
end

---------------------------------------------------------------------
-- Saved variables (settings per type, positions per Edit Mode layout)
---------------------------------------------------------------------
local function InitDB()
	RarityCustomPopupsDB = RarityCustomPopupsDB or {}
	db = RarityCustomPopupsDB
	db.settings = db.settings or {}
	db.layouts = db.layouts or {}
	for _, kind in ipairs(ORDER) do
		local s = db.settings[kind] or {}
		for k, v in pairs(DEFAULT_SETTINGS) do
			if s[k] == nil then
				s[k] = v
			end
		end
		db.settings[kind] = s
	end
end

local function GetPos(layoutName, kind)
	db.layouts[layoutName] = db.layouts[layoutName] or {}
	local l = db.layouts[layoutName]
	if not l[kind] then
		l[kind] = CopyTable(DEFAULT_POS[kind])
	end
	return l[kind]
end

local function ApplyPosition(kind, layoutName)
	local p = GetPos(layoutName, kind)
	local f = popups[kind]
	f:ClearAllPoints()
	f:SetPoint(p.point, UIParent, p.point, p.x, p.y)
end

---------------------------------------------------------------------
-- Rounded frame textures (9-sliced)
---------------------------------------------------------------------
local BACKDROP = {
	bgFile = "Interface\\Buttons\\WHITE8x8",
	edgeFile = "Interface\\Buttons\\WHITE8x8",
	edgeSize = 1,
}
local RADIUS = 10

local function MakeRounded(f)
	f.bg = f:CreateTexture(nil, "BACKGROUND", nil, 0)
	f.bg:SetAllPoints()
	f.bg:SetTexture(MEDIA .. "bg.tga")
	f.bg:SetTextureSliceMargins(RADIUS, RADIUS, RADIUS, RADIUS)
	f.bg:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)

	f.border = f:CreateTexture(nil, "BACKGROUND", nil, 1)
	f.border:SetAllPoints()
	f.border:SetTexture(MEDIA .. "border.tga")
	f.border:SetTextureSliceMargins(RADIUS, RADIUS, RADIUS, RADIUS)
	f.border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched)
end

---------------------------------------------------------------------
-- Effects: shine sweep, icon pop, confetti burst
---------------------------------------------------------------------
local WHITE = "Interface\\Buttons\\WHITE8x8"
local ICON_X = 38 -- icon centre, measured from the popup's left edge
local MAX_PARTICLES = 80
local GRAVITY = 520
local GOLD_PALETTE = { { 1, 0.82, 0 }, { 1, 0.92, 0.4 }, { 1, 0.65, 0.1 }, { 1, 1, 1 } }

local function BuildPalette(kind, first)
	if first then
		return GOLD_PALETTE
	end
	local c = TYPES[kind].color
	return {
		c,
		{ c[1] + (1 - c[1]) * 0.5, c[2] + (1 - c[2]) * 0.5, c[3] + (1 - c[3]) * 0.5 },
		{ 1, 1, 1 },
		{ c[2], c[3], c[1] },
	}
end

local function ConfettiUpdate(fx, dt)
	local f = fx.owner
	if dt > 0.1 then
		dt = 0.1
	end
	local alive = 0
	for _, p in ipairs(f.particles) do
		if p.active then
			p.t = p.t + dt
			if p.t >= p.life then
				p.active = false
				p.tex:Hide()
			else
				p.vy = p.vy - GRAVITY * dt
				p.vx = p.vx * (1 - 1.5 * dt)
				p.x = p.x + p.vx * dt
				p.y = p.y + p.vy * dt
				local age = p.t / p.life
				p.tex:SetAlpha(age < 0.65 and 1 or (1 - age) / 0.35)
				-- fluttering: the piece's width follows a cosine, like a tumbling bit of paper
				p.tex:SetSize(math.max(1, p.w * math.abs(math.cos(p.phase + p.t * p.spin))), p.h)
				p.tex:ClearAllPoints()
				p.tex:SetPoint("CENTER", fx, "LEFT", ICON_X + p.x, p.y)
				alive = alive + 1
			end
		end
	end
	if alive == 0 then
		fx:SetScript("OnUpdate", nil)
		fx:Hide()
	end
end

local function StartConfetti(f, kind, first)
	local fx = f.fx
	local count = math.floor(40 * db.settings[kind].intensity / 100 + 0.5)
	count = math.max(5, math.min(MAX_PARTICLES, count))
	for i = #f.particles + 1, count do
		local tex = fx:CreateTexture(nil, "OVERLAY")
		tex:SetTexture(WHITE)
		tex:Hide()
		f.particles[i] = { tex = tex, active = false }
	end

	local palette = BuildPalette(kind, first)
	for i, p in ipairs(f.particles) do
		if i <= count then
			local color = palette[math.random(#palette)]
			local angle = math.random() * 2 * math.pi
			local speed = 120 + math.random() * 230
			p.active = true
			p.t = 0
			p.life = 1.1 + math.random() * 0.9
			p.x = math.random(-8, 8)
			p.y = math.random(-8, 8)
			p.vx = math.cos(angle) * speed
			p.vy = math.sin(angle) * speed + 140
			p.w = math.random(5, 9)
			p.h = math.random(3, 6)
			p.phase = math.random() * 2 * math.pi
			p.spin = 8 + math.random() * 8
			p.tex:SetVertexColor(color[1], color[2], color[3])
			p.tex:SetAlpha(1)
			p.tex:SetSize(p.w, p.h)
			p.tex:ClearAllPoints()
			p.tex:SetPoint("CENTER", fx, "LEFT", ICON_X + p.x, p.y)
			p.tex:Show()
		else
			p.active = false
			p.tex:Hide()
		end
	end
	fx:Show()
	fx:SetScript("OnUpdate", ConfettiUpdate)
end

local function StopEffects(f)
	if not f.effectsOK then
		return
	end
	f.shineAG:Stop()
	f.popAG:Stop()
	f.fx:SetScript("OnUpdate", nil)
	f.fx:Hide()
	for _, p in ipairs(f.particles) do
		p.active = false
		p.tex:Hide()
	end
end

-- force = true ignores the "Effects" checkbox (used by the Edit Mode preview buttons)
local function DoPlayEffects(kind, first, force)
	local cfg = db.settings[kind]
	if not (cfg.effects or force) then
		return
	end
	local f = popups[kind]
	local style = cfg.effectStyle
	if style == "all" or style == "shine" then
		f.shineAG:Stop()
		f.shineAG:Play()
		f.popAG:Stop()
		f.popAG:Play()
	end
	if style == "all" or style == "confetti" then
		StartConfetti(f, kind, first)
	end
end

local function PlayEffects(kind, first, force)
	local f = popups[kind]
	if not f.effectsOK then
		return
	end
	local ok, err = pcall(DoPlayEffects, kind, first, force)
	if not ok and not f.effectsErrorShown then
		f.effectsErrorShown = true
		Print("effect error, please report this: " .. tostring(err))
	end
end

local function CreateEffects(f)
	-- Shine sweep, clipped to the popup
	local clip = CreateFrame("Frame", nil, f)
	clip:SetPoint("TOPLEFT", 3, -3)
	clip:SetPoint("BOTTOMRIGHT", -3, 3)
	clip:SetFrameLevel(f:GetFrameLevel() + 3)
	clip:SetClipsChildren(true)

	local streak = CreateFrame("Frame", nil, clip)
	streak:SetWidth(44)
	streak:SetPoint("TOPRIGHT", clip, "TOPLEFT")
	streak:SetPoint("BOTTOMRIGHT", clip, "BOTTOMLEFT")
	local left = streak:CreateTexture(nil, "OVERLAY")
	left:SetTexture(WHITE)
	left:SetWidth(22)
	left:SetPoint("TOPLEFT")
	left:SetPoint("BOTTOMLEFT")
	left:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0), CreateColor(1, 1, 1, 0.3))
	local right = streak:CreateTexture(nil, "OVERLAY")
	right:SetTexture(WHITE)
	right:SetWidth(22)
	right:SetPoint("TOPRIGHT")
	right:SetPoint("BOTTOMRIGHT")
	right:SetGradient("HORIZONTAL", CreateColor(1, 1, 1, 0.3), CreateColor(1, 1, 1, 0))
	streak:Hide()

	local shine = streak:CreateAnimationGroup()
	local move = shine:CreateAnimation("Translation")
	move:SetOffset(340, 0)
	move:SetDuration(0.7)
	move:SetStartDelay(0.15)
	move:SetSmoothing("IN_OUT")
	shine:SetScript("OnPlay", function()
		streak:Show()
	end)
	shine:SetScript("OnFinished", function()
		streak:Hide()
	end)
	f.shineAG = shine

	-- Icon pop: grows with a little overshoot, then settles
	local pop = f.iconBorder:CreateAnimationGroup()
	local grow = pop:CreateAnimation("Scale")
	grow:SetOrder(1)
	grow:SetDuration(0.16)
	grow:SetScaleFrom(0.4, 0.4)
	grow:SetScaleTo(1.18, 1.18)
	grow:SetSmoothing("OUT")
	grow:SetOrigin("CENTER", 0, 0)
	local settle = pop:CreateAnimation("Scale")
	settle:SetOrder(2)
	settle:SetDuration(0.12)
	settle:SetScaleFrom(1.18, 1.18)
	settle:SetScaleTo(1, 1)
	settle:SetSmoothing("IN_OUT")
	settle:SetOrigin("CENTER", 0, 0)
	f.popAG = pop

	-- Confetti layer (not clipped, so pieces can fly outside the popup); particles are created on demand
	local fx = CreateFrame("Frame", nil, f)
	fx:SetAllPoints(f)
	fx:SetFrameLevel(f:GetFrameLevel() + 6)
	fx.owner = f
	fx:Hide()
	f.fx = fx
	f.particles = {}
end

---------------------------------------------------------------------
-- Popup frames
---------------------------------------------------------------------
local StartCountdown

local function CreatePopup(kind)
	local c = TYPES[kind].color
	local d = DEFAULT_POS[kind]
	local f = CreateFrame("Frame", nil, UIParent)
	f.editModeName = TYPES[kind].editName
	f:SetSize(300, 76)
	f:SetFrameStrata("DIALOG")
	f:SetFrameLevel(10)
	f:SetClampedToScreen(true)
	f:SetPoint(d.point, UIParent, d.point, d.x, d.y)
	MakeRounded(f)
	f.bg:SetVertexColor(0, 0, 0, 0.8)
	f.border:SetVertexColor(c[1], c[2], c[3], 1)

	f.iconBorder = CreateFrame("Frame", nil, f, "BackdropTemplate")
	f.iconBorder:SetSize(52, 52)
	f.iconBorder:SetPoint("LEFT", 12, 0)
	f.iconBorder:SetBackdrop(BACKDROP)
	f.iconBorder:SetBackdropColor(0, 0, 0, 1)
	f.iconBorder:SetBackdropBorderColor(c[1], c[2], c[3], 1)

	f.icon = f.iconBorder:CreateTexture(nil, "ARTWORK")
	f.icon:SetPoint("TOPLEFT", 1, -1)
	f.icon:SetPoint("BOTTOMRIGHT", -1, 1)
	f.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	f.title:SetPoint("TOPLEFT", f.iconBorder, "TOPRIGHT", 10, 1)
	f.title:SetTextColor(c[1], c[2], c[3])
	f.title:SetText(TYPES[kind].label)

	f.name = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
	f.name:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -4)
	f.name:SetPoint("RIGHT", f, "RIGHT", -12, 0)
	f.name:SetJustifyH("LEFT")
	f.name:SetWordWrap(false)

	f.attempts = f:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	f.attempts:SetPoint("TOPLEFT", f.name, "BOTTOMLEFT", 0, -4)
	f.attempts:SetPoint("RIGHT", f, "RIGHT", -12, 0)
	f.attempts:SetJustifyH("LEFT")
	f.attempts:SetWordWrap(false)
	f.attempts:SetTextColor(0.7, 0.7, 0.7)

	-- Effects are cosmetic: if anything in them fails, the popup and Edit Mode must still work
	local effectsOK, effectsErr = pcall(CreateEffects, f)
	f.effectsOK = effectsOK
	if not effectsOK then
		Print("effects disabled, please report this: " .. tostring(effectsErr))
	end

	-- Hovering keeps the popup up; the countdown restarts when the mouse leaves
	f:EnableMouse(true)
	f:SetScript("OnEnter", function()
		local s = state[kind]
		s.hover = true
		if not s.busy then
			return
		end
		s.token = s.token + 1 -- cancels any pending hide
		if s.fading then
			s.fading = false
			UIFrameFadeRemoveFrame(f)
			f:SetAlpha(1)
		end
	end)
	f:SetScript("OnLeave", function()
		local s = state[kind]
		s.hover = false
		if s.busy and not editing then
			StartCountdown(kind)
		end
	end)

	f:SetScale(db.settings[kind].scale)
	f:SetAlpha(0)
	f:Hide()
	popups[kind] = f
	state[kind] = { queue = {}, busy = false, hover = false, fading = false, token = 0 }
end

local function SetContent(f, title, name, icon, subText)
	f.title:SetText(title)
	f.icon:SetTexture(icon)
	f.name:SetText(name)
	f.attempts:SetText(subText or "")
end

---------------------------------------------------------------------
-- Queue / display
---------------------------------------------------------------------
local ShowNext

local function Finish(kind)
	local f, s = popups[kind], state[kind]
	s.token = s.token + 1
	local t = s.token
	s.fading = true
	UIFrameFadeOut(f, 0.5, f:GetAlpha(), 0)
	C_Timer.After(0.5, function()
		if s.token ~= t then
			return -- the mouse came back during the fade
		end
		s.fading = false
		s.busy = false
		s.hover = false
		if not editing then
			StopEffects(f)
			f:Hide()
		end
		ShowNext(kind)
	end)
end

-- (Re)starts the time-on-screen countdown; does nothing while the mouse is over the popup
StartCountdown = function(kind)
	local s = state[kind]
	s.token = s.token + 1
	local t = s.token
	C_Timer.After(db.settings[kind].duration, function()
		if s.token ~= t or s.hover then
			return
		end
		Finish(kind)
	end)
end

ShowNext = function(kind)
	local s, f = state[kind], popups[kind]
	if s.busy or editing then
		return
	end
	local item = table.remove(s.queue, 1)
	if not item then
		return
	end
	local cfg = db.settings[kind]
	s.busy = true
	f:SetScale(cfg.scale)
	SetContent(f, item.title, item.name, item.icon, item.subText)
	f:SetAlpha(0)
	f:Show()
	UIFrameFadeIn(f, 0.4, 0, 1)
	if cfg.sound then
		PlaySoundFile(ACHIEVEMENT_SOUND_FILE)
	end
	s.fading = false
	s.hover = f:IsMouseOver() and true or false
	PlayEffects(kind, item.first)
	StartCountdown(kind)
end

local function Enqueue(kind, title, name, icon, subText, first)
	table.insert(state[kind].queue, { title = title, name = name, icon = icon, subText = subText, first = first })
	ShowNext(kind)
end

---------------------------------------------------------------------
-- Rarity "found" hook (primary trigger: fires when the item is looted)
---------------------------------------------------------------------
local function AttemptsText(attempts, item)
	if item and item.method == CONSTANTS.DETECTION_METHODS.COLLECTION then
		return L["Collection Complete"]
	end
	if type(attempts) ~= "number" or attempts <= 1 then
		return L["Obtained On Your First Attempt"]
	end
	-- Reuse Rarity's localized string, but with thousands separators ("12,345")
	local fmt = (L["Obtained After %d Attempts"]:gsub("%%d", "%%s"))
	local ok, text = pcall(string.format, fmt, BreakUpLargeNumbers(attempts))
	if ok then
		return text
	end
	return format(L["Obtained After %d Attempts"], attempts)
end

-- First-attempt finds get the gold confetti
local function IsFirstAttempt(attempts, item)
	if item and item.method == CONSTANTS.DETECTION_METHODS.COLLECTION then
		return false
	end
	return type(attempts) ~= "number" or attempts <= 1
end

local function Classify(itemId, item)
	if item and item.type == CONSTANTS.ITEM_TYPES.MOUNT then
		return "mount", TYPES.mount.label
	elseif item and item.type == CONSTANTS.ITEM_TYPES.PET then
		return "pet", TYPES.pet.label
	end
	-- Rarity files toys and other items together ("Toy or Item")
	local isToy = C_ToyBox and C_ToyBox.GetToyInfo and C_ToyBox.GetToyInfo(itemId)
	return "toy", isToy and TYPES.toy.label or "Item Collected"
end

-- Key used to avoid showing a second popup when the same thing is later learned
local function DedupeKey(kind, itemId)
	if kind == "mount" then
		local mountId = C_MountJournal and C_MountJournal.GetMountFromItem and C_MountJournal.GetMountFromItem(itemId)
		if mountId and mountId ~= 0 then
			return "mount:" .. mountId
		end
	elseif kind == "pet" then
		local speciesId = C_PetJournal and C_PetJournal.GetPetInfoByItemID and select(13, C_PetJournal.GetPetInfoByItemID(itemId))
		if speciesId then
			return "pet:" .. speciesId
		end
	else
		return "toy:" .. itemId
	end
end

local function ResolveItem(itemId, tries, callback)
	local name, _, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemId)
	if name then
		callback(name, icon or C_Item.GetItemIconByID(itemId) or FALLBACK_ICON)
	elseif tries < 8 then
		C_Item.RequestLoadItemDataByID(itemId)
		C_Timer.After(0.5, function()
			ResolveItem(itemId, tries + 1, callback)
		end)
	end
end

local function OnRarityFound(itemId, attempts, item)
	if not db or not itemId then
		return
	end
	if item == nil and Rarity.Tracking and Rarity.Tracking.GetTrackedItem then
		item = Rarity.Tracking:GetTrackedItem()
	end

	local kind, title = Classify(itemId, item)
	if not db.settings[kind].enabled then
		return
	end

	local key = DedupeKey(kind, itemId)
	if key then
		shown[key] = true
	end

	local subText = AttemptsText(attempts, item)
	local first = IsFirstAttempt(attempts, item)
	ResolveItem(itemId, 0, function(name, icon)
		Enqueue(kind, title, name, icon, subText, first)
	end)
end

---------------------------------------------------------------------
-- Optional fallback: show when learned (off by default, per type)
---------------------------------------------------------------------
local function OnLearned(kind, key, name, icon)
	local cfg = db.settings[kind]
	if not (cfg.enabled and cfg.onLearn) then
		return
	end
	if key and shown[key] then
		return
	end
	if key then
		shown[key] = true
	end
	Enqueue(kind, TYPES[kind].label, name, icon, nil)
end

local function HandleMount(mountID)
	local name, _, icon = C_MountJournal.GetMountInfoByID(mountID)
	if name then
		OnLearned("mount", "mount:" .. mountID, name, icon)
	end
end

local function HandlePet(petGUID)
	local speciesID = C_PetJournal.GetPetInfoByPetID(petGUID)
	if not speciesID then
		return
	end
	local name, icon = C_PetJournal.GetPetInfoBySpeciesID(speciesID)
	if name then
		OnLearned("pet", "pet:" .. speciesID, name, icon)
	end
end

local function HandleToy(itemID, tries)
	tries = tries or 0
	local name = C_Item.GetItemNameByID(itemID)
	local icon = C_Item.GetItemIconByID(itemID)
	if name and icon then
		OnLearned("toy", "toy:" .. itemID, name, icon)
	elseif tries < 8 then
		C_Item.RequestLoadItemDataByID(itemID)
		C_Timer.After(0.5, function()
			HandleToy(itemID, tries + 1)
		end)
	end
end

---------------------------------------------------------------------
-- Edit Mode integration
---------------------------------------------------------------------
local function BuildSettings(kind)
	local function cfg()
		return db.settings[kind]
	end
	return {
		{
			name = "Enabled",
			kind = LEM.SettingType.Checkbox,
			default = DEFAULT_SETTINGS.enabled,
			get = function()
				return cfg().enabled
			end,
			set = function(_, v)
				cfg().enabled = v
			end,
		},
		{
			name = "Scale",
			kind = LEM.SettingType.Slider,
			default = DEFAULT_SETTINGS.scale,
			minValue = 0.5,
			maxValue = 2,
			valueStep = 0.05,
			formatter = function(v)
				return string.format("%.2f", v)
			end,
			get = function()
				return cfg().scale
			end,
			set = function(_, v)
				cfg().scale = v
				popups[kind]:SetScale(v)
			end,
		},
		{
			name = "Duration (sec)",
			kind = LEM.SettingType.Slider,
			default = DEFAULT_SETTINGS.duration,
			minValue = 1,
			maxValue = 30,
			valueStep = 1,
			formatter = function(v)
				return string.format("%d", v)
			end,
			get = function()
				return cfg().duration
			end,
			set = function(_, v)
				cfg().duration = v
			end,
		},
		{
			name = "Play sound",
			kind = LEM.SettingType.Checkbox,
			default = DEFAULT_SETTINGS.sound,
			get = function()
				return cfg().sound
			end,
			set = function(_, v)
				cfg().sound = v
			end,
		},
		{
			name = "Also show on learn",
			desc = "Also show a popup when this is learned/collected through the game, for things Rarity did not announce (no attempt count).",
			kind = LEM.SettingType.Checkbox,
			default = DEFAULT_SETTINGS.onLearn,
			get = function()
				return cfg().onLearn
			end,
			set = function(_, v)
				cfg().onLearn = v
			end,
		},
		{
			name = "Effects",
			desc = "Shine, icon pop and confetti when the popup appears.",
			kind = LEM.SettingType.Checkbox,
			default = DEFAULT_SETTINGS.effects,
			get = function()
				return cfg().effects
			end,
			set = function(_, v)
				cfg().effects = v
			end,
		},
		{
			name = "Effect style",
			kind = LEM.SettingType.Dropdown,
			default = DEFAULT_SETTINGS.effectStyle,
			values = {
				{ text = "Shine + icon pop + confetti", value = "all" },
				{ text = "Confetti only", value = "confetti" },
				{ text = "Shine + icon pop only", value = "shine" },
			},
			get = function()
				return cfg().effectStyle
			end,
			set = function(_, v)
				cfg().effectStyle = v
			end,
		},
		{
			name = "Confetti amount",
			kind = LEM.SettingType.Slider,
			default = DEFAULT_SETTINGS.intensity,
			minValue = 25,
			maxValue = 200,
			valueStep = 25,
			formatter = function(v)
				return string.format("%d%%", v)
			end,
			get = function()
				return cfg().intensity
			end,
			set = function(_, v)
				cfg().intensity = v
			end,
		},
	}
end

local function AddPreviewButtons(f, kind)
	local buttons = {
		{
			text = "Preview effect",
			click = function()
				PlayEffects(kind, false, true)
			end,
		},
		{
			text = "Preview first-attempt effect",
			click = function()
				PlayEffects(kind, true, true)
			end,
		},
	}
	-- older LibEditMode copies (loaded by other addons) only have the single-button function
	if LEM.AddFrameSettingsButtons then
		LEM:AddFrameSettingsButtons(f, buttons)
	elseif LEM.AddFrameSettingsButton then
		for _, button in ipairs(buttons) do
			LEM:AddFrameSettingsButton(f, button)
		end
	end
end

local function SetupEditMode()
	for _, kind in ipairs(ORDER) do
		local f = popups[kind]
		local ok, err = pcall(function()
			LEM:AddFrame(f, function(_, layoutName, point, x, y)
				local p = GetPos(layoutName, kind)
				p.point, p.x, p.y = point, x, y
			end, DEFAULT_POS[kind], TYPES[kind].editName)
			LEM:AddFrameSettings(f, BuildSettings(kind))
		end)
		if not ok then
			Print("Edit Mode setup failed for the " .. kind .. " popup: " .. tostring(err))
		end
		-- the preview buttons are a bonus: never let them break the settings
		local btnOK, btnErr = pcall(AddPreviewButtons, f, kind)
		if not btnOK then
			Print("Edit Mode preview buttons unavailable: " .. tostring(btnErr))
		end
	end

	LEM:RegisterCallback("layout", function(layoutName)
		for _, kind in ipairs(ORDER) do
			ApplyPosition(kind, layoutName)
		end
	end)

	LEM:RegisterCallback("enter", function()
		editing = true
		for _, kind in ipairs(ORDER) do
			local f = popups[kind]
			local selection = LEM.frameSelections and LEM.frameSelections[f]
			if selection then
				selection:SetFrameStrata("TOOLTIP")
			end
			local pv = PREVIEW[kind]
			if not state[kind].busy then
				SetContent(f, TYPES[kind].label, pv[1], pv[2], AttemptsText(1234))
			end
			f:SetScale(db.settings[kind].scale)
			f:SetAlpha(1)
			f:Show()
		end
	end)

	LEM:RegisterCallback("exit", function()
		editing = false
		for _, kind in ipairs(ORDER) do
			local f = popups[kind]
			local selection = LEM.frameSelections and LEM.frameSelections[f]
			if selection then
				selection:SetFrameStrata(f:GetFrameStrata())
			end
			if not state[kind].busy then
				StopEffects(popups[kind])
				popups[kind]:Hide()
				popups[kind]:SetAlpha(0)
			else
				state[kind].fading = false
				popups[kind]:SetAlpha(1)
				StartCountdown(kind)
			end
			ShowNext(kind)
		end
	end)
end

---------------------------------------------------------------------
-- Chat commands: added to Rarity's own /rarity (and /rare); everything else is passed through untouched
---------------------------------------------------------------------
local function RunTest(args)
	local one, first
	for word in args:gmatch("%S+") do
		if TYPES[word] then
			one = word
		elseif word == "item" then
			one = "toy"
		elseif word == "first" then
			first = true
		end
	end
	local icons = { mount = 345787, pet = 132834, toy = 5524923 }
	local names = { mount = "Test Mount", pet = "Test Pet", toy = "Test Toy" }
	for _, k in ipairs(one and { one } or ORDER) do
		local attempts = first and 1 or math.random(1, 20000)
		Enqueue(k, TYPES[k].label, names[k], icons[k], AttemptsText(attempts), IsFirstAttempt(attempts))
	end
end

local function ResetPopups()
	local layout = LEM:GetActiveLayoutName() or "Modern"
	db.layouts[layout] = nil
	for _, kind in ipairs(ORDER) do
		ApplyPosition(kind, layout)
		db.settings[kind] = CopyTable(DEFAULT_SETTINGS)
		popups[kind]:SetScale(DEFAULT_SETTINGS.scale)
	end
	Print("popup positions (current layout) and settings reset to defaults.")
end

local function PrintHelp()
	print("|cff9966ffRarity|r commands (|cffffd100/rarity|r or |cffffd100/rare|r):")
	print("  |cffffd100/rarity|r - open the options")
	print("  |cffffd100/rarity test [mount-pet-toy] [first]|r - show a test popup (random attempts; 'first' = first attempt, gold confetti)")
	print("  |cffffd100/rarity popups reset|r - reset popup positions and settings")
	print("  |cffffd100/rarity popups debug|r - print Edit Mode / popup diagnostics")
	print("  Popup position, size, duration, sound and effects: Edit Mode, click a popup")
	print("  |cffffd100/rarity progress|r - toggle the progress bar")
	print("  |cffffd100/rarity multifarm <number>|r - count each detected attempt as <number> attempts")
	print("  |cffffd100/rarity debug|r, |cffffd100dump|r, |cffffd100validate|r, |cffffd100mapinfo|r, |cffffd100purge|r, |cffffd100profiling|r, |cffffd100tinspect|r - debugging tools")
	print("  |cffffd100/rarity test integration|r - Rarity's own integration tests (needs WoWUnit)")
end

local function PrintDebug()
	local _, minor = LibStub("LibEditMode", true)
	print("|cff9966ffRarity Popups debug|r")
	print("  LibEditMode minor: " .. tostring(minor) .. " (this addon ships 18)")
	print("  AddFrameSettingsButtons: " .. tostring(LEM.AddFrameSettingsButtons ~= nil))
	print("  Hooked Rarity: found event=" .. tostring(hooks.found) .. ", /rarity command=" .. tostring(hooks.chat))
	print("  Edit Mode active: " .. tostring(LEM.isEditing) .. ", editing flag: " .. tostring(editing))
	print("  Active layout: " .. tostring(LEM:GetActiveLayoutName()))
	for _, kind in ipairs(ORDER) do
		local f = popups[kind]
		local registered = LEM.frameSelections and LEM.frameSelections[f] ~= nil
		local settings = LEM.frameSettings and LEM.frameSettings[f]
		local buttons = LEM.frameButtons and LEM.frameButtons[f]
		print(
			format(
				"  %s: registered=%s settings=%s buttons=%s effectsOK=%s shown=%s",
				kind,
				tostring(registered),
				tostring(settings and #settings or 0),
				tostring(buttons and #buttons or 0),
				tostring(f.effectsOK),
				tostring(f:IsShown())
			)
		)
	end
end

-- Returns true when the command was handled here, or false plus (optionally) a replacement input for Rarity
local function HandleCommand(input)
	if not db then
		return false
	end
	local cmd, rest = strtrim(input or ""):match("^(%S*)%s*(.-)$")
	cmd, rest = cmd:lower(), rest:lower()

	if cmd == "test" then
		if rest == "integration" then
			return false, "test" -- Rarity's original /rarity test
		end
		RunTest(rest)
		return true
	elseif cmd == "popups" or cmd == "popup" then
		local sub, subRest = rest:match("^(%S*)%s*(.-)$")
		if sub == "test" then
			RunTest(subRest)
		elseif sub == "reset" then
			ResetPopups()
		elseif sub == "debug" then
			PrintDebug()
		else
			PrintHelp()
		end
		return true
	elseif cmd == "help" or cmd == "?" then
		PrintHelp()
		return true
	end
	return false
end

local function HookChatCommand()
	local original = Rarity.OnChatCommand
	if type(original) ~= "function" then
		-- Rarity changed its command handler: keep the popup commands reachable under their own command
		SLASH_RARITYPOPUPS1 = "/rpop"
		SlashCmdList["RARITYPOPUPS"] = function(msg)
			if not HandleCommand(msg) then
				PrintHelp()
			end
		end
		Print("could not attach to /rarity, use |cffffd100/rpop|r instead (e.g. /rpop test).")
		return
	end
	Rarity.OnChatCommand = function(self, input, ...)
		local handled, replacement = HandleCommand(input)
		if handled then
			return
		end
		return original(self, replacement or input, ...)
	end
	hooks.chat = true
end

---------------------------------------------------------------------
-- Setup
---------------------------------------------------------------------
local function Initialize()
	InitDB()
	for _, kind in ipairs(ORDER) do
		CreatePopup(kind)
	end
	SetupEditMode()

	HookChatCommand()

	-- Rarity's own "found" moment. hooksecurefunc runs after the original, so Rarity behaves exactly as before.
	if type(Rarity.ShowFoundAlert) == "function" then
		hooksecurefunc(Rarity, "ShowFoundAlert", function(_, itemId, attempts, item)
			xpcall(function()
				OnRarityFound(itemId, attempts, item)
			end, geterrorhandler())
		end)
		hooks.found = true
	else
		Print("this Rarity version has no ShowFoundAlert anymore, so finds won't show a popup (test popups still work). Please report this.")
	end
end

local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == addonName then
		self:UnregisterEvent("ADDON_LOADED")
		Initialize()
		-- Optional learn fallback; events are registered defensively in case one doesn't exist
		pcall(self.RegisterEvent, self, "NEW_MOUNT_ADDED")
		pcall(self.RegisterEvent, self, "NEW_PET_ADDED")
		pcall(self.RegisterEvent, self, "NEW_TOY_ADDED")
	elseif event == "NEW_MOUNT_ADDED" then
		HandleMount(arg1)
	elseif event == "NEW_PET_ADDED" then
		HandlePet(arg1)
	elseif event == "NEW_TOY_ADDED" then
		HandleToy(arg1)
	end
end)
