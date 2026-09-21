local ADDON_NAME, ns = ...

local feature = {
    key = "ForeverFog",
    page = "QoL",
    searchTerms = {
        "forever fog", "fog", "volume fog", "volumetric fog", "graphics",
    },
}
ns:RegisterFeature(feature.key, feature)

local CVAR = "volumeFog"

local function GetCVarValue()
    local getter = C_CVar and C_CVar.GetCVar or GetCVar
    if type(getter) ~= "function" then return nil end
    local ok, value = pcall(getter, CVAR)
    if not ok or value == nil then return nil end
    return tostring(value)
end

local function FogEnabled()
    local value = GetCVarValue()
    return value ~= nil and tonumber(value) ~= 0
end

local function SetFogEnabled(enabled)
    if not ns.IS_FOREVER then return end
    local setter = C_CVar and C_CVar.SetCVar or SetCVar
    if type(setter) ~= "function" then
        ns:Print("The Forever fog setting is unavailable on this client build.")
        return
    end

    local ok = pcall(setter, CVAR, enabled and "1" or "0")
    if not ok then
        ns:Print("The Forever fog setting could not be changed.")
    end
end

function feature:BuildOptions(parent, yOffset)
    -- Do not expose this control or its section on Retail. volumeFog exists on
    -- other clients, but this product choice belongs only to WoW Forever.
    if not ns.IS_FOREVER then return math.abs(yOffset) end

    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "WOW FOREVER", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Volumetric Fog",
            tooltip = "Enable or disable WoW Forever's volumetric fog. This client setting persists independently of addon SavedVariables.",
            getValue = FogEnabled,
            setValue = SetFogEnabled,
        },
        { type = "label", text = "" }
    )
    y = y - h

    return math.abs(y)
end
