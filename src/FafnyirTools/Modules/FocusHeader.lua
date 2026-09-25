local ADDON_NAME, ns = ...

local feature = {
    key = "FocusHeader",
    page = "Unit Frames",
    searchTerms = { "focus header", "focus reputation", "focus reaction color", "colored focus" },
}
ns:RegisterFeature(feature.key, feature)

local function DB()
    return ns:GetDatabase().focusHeader
end

local function UnitFrameNamespace()
    return EllesmereUI
        and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS.EllesmereUIUnitFrames
end

local function FocusSettings()
    local euf = UnitFrameNamespace()
    if not euf or type(euf.UF_GetSettings) ~= "function" then return nil end
    return euf.UF_GetSettings("focus")
end

local function CaptureExisting()
    local db = DB()
    if db.initialized then return true end
    local settings = FocusSettings()
    if not settings then return false end
    db.enabled = settings.blizzColoredHeader ~= false
    db.initialized = true
    return true
end

local function Apply(reloadFrames)
    if not CaptureExisting() then return false end
    local settings = FocusSettings()
    if not settings then return false end
    if DB().enabled then
        settings.blizzColoredHeader = nil
    else
        settings.blizzColoredHeader = false
    end

    local euf = UnitFrameNamespace()
    if reloadFrames and euf and type(euf.ReloadFrames) == "function" then
        euf.ReloadFrames()
    end
    return true
end

function feature:Initialize()
    Apply(false)
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then Apply(false) end
end

function feature:Refresh()
    Apply(true)
end

function feature:Reset()
    local db = DB()
    db.enabled = ns.defaults.focusHeader.enabled
    db.initialized = true
    Apply(true)
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "BLIZZARD STYLE FOCUS FRAME", y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = "Blizz Colored Focus Header",
            tooltip = "Color the strip behind the full Focus Frame's name by its reaction. Applies to EllesmereUI's Blizzard style only; Focus Target is unchanged.",
            getValue = function()
                CaptureExisting()
                return DB().enabled
            end,
            setValue = function(value)
                local db = DB()
                db.enabled = value and true or false
                db.initialized = true
                Apply(true)
            end,
        },
        { type = "label", text = "Focus Target has no reputation strip." })
    y = y - h
    return math.abs(y)
end
