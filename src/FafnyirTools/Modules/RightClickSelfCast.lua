local ADDON_NAME, ns = ...

local feature = {
    key = "RightClickSelfCast",
    page = "Action Bars",
    searchTerms = {
        "right click",
        "right-click",
        "self cast",
        "action bars",
    },
}

ns:RegisterFeature(feature.key, feature)

local refreshPending = false

local function DB()
    return ns:GetDatabase().rightClickSelfCast
end

local function FindActionButton(index)
    return _G["EABButton" .. index]
        or _G["EllesmereUI_ActionButton" .. index]
        or _G["EUI_ActionButton" .. index]
end

local function ApplyToButton(button)
    if not button or not button.SetAttribute then return end

    if InCombatLockdown() then
        refreshPending = true
        return
    end

    if DB().enabled then
        -- EllesmereUI's modern EABButton frames are SecureActionButtons driven
        -- by their existing "action" attribute. For right click, reuse that
        -- action dynamically and only override the unit to player. This keeps
        -- paging, macros, override spells and slot changes in sync automatically.
        button:RegisterForClicks("AnyDown", "AnyUp")
        button:SetAttribute("type2", "action")
        button:SetAttribute("action2", nil)
        button:SetAttribute("unit2", "player")
    else
        button:SetAttribute("type2", nil)
        button:SetAttribute("action2", nil)
        button:SetAttribute("unit2", nil)
    end
end

function feature:Refresh()
    if InCombatLockdown() then
        refreshPending = true
        return
    end

    refreshPending = false

    for i = 1, 180 do
        ApplyToButton(FindActionButton(i))
    end
end

function feature:Initialize()
    C_Timer.After(0, function()
        feature:Refresh()
    end)

    C_Timer.After(1, function()
        feature:Refresh()
    end)
end

function feature:Reset()
    DB().enabled = ns.defaults.rightClickSelfCast.enabled
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "RIGHT-CLICK SELF CAST", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable Right-Click Self Cast",
            tooltip = "Right-click a spell on an EllesmereUI action bar to cast it on yourself.",
            getValue = function()
                return DB().enabled
            end,
            setValue = function(value)
                DB().enabled = value
                feature:Refresh()
            end,
        },
        {
            type = "label",
            text = "",
        }
    )
    y = y - h

    return math.abs(y)
end

function feature:HandleEvent(event)
    if event == "PLAYER_REGEN_ENABLED" then
        if refreshPending then
            self:Refresh()
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        self:Refresh()
    end
end
