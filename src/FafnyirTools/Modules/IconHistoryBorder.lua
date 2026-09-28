local ADDON_NAME, ns = ...

local feature = {
    key = "IconHistoryBorder",
    page = "QoL",
    searchTerms = { "icon history", "pixel border", "damage meters", "spell history" },
}
ns:RegisterFeature(feature.key, feature)

local hooked = false

local function DamageMetersNamespace()
    return EllesmereUI
        and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS.EllesmereUIDamageMeters
end

local function DB()
    return ns:GetDatabase().iconHistoryBorder
end

local function BorderEnabled()
    return DB().enabled == true
end

local function SetBorderShown(icon, border)
    border:SetShown(BorderEnabled() and icon:IsShown())
end

local function ApplyToIcon(icon)
    if not icon then return end

    local border = icon._fafnyirHistoryBorder
    if not BorderEnabled() then
        if border then border:Hide() end
        return
    end

    if not border then
        border = CreateFrame("Frame", nil, icon)
        border:SetAllPoints(icon)
        icon._fafnyirHistoryBorder = border

        icon:HookScript("OnShow", function(self)
            SetBorderShown(self, border)
        end)
        icon:HookScript("OnHide", function()
            border:Hide()
        end)
    end

    local texture = DB().texture or "pixels"
    local size = EllesmereUI.GetBorderDefaultSize
        and EllesmereUI.GetBorderDefaultSize("damagemeters_icon", texture)
        or 1
    local color, behind
    if EllesmereUI.GetBorderStyleSelectDefaults then
        color, behind = EllesmereUI.GetBorderStyleSelectDefaults(texture)
    end
    color = color or (texture == "solid"
        and { r = 0, g = 0, b = 0 }
        or { r = 1, g = 1, b = 1 })
    border:SetFrameLevel(math.max(0, icon:GetFrameLevel() + (behind and -1 or 6)))
    local exactPixels = EllesmereUI.BorderPx
        and EllesmereUI.BorderPx(nil, size, texture)

    EllesmereUI.ApplyBorderStyle(
        border,
        size,
        color.r or 0.57,
        color.g or 0.57,
        color.b or 0.57,
        1,
        texture,
        nil,
        nil,
        nil,
        nil,
        "damagemeters_icon",
        size,
        nil,
        exactPixels
    )
    SetBorderShown(icon, border)
end

local function Apply()
    if not EllesmereUI or type(EllesmereUI.ApplyBorderStyle) ~= "function" then return end
    local strip = _G.EllesmereUIDMIconStrip
    if not strip then return end

    local icons = { strip:GetChildren() }
    for i = 1, #icons do
        ApplyToIcon(icons[i])
    end
end

local function InstallHooks()
    if hooked then return true end
    local dm = DamageMetersNamespace()
    if not dm then return false end

    if type(dm.ApplySpellHistory) == "function" then
        hooksecurefunc(dm, "ApplySpellHistory", Apply)
    end
    if type(dm.ApplyIconBorder) == "function" then
        hooksecurefunc(dm, "ApplyIconBorder", Apply)
    end

    hooked = true
    Apply()
    return true
end

function feature:Initialize()
    InstallHooks()
end

function feature:HandleEvent(event, addonName)
    if event == "PLAYER_ENTERING_WORLD" then
        InstallHooks()
        Apply()
    elseif event == "ADDON_LOADED" and addonName == "EllesmereUIDamageMeters" then
        InstallHooks()
    end
end

function feature:Refresh()
    InstallHooks()
    Apply()
end

function feature:Reset()
    DB().enabled = ns.defaults.iconHistoryBorder.enabled
    DB().texture = ns.defaults.iconHistoryBorder.texture
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "DAMAGE METER ICON HISTORY", y)
    y = y - h
    local values, order
    if EllesmereUI.GetBorderTextureDropdown then
        values, order = EllesmereUI.GetBorderTextureDropdown()
    else
        values, order = { solid = "Solid", pixels = "Pixels" }, { "solid", "pixels" }
    end
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = "Enable Icon Border",
            tooltip = "Add the selected EllesmereUI border to Damage Meter Icon History spell icons.",
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value and true or false
                feature:Refresh()
            end,
        },
        {
            type = "dropdown",
            text = "Border Style",
            values = values,
            order = order,
            disabled = function() return not DB().enabled end,
            disabledTooltip = "Enable Icon Border",
            getValue = function() return DB().texture or "pixels" end,
            setValue = function(value)
                DB().texture = value
                feature:Refresh()
            end,
        })
    y = y - h
    return math.abs(y)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, event, addonName)
    feature:HandleEvent(event, addonName)
end)
