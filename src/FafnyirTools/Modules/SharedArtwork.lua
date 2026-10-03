local ADDON_NAME, ns = ...

local feature = {
    key = "SharedArtwork", page = "Unit Frames",
    searchTerms = { "nameplate target arrows", "sharedmedia", "role icons", "party", "raid" },
}
ns:RegisterFeature(feature.key, feature)

local MEDIA = "Interface\\AddOns\\FafnyirMedia\\Textures\\"
local CATEGORY = "targetarrow"
local roles = { TANK = MEDIA .. "Roles\\Tank.tga", HEALER = MEDIA .. "Roles\\Healer.tga",
    DAMAGER = MEDIA .. "Roles\\DPS.tga" }
local roleKeys = { TANK = "- Tank", HEALER = "- Healer", DAMAGER = "- DPS" }
local textures = setmetatable({}, { __mode = "k" })
local hookedNamespaces = setmetatable({}, { __mode = "k" })
local callbackMedia
local function DB() return ns:GetDatabase().sharedArtwork end
local function Module(name)
    return EllesmereUI and EllesmereUI._ModuleNS and EllesmereUI._ModuleNS[name]
end
local function LSM()
    return LibStub and LibStub("LibSharedMedia-3.0", true)
end
local function IsArrowBackground(key)
    return key:lower():find("arrow", 1, true) ~= nil
end
local function IsArrowSelection(value)
    return value:sub(1, 11) ~= "background:" or IsArrowBackground(value:sub(12))
end
local function ArrowPaths()
    local media = LSM()
    if DB().arrow == "native" or not media then return end
    local selection = DB().arrow
    if not IsArrowSelection(selection) then return end
    local category, key = CATEGORY, selection
    if selection:sub(1, 11) == "background:" then
        category, key = "background", selection:sub(12)
    end
    local entry = media:Fetch(category, key, true)
    if type(entry) == "string" and entry ~= "" then return entry, entry, true end
    if type(entry) == "table" and type(entry.left) == "string"
        and type(entry.right) == "string" and entry.left ~= "" and entry.right ~= "" then
        return entry.left, entry.right, false
    end
end
local function ApplyTexture(texture, state)
    if state.busy then return end
    local left, right, mirror = ArrowPaths()
    state.busy = true
    if left then
        texture:SetTexture(state.side == "left" and left or right)
        if mirror and state.side == "right" then texture:SetTexCoord(1, 0, 0, 1)
        else texture:SetTexCoord(0, 1, 0, 1) end
        state.applied = true
    elseif state.applied then
        texture:SetTexture(state.native)
        texture:SetTexCoord(unpack(state.coords))
        state.applied = false
    end
    state.busy = false
end
local function Track(texture, side)
    if not texture then return end
    local state = textures[texture]
    if not state then
        state = { side = side, native = texture:GetTexture(), coords = { texture:GetTexCoord() } }
        textures[texture] = state
        hooksecurefunc(texture, "SetTexture", function(_, path)
            if state.busy then return end
            state.native = path
            ApplyTexture(texture, state)
        end)
    end
    ApplyTexture(texture, state)
end
local function ScanArrows()
    local enp = Module("EllesmereUINameplates") or _G.EllesmereNameplates_NS
    if not enp then return end
    for _, plate in pairs(enp.plates or {}) do
        Track(plate.leftArrow, "left")
        Track(plate.rightArrow, "right")
    end
end
local function ApplyRole(d, settings, unit)
    -- Post-hook native rendering: never show a role EUI hides, or change geometry.
    if not DB().roles or not d or d._isExtra or not d.roleIcon or not d.roleIcon:IsShown() then return end
    if type(unit) ~= "string" or (issecretvalue and issecretvalue(unit)) then return end
    if not unit:match("^party%d+$") and not unit:match("^raid%d+$")
        and not (unit == "player" and d._isParty) then return end
    local role = EllesmereUI.UnitEffectiveRole and EllesmereUI.UnitEffectiveRole(unit)
    if issecretvalue and issecretvalue(role) then return end
    local media = LSM()
    local path = role and roleKeys[role] and media and media:Fetch("background", roleKeys[role], true)
    if type(path) ~= "string" or path == "" then path = role and roles[role] end
    if path then
        d.roleIcon:SetTexture(path)
        d.roleIcon:SetTexCoord(0, 1, 0, 1)
    end
