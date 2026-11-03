local ADDON_NAME, ns = ...

local function AddOnLoaded(name)
    return C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded(name)
end

-- EllesmereUI Minimap already owns addon-button grouping. OptionalDeps ensures
-- it has loaded before this file when enabled, so the two collectors never
-- compete for the same frames.
if AddOnLoaded("EllesmereUIMinimap") then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "MinimapButtonCollector",
    page = T("CORE.QOL"),
    searchTerms = { "minimap", "button", "collector", "gather", "group", "flyout" },
}
ns:RegisterFeature(feature.key, feature)

local BUTTON_SIZE = 32
local CELL_SIZE = 34
local COLUMNS = 5
local button, panel, storage
local collected = setmetatable({}, { __mode = "k" })
local ordered = {}
local currentAngle
local dragging = false

local blacklist = {
    AddonCompartmentFrame = true,
    ExpansionLandingPageMinimapButton = true,
    GameTimeFrame = true,
    MiniMapTracking = true,
    MinimapBackdrop = true,
    MinimapCluster = true,
    MinimapZoneTextButton = true,
    QueueStatusButton = true,
    TimeManagerClockButton = true,
    FafnyirToolsMinimapButton = true,
    FafnyirToolsMinimapCollectorButton = true,
}

local function DB()
    return ns:GetDatabase().minimapButtonCollector
end

local function Enabled()
    return DB().enabled == true
end

local function SafeCall(object, method, ...)
    local fn = object and object[method]
    if type(fn) ~= "function" then return false end
    return pcall(fn, object, ...)
end

local function ReadPoints(frame)
    local ok, count = SafeCall(frame, "GetNumPoints")
    if not ok then return nil end
    local points = {}
    for index = 1, count do
        local pointOK, point, relativeTo, relativePoint, x, y = SafeCall(frame, "GetPoint", index)
        if not pointOK or (issecretvalue and (issecretvalue(point)
            or issecretvalue(relativeTo) or issecretvalue(relativePoint)
            or issecretvalue(x) or issecretvalue(y))) then
            return nil
        end
        points[index] = { point, relativeTo, relativePoint, x or 0, y or 0 }
    end
    return points
end

local function RestorePoints(frame, points)
    if not frame or not points then return end
    frame:ClearAllPoints()
    for _, point in ipairs(points) do frame:SetPoint(unpack(point)) end
end

local function Eligible(frame)
    if not frame or frame == button or frame == panel or frame == storage or collected[frame] then return false end
    local ok, name = SafeCall(frame, "GetName")
    if not ok then return false end
    if name and (blacklist[name] or name:match("^Mini[Mm]ap") or name:match("^MiniMap")) then return false end
    local typeOK, objectType = SafeCall(frame, "GetObjectType")
    if not typeOK or objectType ~= "Button" then return false end
    local protectedOK, protected = SafeCall(frame, "IsProtected")
    if protectedOK and protected then return false end
    local shownOK, shown = SafeCall(frame, "IsShown")
    if not shownOK or not shown then return false end
    local widthOK, width = SafeCall(frame, "GetWidth")
    local heightOK, height = SafeCall(frame, "GetHeight")
    if not widthOK or not heightOK or type(width) ~= "number" or type(height) ~= "number"
        or width < 16 or height < 16 or width > 64 or height > 64 then
        return false
    end
    return ReadPoints(frame) ~= nil
end

