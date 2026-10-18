local ADDON_NAME, ns = ...
local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "LevelingForecast",
    page = T("CORE.QOL"),
    searchTerms = { "leveling", "forecast", "quest xp", "warband", "experience", "bonus" },
}

ns:RegisterFeature(feature.key, feature)

-- Midnight 12.1 XP requirements for the level shown to the level after it.
-- The live UnitXPMax value remains authoritative for the player's current
-- level. Future levels are used only when that live value matches this table,
-- so a client rebalance falls back to the conservative one-level projection.
local MIDNIGHT_XP_TO_NEXT_LEVEL = {
    [80] = 403725,
    [81] = 423390,
    [82] = 443395,
    [83] = 463740,
    [84] = 484430,
    [85] = 505455,
    [86] = 526825,
    [87] = 548535,
    [88] = 570590,
    [89] = 592980,
}

local function UsableNumber(value)
    if type(value) ~= "number" then return nil end
    if issecretvalue and issecretvalue(value) then return nil end
    return value
end

local function EffectiveMaxLevel()
    local maximum = (GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
        or (GetMaxPlayerLevel and GetMaxPlayerLevel())
    return UsableNumber(maximum)
end

local function IsAtMaxLevel(level, maximum)
    if IsPlayerAtEffectiveMaxLevel and IsPlayerAtEffectiveMaxLevel() then
        return true
    end
    if IsLevelAtEffectiveMaxLevel and IsLevelAtEffectiveMaxLevel(level) then
        return true
    end
    return type(maximum) == "number" and level >= maximum
end

function feature:GetCompletedQuestXP()
    if not (C_QuestLog and C_QuestLog.GetNumQuestLogEntries
        and C_QuestLog.GetQuestIDForLogIndex and C_QuestLog.IsComplete
        and GetQuestLogRewardXP)
    then
        return 0, 0, 0, 0
    end

    local count, totalXP, baseXP, adjustedForBonus = 0, 0, 0, 0
    local seen = {}
    for index = 1, C_QuestLog.GetNumQuestLogEntries() do
        local questID = C_QuestLog.GetQuestIDForLogIndex(index)
        if type(questID) == "number" and questID > 0 and not seen[questID]
            and C_QuestLog.IsComplete(questID)
        then
            seen[questID] = true
            local adjusted, base = GetQuestLogRewardXP(questID)
            adjusted = UsableNumber(adjusted)
            base = UsableNumber(base)
            if adjusted and adjusted > 0 then
                count = count + 1
                totalXP = totalXP + adjusted
                if base and base > 0 then
                    baseXP = baseXP + base
                    adjustedForBonus = adjustedForBonus + adjusted
                end
            end
        end
    end
    return count, totalXP, baseXP, adjustedForBonus
end

function feature:GetForecast()
    local level = UsableNumber(UnitLevel and UnitLevel("player")) or 0
    local current = UsableNumber(UnitXP and UnitXP("player")) or 0
    local maximum = UsableNumber(UnitXPMax and UnitXPMax("player")) or 0
    local maximumLevel = EffectiveMaxLevel()
    local count, questXP, baseXP, adjustedForBonus = self:GetCompletedQuestXP()
    local result = {
        level = level,
        currentXP = current,
        maximumXP = maximum,
        questCount = count,
        questXP = questXP,
        baseQuestXP = baseXP,
        maximumLevel = maximumLevel,
        atMaxLevel = IsAtMaxLevel(level, maximumLevel) or maximum <= 0,
    }

    if baseXP > 0 and adjustedForBonus >= baseXP then
        result.bonusPercent = math.floor((((adjustedForBonus / baseXP) - 1) * 100) + 0.5)
    end

    if not result.atMaxLevel and maximum > 0 then
        local projected = current + questXP
        if projected < maximum then
            result.projectedLevel = level
            result.projectedPercent = projected / maximum * 100
        else
            local projectedLevel = level + 1
            local remaining = projected - maximum
            result.projectedLevel = projectedLevel

            if maximumLevel and projectedLevel >= maximumLevel then
                result.projectedAtMaxLevel = true
            elseif maximumLevel == 90 and MIDNIGHT_XP_TO_NEXT_LEVEL[level] == maximum then
                while projectedLevel < maximumLevel do
                    local required = MIDNIGHT_XP_TO_NEXT_LEVEL[projectedLevel]
                    if not required then break end
                    if remaining < required then
                        result.projectedPercent = remaining / required * 100
                        remaining = nil
                        break
                    end
                    remaining = remaining - required
                    projectedLevel = projectedLevel + 1
                    result.projectedLevel = projectedLevel
                end
                if projectedLevel >= maximumLevel then
                    result.projectedAtMaxLevel = true
                elseif remaining then
                    result.overflowXP = remaining
                end
            else
                result.overflowXP = remaining
            end
        end
    end
    return result
end

local function Number(value)
    if BreakUpLargeNumbers then return BreakUpLargeNumbers(value) end
    return tostring(value)
end

local function Percent(value)
    return string.format("%.1f%%", value or 0)
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    local forecast = self:GetForecast()

    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, T("QOL.LEVELING_FORECAST"), y)
    y = y - h

    if forecast.atMaxLevel then
        _, h = W:DualRow(parent, y,
            { type = "label", text = T("QOL.CURRENT_PROGRESS") },
            { type = "label", text = T("QOL.MAXIMUM_LEVEL") })
        y = y - h
    else
        local currentPercent = forecast.maximumXP > 0
            and forecast.currentXP / forecast.maximumXP * 100 or 0
        _, h = W:DualRow(parent, y,
            { type = "label", text = T("QOL.CURRENT_PROGRESS") },
            { type = "label", text = T("QOL.LEVEL_PERCENT", forecast.level, Percent(currentPercent)) })
        y = y - h
    end

    _, h = W:DualRow(parent, y,
        { type = "label", text = T("QOL.COMPLETED_QUESTS_READY") },
        { type = "label", text = tostring(forecast.questCount) })
    y = y - h

    _, h = W:DualRow(parent, y,
        { type = "label", text = T("QOL.COMPLETED_QUEST_XP") },
        { type = "label", text = Number(forecast.questXP) })
    y = y - h

    local bonus = forecast.bonusPercent ~= nil
        and (forecast.bonusPercent > 0 and ("+" .. forecast.bonusPercent .. "%") or "0%")
        or T("QOL.NOT_AVAILABLE")
    _, h = W:DualRow(parent, y,
        { type = "label", text = T("QOL.EFFECTIVE_QUEST_XP_BONUS") },
        { type = "label", text = bonus })
    y = y - h

    local projection
    if forecast.atMaxLevel then
        projection = T("QOL.MAXIMUM_LEVEL")
    elseif forecast.projectedAtMaxLevel then
        projection = T("QOL.LEVEL_PERCENT", forecast.projectedLevel, T("QOL.MAXIMUM_LEVEL"))
    elseif forecast.projectedPercent then
        projection = T("QOL.LEVEL_PERCENT", forecast.projectedLevel, Percent(forecast.projectedPercent))
    else
        projection = T("QOL.LEVEL_OR_HIGHER_WITH_OVERFLOW", forecast.projectedLevel, Number(forecast.overflowXP or 0))
    end
    _, h = W:DualRow(parent, y,
        { type = "label", text = T("QOL.PROJECTED_AFTER_TURN_INS") },
        { type = "label", text = projection })
    y = y - h

    _, h = W:DualRow(parent, y,
        { type = "label", text = T("QOL.FORECAST_USES_ADJUSTED_QUEST_XP") })
    y = y - h

    _, h = W:DualRow(parent, y,
        { type = "label", text = T("QOL.REOPEN_TO_REFRESH") })
    y = y - h

    return math.abs(y)
end