end
local function Install()
    local media = LSM()
    if media and media ~= callbackMedia and media.RegisterCallback then
        callbackMedia = media
        media.RegisterCallback(feature, "LibSharedMedia_Registered", function(_, category)
            if category == CATEGORY or category == "background" then feature:Refresh() end
        end)
    end
    local enp = Module("EllesmereUINameplates") or _G.EllesmereNameplates_NS
    if enp and not hookedNamespaces[enp] and type(enp.RefreshAllSettings) == "function" then
        hooksecurefunc(enp, "RefreshAllSettings", ScanArrows)
        hookedNamespaces[enp] = true
    end
    local erf = Module("EllesmereUIRaidFrames")
    if erf and not hookedNamespaces[erf] and type(erf._UpdateRoleIcon) == "function" then
        hooksecurefunc(erf, "_UpdateRoleIcon", ApplyRole)
        hookedNamespaces[erf] = true
    end
    ScanArrows()
end
function feature:Refresh()
    Install()
    for texture, state in pairs(textures) do ApplyTexture(texture, state) end
    local erf = Module("EllesmereUIRaidFrames")
    if erf and type(erf._UpdateRoleIcons) == "function" then erf._UpdateRoleIcons() end
end
function feature:Initialize() self:Refresh() end
function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then self:Refresh() end
end
function feature:Reset()
    DB().arrow = ns.defaults.sharedArtwork.arrow
    DB().roles = ns.defaults.sharedArtwork.roles
    self:Refresh()
end
function feature:BuildOptions(parent, yOffset)
    local W, y, h = EllesmereUI.Widgets, yOffset
    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, "NAMEPLATE TARGET ARROWS / PARTY & RAID ICONS", y)
    y = y - h
    local values, order = { native = "Use EllesmereUI Style" }, { "native" }
    local media = LSM()
    -- SharedMedia background entries are full image paths. Preserve their names
    -- in the UI while keeping storage distinct from paired targetarrow entries.
    for _, key in ipairs(media and media:List("background") or {}) do
        if IsArrowBackground(key) then
            local value = "background:" .. key
            values[value] = key
            order[#order + 1] = value
        end
    end
    for _, key in ipairs(media and media:List(CATEGORY) or {}) do
        if key ~= "native" then values[key] = key; order[#order + 1] = key end
    end
    if IsArrowSelection(DB().arrow) and not values[DB().arrow] then
        values[DB().arrow] = DB().arrow .. " (unavailable)"
        order[#order + 1] = DB().arrow
    end
    _, h = W:DualRow(parent, y,
        { type = "dropdown", text = "Nameplate Target Arrow", values = values, order = order,
          tooltip = "Choose SharedMedia target-arrow artwork. Enable arrows and adjust their size and color in EllesmereUI Nameplates. Missing media falls back to EllesmereUI.",
          getValue = function() return IsArrowSelection(DB().arrow) and DB().arrow or "native" end,
          setValue = function(value) DB().arrow = value; feature:Refresh() end },
        { type = "toggle", text = "FafnyirMedia Party / Raid Role Icons",
          tooltip = "Replace visible Party and Raid role icons with FafnyirMedia artwork. EllesmereUI still controls role visibility, size and position.",
          getValue = function() return DB().roles end,
          setValue = function(value) DB().roles = value and true or false; feature:Refresh() end })
    return math.abs(y - h)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:RegisterEvent("NAME_PLATE_UNIT_ADDED")
loader:RegisterEvent("PLAYER_TARGET_CHANGED")
loader:SetScript("OnEvent", function(_, event, addon)
    if event == "NAME_PLATE_UNIT_ADDED" or event == "PLAYER_TARGET_CHANGED" or addon == "EllesmereUINameplates"
        or addon == "EllesmereUIRaidFrames" or addon == "FafnyirMedia" then
        -- Defer until the host has created its pools/arrow textures.
        local refresh = (event == "NAME_PLATE_UNIT_ADDED" or event == "PLAYER_TARGET_CHANGED")
            and Install or function() feature:Refresh() end
        if C_Timer and C_Timer.After then C_Timer.After(0, refresh)
        else refresh() end
    end
end)
