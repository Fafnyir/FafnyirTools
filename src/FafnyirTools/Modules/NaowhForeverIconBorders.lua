local ADDON_NAME, ns = ...
local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

if not ns.IS_FOREVER or not ns.HAS_ELLESMEREUI or not _G.NaowhForever then return end

local feature = {
    key = "NaowhForeverIconBorders",
    page = T("CORE.QOL"),
    searchTerms = { "naowh", "forever", "food", "drink", "consumable", "gear", "trinket", "blessings", "sleeping bag", "fishing pole", "pixel border" },
}
ns:RegisterFeature(feature.key, feature)

local tracked = setmetatable({}, { __mode = "k" })
local settingsHooked = setmetatable({}, { __mode = "k" })
local refreshQueued = false
local sleepingBagHooked = false
local BORDER_PIXELS = 24

local function DB()
    return ns:GetDatabase().naowhForeverIconBorders
end

local function Enabled()
    return DB().enabled == true
end

local function ClickableFishingPole()
    return DB().clickableFishingPole == true
end

local function FishingAvailable()
    local owner = _G.NaowhForever
    local store = owner and owner.QoLSettings
    if not store or type(store.Get) ~= "function" or not _G.NaowhForeverFish then return false end
    local okEnabled, enabled = pcall(store.Get, "enabled")
    local okFishing, fishing = pcall(store.Get, "fishingKey")
    return okEnabled and okFishing and enabled == true and fishing == true
end

local function SafeShown(frame)
    local ok, shown = pcall(frame.IsShown, frame)
    return ok and shown == true
end

local function SetBorderShown(target, border)
    border:SetShown(Enabled() and SafeShown(target))
end

local function ApplyBorder(target)
    if not target then return end
    local border = tracked[target]
    if not Enabled() or not EllesmereUI or type(EllesmereUI.ApplyBorderStyle) ~= "function" then
        if border then border:Hide() end
        return
    end
    if InCombatLockdown and InCombatLockdown() then return end

    if not border then
        border = CreateFrame("Frame", nil, target)
        border:SetAllPoints(target)
        tracked[target] = border
        if target.HookScript then
            target:HookScript("OnShow", function(self) SetBorderShown(self, border) end)
            target:HookScript("OnHide", function() border:Hide() end)
        end
    end

    local texture = DB().texture or "pixels"
    local context = "naowh_forever_icon"
    local exactPixels
    local size
    if texture == "pixels" then
        exactPixels = BORDER_PIXELS
        size = EllesmereUI.BorderPxStep
            and EllesmereUI.BorderPxStep(BORDER_PIXELS, texture)
            or 3
    else
        size = EllesmereUI.GetBorderDefaultSize
            and EllesmereUI.GetBorderDefaultSize(context, texture)
            or 1
    end
    local color, behind
    if EllesmereUI.GetBorderStyleSelectDefaults then
        color, behind = EllesmereUI.GetBorderStyleSelectDefaults(texture)
    end
    color = color or { r = 1, g = 1, b = 1 }
    local ok, level = pcall(target.GetFrameLevel, target)
    border:SetFrameLevel(math.max(0, (ok and level or 0) + (behind and -1 or 8)))
    EllesmereUI.ApplyBorderStyle(
        border, size,
        color.r or 1, color.g or 1, color.b or 1, 1,
        texture, nil, nil, nil, nil,
        context, size, nil, exactPixels
    )
    SetBorderShown(target, border)
end

local function Children(frame)
    if not frame or type(frame.GetChildren) ~= "function" then return {} end
    local children
    local ok = pcall(function() children = { frame:GetChildren() } end)
    return ok and children or {}
end

local function HasIcon(frame)
    return frame and (frame.icon ~= nil or frame.tex ~= nil)
end

local function ScanChildren(frame, depth)
    if not frame or depth < 1 then return end
    for _, child in ipairs(Children(frame)) do
        if HasIcon(child) then ApplyBorder(child) end
        ScanChildren(child, depth - 1)
    end
end

local function ApplyNamed(name)
    local target = _G[name]
    if target then ApplyBorder(target) end
end

local function IsSleepingBag(frame)
    if not (frame and frame.tex and frame.cooldown and frame.count) then return false end
    if type(frame.GetAttribute) ~= "function" then return false end
    local ok, item = pcall(frame.GetAttribute, frame, "item1")
    return ok and (item == "item:211527" or item == 211527)
end

local function ScanSleepingBag()
    for _, child in ipairs(Children(UIParent)) do
        if IsSleepingBag(child) then ApplyBorder(child) end
    end
end

