local ADDON_NAME, ns = ...

local feature = {
    key = "XPBar",
    page = "XP & Progression",
    searchTerms = {
        "xp bar",
        "experience bar",
        "gradient",
        "rested xp",
        "quest xp",
        "completed quests",
        "data bar",
    },
}

ns:RegisterFeature(feature.key, feature)

local XP_BAR_NAME = "EllesmereEAB_XPBar_Bar"
local RESTED_BAR_NAME = "EllesmereEAB_XPBar_Rested"
local retryTicker
local hooksInstalled = false
local applying = false
local borderFrame
local xpTextLeft
local xpTextRight
local nativeXPText
local textHooksInstalled = false
local textApplying = false
local textRefreshQueued = false

local function DB()
    return ns:GetDatabase().xpBar
end

local function Abbreviate(value)
    if type(AbbreviateLargeNumbers) == "function" then
        return AbbreviateLargeNumbers(value)
    end
    if type(BreakUpLargeNumbers) == "function" then
        return BreakUpLargeNumbers(value)
    end
    return tostring(value)
end

local function CopyFontStyle(source, target)
    if source.GetFont and target.SetFont then
        local path, size, flags = source:GetFont()
        if path then target:SetFont(path, size, flags) end
    end
    if source.GetTextColor and target.SetTextColor then
        target:SetTextColor(source:GetTextColor())
    end
    if source.GetShadowColor and target.SetShadowColor then
        target:SetShadowColor(source:GetShadowColor())
    end
    if source.GetShadowOffset and target.SetShadowOffset then
        target:SetShadowOffset(source:GetShadowOffset())
    end
end

local function UpdateXPText()
    local xpBar = _G[XP_BAR_NAME]
    local holder = xpBar and xpBar:GetParent()
    local center = holder and holder._text
    if not center then return false end

    local host = center:GetParent()
    if not host or not host.CreateFontString then return false end
    if not xpTextLeft then
        xpTextLeft = host:CreateFontString(nil, "OVERLAY")
        xpTextRight = host:CreateFontString(nil, "OVERLAY")
    end

    if not DB().customTextEnabled then
        xpTextLeft:Hide()
        xpTextRight:Hide()
        if nativeXPText ~= nil then
            textApplying = true
            center:SetText(nativeXPText)
            textApplying = false
        end
        return true
    end

    CopyFontStyle(center, xpTextLeft)
    CopyFontStyle(center, xpTextRight)

    local _, _, _, offsetX, offsetY = center:GetPoint(1)
    offsetX, offsetY = offsetX or 0, offsetY or 0
    center:ClearAllPoints()
    center:SetPoint("CENTER", host, "CENTER", offsetX, offsetY)
    center:SetJustifyH("CENTER")
    xpTextLeft:ClearAllPoints()
    xpTextLeft:SetPoint("LEFT", host, "LEFT", 6 + offsetX, offsetY)
    xpTextLeft:SetJustifyH("LEFT")
    xpTextRight:ClearAllPoints()
    xpTextRight:SetPoint("RIGHT", host, "RIGHT", -6 + offsetX, offsetY)
    xpTextRight:SetJustifyH("RIGHT")

    local current = math.max(0, UnitXP("player") or 0)
    local maximum = math.max(1, UnitXPMax("player") or 0)
    local rested = math.max(0, GetXPExhaustion and (GetXPExhaustion() or 0) or 0)
    local percentage = (current / maximum) * 100
    local restedPercentage = (rested / maximum) * 100

    textApplying = true
    xpTextLeft:SetText(string.format("%s %d", LEVEL or "Level", UnitLevel("player") or 0))
    center:SetText(string.format("%s / %s | %.1f%%", Abbreviate(current), Abbreviate(maximum), percentage))
    xpTextRight:SetText(string.format("%s: %.1f%%", RESTED or "Rested", restedPercentage))
    textApplying = false
    xpTextLeft:Show()
    xpTextRight:Show()
    return true
end

local function QueueXPTextUpdate()
    if textRefreshQueued then return end
    textRefreshQueued = true
    C_Timer.After(0, function()
        textRefreshQueued = false
        UpdateXPText()
    end)
end

local function InstallTextHooks()
    if textHooksInstalled then return true end
    local xpBar = _G[XP_BAR_NAME]
    local holder = xpBar and xpBar:GetParent()
    local center = holder and holder._text
    if not center then return false end

    nativeXPText = center:GetText()
    hooksecurefunc(center, "SetText", function(_, value)
        if textApplying then return end
        nativeXPText = value
        QueueXPTextUpdate()
    end)
    hooksecurefunc(center, "SetFont", function()
        if not textApplying then QueueXPTextUpdate() end
    end)
    textHooksInstalled = true
    return true
