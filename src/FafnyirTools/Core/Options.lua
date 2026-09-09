local ADDON_NAME, ns = ...

local options = {}
ns.Options = options

local retryTicker

local function OrderedFeatures()
    return {
        ns.modules.GlobalSettings,
        ns.modules.About,
        ns.modules.PermanentCompanionPet,
        ns.modules.UnitFrameSources,
        ns.modules.AuraSkins,
        ns.modules.Resting,
        ns.modules.RightClickSelfCast,
        ns.modules.BlizzardBarArt,
        ns.modules.FlyoutButtonMatch,
        ns.modules.XPBar,
        ns.modules.Inventory,
        ns.modules.DeviceLayout,
    }
end

local function BuildPage(pageName, parent, yOffset)
    local y = yOffset
    for _, feature in ipairs(OrderedFeatures()) do
        if feature and feature.page == pageName and feature.BuildOptions then
            -- Feature builders return the absolute bottom offset, not height.
            y = -feature:BuildOptions(parent, y)
        end
    end

    return math.abs(y)
end

local function BuildConfig()
    local pages = {}
    local addedPages = {}
    local searchTerms = {
        "fafnyir",
        "tools",
    }

    for _, feature in ipairs(OrderedFeatures()) do
        if feature then
            if feature.page and not addedPages[feature.page] then
                pages[#pages + 1] = feature.page
                addedPages[feature.page] = true
            end

            for _, term in ipairs(feature.searchTerms or {}) do
                searchTerms[#searchTerms + 1] = term
            end
        end
    end

    return {
        title = "Fafnyir Tools",
        description = "A collection of enhancements for EllesmereUI.",
        pages = pages,
        searchTerms = searchTerms,
        buildPage = BuildPage,
        onReset = function()
            ns:ResetDatabase()

            if EllesmereUI and EllesmereUI.RefreshPage then
                EllesmereUI:RefreshPage(true)
            end
            if EllesmereUI and EllesmereUI.ShowConfirmPopup then
                EllesmereUI:ShowConfirmPopup({
                    title = "FafnyirTools Defaults Restored",
                    message = "All Unit Frame sources were set to EllesmereUI. Reload now to apply frame ownership.",
                    confirmText = "Reload Now",
                    cancelText = "Later",
                    onConfirm = ReloadUI,
                })
            end
        end,
    }
end

function options:Register()
    if ns.state.optionsRegistered then
        return true
    end

    if not ns.Sidebar or not ns.Sidebar:Install() then
        return false
    end

    if not EllesmereUI
        or type(EllesmereUI.RegisterModule) ~= "function"
        or not EllesmereUI.Widgets
    then
        return false
    end

    _G.FafnyirTools_PendingOptionsConfig = BuildConfig()

    local bridge, bridgeError = loadstring(
        "local c = _G.FafnyirTools_PendingOptionsConfig; "
        .. "if c and EllesmereUI then "
        .. "EllesmereUI:RegisterModule('FafnyirTools', c) "
        .. "end",
        "@Interface/AddOns/EllesmereUI/FafnyirToolsBridge.lua"
    )

    if not bridge then
        _G.FafnyirTools_PendingOptionsConfig = nil
        ns:Print("options bridge error: " .. tostring(bridgeError))
        return false
    end

    local ok, registrationError = pcall(bridge)
    _G.FafnyirTools_PendingOptionsConfig = nil

    if not ok then
        ns:Print("options registration error: " .. tostring(registrationError))
        return false
    end

    ns.state.optionsRegistered = true

    if retryTicker then
        retryTicker:Cancel()
        retryTicker = nil
    end

    return true
end

function options:StartRegistration()
    C_Timer.After(0, function()
        options:Register()
    end)

    C_Timer.After(0.5, function()
        options:Register()
    end)

    C_Timer.After(1, function()
        options:Register()
    end)

    if not retryTicker then
        retryTicker = C_Timer.NewTicker(0.5, function()
            options:Register()
        end)
    end
end
