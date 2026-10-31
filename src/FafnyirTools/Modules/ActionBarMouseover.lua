local ADDON_NAME, ns = ...
if ns.HAS_ELLESMEREUI then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "ActionBarMouseover",
    page = T("CORE.ACTION_BARS"),
    searchTerms = { "action bar", "mouseover", "fade", "opacity", "default bars" },
}
ns:RegisterFeature(feature.key, feature)

local BAR_DEFINITIONS = {
    { key = "main", frames = { "MainActionBar", "MainMenuBar" }, buttonPrefix = "ActionButton" },
    { key = "bar2", frames = { "MultiBarBottomLeft" }, buttonPrefix = "MultiBarBottomLeftButton" },
    { key = "bar3", frames = { "MultiBarBottomRight" }, buttonPrefix = "MultiBarBottomRightButton" },
    { key = "bar4", frames = { "MultiBarRight" }, buttonPrefix = "MultiBarRightButton" },
    { key = "bar5", frames = { "MultiBarLeft" }, buttonPrefix = "MultiBarLeftButton" },
    { key = "bar6", frames = { "MultiBar5" }, buttonPrefix = "MultiBar5Button" },
    { key = "bar7", frames = { "MultiBar6" }, buttonPrefix = "MultiBar6Button" },
    { key = "bar8", frames = { "MultiBar7" }, buttonPrefix = "MultiBar7Button" },
    { key = "pet", frames = { "PetActionBar" }, buttonPrefix = "PetActionButton", buttonCount = 10 },
    { key = "stance", frames = { "StanceBar" }, buttonPrefix = "StanceButton", buttonCount = 10 },
    {
        key = "micro", frames = { "MicroMenu", "MainMenuBarMicroButtons" },
        buttonNames = {
            "CharacterMicroButton", "ProfessionMicroButton", "PlayerSpellsMicroButton",
            "SpellbookMicroButton", "AchievementMicroButton", "QuestLogMicroButton",
            "GuildMicroButton", "LFDMicroButton", "CollectionsMicroButton",
            "EJMicroButton", "StoreMicroButton", "MainMenuMicroButton",
        },
    },
    {
        key = "bags", frames = { "BagsBar", "MainMenuBarBagManager" },
        buttonNames = {
            "MainMenuBarBackpackButton", "CharacterBag0Slot", "CharacterBag1Slot",
            "CharacterBag2Slot", "CharacterBag3Slot", "CharacterReagentBag0Slot",
            "KeyRingButton",
        },
    },
}

local groups = {}
local hooked = setmetatable({}, { __mode = "k" })
local leaveGeneration = 0

local function DB()
    return ns:GetDatabase().actionBarMouseover
end

local function ResolveFrame(definition)
    for _, name in ipairs(definition.frames) do
        if _G[name] then return _G[name] end
    end
end

local function IsHovered(region)
    if not region or not region.IsMouseOver then return false end
    local ok, value = pcall(region.IsMouseOver, region)
    return ok and value == true
end

local function GroupHovered(group)
    if IsHovered(group.frame) then return true end
    for _, button in ipairs(group.buttons) do
        if IsHovered(button) then return true end
    end
    return false
end

local function ApplyGroup(group, hovered)
    if not group.frame or not group.frame.SetAlpha then return end
    local bars = DB().bars or {}
    if not DB().enabled or bars[group.key] == false or hovered then
        group.frame:SetAlpha(1)
    else
        local opacity = math.max(0, math.min(1, tonumber(DB().fadedOpacity) or 0))
        group.frame:SetAlpha(opacity)
    end
end

local function RefreshHoverState()
    for _, group in ipairs(groups) do ApplyGroup(group, GroupHovered(group)) end
end

local function QueueLeaveCheck()
    leaveGeneration = leaveGeneration + 1
    local generation = leaveGeneration
    if C_Timer and C_Timer.After then
        C_Timer.After(0.08, function()
            if generation == leaveGeneration then RefreshHoverState() end
        end)
    else
        RefreshHoverState()
    end
end

local function HookRegion(region)
    if not region or hooked[region] or not region.HookScript then return end
    hooked[region] = true
    region:HookScript("OnEnter", function()
        leaveGeneration = leaveGeneration + 1
        RefreshHoverState()
    end)
    region:HookScript("OnLeave", QueueLeaveCheck)
end