end

local function GetColor(key, fallback)
    local settings = DB()
    local value = settings[key]

    if type(value) ~= "table" then
        value = {
            r = fallback.r,
            g = fallback.g,
            b = fallback.b,
            a = fallback.a,
        }
        settings[key] = value
    end

    return value
end

-- Keep quest rewards separate from the gradient toggle and from rested XP.
-- The texture belongs to the existing bar, inheriting its visibility and alpha.
local questXP = 0
local questOverlay
local refreshPending = false

local function UpdateQuestXP()
    questXP = 0
    if not DB().questEnabled or not C_QuestLog or not GetQuestLogRewardXP then return end

    local seen = {}
    for index = 1, C_QuestLog.GetNumQuestLogEntries() do
        local info = C_QuestLog.GetInfo(index)
        local questID = info and info.questID
        if questID and questID > 0 and not info.isHeader and not info.isHidden
            and not seen[questID] and C_QuestLog.IsComplete(questID)
        then
            seen[questID] = true
            -- Pass the ID explicitly; never change the player's selected quest.
            local reward = GetQuestLogRewardXP(questID)
            if type(reward) == "number" and reward > 0 then
                questXP = questXP + reward
            end
        end
    end
end

function feature:UpdateQuestOverlay()
    local xpBar = _G[XP_BAR_NAME]
    if not xpBar then return end
    if questOverlay then questOverlay:Hide() end
    if not DB().questEnabled or questXP <= 0 then return end

    local level = UnitLevel("player") or 0
    local maxLevel = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
        or (GetMaxPlayerLevel and GetMaxPlayerLevel())
    if (IsPlayerAtEffectiveMaxLevel and IsPlayerAtEffectiveMaxLevel())
        or (IsLevelAtEffectiveMaxLevel and IsLevelAtEffectiveMaxLevel(level))
        or (maxLevel and level >= maxLevel)
        or (IsXPUserDisabled and IsXPUserDisabled()) then return end

    local maximum = UnitXPMax("player") or 0
    if maximum <= 0 then return end
    local current = math.max(0, math.min(UnitXP("player") or 0, maximum))
    local amount = math.min(questXP, maximum - current)
    local width, height = xpBar:GetSize()
    if amount <= 0 or width <= 0 or height <= 0 then return end

    if not questOverlay then
        questOverlay = xpBar:CreateTexture(nil, "OVERLAY", nil, 1)
    end
    local color = GetColor("questColor", ns.defaults.xpBar.questColor)
    questOverlay:SetColorTexture(color.r, color.g, color.b, color.a or 1)
    questOverlay:ClearAllPoints()
    -- Clip at the level boundary; the full total remains cached for future updates.
    questOverlay:SetPoint("TOPLEFT", xpBar, "TOPLEFT", width * current / maximum, 0)
    questOverlay:SetSize(width * amount / maximum, height)
    questOverlay:Show()
end

local function ApplyGradient(texture, orientation, first, second)
    if not texture then return end

    texture:SetVertexColor(1, 1, 1, 1)

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

local function ApplyBorder(xpBar)
    if not xpBar or not EllesmereUI or not EllesmereUI.ApplyBorderStyle then return end
    if not borderFrame then
        local holder = xpBar:GetParent()
        -- EllesmereUI already creates a one-pixel border host around the outer
        -- data-bar holder. Restyle that host so the configurable border replaces
        -- the native edge instead of stacking around the inset StatusBar.
        borderFrame = holder and holder._border and holder._border._frame
        if not borderFrame then
            borderFrame = CreateFrame("Frame", nil, holder or xpBar)
            borderFrame:EnableMouse(false)
            borderFrame:SetAllPoints(holder or xpBar)
        end
    end
    -- Textured styles render their BackdropTemplate at this host's level.
    -- Keep it above the inset StatusBar but below EUI's dedicated text host.
    borderFrame:SetFrameLevel(xpBar:GetFrameLevel() + 1)
    local settings = DB()
    local defaults = ns.defaults.xpBar
    local color = GetColor("borderColor", defaults.borderColor)
    local size = settings.borderSize
    if type(size) ~= "number" then size = defaults.borderSize end
    EllesmereUI.ApplyBorderStyle(
        borderFrame, math.max(0, size or 0),
        color.r, color.g, color.b, color.a or 1,
        settings.borderTexture or defaults.borderTexture or "solid",
        settings.borderTextureOffset, settings.borderTextureOffsetY,
        settings.borderTextureShiftX, settings.borderTextureShiftY
    )
