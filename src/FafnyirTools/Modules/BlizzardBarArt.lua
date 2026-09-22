local ADDON_NAME, ns = ...

local feature = {
    key = "BlizzardBarArt",
    page = "Action Bars",
    searchTerms = {
        "blizzard",
        "bar art",
        "action bar",
        "end caps",
        "gryphon",
    },
}
ns:RegisterFeature(feature.key, feature)

local holder
local sourceBar
local borderArt
local endCaps

local original = {}
local watched = setmetatable({}, { __mode = "k" })
local refreshQueued = false

local function DB()
    return ns:GetDatabase().blizzardBarArt
end

local function MainBar()
    return _G.EABBar_MainBar
end

local function SourceBar()
    return _G.MainActionBar
end

local Refresh

local function QueueRefresh()
    if refreshQueued then return end
    refreshQueued = true
    C_Timer.After(0, function()
        refreshQueued = false
        Refresh()
    end)
end

local function WatchArtwork(frame)
    if not frame or watched[frame] then return end
    if frame.HookScript then
        frame:HookScript("OnHide", QueueRefresh)
    end
    if hooksecurefunc then
        hooksecurefunc(frame, "SetAlpha", function(_, alpha)
            if DB().enabled and alpha == 0 then QueueRefresh() end
        end)
        hooksecurefunc(frame, "SetParent", function(_, newParent)
            if DB().enabled and holder and newParent ~= holder then QueueRefresh() end
        end)
    end
    watched[frame] = true
end

local function SaveFrameState(frame)
    if not frame or original[frame] then return end

    local state = {
        parent = frame:GetParent(),
        width = frame:GetWidth(),
        height = frame:GetHeight(),
        scale = frame:GetScale(),
        points = {},
    }

    for i = 1, frame:GetNumPoints() do
        state.points[i] = { frame:GetPoint(i) }
    end

    original[frame] = state
end

local function EnsureHolder(target)
    if not holder then
        holder = CreateFrame("Frame", "FafnyirToolsBlizzardBarArt", UIParent)
        holder:SetFrameStrata("BACKGROUND")
        holder:SetFrameLevel(1)
        holder:EnableMouse(false)
    end

    holder:ClearAllPoints()
    holder:SetPoint("CENTER", target, "CENTER", 0, 0)
    holder:SetSize(target:GetWidth() + 260, math.max(target:GetHeight() + 120, 140))
    holder:SetAlpha(1)
    holder:Show()
end

local function ArtworkScale(target)
    -- Ellesmere lays out action buttons from a native 45x45 button footprint.
    -- Read the first live Bar 1 button instead of MainActionBar: Ellesmere's
    -- early Blizzard-bar disposal can leave MainActionBar at a stale width.
    local button = _G.EABButton1
    local buttonW = button and button:GetWidth()
    if not buttonW or buttonW <= 0 then return 1 end

    -- Blizzard-style buttons remain 45 units wide and use SetScale(); custom
    -- style buttons change GetWidth(). Effective scale covers both paths.
    local buttonScale = button:GetEffectiveScale() or 1
    local holderScale = holder and holder:GetEffectiveScale() or 1
    if holderScale <= 0 then holderScale = 1 end

    -- Blizzard's decorative frame needs a small visual calibration that can
    -- vary with the installation's UI scale and rendering setup.
    local calibration = tonumber(DB().scaleMultiplier) or 1.06
    calibration = math.max(1.00, math.min(1.10, calibration))
    local scale = (buttonW / 45) * (buttonScale / holderScale) * calibration
    if scale <= 0 or scale > 4 then return 1 end
    return scale
end

local function LayoutBorder(target, scale)
    if not borderArt then return end

    SaveFrameState(borderArt)

    local sourceW = original[borderArt] and original[borderArt].width or borderArt:GetWidth()
    local sourceH = original[borderArt] and original[borderArt].height or borderArt:GetHeight()

    if not sourceW or sourceW <= 0 then sourceW = target:GetWidth() end
    if not sourceH or sourceH <= 0 then sourceH = target:GetHeight() end

    borderArt:SetParent(holder)
    borderArt:ClearAllPoints()
    borderArt:SetScale(1)
    borderArt:SetSize(sourceW * scale, sourceH * scale)
    borderArt:SetPoint("CENTER", target, "CENTER", 0, -2)
    borderArt:SetAlpha(1)
    borderArt:Show()
