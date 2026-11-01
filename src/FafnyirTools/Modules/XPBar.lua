local ADDON_NAME, ns = ...

if ns.HAS_ELLESMEREUI then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "XPBar",
    page = T("CORE.XP_PROGRESSION"),
    searchTerms = {
        "xp bar", "experience bar", "gradient", "rested xp",
        "quest xp", "completed quests",
    },
}
ns:RegisterFeature(feature.key, feature)

local EXPERIENCE_INDEX = 4
local WHITE_TEXTURE = "Interface\\Buttons\\WHITE8X8"
local retryTicker
local refreshPending = false
local applying = false
local hookedBars = setmetatable({}, { __mode = "k" })
local nativeTextures = setmetatable({}, { __mode = "k" })
local questOverlays = setmetatable({}, { __mode = "k" })
local trackMasks = setmetatable({}, { __mode = "k" })
local maskedTextures = setmetatable({}, { __mode = "k" })
local questXP = 0

local function DB()
    return ns:GetDatabase().xpBar
end

local function UsableNumber(value)
    if type(value) ~= "number" then return nil end
    if issecretvalue and issecretvalue(value) then return nil end
    return value
end

local function GetColor(key, fallback)
    local settings = DB()
    if type(settings[key]) ~= "table" then
        settings[key] = {
            r = fallback.r, g = fallback.g, b = fallback.b, a = fallback.a,
        }
    end
    local color = settings[key]
    color.r = tonumber(color.r) or fallback.r
    color.g = tonumber(color.g) or fallback.g
    color.b = tonumber(color.b) or fallback.b
    color.a = tonumber(color.a) or fallback.a or 1
    return color
end

local function ExperienceIndex()
    return StatusTrackingBarInfo and StatusTrackingBarInfo.BarsEnum
        and StatusTrackingBarInfo.BarsEnum.Experience or EXPERIENCE_INDEX
end

