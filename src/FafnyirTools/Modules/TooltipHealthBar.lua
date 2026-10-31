local ADDON_NAME, ns = ...
if ns.HAS_ELLESMEREUI then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "TooltipHealthBar",
    page = T("CORE.QOL"),
    searchTerms = { "tooltip", "health", "health bar", "unit tooltip" },
}
ns:RegisterFeature(feature.key, feature)

local hookedBars = setmetatable({}, { __mode = "k" })

local function DB()
    return ns:GetDatabase().tooltipHealthBar
end

local function ResolveHealthBar()
    return _G.GameTooltipStatusBar or (_G.GameTooltip and _G.GameTooltip.StatusBar)
end

function feature:Refresh()
    local bar = ResolveHealthBar()
    if not bar then return false end

    if not hookedBars[bar] and type(hooksecurefunc) == "function" then
        hookedBars[bar] = true
        hooksecurefunc(bar, "Show", function(self)
            if DB().hidden then self:SetAlpha(0) end
        end)
    end

    bar:SetAlpha(DB().hidden and 0 or 1)
    return true
end

function feature:Initialize()
    self:Refresh()
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then self:Refresh() end
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h
    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, T("QOL.DEFAULT_TOOLTIP"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle", text = T("QOL.HIDE_DEFAULT_TOOLTIP_HEALTH_BAR"),
            getValue = function() return DB().hidden end,
            setValue = function(value) DB().hidden = value; feature:Refresh() end,
        },
        {
            type = "label", text = T("QOL.DEFAULT_TOOLTIP_HEALTH_BAR_NOTE"),
        }
    )
    y = y - h
    return math.abs(y)
end