end

local function LayoutEndCaps(target, scale)
    if not endCaps then return end

    SaveFrameState(endCaps)

    local sourceW = original[endCaps] and original[endCaps].width or endCaps:GetWidth()
    local sourceH = original[endCaps] and original[endCaps].height or endCaps:GetHeight()

    if not sourceW or sourceW <= 0 then sourceW = target:GetWidth() end
    if not sourceH or sourceH <= 0 then sourceH = target:GetHeight() end

    endCaps:SetParent(holder)
    endCaps:ClearAllPoints()
    endCaps:SetScale(1)
    endCaps:SetSize(sourceW * scale, sourceH * scale)
    endCaps:SetPoint("CENTER", target, "CENTER", 0, -4)
    endCaps:SetAlpha(1)
    endCaps:Show()
end

local function Install()
    local target = MainBar()
    local currentSource = SourceBar()
    if not (target and currentSource) then return end

    -- Blizzard/EllesmereUI can rebuild or replace these regions while applying
    -- Edit Mode, paging, vehicle, zone, or specialization state. Resolve the
    -- live objects every time instead of trusting the login-time references.
    sourceBar = currentSource
    borderArt = currentSource.BorderArt
    endCaps = currentSource.EndCaps
    if not (borderArt or endCaps) then return end

    WatchArtwork(borderArt)
    WatchArtwork(endCaps)

    EnsureHolder(target)
    local scale = ArtworkScale(target)
    LayoutBorder(target, scale)
    LayoutEndCaps(target, scale)

end

Refresh = function()
    if not DB().enabled then
        if holder then holder:Hide() end
        return
    end

    Install()
end

local function RefreshSoon()
    C_Timer.After(0, Refresh)
    C_Timer.After(0.25, Refresh)
    C_Timer.After(1, Refresh)
    C_Timer.After(2, Refresh)
end

local function WatchLayout(target)
    if target and not watched[target] then
        target:HookScript("OnSizeChanged", function()
            C_Timer.After(0, Refresh)
        end)
        watched[target] = true
    end

    local button = _G.EABButton1
    if button and not watched[button] then
        button:HookScript("OnSizeChanged", function()
            C_Timer.After(0, Refresh)
        end)
        watched[button] = true
    end

end

function feature:Initialize()
    local f = CreateFrame("Frame")
    f:RegisterEvent("PLAYER_LOGIN")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    f:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
    f:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    f:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
    f:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
    f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    f:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:SetScript("OnEvent", function()
        RefreshSoon()
        C_Timer.After(0, function()
            WatchLayout(MainBar())
        end)
    end)

    RefreshSoon()
    C_Timer.After(2, function()
        WatchLayout(MainBar())
        Refresh()
    end)
end

function feature:Refresh()
    RefreshSoon()
end

function feature:Reset()
    DB().enabled = ns.defaults.blizzardBarArt.enabled
    DB().scaleMultiplier = ns.defaults.blizzardBarArt.scaleMultiplier
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "BLIZZARD BAR ART", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable Blizzard Bar Art",
            tooltip = "Show Blizzard's decorative border and end caps behind EllesmereUI Bar 1.",
            getValue = function()
                return DB().enabled
            end,
            setValue = function(value)
                DB().enabled = value
                feature:Refresh()
            end,
        },
        {
            type = "slider",
            text = "Art Scale",
            tooltip = "Fine-tune the decorative artwork for this installation. This calibration is not included in Global Settings exports.",
            min = 1.00,
            max = 1.10,
            step = 0.01,
            getValue = function()
                return DB().scaleMultiplier
            end,
            setValue = function(value)
                DB().scaleMultiplier = value
                feature:Refresh()
            end,
        }
    )
    y = y - h

    return math.abs(y)
end
