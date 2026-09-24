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

local function DB()
    return ns:GetDatabase().foreverFog
end

local function GetCVarValue()
    local getter = C_CVar and C_CVar.GetCVar or GetCVar
    if type(getter) ~= "function" then return nil end
    local ok, value = pcall(getter, CVAR)
    if not ok or value == nil then return nil end
    return tostring(value)
end

local function LiveFogEnabled()
    local value = GetCVarValue()
    if value == nil then return nil end
    return tonumber(value) ~= 0
end

local function ApplyFogSetting(enabled)
    if not ns.IS_FOREVER then return end
    local applied = false

    -- ConsoleExec is the exact API equivalent of the validated
    -- `/console volumeFog 0|1` command. Fall back to SetCVar on clients that
    -- do not expose it to addons.
    if type(ConsoleExec) == "function" then
        local ok, result = pcall(ConsoleExec, CVAR .. " " .. (enabled and "1" or "0"))
        applied = ok and result ~= false
    end
    if not applied then
        local setter = C_CVar and C_CVar.SetCVar or SetCVar
        if type(setter) == "function" then
            applied = pcall(setter, CVAR, enabled and "1" or "0")
        end
    end
    if not applied then
        ns:Print("The Forever fog setting could not be changed.")
    end
end

local function SetFogEnabled(enabled)
    local db = DB()
    db.enabled = enabled and true or false
    db.initialized = true
    ApplyFogSetting(db.enabled)
end

local function CaptureInitialSetting()
    local db = DB()
    if db.initialized then return end
    local live = LiveFogEnabled()
    if live ~= nil then db.enabled = live end
    db.initialized = true
end

local function ReapplySoon()
    if not ns.IS_FOREVER then return end
    CaptureInitialSetting()
    ApplyFogSetting(DB().enabled)
    if C_Timer and C_Timer.After then
        C_Timer.After(1, function()
            ApplyFogSetting(DB().enabled)
        end)
    end
end

function feature:Initialize()
    ReapplySoon()
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        ReapplySoon()
    end
end

function feature:Reset()
    local db = DB()
    db.enabled = ns.defaults.foreverFog.enabled
    db.initialized = true
    ApplyFogSetting(db.enabled)
end

function feature:BuildOptions(parent, yOffset)
    -- Do not expose this control or its section on Retail. The preference is
    -- stored here because Forever can overwrite the graphics CVar after login.
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
            tooltip = "Enable or disable WoW Forever's volumetric fog. FafnyirTools reapplies this preference after login and world changes.",
            getValue = function() return DB().enabled end,
            setValue = SetFogEnabled,
        },
        { type = "label", text = "" }
    )
    y = y - h

    return math.abs(y)
end