local function DiscoverBars()
    groups = {}
    for _, definition in ipairs(BAR_DEFINITIONS) do
        local frame = ResolveFrame(definition)
        if frame then
            local group = { key = definition.key, frame = frame, buttons = {} }
            HookRegion(frame)
            for index = 1, definition.buttonCount or 12 do
                local button = definition.buttonPrefix and _G[definition.buttonPrefix .. index]
                if button then
                    group.buttons[#group.buttons + 1] = button
                    HookRegion(button)
                end
            end
            for _, name in ipairs(definition.buttonNames or {}) do
                local button = _G[name]
                if button then
                    group.buttons[#group.buttons + 1] = button
                    HookRegion(button)
                end
            end
            groups[#groups + 1] = group
        end
    end
end

function feature:Refresh()
    DiscoverBars()
    RefreshHoverState()
end

function feature:Initialize()
    self:Refresh()
    if C_Timer and C_Timer.After then
        C_Timer.After(1, function() feature:Refresh() end)
    end
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" or event == "EDIT_MODE_LAYOUTS_UPDATED" then
        self:Refresh()
    end
end

local function RequestEnableReload()
    if not EllesmereUI or not EllesmereUI.ShowConfirmPopup then return end
    EllesmereUI:ShowConfirmPopup({
        title = T("CORE.RELOAD_REQUIRED"),
        message = T("ACTION_BARS.MOUSEOVER_ENABLE_RELOAD"),
        confirmText = T("CORE.RELOAD_NOW"),
        cancelText = T("CORE.LATER"),
        reload = true,
    })
end

local function BarToggle(key, text)
    return {
        type = "toggle", text = text,
        disabled = function() return not DB().enabled end,
        getValue = function() return DB().bars[key] end,
        setValue = function(value) DB().bars[key] = value; feature:Refresh() end,
    }
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h
    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, T("ACTION_BARS.MOUSEOVER_ACTION_BARS"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle", text = T("ACTION_BARS.ENABLE_MOUSEOVER_ACTION_BARS"),
            getValue = function() return DB().enabled end,
            setValue = function(value)
                local wasEnabled = DB().enabled == true
                DB().enabled = value
                feature:Refresh()
                if value and not wasEnabled then RequestEnableReload() end
            end,
        },
        {
            type = "slider", text = T("ACTION_BARS.FADED_OPACITY"),
            min = 0, max = 1, step = 0.05,
            disabled = function() return not DB().enabled end,
            getValue = function() return DB().fadedOpacity end,
            setValue = function(value) DB().fadedOpacity = value; RefreshHoverState() end,
        }
    )
    y = y - h
    _, h = W:DualRow(parent, y,
        { type = "label", text = T("ACTION_BARS.MOUSEOVER_ACTION_BARS_NOTE") },
        { type = "label", text = "" }
    )
    y = y - h
    _, h = W:SectionHeader(parent, T("ACTION_BARS.BARS_TO_FADE"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        BarToggle("main", T("ACTION_BARS.ACTION_BAR_NUMBER", 1)),
        BarToggle("bar2", T("ACTION_BARS.ACTION_BAR_NUMBER", 2)))
    y = y - h
    _, h = W:DualRow(parent, y,
        BarToggle("bar3", T("ACTION_BARS.ACTION_BAR_NUMBER", 3)),
        BarToggle("bar4", T("ACTION_BARS.ACTION_BAR_NUMBER", 4)))
    y = y - h
    _, h = W:DualRow(parent, y,
        BarToggle("bar5", T("ACTION_BARS.ACTION_BAR_NUMBER", 5)),
        BarToggle("bar6", T("ACTION_BARS.ACTION_BAR_NUMBER", 6)))
    y = y - h
    _, h = W:DualRow(parent, y,
        BarToggle("bar7", T("ACTION_BARS.ACTION_BAR_NUMBER", 7)),
        BarToggle("bar8", T("ACTION_BARS.ACTION_BAR_NUMBER", 8)))
    y = y - h
    _, h = W:DualRow(parent, y,
        BarToggle("pet", T("ACTION_BARS.PET_BAR")),
        BarToggle("stance", T("ACTION_BARS.STANCE_BAR")))
    y = y - h
    _, h = W:DualRow(parent, y,
        BarToggle("micro", T("ACTION_BARS.MICRO_MENU")),
        BarToggle("bags", T("ACTION_BARS.BAG_BAR")))
    y = y - h
    return math.abs(y)
end
