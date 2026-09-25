local ADDON_NAME, ns = ...

local feature = {
    key = "UnitFrameNames",
    page = "Unit Frames",
    searchTerms = { "first name", "last name", "whole name", "surname", "party names", "raid names" },
}
ns:RegisterFeature(feature.key, feature)

local MODES = {
    first = "First Name",
    last = "Last Name",
    whole = "Whole Name",
}
local ORDER = { "first", "last", "whole" }
local originalWithSurname
local wrappedWithSurname

local function DB()
    return ns:GetDatabase().unitFrameNames
end

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function CalledFromSupportedFrames()
    -- WithSurname is shared by Unit Frames, Raid Frames, and Nameplates. Keep
    -- this preference scoped to the two requested frame modules. debugstack is
    -- Blizzard's supported caller-inspection helper; fail closed if unavailable
    -- so a client change cannot leak the setting onto another UI surface.
    if type(debugstack) ~= "function" then return false end
    local stack = debugstack(2, 8, 0)
    if type(stack) ~= "string" then return false end
    return stack:find("EllesmereUIUnitFrames", 1, true) ~= nil
        or stack:find("EllesmereUIRaidFrames", 1, true) ~= nil
end

local function FormatForeverName(name, surname, fallback)
    if not ns.IS_FOREVER then return fallback end
    if not CalledFromSupportedFrames() then return fallback end

    local mode = DB().mode
    if mode == "whole" or not MODES[mode] then return fallback end
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
    local refreshMain = _G._EUF_RefreshUnitNames
    if type(refreshMain) == "function" then refreshMain() end

    local raid = EllesmereUI and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS.EllesmereUIRaidFrames
    if raid and type(raid.RefreshAllNames) == "function" then
        raid.RefreshAllNames()
    end
end

local function Install()
    if not ns.IS_FOREVER or not EllesmereUI or type(EllesmereUI.WithSurname) ~= "function" then
        return false
    end
    if EllesmereUI.WithSurname == wrappedWithSurname then return true end

    originalWithSurname = EllesmereUI.WithSurname
    wrappedWithSurname = function(name, surname)
        return FormatForeverName(name, surname, originalWithSurname(name, surname))
    end
    EllesmereUI.WithSurname = wrappedWithSurname
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
            tooltip = "Choose whether EllesmereUI main, Party, and Raid frames show a Forever character's first name, surname, or whole name. Nameplates, NPC names, and configured nicknames are unchanged.",
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
