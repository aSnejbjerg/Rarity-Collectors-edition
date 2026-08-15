local Tooltips = {}

-- Since LibQTip is embedded into release versions as a mandatory dependency, we can rely on it being available
-- This means we don't need to perform additional checks like we do before using the TSM_API inside this module

-- Dependencies are loaded before any of our own files, so it should be safe to cache it on load
local LibQTip = LibStub("LibQTip-1.0")

-- LibQTip scrolls by 10 pixels per wheel click, which is less than the height of a single row: the
-- collection list barely moves. Scroll by whole rows instead, derived from the tooltip's own font so
-- it keeps up if the font size changes.
local SCROLL_ROWS_PER_WHEEL_CLICK = 3
local FALLBACK_FONT_HEIGHT = 12 -- GameTooltipText's height, if the font object won't report one
local ROW_SPACING = 3 -- LibQTip's CELL_MARGIN_V, the vertical gap it puts between rows

local function SetScrollStepInRows(tooltip, rows)
	local font = tooltip.GetFont and tooltip:GetFont()
	local _, fontHeight = font and font:GetFont()

	tooltip:SetScrollStep(rows * ((fontHeight or FALLBACK_FONT_HEIGHT) + ROW_SPACING))
end

function Tooltips:IsTooltipAcquired(tooltipName)
	return LibQTip:IsAcquired(tooltipName)
end

-- TODO Separate acquire from create and don't forward varargs here
function Tooltips:AcquireTooltip(tooltipName, ...)
	local tooltip = LibQTip:Acquire(tooltipName, ...)

	-- LibQTip clears the scroll step when a tooltip is released, so this has to be set on every acquire
	SetScrollStepInRows(tooltip, SCROLL_ROWS_PER_WHEEL_CLICK)

	return tooltip
end

function Tooltips:ReleaseTooltip(tooltipName)
	return LibQTip:Release(tooltipName)
end

-- No idea why this is used directly, but let's worry about that later
function Tooltips:GetLabelProvider()
	return LibQTip.LabelProvider
end

Rarity.Tooltips = Tooltips
