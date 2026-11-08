local ADDON_NAME, ns = ...
if not ns:StandaloneFPSAvailable() then return end

local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "FPSDisplay",
    page = T("CORE.QOL"),
    searchTerms = { "fps", "frames per second", "latency", "ping", "performance" },
}
ns:RegisterFeature(feature.key, feature)

local display
local ticker

local function DB()
    return ns:GetDatabase().fpsDisplay
end

local function SavePosition()
    if not display or not display.GetCenter or not UIParent or not UIParent.GetCenter then return end
    local x, y = display:GetCenter()
    local parentX, parentY = UIParent:GetCenter()
    if x and y and parentX and parentY then
        DB().position = { x = x - parentX, y = y - parentY }
    end
end

local function ApplyPosition()
    if not display then return end
    local position = DB().position
    display:ClearAllPoints()
    if type(position) == "table" then
        display:SetPoint("CENTER", UIParent, "CENTER", tonumber(position.x) or 0, tonumber(position.y) or 0)
    else
        display:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

local function UpdateText()
    if not display or not display.text then return end
    local fps = GetFramerate and GetFramerate() or 0
    if DB().showLatency and GetNetStats then
        local _, _, _, worldLatency = GetNetStats()
        display.text:SetFormattedText("%.1f FPS  |  %d ms", fps, tonumber(worldLatency) or 0)
    else
        display.text:SetFormattedText("%.1f FPS", fps)
    end
end

local function EnsureDisplay()
    if display then return display end
    display = CreateFrame("Frame", "FafnyirToolsFPSDisplayFrame", UIParent)
    display:SetSize(180, 34)
    display:SetClampedToScreen(true)
    display:SetMovable(true)
    display:EnableMouse(true)
    display:RegisterForDrag("LeftButton")
    display:SetScript("OnDragStart", function(self) self:StartMoving() end)
    display:SetScript("OnDragStop", function(self) self:StopMovingOrSizing(); SavePosition() end)
    display.text = display:CreateFontString(nil, "OVERLAY")
    display.text:SetPoint("CENTER")
    display.text:SetTextColor(1, 1, 1, 1)
    ApplyPosition()
    return display
end

function feature:Refresh()
    local frame = EnsureDisplay()
    frame.text:SetFont(STANDARD_TEXT_FONT, tonumber(DB().fontSize) or 18, "OUTLINE")
    if DB().enabled then
        frame:Show()
        UpdateText()
        if not ticker and C_Timer and C_Timer.NewTicker then
            ticker = C_Timer.NewTicker(0.25, UpdateText)
        end
    else
        frame:Hide()
        if ticker then ticker:Cancel(); ticker = nil end
    end
end

function feature:ResetPosition()
    DB().position = nil
    ApplyPosition()
end

function feature:Initialize()
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h
    parent._showRowDivider = true
    _, h = W:SectionHeader(parent, T("QOL.FPS_DISPLAY"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle", text = T("QOL.ENABLE_FPS_DISPLAY"),
            getValue = function() return DB().enabled end,
            setValue = function(value) DB().enabled = value; feature:Refresh() end,
        },
        {
            type = "toggle", text = T("QOL.SHOW_WORLD_LATENCY"),
            disabled = function() return not DB().enabled end,
            getValue = function() return DB().showLatency end,
            setValue = function(value) DB().showLatency = value; UpdateText() end,
        }
    )
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "slider", text = T("QOL.FPS_FONT_SIZE"), min = 10, max = 32, step = 1,
            disabled = function() return not DB().enabled end,
            getValue = function() return DB().fontSize end,
            setValue = function(value) DB().fontSize = value; feature:Refresh() end,
        },
        {
            type = "button", text = T("QOL.RESET_FPS_POSITION"),
            buttonText = T("UNIT_FRAMES.RESET"),
            onClick = function() feature:ResetPosition() end,
        }
    )
    y = y - h
    return math.abs(y)
end

SLASH_FAFNYIRTOOLSFPS1 = "/fpsdisplay"
SlashCmdList.FAFNYIRTOOLSFPS = function(message)
    message = tostring(message or ""):lower():match("^%s*(.-)%s*$")
    if message == "reset" then
        feature:ResetPosition()
    else
        DB().enabled = not DB().enabled
        feature:Refresh()
    end
end