local function LayoutPanel()
    if not panel then return end
    local visible = {}
    for _, frame in ipairs(ordered) do
        local state = collected[frame]
        if state then visible[#visible + 1] = frame end
    end
    local rows = math.max(1, math.ceil(#visible / COLUMNS))
    panel:SetSize((COLUMNS * CELL_SIZE) + 16, (rows * CELL_SIZE) + 16)
    for index, frame in ipairs(visible) do
        local state = collected[frame]
        frame:SetParent(panel)
        frame:ClearAllPoints()
        if frame.SetScale then
            local nativeSize = math.max(1, state.width or 28, state.height or 28)
            frame:SetScale((state.scale or 1) * math.min(1, 28 / nativeSize))
        end
        if frame.SetAlpha then frame:SetAlpha(1) end
        if frame.SetFrameStrata then frame:SetFrameStrata("DIALOG") end
        if frame.SetFrameLevel and panel.GetFrameLevel then
            frame:SetFrameLevel(panel:GetFrameLevel() + 5)
        end
        local column = (index - 1) % COLUMNS
        local row = math.floor((index - 1) / COLUMNS)
        frame:SetPoint("TOPLEFT", panel, "TOPLEFT", 10 + (column * CELL_SIZE), -10 - (row * CELL_SIZE))
        frame:Show()
    end
end

local function ClosePanel()
    if not panel then return end
    panel:Hide()
    for frame in pairs(collected) do
        frame:SetParent(storage)
    end
end

local function OpenPanel()
    if not panel then return end
    LayoutPanel()
    panel:Show()
end

local function Collect(frame)
    if not Eligible(frame) then return false end
    local parentOK, parent = SafeCall(frame, "GetParent")
    local widthOK, width = SafeCall(frame, "GetWidth")
    local heightOK, height = SafeCall(frame, "GetHeight")
    local scaleOK, scale = SafeCall(frame, "GetScale")
    local strataOK, strata = SafeCall(frame, "GetFrameStrata")
    local levelOK, level = SafeCall(frame, "GetFrameLevel")
    local points = ReadPoints(frame)
    if not parentOK or not widthOK or not heightOK or not points then return false end
    collected[frame] = {
        parent = parent,
        points = points,
        width = width,
        height = height,
        scale = scaleOK and scale or 1,
        strata = strataOK and strata or nil,
        level = levelOK and level or nil,
    }
    ordered[#ordered + 1] = frame
    frame:SetParent(storage)
    return true
end

local function Scan()
    if not Enabled() or not Minimap or InCombatLockdown and InCombatLockdown() then return false end
    local candidates, seen = {}, {}
    local function AddCandidate(frame)
        if frame and not seen[frame] then
            seen[frame] = true
            candidates[#candidates + 1] = frame
        end
    end
    local function AddChildren(owner)
        if not owner then return end
        local children
        local ok = pcall(function() children = { owner:GetChildren() } end)
        if not ok then return end
        for _, frame in ipairs(children) do AddCandidate(frame) end
    end
    AddChildren(Minimap)
    AddChildren(MinimapCluster)
    local libDBIcon = LibStub and LibStub("LibDBIcon-1.0", true)
    if libDBIcon and type(libDBIcon.objects) == "table" then
        for _, frame in pairs(libDBIcon.objects) do AddCandidate(frame) end
    end
    local changed = false
    for _, frame in ipairs(candidates) do
        if Collect(frame) then changed = true end
    end
    if changed and panel and panel:IsShown() then LayoutPanel() end
    return changed
end

local function Atan2(y, x)
    if math.atan2 then return math.atan2(y, x) end
    if x > 0 then return math.atan(y / x) end
    if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
    if x < 0 then return math.atan(y / x) - math.pi end
    if y > 0 then return math.pi / 2 end
    if y < 0 then return -math.pi / 2 end
    return 0
end

local function UpdatePosition()
    if not button or not Minimap then return end
    local angle = math.rad(currentAngle or tonumber(DB().angle) or 180)
    local width = Minimap:GetWidth() or 140
    local height = Minimap:GetHeight() or 140
    local radius = (math.max(width, height) / 2) + 5
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function DragOnUpdate()
    local minimapX, minimapY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap:GetEffectiveScale() or 1
    if not minimapX or not minimapY or not cursorX or not cursorY or scale == 0 then return end
    currentAngle = math.deg(Atan2((cursorY / scale) - minimapY, (cursorX / scale) - minimapX))
    UpdatePosition()
end

local function CreateCollector()
    if button or not Minimap then return end
    storage = CreateFrame("Frame", "FafnyirToolsMinimapCollectorStorage", UIParent)
    storage:Hide()

    panel = CreateFrame("Frame", "FafnyirToolsMinimapCollectorPanel", UIParent,
        BackdropTemplateMixin and "BackdropTemplate" or nil)
    -- Some third-party minimap buttons lock their native frame strata and
    -- ignore attempts to raise them. Keep the flyout backdrop below those
    -- buttons instead of relying on every addon to accept a strata change.
    panel:SetFrameStrata("LOW")
    panel:SetClampedToScreen(true)
    panel:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
    panel:SetBackdropColor(0.047, 0.051, 0.059, 0.96)
    panel:SetBackdropBorderColor(0.388, 0.345, 0.722, 1)
    -- Expand beside the minimap rather than below it, where Retail's
    -- Objective Tracker normally occupies the same right-side column.
    panel:SetPoint("TOPRIGHT", Minimap, "TOPLEFT", -6, 0)
    panel:Hide()
    table.insert(UISpecialFrames, panel:GetName())

    button = CreateFrame("Button", "FafnyirToolsMinimapCollectorButton", Minimap)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(Minimap:GetFrameLevel() + 9)
    button:SetClampedToScreen(true)
    button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(25, 25); background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetVertexColor(0, 0, 0, 1)
    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(21, 21); icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\FafnyirTools\\Media\\Logo.tga")
    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53); overlay:SetPoint("TOPLEFT")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnClick", function(_, mouseButton)
        if dragging then return end
        if mouseButton == "RightButton" then Scan(); return end
        if panel:IsShown() then ClosePanel() else Scan(); OpenPanel() end
    end)
    button:SetScript("OnDragStart", function(self)
        dragging = true; self:SetScript("OnUpdate", DragOnUpdate); ClosePanel()
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil); dragging = false
        DB().angle = currentAngle or tonumber(DB().angle) or 180
        UpdatePosition()
    end)
    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine(T("QOL.MINIMAP_COLLECTOR"))
        GameTooltip:AddLine(T("QOL.MINIMAP_COLLECTOR_LEFT_CLICK"), 1, 1, 1)
        GameTooltip:AddLine(T("QOL.MINIMAP_COLLECTOR_RIGHT_CLICK"), 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    currentAngle = tonumber(DB().angle) or 180
    UpdatePosition()
    button:Show()
end

function feature:Initialize()
    if not Enabled() then return end
    CreateCollector()
    Scan()
    if C_Timer and C_Timer.After then
        C_Timer.After(1, Scan)
        C_Timer.After(3, Scan)
    end
end

function feature:HandleEvent(event)
    if event == "PLAYER_REGEN_ENABLED" and Enabled() then Scan() end
end

function feature:GetButton() return button end
function feature:GetPanel() return panel end

function feature:Reset()
    DB().enabled = false
    DB().angle = 180
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local _, h = W:SectionHeader(parent, T("QOL.MINIMAP_COLLECTOR"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = T("QOL.ENABLE_MINIMAP_COLLECTOR"),
            getValue = function() return Enabled() end,
            setValue = function(value)
                DB().enabled = value == true
                EllesmereUI:ShowConfirmPopup({
                    title = T("CORE.RELOAD_REQUIRED"),
                    message = T("QOL.MINIMAP_COLLECTOR_RELOAD"),
                    confirmText = T("CORE.RELOAD_NOW"),
                    cancelText = T("CORE.LATER"),
                    reload = true,
                })
            end,
        },
        { type = "label", text = T("QOL.MINIMAP_COLLECTOR_NOTE") })
    y = y - h
    return math.abs(y)
end
