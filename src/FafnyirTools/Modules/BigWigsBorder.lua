local ADDON_NAME, ns = ...
local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "BigWigsBorder",
    page = T("CORE.QOL"),
    searchTerms = { "bigwigs", "pixel border", "timer bars", "boss bars" },
}
ns:RegisterFeature(feature.key, feature)

local trackedBars = setmetatable({}, { __mode = "k" })
local messagesRegistered = false

local function DB()
    return ns:GetDatabase().bigWigsBorder
end

local function Enabled()
    return DB().enabled == true
end

local function BigWigsAvailable()
    return BigWigsLoader and type(BigWigsLoader.RegisterMessage) == "function"
end

local function HideBorder(target, field)
    local border = target and target[field]
    if border then border:Hide() end
end

local function RestoreIconLayout(bar)
    if bar and type(bar.SetIconPosition) == "function" then
        local position = type(bar.GetIconPosition) == "function" and bar:GetIconPosition() or "LEFT"
        bar:SetIconPosition(position)
    end
end

local function ApplyIconOffset(bar)
    local icon = bar and bar.candyBarIconFrame
    local status = bar and bar.candyBarBar
    if not icon or not status then return end

    RestoreIconLayout(bar)
    local offset = math.max(0, tonumber(DB().iconOffset) or 0)
    if not Enabled() or offset == 0 or not icon:IsShown() then return end

    local position = type(bar.GetIconPosition) == "function" and bar:GetIconPosition() or "LEFT"
    icon:ClearAllPoints()
    status:ClearAllPoints()
    if position == "RIGHT" then
        icon:SetPoint("TOPRIGHT", bar, "TOPRIGHT", offset, 0)
        icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", offset, 0)
        status:SetPoint("TOPRIGHT", icon, "TOPLEFT", -offset, 0)
        status:SetPoint("BOTTOMRIGHT", icon, "BOTTOMLEFT", -offset, 0)
        status:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
        status:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
    else
        icon:SetPoint("TOPLEFT", bar, "TOPLEFT", -offset, 0)
        icon:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", -offset, 0)
        status:SetPoint("TOPLEFT", icon, "TOPRIGHT", offset, 0)
        status:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", offset, 0)
        status:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
        status:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, 0)
    end
end

local function ApplyPixelsBorder(bar, target, field, context)
    if not target then return end
    if not Enabled() or not EllesmereUI or type(EllesmereUI.ApplyBorderStyle) ~= "function" then
        HideBorder(target, field)
        return
    end

    local border = target[field]
    if not border then
        border = CreateFrame("Frame", nil, bar)
        target[field] = border
    end

    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", target, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", 0, 0)
    border:SetFrameLevel(math.max(0, bar:GetFrameLevel() + 8))

    local texture = "pixels"
    local size = EllesmereUI.GetBorderDefaultSize
        and EllesmereUI.GetBorderDefaultSize(context, texture)
        or 1
    local color = EllesmereUI.GetBorderStyleSelectDefaults
        and EllesmereUI.GetBorderStyleSelectDefaults(texture)
        or nil
    color = color or { r = 1, g = 1, b = 1 }
    local exactPixels = EllesmereUI.BorderPx
        and EllesmereUI.BorderPx(nil, size, texture)

    EllesmereUI.ApplyBorderStyle(
        border,
        size,
        color.r or 1,
        color.g or 1,
        color.b or 1,
        1,
        texture,
        nil,
        nil,
        nil,
        nil,
        context,
        size,
        nil,
        exactPixels
    )
    border:SetShown(bar:IsShown() and target:IsShown())
end

local function ApplyToBar(bar)
    if not bar then return end
    trackedBars[bar] = true
    ApplyIconOffset(bar)
    ApplyPixelsBorder(bar, bar.candyBarBar, "_fafnyirBigWigsBorder", "bigwigs_bar")
    ApplyPixelsBorder(bar, bar.candyBarIconFrame, "_fafnyirBigWigsIconBorder", "bigwigs_icon")
end

local function HideBarBorders(bar)
    HideBorder(bar and bar.candyBarBar, "_fafnyirBigWigsBorder")
    HideBorder(bar and bar.candyBarIconFrame, "_fafnyirBigWigsIconBorder")
    RestoreIconLayout(bar)
end

local function OnBarCreated(_, _, bar)
    ApplyToBar(bar)
end

local function OnBarEmphasized(_, _, bar)
    ApplyToBar(bar)
end

local function RegisterMessages()
    if messagesRegistered or not BigWigsAvailable() then return false end
    BigWigsLoader.RegisterMessage(feature, "BigWigs_BarCreated", OnBarCreated)
    BigWigsLoader.RegisterMessage(feature, "BigWigs_BarEmphasized", OnBarEmphasized)
    messagesRegistered = true
    return true
end

function feature:Initialize()
    RegisterMessages()
end

function feature:Refresh()
    RegisterMessages()
    for bar in pairs(trackedBars) do
        if Enabled() then
            ApplyToBar(bar)
        else
            HideBarBorders(bar)
        end
    end
end

function feature:Reset()
    DB().enabled = ns.defaults.bigWigsBorder.enabled
    DB().iconOffset = ns.defaults.bigWigsBorder.iconOffset
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, T("QOL.BIGWIGS_PIXEL_BORDER"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = T("QOL.ENABLE_BIGWIGS_PIXEL_BORDER"),
            tooltip = T("QOL.APPLY_THE_ELLESMEREUI_PIXELS_BORDER_TO_BIGWIGS_TIMER"),
            disabled = function() return not BigWigsAvailable() end,
            disabledTooltip = T("QOL.BIGWIGS_BARS_ARE_NOT_AVAILABLE"),
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value and true or false
                feature:Refresh()
            end,
        },
        {
            type = "slider",
            text = T("QOL.BIGWIGS_ICON_OFFSET"),
            tooltip = T("QOL.MOVE_BIGWIGS_SPELL_ICONS_AWAY_FROM_THE_TIMER_BAR"),
            min = 0,
            max = 10,
            step = 1,
            disabled = function() return not DB().enabled end,
            disabledTooltip = T("QOL.ENABLE_BIGWIGS_PIXEL_BORDER"),
            getValue = function() return DB().iconOffset or 0 end,
            setValue = function(value)
                DB().iconOffset = value
                feature:Refresh()
            end,
        })
    y = y - h
    return math.abs(y)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "BigWigs" or addonName == "BigWigs_Plugins" then
        RegisterMessages()
    end
end)