end


function feature:Apply()
    if applying then return true end

    local xpBar = _G[XP_BAR_NAME]
    local restedBar = _G[RESTED_BAR_NAME]
    if not xpBar then return false end

    applying = true
    self:UpdateQuestOverlay()
    ApplyBorder(xpBar)
    InstallTextHooks()
    UpdateXPText()

    local settings = DB()
    local defaults = ns.defaults.xpBar
    local orientation = settings.orientation or "HORIZONTAL"
    local holder = xpBar:GetParent()

    if not settings.enabled then
        if holder and holder._updateFunc then
            holder._updateFunc()
        end

        applying = false
        return true
    end

    if restedBar and not settings.restedEnabled then
        if holder and holder._updateFunc then
            holder._updateFunc()
        end
    end

    ApplyGradient(
        xpBar:GetStatusBarTexture(),
        orientation,
        GetColor("startColor", defaults.startColor),
        GetColor("endColor", defaults.endColor)
    )

    if restedBar and settings.restedEnabled then
        ApplyGradient(
            restedBar:GetStatusBarTexture(),
            orientation,
            GetColor("restedStartColor", defaults.restedStartColor),
            GetColor("restedEndColor", defaults.restedEndColor)
        )
    end

    applying = false
    return true
end

function feature:Refresh()
    UpdateQuestXP()
    if not self:Apply() then
        self:StartRetry()
    end
end

function feature:StartRetry()
    if retryTicker then return end

    retryTicker = C_Timer.NewTicker(0.5, function()
        if feature:Apply() then
            retryTicker:Cancel()
            retryTicker = nil
            feature:InstallHooks()
        end
    end)
end

function feature:InstallHooks()
    if hooksInstalled then return true end

    local xpBar = _G[XP_BAR_NAME]
    local restedBar = _G[RESTED_BAR_NAME]
    if not xpBar then return false end

    hooksInstalled = true
    InstallTextHooks()

    hooksecurefunc(xpBar, "SetValue", function() feature:UpdateQuestOverlay() end)
    xpBar:HookScript("OnSizeChanged", function() feature:UpdateQuestOverlay() end)
    xpBar:HookScript("OnShow", function() feature:UpdateQuestOverlay() end)

    hooksecurefunc(xpBar, "SetStatusBarColor", function()
        if DB().enabled and not applying then
            feature:Apply()
        end
    end)

    if restedBar then
        hooksecurefunc(restedBar, "SetStatusBarColor", function()
            if DB().enabled and DB().restedEnabled and not applying then
                feature:Apply()
            end
        end)
    end

    return true
end

function feature:Initialize()
    UpdateQuestXP()
    if self:Apply() then
        self:InstallHooks()
    else
        self:StartRetry()
    end
end

function feature:Reset()
    local settings = DB()

    for key, value in pairs(ns.defaults.xpBar) do
        if type(value) == "table" then
            settings[key] = {
                r = value.r,
                g = value.g,
                b = value.b,
                a = value.a,
            }
        else
            settings[key] = value
        end
    end

    self:Refresh()
end

