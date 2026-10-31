local ADDON_NAME, ns = ...
if ns.HAS_ELLESMEREUI then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "NativeResting",
    page = T("CORE.QOL"),
    searchTerms = { "resting", "rest icon", "zzz", "native player frame" },
}
ns:RegisterFeature(feature.key, feature)

local restIcon
local originalPoints
local updateHooked = false

local function DB()
    return ns:GetDatabase().nativeResting
end

local function PlayerAtMaxLevel()
    local level = UnitLevel("player") or 0
    if IsPlayerAtEffectiveMaxLevel and IsPlayerAtEffectiveMaxLevel() then return true end
    if IsLevelAtEffectiveMaxLevel and IsLevelAtEffectiveMaxLevel(level) then return true end
    local maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
        or (GetMaxPlayerLevel and GetMaxPlayerLevel())
    return type(maxLevel) == "number" and level >= maxLevel
end

local function FindNestedRestIcon()
    local playerFrame = _G.PlayerFrame
    if not playerFrame then return nil end

    local content = playerFrame.PlayerFrameContent
    local main = content and content.PlayerFrameContentMain
    local contextual = content and content.PlayerFrameContentContextual
    local status = main and (main.StatusContainer or main.Status)
    return (contextual and contextual.PlayerRestLoop)
        or playerFrame.RestIcon
        or (content and content.RestIcon)
        or (main and main.RestIcon)
        or (status and status.RestIcon)
end

local function ResolveRestIcon()
    local candidate = FindNestedRestIcon() or _G.PlayerRestIcon
    if candidate and candidate.GetNumPoints and candidate.GetPoint then
        if candidate ~= restIcon then
            restIcon = candidate
            originalPoints = nil
        end
        return restIcon
    end
    return nil
end

local function CaptureOriginalPoints(icon)
    if originalPoints then return end
    originalPoints = {}
    for index = 1, icon:GetNumPoints() do
        local point, relativeTo, relativePoint, x, y = icon:GetPoint(index)
        originalPoints[index] = { point, relativeTo, relativePoint, x or 0, y or 0 }
    end
end

local function RestoreOriginalPoints(icon)
    if not originalPoints or #originalPoints == 0 then return end
    icon:ClearAllPoints()
    for _, anchor in ipairs(originalPoints) do
        icon:SetPoint(anchor[1], anchor[2], anchor[3], anchor[4], anchor[5])
    end
end

local function AskBlizzardToRefresh()
    if type(_G.PlayerFrame_UpdateStatus) == "function" then
        _G.PlayerFrame_UpdateStatus()
    end
end

function feature:ApplyLayout()
    local icon = ResolveRestIcon()
    if not icon then return false end
    CaptureOriginalPoints(icon)

    local settings = DB()
    RestoreOriginalPoints(icon)
    if not settings.enabled then return true end

    local xOffset = tonumber(settings.offsetX) or 0
    local yOffset = tonumber(settings.offsetY) or 0
    if xOffset == 0 and yOffset == 0 then return true end

    icon:ClearAllPoints()
    for _, anchor in ipairs(originalPoints) do
        icon:SetPoint(
            anchor[1], anchor[2], anchor[3],
            (anchor[4] or 0) + xOffset,
            (anchor[5] or 0) + yOffset
        )
    end
    return true
end

function feature:UpdateVisibility()
    local icon = ResolveRestIcon()
    if not icon then return false end
    local settings = DB()
    if settings.enabled and settings.hideAtMaxLevel and PlayerAtMaxLevel() then
        icon:Hide()
    end
    return true
end

function feature:Refresh()
    local settings = DB()
    self:ApplyLayout()
    AskBlizzardToRefresh()
    self:UpdateVisibility()
    if not settings.enabled and restIcon then RestoreOriginalPoints(restIcon) end
end

function feature:Initialize()
    self:Refresh()
    if not updateHooked and type(hooksecurefunc) == "function"
        and type(_G.PlayerFrame_UpdatePlayerRestLoop) == "function"
    then
        updateHooked = true
        hooksecurefunc("PlayerFrame_UpdatePlayerRestLoop", function()
            feature:ApplyLayout()
            feature:UpdateVisibility()
        end)
    end
end

function feature:Reset()
    local settings = DB()
    for key, value in pairs(ns.defaults.nativeResting) do settings[key] = value end
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, T("QOL.NATIVE_RESTING_INDICATOR"), y)
    y = y - h

    _, h = W:DualRow(parent, y,
        {
            type = "toggle", text = T("QOL.ENABLE_NATIVE_RESTING_CONTROLS"),
            getValue = function() return DB().enabled end,
            setValue = function(value) DB().enabled = value; feature:Refresh() end,
        },
        {
            type = "toggle", text = T("UNIT_FRAMES.HIDE_AT_MAX_LEVEL"),
            disabled = function() return not DB().enabled end,
            getValue = function() return DB().hideAtMaxLevel end,
            setValue = function(value) DB().hideAtMaxLevel = value; feature:Refresh() end,
        }
    )
    y = y - h

    _, h = W:TripleRow(parent, y,
        {
            type = "slider", text = T("UNIT_FRAMES.HORIZONTAL_OFFSET"),
            min = -25, max = 130, step = 1,
            disabled = function() return not DB().enabled end,
            getValue = function() return DB().offsetX end,
            setValue = function(value) DB().offsetX = value; feature:ApplyLayout() end,
        },
        {
            type = "slider", text = T("UNIT_FRAMES.VERTICAL_OFFSET"),
            min = -25, max = 25, step = 1,
            disabled = function() return not DB().enabled end,
            getValue = function() return DB().offsetY end,
            setValue = function(value) DB().offsetY = value; feature:ApplyLayout() end,
        },
        {
            type = "button", text = T("QOL.RESET_NATIVE_RESTING_SETTINGS"),
            buttonText = T("UNIT_FRAMES.RESET"),
            onClick = function() feature:Reset(); EllesmereUI:RefreshPage(true) end,
        }
    )
    y = y - h
    return math.abs(y)
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD"
        or event == "PLAYER_UPDATE_RESTING"
        or event == "PLAYER_LEVEL_UP"
    then
        self:Refresh()
    end
end
