local ADDON_NAME, ns = ...
if ns.HAS_ELLESMEREUI then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "MinimapButton",
    searchTerms = { "minimap", "button", "launcher", "open settings" },
}
ns:RegisterFeature(feature.key, feature)

local BUTTON_SIZE = 32
local button
local currentAngle
local dragging = false

local function Atan2(y, x)
    if math.atan2 then return math.atan2(y, x) end
    if x > 0 then return math.atan(y / x) end
    if x < 0 and y >= 0 then return math.atan(y / x) + math.pi end
    if x < 0 then return math.atan(y / x) - math.pi end
    if y > 0 then return math.pi / 2 end
    if y < 0 then return -math.pi / 2 end
    return 0
end

local function DB()
    return ns:GetDatabase().minimapButton
end

local function GetAngle()
    if currentAngle == nil then currentAngle = tonumber(DB().angle) or 220 end
    return currentAngle
end

local function UpdatePosition()
    if not button or not Minimap then return end
    local angle = math.rad(GetAngle())
    local width = Minimap.GetWidth and Minimap:GetWidth() or 140
    local height = Minimap.GetHeight and Minimap:GetHeight() or 140
    local radius = (math.max(width or 140, height or 140) / 2) + 5
    button:ClearAllPoints()
    button:SetPoint("CENTER", Minimap, "CENTER", math.cos(angle) * radius, math.sin(angle) * radius)
end

local function DragOnUpdate()
    if not Minimap or not Minimap.GetCenter or not GetCursorPosition then return end
    local minimapX, minimapY = Minimap:GetCenter()
    local cursorX, cursorY = GetCursorPosition()
    local scale = Minimap.GetEffectiveScale and Minimap:GetEffectiveScale() or 1
    if not minimapX or not minimapY or not cursorX or not cursorY or scale == 0 then return end
    cursorX, cursorY = cursorX / scale, cursorY / scale
    currentAngle = math.deg(Atan2(cursorY - minimapY, cursorX - minimapX))
    UpdatePosition()
end

local function CreateButton()
    if button or not Minimap then return button end
    button = CreateFrame("Button", "FafnyirToolsMinimapButton", Minimap)
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameStrata("MEDIUM")
    if button.SetFrameLevel and Minimap.GetFrameLevel then
        button:SetFrameLevel(Minimap:GetFrameLevel() + 8)
    end
    button:SetClampedToScreen(true)
    button:SetMovable(true)
    button:RegisterForClicks("LeftButtonUp")
    button:RegisterForDrag("LeftButton")

    local background = button:CreateTexture(nil, "BACKGROUND")
    background:SetSize(25, 25)
    background:SetPoint("CENTER")
    background:SetTexture("Interface\\Minimap\\UI-Minimap-Background")
    background:SetVertexColor(0, 0, 0, 1)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetSize(21, 21)
    icon:SetPoint("CENTER")
    icon:SetTexture("Interface\\AddOns\\FafnyirTools\\Media\\Logo.tga")

    local overlay = button:CreateTexture(nil, "OVERLAY")
    overlay:SetSize(53, 53)
    overlay:SetPoint("TOPLEFT")
    overlay:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

    button:SetScript("OnClick", function(_, mouseButton)
        if mouseButton == "LeftButton" and EllesmereUI and EllesmereUI.ToggleOptions then
            EllesmereUI:ToggleOptions()
        end
    end)
    button:SetScript("OnDragStart", function(self)
        dragging = true
        if self.LockHighlight then self:LockHighlight() end
        self:SetScript("OnUpdate", DragOnUpdate)
        if GameTooltip then GameTooltip:Hide() end
    end)
    button:SetScript("OnDragStop", function(self)
        self:SetScript("OnUpdate", nil)
        if self.UnlockHighlight then self:UnlockHighlight() end
        dragging = false
        DB().angle = GetAngle()
        UpdatePosition()
    end)
    button:SetScript("OnEnter", function(self)
        if dragging or not GameTooltip then return end
        GameTooltip:SetOwner(self, "ANCHOR_LEFT")
        GameTooltip:AddLine("|cFF6358B8" .. T("CORE.FAFNYIR_TOOLS") .. "|r")
        GameTooltip:AddLine(T("QOL.MINIMAP_BUTTON_LEFT_CLICK"), 1, 1, 1)
        GameTooltip:AddLine(T("QOL.MINIMAP_BUTTON_DRAG"), 0.75, 0.75, 0.75)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", function()
        if GameTooltip then GameTooltip:Hide() end
    end)

    UpdatePosition()
    button:Show()
    return button
end

function feature:Refresh()
    currentAngle = tonumber(DB().angle) or 220
    CreateButton()
    UpdatePosition()
end

function feature:Initialize()
    self:Refresh()
    if C_Timer and C_Timer.After then C_Timer.After(1, function() feature:Refresh() end) end
end

function feature:GetButton()
    return button
end
