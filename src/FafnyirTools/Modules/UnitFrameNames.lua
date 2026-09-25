local ADDON_NAME, ns = ...

local feature = {
    key = "UnitFrameNames",
    page = "Unit Frames",
    searchTerms = { "first name", "last name", "whole name", "surname" },
}
ns:RegisterFeature(feature.key, feature)

local MODES = {
    first = "First Name",
    last = "Last Name",
    whole = "Whole Name",
}
local ORDER = { "first", "last", "whole" }
local wrappedResolver
local wrappedNamespace

local function DB()
    return ns:GetDatabase().unitFrameNames
end

local function GetUnitFrameNamespace()
    return EllesmereUI
        and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS.EllesmereUIUnitFrames
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function FormatForeverName(unit, fallback)
    if not ns.IS_FOREVER then return fallback end

    local mode = DB().mode
    if mode == "whole" or not MODES[mode] then return fallback end
    if not UnitIsPlayer(unit) then return fallback end

    local name, surname = UnitName(unit)
    if IsSecret(name) or IsSecret(surname) then return fallback end
    if type(name) ~= "string" or name == "" then return fallback end
    if type(surname) ~= "string" or surname == "" then return fallback end

    if mode == "last" then return surname end

    -- A few Forever units already include the surname in UnitName's first
    -- return. Strip that exact suffix for First Name instead of splitting on
    -- spaces, which would damage compound given names.
    local separator = Constants and Constants.CharacterNameSeparatorConsts
        and Constants.CharacterNameSeparatorConsts.CHARACTERNAME_SURNAME_SEPARATOR or " "
    local suffix = separator .. surname
    if #name > #suffix and name:sub(-#suffix) == suffix then
        return name:sub(1, #name - #suffix)
    end
    return name
end

local function RefreshNames()
    local refresh = _G._EUF_RefreshUnitNames
    if type(refresh) == "function" then refresh() end
end

local function Install()
    if not ns.IS_FOREVER then return false end
    local euf = GetUnitFrameNamespace()
    if not euf or type(euf.ResolveUnitNickname) ~= "function" then return false end
    if euf == wrappedNamespace and euf.ResolveUnitNickname == wrappedResolver then return true end

    local original = euf.ResolveUnitNickname
    wrappedNamespace = euf
    wrappedResolver = function(unit)
        return FormatForeverName(unit, original(unit))
    end
    euf.ResolveUnitNickname = wrappedResolver
    RefreshNames()
    return true
end

function feature:Initialize()
    Install()
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then Install() end
end

function feature:Refresh()
    Install()
    RefreshNames()
end

function feature:Reset()
    DB().mode = ns.defaults.unitFrameNames.mode
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    if not ns.IS_FOREVER then return math.abs(yOffset) end

    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "UNIT FRAME NAMES", y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "dropdown",
            text = "Character Name Display",
            tooltip = "Choose whether EllesmereUI unit frames show a Forever character's first name, surname, or whole name. NPC names are unchanged.",
            values = MODES,
            order = ORDER,
            getValue = function() return DB().mode end,
            setValue = function(value)
                if not MODES[value] then return end
                DB().mode = value
                feature:Refresh()
            end,
        },
        { type = "label", text = "WoW Forever only." })
    y = y - h
    return math.abs(y)
end