local function AttachSwatch(region, key, fallback)
    local swatch, refresh = EllesmereUI.BuildColorSwatch(
        region,
        region:GetFrameLevel() + 5,
        function()
            local color = GetColor(key, fallback)
            return color.r, color.g, color.b, color.a or 1
        end,
        function(r, g, b, a)
            local color = GetColor(key, fallback)
            color.r = r
            color.g = g
            color.b = b
            color.a = a or color.a or 1
            feature:Refresh()
        end,
        true,
        22
    )

    swatch:SetPoint("RIGHT", region, "RIGHT", -8, 0)
    region._lastInline = swatch

    if EllesmereUI.RegisterWidgetRefresh then
        EllesmereUI.RegisterWidgetRefresh(refresh)
    end
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h
    local defaults = ns.defaults.xpBar

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "XP BAR TEXT", y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = "Enable Three-Zone XP Text",
            tooltip = "Show Level on the left, current/max XP and percentage in the center, and rested XP on the right. Disable to restore EllesmereUI's native XP text.",
            getValue = function() return DB().customTextEnabled end,
            setValue = function(value)
                DB().customTextEnabled = value and true or false
                if not value then
                    local xpBar = _G[XP_BAR_NAME]
                    local holder = xpBar and xpBar:GetParent()
                    if holder and holder._updateFunc then holder._updateFunc() end
                end
                feature:Refresh()
            end,
        },
        { type = "label", text = "Left: Level   Center: XP / Max | %   Right: Rested %" })
    y = y - h

    _, h = W:Spacer(parent, y, 18)
    y = y - h

    _, h = W:SectionHeader(parent, "XP BAR GRADIENT", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable XP Bar Gradient",
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value
                feature:Refresh()
            end,
        },
        {
            type = "dropdown",
            text = "Gradient Direction",
            values = {
                HORIZONTAL = "Horizontal",
                VERTICAL = "Vertical",
            },
            order = { "HORIZONTAL", "VERTICAL" },
            getValue = function()
                return DB().orientation or "HORIZONTAL"
            end,
            setValue = function(value)
                DB().orientation = value
                feature:Refresh()
            end,
        }
    )
    y = y - h

    local mainRow
    mainRow, h = W:DualRow(
        parent,
        y,
        { type = "label", text = "Gradient Start Color" },
        { type = "label", text = "Gradient End Color" }
    )
    y = y - h

    AttachSwatch(mainRow._leftRegion, "startColor", defaults.startColor)
    AttachSwatch(mainRow._rightRegion, "endColor", defaults.endColor)

    _, h = W:Spacer(parent, y, 18)
    y = y - h

    _, h = W:SectionHeader(parent, "XP BAR BORDER", y)
    y = y - h
    local borderValues, borderOrder = EllesmereUI.GetBorderTextureDropdown()
    local borderRow
    borderRow, h = W:DualRow(parent, y,
        {
            type = "dropdown", text = "Border Style",
            values = borderValues, order = borderOrder,
            getValue = function() return DB().borderTexture or defaults.borderTexture end,
            setValue = function(value)
                local settings = DB()
                settings.borderTexture = value
                settings.borderTextureOffset = nil
                settings.borderTextureOffsetY = nil
                settings.borderTextureShiftX = nil
                settings.borderTextureShiftY = nil
                if EllesmereUI.GetBorderStyleSelectDefaults then
                    local color = EllesmereUI.GetBorderStyleSelectDefaults(value)
                    if color then
                        local current = GetColor("borderColor", defaults.borderColor)
                        current.r, current.g, current.b = color.r, color.g, color.b
                        current.a = color.a or 1
                    end
                end
                feature:Refresh()
            end,
        },
        {
            type = "slider", text = "Border Size", min = 0, max = 4, step = 1,
            getValue = function() return DB().borderSize or 0 end,
            setValue = function(value) DB().borderSize = value; feature:Refresh() end,
        })
    y = y - h
    AttachSwatch(borderRow._rightRegion, "borderColor", defaults.borderColor)

    _, h = W:Spacer(parent, y, 18)
    y = y - h

    _, h = W:SectionHeader(parent, "RESTED XP GRADIENT", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable Rested XP Gradient",
            getValue = function() return DB().restedEnabled end,
            setValue = function(value)
                DB().restedEnabled = value
                feature:Refresh()
            end,
        },
        {
            type = "button",
            text = "Reset XP Gradient",
            buttonText = "Reset",
            onClick = function()
                feature:Reset()
                if EllesmereUI and EllesmereUI.RefreshPage then
                    EllesmereUI:RefreshPage(true)
                end
            end,
        }
    )
    y = y - h

    local restedRow
    restedRow, h = W:DualRow(
        parent,
        y,
        { type = "label", text = "Rested Start Color" },
        { type = "label", text = "Rested End Color" }
    )
    y = y - h

    AttachSwatch(restedRow._leftRegion, "restedStartColor", defaults.restedStartColor)
    AttachSwatch(restedRow._rightRegion, "restedEndColor", defaults.restedEndColor)

    _, h = W:Spacer(parent, y, 18)
    y = y - h
    _, h = W:SectionHeader(parent, "COMPLETED QUEST XP", y)
    y = y - h
    local questRow
    questRow, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = "Enable Quest XP Overlay",
            getValue = function() return DB().questEnabled end,
            setValue = function(value)
                DB().questEnabled = value
                feature:Refresh()
            end,
        },
        { type = "label", text = "Quest XP Color" }
    )
    y = y - h
    AttachSwatch(questRow._rightRegion, "questColor", defaults.questColor)

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
        if refreshPending then return end
        refreshPending = true
        C_Timer.After(0, function()
            refreshPending = false
            feature:Refresh()
        end)
    end
end
