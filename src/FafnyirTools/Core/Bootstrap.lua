local ADDON_NAME, ns = ...

ns.ADDON_NAME = ADDON_NAME
ns.MODULE_KEY = "FafnyirTools"
ns.modules = ns.modules or {}
ns.state = ns.state or {
    optionsRegistered = false,
}

local interfaceVersion = GetBuildInfo and select(4, GetBuildInfo())
ns.IS_FOREVER = type(interfaceVersion) == "number"
    and interfaceVersion >= 16000
    and interfaceVersion < 20000

function ns:ForeverSavedVariablesUnsafe()
    return self.IS_FOREVER
        and EllesmereUI
        and EllesmereUI.FOREVER_SV_BUG == true
end

function ns:PrintForeverSavedVariablesWarning()
    self:Print("Forever beta is not reliably saving addon settings yet. Reload-dependent changes are disabled to protect your configuration.")
end

ns.defaults = {
    sharedArtwork = { arrow = "native", roles = false },
    foreverFog = {
        enabled = true,
        initialized = false,
    },
    flyoutFix = {
        enabled = true,
    },
    iconHistoryBorder = {
        enabled = false,
        texture = "pixels",
    },
    focusHeader = {
        enabled = true,
        initialized = false,
    },
    permanentCompanionPet = {
        enabled = false,
        mode = "randomFavorite",
        petName = "",
        disableInPvP = true,
        characters = {},
    },
    resting = {
        enabled = true,
        hideAtMaxLevel = false,
        size = 36,
        offsetX = 20,
        offsetY = -15,
    },
    rightClickSelfCast = {
        enabled = true,
    },
    unitFrameNames = {
        mode = "whole",
    },
    deviceLayout = {
        enabled = true,
        presetIndex = 0,
        specOverrides = {},
    },
    inventory = {
        enabled = true,
        tooltips = true,
        characters = {},
        warband = { items = {}, money = 0, updated = 0 },
        guilds = {},
        mail = {},
        auctions = {},
        currencies = {},
    },
    xpBar = {
        enabled = false,
        orientation = "HORIZONTAL",
        startColor = { r = 85 / 255, g = 99 / 255, b = 1, a = 1 },
        endColor = { r = 197 / 255, g = 97 / 255, b = 1, a = 1 },
        questEnabled = true,
        questColor = { r = 1, g = 150 / 255, b = 0, a = 1 },
        restedEnabled = true,
        restedStartColor = { r = 79 / 255, g = 143 / 255, b = 1, a = 1 },
        restedEndColor = { r = 79 / 255, g = 143 / 255, b = 1, a = 1 },
    },
    auraSkins = {
        enabled = false,
        iconSize = 32,
        targetIconSize = 32,
        targetBuffFilter = "all",
        targetDebuffFilter = "all",
        showText = true,
        textSize = 11,
        borderTexture = "solid",
        borderSize = 1,
        borderBehind = false,
        borderR = 0,
        borderG = 0,
        borderB = 0,
        borderA = 1,
        noBorderDebuffs = true,
        buffIconZoom = 0.055,
        debuffIconZoom = 0.055,
        durationFormat = "blizzard",
        showExpandButton = true,
        targetAuras = true,
    },
}

local function CopyDefaults(source, target)
    for key, value in pairs(source) do
        if type(value) == "table" then
            if type(target[key]) ~= "table" then
                target[key] = {}
            end
            CopyDefaults(value, target[key])
        elseif target[key] == nil then
            target[key] = value
        end
    end
end

ns.CopyDefaults = CopyDefaults

function ns:InitializeDatabase()
    FafnyirToolsDB = FafnyirToolsDB or {}
    -- v1.1.0/v1.1.1 used questXP* keys. Migrate only missing new keys;
    -- never replace a choice already saved by the QuestXPFixed build.
    local xp = FafnyirToolsDB.xpBar
    if type(xp) == "table" then
        if xp.questEnabled == nil and xp.questXPEnabled ~= nil then
            xp.questEnabled = xp.questXPEnabled
        end
        if xp.questColor == nil and type(xp.questXPColor) == "table" then
            local old = xp.questXPColor
            xp.questColor = { r = old.r, g = old.g, b = old.b, a = old.a }
        end
    end
    CopyDefaults(self.defaults, FafnyirToolsDB)
end

function ns:GetDatabase()
    self:InitializeDatabase()
    return FafnyirToolsDB
end

function ns:RegisterFeature(key, feature)
    if type(key) ~= "string" or type(feature) ~= "table" then
        return
    end

    self.modules[key] = feature
end

function ns:ResetDatabase()
    FafnyirToolsDB = {}
    CopyDefaults(self.defaults, FafnyirToolsDB)

    -- A reset intentionally restores the coloured Blizzard-style Focus header
    -- instead of adopting the pre-reset EllesmereUI value during Refresh.
    FafnyirToolsDB.focusHeader.initialized = true

    for _, feature in pairs(self.modules) do
        if type(feature.Refresh) == "function" then
            feature:Refresh()
        end
    end
end

function ns:Print(message)
    print("Fafnyir Tools: " .. tostring(message))
end

ns:InitializeDatabase()

SLASH_FAFNYIRTOOLS1 = "/faftools"
SlashCmdList["FAFNYIRTOOLS"] = function()
    if EllesmereUI and EllesmereUI.NavigateToElementSettings then
        EllesmereUI:NavigateToElementSettings(ns.MODULE_KEY, "Unit Frames")
    elseif EllesmereUI and EllesmereUI.ToggleOptions then
        EllesmereUI:ToggleOptions()
    else
        ns:Print("EllesmereUI options are not available yet.")
    end
end

SLASH_FAFNYIRTOOLSDEBUG1 = "/faftoolsdebug"
SlashCmdList["FAFNYIRTOOLSDEBUG"] = function()
    local euiLoaded = C_AddOns
        and C_AddOns.IsAddOnLoaded
        and C_AddOns.IsAddOnLoaded("EllesmereUI")

    local apiReady = EllesmereUI
        and type(EllesmereUI.RegisterModule) == "function"

    local sidebarEntry = EllesmereUI
        and EllesmereUI._addonInfoByFolder
        and EllesmereUI._addonInfoByFolder[ns.MODULE_KEY] ~= nil

    print("Fafnyir Tools debug:")
    print("  Addon loaded: yes")
    print("  WoW Forever client: " .. (ns.IS_FOREVER and "yes" or "no"))
    print("  SavedVariables reliable: " .. (ns:ForeverSavedVariablesUnsafe() and "no (beta client bug)" or "yes"))
    print("  EllesmereUI loaded: " .. (euiLoaded and "yes" or "no"))
    print("  EllesmereUI options API: " .. (apiReady and "ready" or "missing"))
    print("  Sidebar entry: " .. (sidebarEntry and "installed" or "missing"))
    print("  Options registered: " .. (ns.state.optionsRegistered and "yes" or "no"))
    print("  Features loaded: "
        .. (ns.modules.Resting and "Resting " or "")
        .. (ns.modules.RightClickSelfCast and "RightClickSelfCast " or "")
        .. (ns.modules.XPBar and "XPBar " or "")
        .. (ns.modules.DeviceLayout and "DeviceLayout " or "")
        .. (ns.modules.AuraSkins and "AuraSkins " or "")
        .. (ns.modules.Inventory and "Inventory" or ""))
end
