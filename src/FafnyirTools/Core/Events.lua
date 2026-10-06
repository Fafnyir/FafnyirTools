local ADDON_NAME, ns = ...

local events = CreateFrame("Frame")

events:RegisterEvent("PLAYER_LOGIN")
events:RegisterEvent("PLAYER_ENTERING_WORLD")
events:RegisterEvent("PLAYER_UPDATE_RESTING")
events:RegisterEvent("PLAYER_LEVEL_UP")
events:RegisterEvent("PLAYER_REGEN_ENABLED")
events:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED")
events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
events:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
events:RegisterEvent("PLAYERBANKSLOTS_CHANGED")
events:RegisterEvent("BANKFRAME_OPENED")
events:RegisterEvent("PLAYER_MONEY")
events:RegisterEvent("BAG_UPDATE_DELAYED")
events:RegisterEvent("PLAYER_STARTED_MOVING")
events:RegisterEvent("ZONE_CHANGED_NEW_AREA")
events:RegisterEvent("PLAYER_MOUNT_DISPLAY_CHANGED")
events:RegisterEvent("PLAYER_CONTROL_GAINED")
events:RegisterEvent("PET_JOURNAL_LIST_UPDATE")
events:RegisterEvent("COMPANION_UPDATE")

events:SetScript("OnEvent", function(_, event, ...)
    if event == "PLAYER_LOGIN" then
        if ns.Sidebar then
            ns.Sidebar:Install()
        end

        for _, feature in pairs(ns.modules) do
            if type(feature.Initialize) == "function" then
                feature:Initialize()
            end
        end

        if ns.Options then
            ns.Options:StartRegistration()
        end

        return
    end

    if event == "PLAYER_ENTERING_WORLD"
        and ns.Options
        and not ns.state.optionsRegistered
    then
        ns.Options:Register()
    end

    for _, feature in pairs(ns.modules) do
        if type(feature.HandleEvent) == "function" then
            feature:HandleEvent(event, ...)
        end
    end
end)
