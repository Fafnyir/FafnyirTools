local ADDON_NAME, ns = ...

local feature = {
    key = "IconHistoryBorder",
}
ns:RegisterFeature(feature.key, feature)

local hooked = false

local function DamageMetersNamespace()
    return EllesmereUI
        and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS.EllesmereUIDamageMeters
end

local function DamageMetersSettings()
    local db = _G._EDM_DB
    return db and db.profile and db.profile.dm
end

local function BorderEnabled(settings)
    return settings
        and settings.customIconBorder == true
        and (settings.iconBorderSize or 0) > 0
end

local function SetBorderShown(icon, border, settings)
    border:SetShown(BorderEnabled(settings) and icon:IsShown())
end

local function ApplyToIcon(icon, settings)
    if not icon then return end

    local border = icon._fafnyirHistoryBorder
    if not BorderEnabled(settings) then
        if border then border:Hide() end
        return
    end

    if not border then
        border = CreateFrame("Frame", nil, icon)
        border:SetAllPoints(icon)
        border:SetFrameLevel(icon:GetFrameLevel() + 6)
        icon._fafnyirHistoryBorder = border

        icon:HookScript("OnShow", function(self)
            SetBorderShown(self, border, DamageMetersSettings())
        end)
        icon:HookScript("OnHide", function()
            border:Hide()
        end)
    end

    local size = settings.iconBorderSize or 0
    local texture = settings.iconBorderTexture or "solid"
    local exactPixels = EllesmereUI.BorderPx
        and EllesmereUI.BorderPx(settings.iconBorderSizePx, size, texture)

    EllesmereUI.ApplyBorderStyle(
        border,
        size,
        settings.iconBorderR or 0,
        settings.iconBorderG or 0,
        settings.iconBorderB or 0,
        settings.iconBorderA == nil and 1 or settings.iconBorderA,
        texture,
        settings.iconBorderTextureOffset,
        settings.iconBorderTextureOffsetY,
        settings.iconBorderTextureShiftX,
        settings.iconBorderTextureShiftY,
        "damagemeters_icon",
        size,
        nil,
        exactPixels
    )
    SetBorderShown(icon, border, settings)
end

local function Apply()
    if not EllesmereUI or type(EllesmereUI.ApplyBorderStyle) ~= "function" then return end
    local strip = _G.EllesmereUIDMIconStrip
    if not strip then return end

    local settings = DamageMetersSettings()
    local icons = { strip:GetChildren() }
    for i = 1, #icons do
        ApplyToIcon(icons[i], settings)
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

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, event, addonName)
    feature:HandleEvent(event, addonName)
end)

