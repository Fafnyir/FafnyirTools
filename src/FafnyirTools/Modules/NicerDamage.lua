local ADDON_NAME, ns = ...
if ns.HAS_ELLESMEREUI then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "NicerDamage",
    page = T("CORE.QOL"),
    searchTerms = { "damage", "combat text", "font", "nicer damage" },
}
ns:RegisterFeature(feature.key, feature)

local originalDamageFont = DAMAGE_TEXT_FONT or STANDARD_TEXT_FONT
local customDamageFont = "Interface\\AddOns\\FafnyirTools\\Media\\NicerDamage.ttf"

local function DB()
    return ns:GetDatabase().nicerDamage
end

local function RequestReload()
    if not EllesmereUI or not EllesmereUI.ShowConfirmPopup then return end
    EllesmereUI:ShowConfirmPopup({
        title = T("CORE.RELOAD_REQUIRED"),
        message = T("QOL.NICER_DAMAGE_RELOAD_NOTE"),
        confirmText = T("CORE.RELOAD_NOW"),
        cancelText = T("CORE.LATER"),
        reload = true,
    })
end

function feature:Refresh()
    DAMAGE_TEXT_FONT = DB().enabled and customDamageFont or originalDamageFont
end

function feature:Initialize()
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h
    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, T("QOL.NICER_DAMAGE"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle", text = T("QOL.ENABLE_NICER_DAMAGE"),
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value
                feature:Refresh()
                RequestReload()
            end,
        },
        {
            type = "label", text = T("QOL.NICER_DAMAGE_RELOAD_NOTE"),
        }
    )
    y = y - h
    return math.abs(y)
end

feature:Refresh()
