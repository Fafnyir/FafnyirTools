local ADDON_NAME, ns = ...

local feature = {
    key = "UnitFrameSources",
    page = "Unit Frames",
    searchTerms = {
        "unit frames", "player frame", "target frame", "boss frames",
        "target of target", "tot", "focus frame", "pet frame",
        "frame source", "blizzard", "ellesmereui",
    },
}
ns:RegisterFeature(feature.key, feature)

local SOURCE_VALUES = {
    eui = "EllesmereUI",
    blizzard = "Blizzard Default",
    hidden = "Hidden",
}
local SOURCE_ORDER = { "eui", "blizzard", "hidden" }

local function DB()
    return ns:GetDatabase().unitFrameSources
end

local function GetEUFNS()
    return EllesmereUI
        and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS["EllesmereUIUnitFrames"]
end

local function PromptReload()
    local message = "Changing a Unit Frame source requires a UI reload. EllesmereUI creates or suppresses these frames during startup."

    if EllesmereUI and EllesmereUI.ShowConfirmPopup then
        EllesmereUI:ShowConfirmPopup({
            title = "Reload Required",
            message = message,
            confirmText = "Reload Now",
            cancelText = "Later",
            onConfirm = ReloadUI,
        })
        return
    end

    StaticPopupDialogs["FAFNYIRTOOLS_UNITFRAME_RELOAD"] =
        StaticPopupDialogs["FAFNYIRTOOLS_UNITFRAME_RELOAD"] or {
            text = message,
            button1 = "Reload Now",
            button2 = "Later",
            OnAccept = ReloadUI,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }

    StaticPopup_Show("FAFNYIRTOOLS_UNITFRAME_RELOAD")
end

local function ApplyOne(unit, source)
    if source == nil or source == "inherit" then return true end

    local euf = GetEUFNS()
    if not euf or type(euf.SetUnitFrameSource) ~= "function" then
        return false
    end

    euf.SetUnitFrameSource(unit, source)
    return true
end

function feature:ApplySaved()
    local db = DB()
    local ok = true

    if not ApplyOne("player", db.player) then ok = false end
    if not ApplyOne("target", db.target) then ok = false end
    if not ApplyOne("boss", db.boss) then ok = false end
    if not ApplyOne("targettarget", db.targettarget) then ok = false end
    if not ApplyOne("focus", db.focus) then ok = false end
    if not ApplyOne("pet", db.pet) then ok = false end

    return ok
end

local function SetSource(unit, value)
    if not SOURCE_VALUES[value] then return end
    DB()[unit] = value

    if value ~= "inherit" then
        local euf = GetEUFNS()
        if not euf or type(euf.SetUnitFrameSource) ~= "function" then
            ns:Print("EllesmereUI Unit Frames is not loaded.")
            return
        end
        euf.SetUnitFrameSource(unit, value)
    end

    PromptReload()
end

local function SourceWidget(unit, label, tooltip)
    return {
        type = "dropdown",
        text = label,
        tooltip = tooltip,
        values = SOURCE_VALUES,
        order = SOURCE_ORDER,
        getValue = function()
            local saved = DB()[unit]
            if SOURCE_VALUES[saved] then return saved end
            -- Legacy inherited/unset choices display EUI's effective source
            -- without writing a new override or changing the user's layout.
            local euf = GetEUFNS()
            if euf and type(euf.GetUnitFrameSource) == "function" then
                local source = euf.GetUnitFrameSource(unit)
                if SOURCE_VALUES[source] then return source end
            end
            return nil -- Unknown source; do not invent a selection.
        end,
        setValue = function(value)
            SetSource(unit, value)
        end,
    }
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "UNIT FRAME SOURCES", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        SourceWidget(
            "player",
            "Player Frame",
            "Choose whether the Player frame is provided by EllesmereUI, Blizzard, or hidden. Requires a UI reload."
        ),
        SourceWidget(
            "target",
            "Target Frame",
            "Choose whether the Target frame is provided by EllesmereUI, Blizzard, or hidden. Requires a UI reload."
        )
    )
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        SourceWidget(
            "targettarget",
            "Target of Target",
            "Choose whether Target of Target is provided by EllesmereUI, Blizzard, or hidden. Blizzard Default requires Target Frame to use Blizzard too; otherwise EllesmereUI falls back to its own ToT frame. Requires a UI reload."
        ),
        SourceWidget(
            "focus",
            "Focus Frame",
            "Choose whether the Focus frame is provided by EllesmereUI, Blizzard, or hidden. Requires a UI reload."
        )
    )
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        SourceWidget(
            "boss",
            "Boss Frames",
            "Choose whether Boss frames are provided by EllesmereUI, Blizzard, or hidden. Requires a UI reload."
        ),
        SourceWidget(
            "pet",
            "Pet Frame",
            "Choose whether the Pet frame is provided by EllesmereUI, Blizzard, or hidden. Requires a UI reload."
        )
    )
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "label",
            text = "Source changes require a reload.",
        },
        { type = "label", text = "" }
    )
    y = y - h

    return math.abs(y)
end

function feature:HandleEvent(event)
    if event == "PLAYER_LOGIN" or event == "PLAYER_ENTERING_WORLD" then
        -- Usually the options addon and Unit Frames namespace are ready by login.
        -- Retry briefly for load-order differences. Saved source changes are
        -- intentionally applied before the next reload takes effect.
        if self:ApplySaved() then return end
        C_Timer.After(0.5, function() feature:ApplySaved() end)
        C_Timer.After(1.5, function() feature:ApplySaved() end)
    end
end
