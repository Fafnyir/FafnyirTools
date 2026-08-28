local ADDON_NAME, ns = ...

local feature = {
    key = "Resting",
    page = "Unit Frames",
    searchTerms = {
        "resting",
        "rest icon",
        "zzz",
        "player resting",
    },
}

ns:RegisterFeature(feature.key, feature)

local MAX_LEVEL = 90
local PLAYER_FRAME_NAME = "EllesmereUIUnitFrames_Player"

local overlayHost
local indicator
local animation
local initialized = false
local retryTicker

local function DB()
    return ns:GetDatabase().resting
end

local function StopRetry()
    if retryTicker then
        retryTicker:Cancel()
        retryTicker = nil
    end
end

function feature:ApplyLayout()
    if not indicator then return end

    local playerFrame = _G[PLAYER_FRAME_NAME]
    if not playerFrame then return end

    local settings = DB()
    local defaults = ns.defaults.resting

    indicator:SetSize(
        tonumber(settings.size) or defaults.size,
        tonumber(settings.size) or defaults.size
    )

    if indicator._texture then
        indicator._texture:ClearAllPoints()
        indicator._texture:SetAllPoints(indicator)
    end

    indicator:ClearAllPoints()
    indicator:SetPoint(
        "BOTTOMRIGHT",
        playerFrame,
        "TOPRIGHT",
        tonumber(settings.offsetX) or defaults.offsetX,
        tonumber(settings.offsetY) or defaults.offsetY
    )

    local maxLevel = playerFrame:GetFrameLevel()
    local children = { playerFrame:GetChildren() }

    for i = 1, #children do
        local child = children[i]
        if child and child ~= overlayHost and child.GetFrameLevel then
            maxLevel = math.max(maxLevel, child:GetFrameLevel())
        end
    end

    if overlayHost then
        overlayHost:SetFrameStrata(playerFrame:GetFrameStrata())
        overlayHost:SetFrameLevel(maxLevel + 1)
    end

    indicator:SetFrameStrata(playerFrame:GetFrameStrata())
    indicator:SetFrameLevel(
        (overlayHost and overlayHost:GetFrameLevel() or maxLevel) + 1
    )
end

function feature:UpdateVisibility()
    if not indicator or not animation then return end

    local settings = DB()
    local hideAtMaxLevel =
        settings.hideAtMaxLevel
        and UnitLevel("player") >= MAX_LEVEL

    local shouldShow =
        settings.enabled
        and IsResting()
        and not hideAtMaxLevel

    if shouldShow then
        indicator:Show()

        if not animation:IsPlaying() then
            animation:Play()
        end
    else
        indicator:Hide()

        if animation:IsPlaying() then
            animation:Stop()
        end
    end
end

function feature:Refresh()
    self:ApplyLayout()
    self:UpdateVisibility()
end

function feature:CreateIndicator(playerFrame)
    if indicator then return end

    overlayHost = CreateFrame(
        "Frame",
        "FafnyirToolsRestingOverlay",
        playerFrame
    )
    overlayHost:SetAllPoints(playerFrame)
    overlayHost:EnableMouse(false)

    indicator = CreateFrame(
        "Frame",
        "FafnyirToolsRestingFrame",
        overlayHost
    )
    indicator:EnableMouse(false)

    local texture = indicator:CreateTexture(nil, "OVERLAY", nil, 7)
    texture:SetAtlas("UI-HUD-UnitFrame-Player-Rest-Flipbook", false)
    texture:SetAllPoints(indicator)
    indicator._texture = texture

    animation = texture:CreateAnimationGroup()
    animation:SetLooping("REPEAT")

    local flipbook = animation:CreateAnimation("Flipbook")
    flipbook:SetDuration(1.5)
    flipbook:SetOrder(1)
    flipbook:SetFlipBookFrames(42)
    flipbook:SetFlipBookRows(7)
    flipbook:SetFlipBookColumns(6)

    indicator:Hide()
    self:Refresh()
end

function feature:TryInitialize()
    if initialized then return true end

    local playerFrame = _G[PLAYER_FRAME_NAME]
    if not playerFrame then return false end

    initialized = true
    StopRetry()
    self:CreateIndicator(playerFrame)
    return true
end

function feature:Initialize()
    if not self:TryInitialize() and not retryTicker then
        retryTicker = C_Timer.NewTicker(0.5, function()
            feature:TryInitialize()
        end)
    end
end

function feature:Reset()
    local settings = DB()

    for key, value in pairs(ns.defaults.resting) do
        settings[key] = value
    end

    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "RESTING INDICATOR", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable Resting Indicator",
            getValue = function()
                return DB().enabled
            end,
            setValue = function(value)
                DB().enabled = value
                feature:Refresh()
            end,
        },
        {
            type = "toggle",
            text = "Hide at Max Level",
            getValue = function()
                return DB().hideAtMaxLevel
            end,
            setValue = function(value)
                DB().hideAtMaxLevel = value
                feature:Refresh()
            end,
        }
    )
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "slider",
            text = "Horizontal Offset",
            min = -100,
            max = 100,
            step = 1,
            getValue = function()
                return DB().offsetX
            end,
            setValue = function(value)
                DB().offsetX = value
                feature:ApplyLayout()
            end,
        },
        {
            type = "slider",
            text = "Vertical Offset",
            min = -100,
            max = 100,
            step = 1,
            getValue = function()
                return DB().offsetY
            end,
            setValue = function(value)
                DB().offsetY = value
                feature:ApplyLayout()
            end,
        }
    )
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "slider",
            text = "Resting Icon Size",
            min = 16,
            max = 96,
            step = 1,
            getValue = function()
                return DB().size
            end,
            setValue = function(value)
                DB().size = value
                feature:ApplyLayout()
            end,
        },
        {
            type = "button",
            text = "Reset Resting Settings",
            buttonText = "Reset",
            onClick = function()
                feature:Reset()

                if EllesmereUI and EllesmereUI.RefreshPage then
                    EllesmereUI:RefreshPage(true)
                end
            end,
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
        if not initialized then
            self:TryInitialize()
        end

        self:Refresh()
    end
end

SLASH_FAFNYIRRESTING1 = "/fafrest"
SlashCmdList["FAFNYIRRESTING"] = function()
    DB().enabled = not DB().enabled
    feature:Refresh()

    ns:Print(
        "Resting "
        .. (DB().enabled and "enabled." or "disabled.")
    )
end