local function NativeBars()
    local result, seen = {}, {}
    local containers = StatusTrackingBarManager and StatusTrackingBarManager.barContainers
    if type(containers) ~= "table" then
        containers = { _G.MainStatusTrackingBarContainer, _G.SecondaryStatusTrackingBarContainer }
    end
    for _, container in pairs(containers) do
        local bar = container and container.bars and container.bars[ExperienceIndex()]
        if bar and bar.StatusBar and not seen[bar] then
            result[#result + 1] = bar
            seen[bar] = true
        end
    end
    return result
end

local function AtMaxLevel()
    local level = UsableNumber(UnitLevel and UnitLevel("player")) or 0
    local maximum = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
        or (GetMaxPlayerLevel and GetMaxPlayerLevel())
    return (IsPlayerAtEffectiveMaxLevel and IsPlayerAtEffectiveMaxLevel())
        or (IsLevelAtEffectiveMaxLevel and IsLevelAtEffectiveMaxLevel(level))
        or (type(maximum) == "number" and level >= maximum)
        or (IsXPUserDisabled and IsXPUserDisabled())
end

local function CaptureNative(bar)
    if nativeTextures[bar] then return nativeTextures[bar] end
    local fill = bar.StatusBar and bar.StatusBar:GetStatusBarTexture()
    local rested = bar.ExhaustionLevelFillBar
    local snapshot = {
        fill = fill,
        fillAtlas = fill and fill.GetAtlas and fill:GetAtlas() or nil,
        fillTexture = fill and fill.GetTexture and fill:GetTexture() or nil,
        rested = rested,
        restedAtlas = rested and rested.GetAtlas and rested:GetAtlas() or nil,
        restedTexture = rested and rested.GetTexture and rested:GetTexture() or nil,
    }
    nativeTextures[bar] = snapshot
    return snapshot
end

local function ApplyTrackMask(bar, texture)
    if not texture or not texture.AddMaskTexture or maskedTextures[texture] then return end
    local status = bar.StatusBar
    if not status or not status.CreateMaskTexture then return end
    local mask = trackMasks[bar]
    if not mask then
        mask = status:CreateMaskTexture(nil, "ARTWORK")
        mask:SetAllPoints(status)
        local snapshot = nativeTextures[bar] or CaptureNative(bar)
        local atlas = snapshot and snapshot.fillAtlas
        local path = snapshot and snapshot.fillTexture
        if atlas and mask.SetAtlas then
            mask:SetAtlas(atlas)
        elseif path and mask.SetTexture then
            mask:SetTexture(path, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
        else
            mask:SetAtlas("UI-HUD-ExperienceBar-Fill-Experience")
        end
        trackMasks[bar] = mask
    end
    texture:AddMaskTexture(mask)
    maskedTextures[texture] = true
end

function feature:ReapplyBar(bar)
    if applying then return end
    applying = true
    self:ApplyBar(bar)
    applying = false
end

local function RestoreTexture(texture, atlas, path)
    if not texture then return end
    if atlas and texture.SetAtlas then
        texture:SetAtlas(atlas)
    elseif path and texture.SetTexture then
        texture:SetTexture(path)
    end
    if texture.SetVertexColor then texture:SetVertexColor(1, 1, 1, 1) end
end

local function ApplyGradient(texture, orientation, first, second)
    if not texture then return end
    if texture.SetTexture then texture:SetTexture(WHITE_TEXTURE) end
    if texture.SetVertexColor then texture:SetVertexColor(1, 1, 1, 1) end
    if texture.SetGradient and CreateColor then
        texture:SetGradient(
            orientation,
            CreateColor(first.r, first.g, first.b, first.a or 1),
            CreateColor(second.r, second.g, second.b, second.a or 1)
        )
    elseif texture.SetGradientAlpha then
        texture:SetGradientAlpha(
            orientation,
            first.r, first.g, first.b, first.a or 1,
            second.r, second.g, second.b, second.a or 1
        )
    end
end

local function UpdateQuestXP()
    questXP = 0
    if not DB().questEnabled or not C_QuestLog or not GetQuestLogRewardXP
        or not C_QuestLog.GetNumQuestLogEntries
        or not C_QuestLog.GetQuestIDForLogIndex
        or not C_QuestLog.IsComplete
    then
        return
    end
    local seen = {}
    for index = 1, C_QuestLog.GetNumQuestLogEntries() do
        local questID = C_QuestLog.GetQuestIDForLogIndex(index)
        if type(questID) == "number" and questID > 0 and not seen[questID]
            and C_QuestLog.IsComplete(questID)
        then
            seen[questID] = true
            local reward = UsableNumber(GetQuestLogRewardXP(questID))
            if reward and reward > 0 then questXP = questXP + reward end
        end
    end
end

function feature:UpdateQuestOverlay(bar)
    local overlay = questOverlays[bar]
    if overlay then overlay:Hide() end
    if not DB().questEnabled or questXP <= 0 or AtMaxLevel() then return end

    local maximum = UsableNumber(UnitXPMax and UnitXPMax("player")) or 0
    local current = UsableNumber(UnitXP and UnitXP("player")) or 0
    if maximum <= 0 then return end
    current = math.max(0, math.min(current, maximum))
    local amount = math.min(questXP, maximum - current)
    local status = bar.StatusBar
    local width, height = status:GetSize()
    if amount <= 0 or not width or not height or width <= 0 or height <= 0 then return end

    if not overlay then
        -- Blizzard's rested prediction texture is ARTWORK -1. Quest XP sits
        -- directly behind it at -2; the StatusBar fill remains above both.
        overlay = bar:CreateTexture(nil, "ARTWORK", nil, -2)
        questOverlays[bar] = overlay
    end
    ApplyTrackMask(bar, overlay)
    local color = GetColor("questColor", ns.defaults.xpBar.questColor)
    overlay:SetColorTexture(color.r, color.g, color.b, color.a or 1)
    overlay:ClearAllPoints()
    overlay:SetPoint("TOPLEFT", status, "TOPLEFT", width * current / maximum, 0)
    overlay:SetSize(width * amount / maximum, height)
    overlay:Show()
end

function feature:ApplyBar(bar)
    local snapshot = CaptureNative(bar)
    local settings = DB()
    local defaults = ns.defaults.xpBar
    local orientation = settings.orientation == "VERTICAL" and "VERTICAL" or "HORIZONTAL"

    ApplyTrackMask(bar, bar.StatusBar:GetStatusBarTexture())
    ApplyTrackMask(bar, snapshot.rested)

    if settings.enabled then
        ApplyGradient(
            bar.StatusBar:GetStatusBarTexture(), orientation,
            GetColor("startColor", defaults.startColor),
            GetColor("endColor", defaults.endColor)
        )
    else
        RestoreTexture(snapshot.fill, snapshot.fillAtlas, snapshot.fillTexture)
    end

    if snapshot.rested then
        if settings.restedEnabled then
            ApplyGradient(
                snapshot.rested, orientation,
                GetColor("restedStartColor", defaults.restedStartColor),
                GetColor("restedEndColor", defaults.restedEndColor)
            )
        else
            RestoreTexture(snapshot.rested, snapshot.restedAtlas, snapshot.restedTexture)
        end
    end
    self:UpdateQuestOverlay(bar)
end

function feature:Apply()
    if applying then return true end
    local bars = NativeBars()
    if #bars == 0 then return false end
    applying = true
    for _, bar in ipairs(bars) do self:ApplyBar(bar) end
    applying = false
    return true
end

function feature:InstallHooks()
    local found = false
    for _, bar in ipairs(NativeBars()) do
        found = true
        if not hookedBars[bar] then
            hookedBars[bar] = true
            if hooksecurefunc and type(bar.UpdateAll) == "function" then
                hooksecurefunc(bar, "UpdateAll", function()
                    feature:ReapplyBar(bar)
                end)
            end
            if hooksecurefunc and type(bar.UpdateStatusBarTextures) == "function" then
                hooksecurefunc(bar, "UpdateStatusBarTextures", function()
                    feature:ReapplyBar(bar)
                end)
            end
            bar:HookScript("OnShow", function() feature:ReapplyBar(bar) end)
            bar:HookScript("OnHide", function() feature:ReapplyBar(bar) end)
            bar:HookScript("OnSizeChanged", function() feature:ReapplyBar(bar) end)
        end
    end
    return found
end

function feature:QueueRefresh()
    if refreshPending then return end
    refreshPending = true
    C_Timer.After(0, function()
        refreshPending = false
        feature:Refresh()
    end)
end

function feature:StartRetry()
    if retryTicker or not (C_Timer and C_Timer.NewTicker) then return end
    retryTicker = C_Timer.NewTicker(0.5, function()
        if feature:Apply() then
            feature:InstallHooks()
            retryTicker:Cancel()
            retryTicker = nil
        end
    end)
end

function feature:Refresh()
    UpdateQuestXP()
    if self:Apply() then self:InstallHooks() else self:StartRetry() end
end

function feature:Initialize()
    self:Refresh()
end

function feature:Reset()
    local settings = DB()
    for key, value in pairs(ns.defaults.xpBar) do
        if type(value) == "table" then
            settings[key] = { r = value.r, g = value.g, b = value.b, a = value.a }
        else
            settings[key] = value
        end
    end
    self:Refresh()
end

local function ColorDescriptor(key, text)
    return {
        type = "color",
        text = text,
        getValue = function() return GetColor(key, ns.defaults.xpBar[key]) end,
        setValue = function(r, g, b, a)
            local color = GetColor(key, ns.defaults.xpBar[key])
            color.r, color.g, color.b, color.a = r, g, b, a
            feature:Refresh()
        end,
    }
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, T("XP.XP_BAR_GRADIENT"), y); y = y - h
    _, h = W:DualRow(parent, y, {
        type = "toggle", text = T("XP.ENABLE_XP_BAR_GRADIENT"),
        getValue = function() return DB().enabled end,
        setValue = function(value) DB().enabled = value; feature:Refresh() end,
    }, {
        type = "dropdown", text = T("XP.GRADIENT_DIRECTION"),
        values = { HORIZONTAL = T("XP.HORIZONTAL"), VERTICAL = T("XP.VERTICAL") },
        order = { "HORIZONTAL", "VERTICAL" },
        getValue = function() return DB().orientation end,
        setValue = function(value) DB().orientation = value; feature:Refresh() end,
    }); y = y - h
    _, h = W:DualRow(parent, y,
        ColorDescriptor("startColor", T("XP.GRADIENT_START_COLOR")),
        ColorDescriptor("endColor", T("XP.GRADIENT_END_COLOR"))); y = y - h
    _, h = W:SectionHeader(parent, T("XP.RESTED_XP_GRADIENT"), y); y = y - h
    _, h = W:DualRow(parent, y, {
        type = "toggle", text = T("XP.ENABLE_RESTED_XP_GRADIENT"),
        getValue = function() return DB().restedEnabled end,
        setValue = function(value) DB().restedEnabled = value; feature:Refresh() end,
    }, {
        type = "button", text = T("XP.RESET_XP_GRADIENT"), buttonText = T("XP.RESET"),
        onClick = function()
            feature:Reset()
            if EllesmereUI and EllesmereUI.RefreshPage then EllesmereUI:RefreshPage(true) end
        end,
    }); y = y - h
    _, h = W:DualRow(parent, y,
        ColorDescriptor("restedStartColor", T("XP.RESTED_START_COLOR")),
        ColorDescriptor("restedEndColor", T("XP.RESTED_END_COLOR"))); y = y - h

    _, h = W:SectionHeader(parent, T("XP.COMPLETED_QUEST_XP"), y); y = y - h
    _, h = W:DualRow(parent, y, {
        type = "toggle", text = T("XP.ENABLE_QUEST_XP_OVERLAY"),
        getValue = function() return DB().questEnabled end,
        setValue = function(value) DB().questEnabled = value; feature:Refresh() end,
    }, ColorDescriptor("questColor", T("XP.QUEST_XP_COLOR"))); y = y - h

    return math.abs(y)
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD"
        or event == "PLAYER_XP_UPDATE"
        or event == "PLAYER_LEVEL_UP"
        or event == "UPDATE_EXHAUSTION"
        or event == "QUEST_LOG_UPDATE"
        or event == "QUEST_WATCH_UPDATE"
        or event == "QUEST_ACCEPTED"
        or event == "QUEST_REMOVED"
        or event == "QUEST_TURNED_IN"
        or event == "QUEST_DATA_LOAD_RESULT"
    then
        self:QueueRefresh()
    end
end