local function ScanFishingPoleReminder()
    for _, child in ipairs(Children(_G.NaowhForeverGearReminders)) do
        if child.slot == 16 and child.texture then
            ApplyBorder(child)
            local click = child._fafnyirFishingClick
            local shouldClick = ClickableFishingPole() and FishingAvailable()
            if shouldClick and not click and not (InCombatLockdown and InCombatLockdown()) then
                click = CreateFrame("Button", nil, child, "SecureActionButtonTemplate")
                click:SetAllPoints(child)
                click:SetFrameLevel(child:GetFrameLevel() + 10)
                -- NaowhForeverFish is an AnyDown action with useOnKeyDown=true.
                -- The forwarding button must execute on the same edge or the
                -- target's secure PreClick never arms the fishing action.
                click:RegisterForClicks("AnyDown", "AnyUp")
                click:SetAttribute("useOnKeyDown", true)
                click:SetAttribute("*type1", "click")
                click:SetAttribute("*clickbutton1", _G.NaowhForeverFish)
                -- An exact empty Ctrl action prevents the wildcard cast, leaving
                -- Ctrl-click available for Naowh's existing dismiss behavior.
                click:SetAttribute("ctrl-type1", "")
                click:SetScript("OnEnter", function()
                    local script = child:GetScript("OnEnter")
                    if script then script(child) end
                end)
                click:SetScript("OnLeave", function()
                    local script = child:GetScript("OnLeave")
                    if script then script(child) end
                end)
                click:SetScript("PostClick", function(_, button, down)
                    if not down and IsControlKeyDown and IsControlKeyDown() then
                        local script = child:GetScript("OnMouseUp")
                        if script then script(child, button) end
                    end
                end)
                child._fafnyirFishingClick = click
            end
            if click then click:SetShown(shouldClick and child:IsShown()) end
        else
            local border = tracked[child]
            if border then border:Hide() end
            if child._fafnyirFishingClick then child._fafnyirFishingClick:Hide() end
        end
    end
end

local function Apply()
    if not Enabled() then
        for _, border in pairs(tracked) do border:Hide() end
    end
    if InCombatLockdown and InCombatLockdown() then return end

    if Enabled() then
        ApplyNamed("NaowhForeverFoodBarFood")
        ApplyNamed("NaowhForeverFoodBarDrink")
        ScanChildren(_G.NaowhForeverConsumableBar, 2)
        ScanChildren(_G.NaowhForeverGearBar, 2)
        ScanChildren(_G.NaowhForeverTrinkets, 2)
        ScanChildren(_G.NaowhForeverBlessingBar, 3)
        ScanSleepingBag()
    end
    ScanFishingPoleReminder()
end

local function QueueRefresh()
    if refreshQueued then return end
    refreshQueued = true
    if not C_Timer or not C_Timer.After then
        refreshQueued = false
        Apply()
        return
    end
    C_Timer.After(0, function()
        refreshQueued = false
        Apply()
    end)
end

local function HookSettings(store)
    if not store or settingsHooked[store] or type(store.Set) ~= "function" then return end
    settingsHooked[store] = true
    hooksecurefunc(store, "Set", QueueRefresh)
end

local function InstallHooks()
    local owner = _G.NaowhForever
    if not owner then return end
    HookSettings(owner.QoLSettings)
    HookSettings(owner.Blessings and owner.Blessings.Settings)
    HookSettings(owner.AuraBuffs and owner.AuraBuffs.Settings)
    local bag = owner.AuraBuffs and owner.AuraBuffs.CampBag
    if bag and not sleepingBagHooked and type(bag.Sync) == "function" then
        sleepingBagHooked = true
        hooksecurefunc(bag, "Sync", QueueRefresh)
    end
end

local function QueueStartupRefresh()
    InstallHooks()
    if not C_Timer or not C_Timer.After then Apply(); return end
    for _, delay in ipairs({ 0, 0.2, 0.5, 1, 2 }) do
        C_Timer.After(delay, function()
            InstallHooks()
            Apply()
        end)
    end
end

function feature:Initialize()
    QueueStartupRefresh()
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED" then
        QueueStartupRefresh()
    end
end

function feature:Refresh()
    InstallHooks()
    Apply()
end

function feature:Reset()
    DB().enabled = ns.defaults.naowhForeverIconBorders.enabled
    DB().texture = ns.defaults.naowhForeverIconBorders.texture
    DB().clickableFishingPole = ns.defaults.naowhForeverIconBorders.clickableFishingPole
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, T("QOL.NAOWH_FOREVER_ICON_BORDERS"), y)
    y = y - h
    local values, order
    if EllesmereUI.GetBorderTextureDropdown then
        values, order = EllesmereUI.GetBorderTextureDropdown()
    else
        values, order = {
            solid = T("QOL.SOLID"),
            pixels = T("QOL.PIXELS"),
        }, { "solid", "pixels" }
    end
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = T("QOL.ENABLE_NAOWH_FOREVER_ICON_BORDERS"),
            tooltip = T("QOL.NAOWH_FOREVER_ICON_BORDERS_NOTE"),
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value and true or false
                feature:Refresh()
            end,
        },
        {
            type = "dropdown",
            text = T("QOL.BORDER_STYLE"),
            values = values,
            order = order,
            disabled = function() return not DB().enabled end,
            disabledTooltip = T("QOL.ENABLE_NAOWH_FOREVER_ICON_BORDERS"),
            getValue = function() return DB().texture or "pixels" end,
            setValue = function(value)
                DB().texture = value
                feature:Refresh()
            end,
        })
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = T("QOL.CLICKABLE_FISHING_POLE_REMINDER"),
            tooltip = T("QOL.CLICKABLE_FISHING_POLE_REMINDER_NOTE"),
            disabled = function() return not FishingAvailable() end,
            disabledTooltip = T("QOL.CLICKABLE_FISHING_POLE_REQUIRES_ONE_KEY"),
            getValue = function() return DB().clickableFishingPole end,
            setValue = function(value)
                DB().clickableFishingPole = value and true or false
                feature:Refresh()
            end,
        },
        { type = "description", text = T("QOL.CLICKABLE_FISHING_POLE_REMINDER_NOTE") })
    y = y - h
    return math.abs(y)
end

local reminderEvents = CreateFrame("Frame")
reminderEvents:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
reminderEvents:RegisterEvent("ZONE_CHANGED_NEW_AREA")
reminderEvents:SetScript("OnEvent", QueueRefresh)
