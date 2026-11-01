local ADDON_NAME, ns = ...

if ns.HAS_ELLESMEREUI then return end

local UI = {
    Widgets = {},
    __fafnyirStandalone = true,
}
_G.EllesmereUI = UI
ns.StandaloneUI = UI

local config
local window
local currentPage
local pageButtons = {}
local activeControls = {}

local DEFAULT_WIDTH = 920
local DEFAULT_HEIGHT = 620
local MIN_WIDTH = 760
local MIN_HEIGHT = 520
local MAX_WIDTH = 1200
local MAX_HEIGHT = 850
local CONTENT_GUTTER = 36

local COLORS = {
    background = { 0x0C / 255, 0x0D / 255, 0x0F / 255, 0.98 },
    surface = { 0x13 / 255, 0x14 / 255, 0x17 / 255, 0.98 },
    surfaceLight = { 0x1C / 255, 0x1D / 255, 0x22 / 255, 1 },
    primary = { 0x2A / 255, 0x2B / 255, 0x32 / 255, 1 },
    secondary = { 0x63 / 255, 0x58 / 255, 0xB8 / 255, 1 },
    highlight = { 0x63 / 255, 0x58 / 255, 0xB8 / 255, 1 },
    bright = { 0.96, 0.96, 0.98, 1 },
    controlBorder = { 0x39 / 255, 0x3A / 255, 0x42 / 255, 0.9 },
    divider = { 0x35 / 255, 0x36 / 255, 0x3D / 255, 0.85 },
    text = { 0.92, 0.92, 0.95, 1 },
    muted = { 0.52, 0.52, 0.58, 1 },
}

local fontPaths = {}
local function FontPath(semibold)
    local weight = semibold and "semibold" or "regular"
    if fontPaths[weight] then return fontPaths[weight] end
    local media = LibStub and LibStub("LibSharedMedia-3.0", true)
    local mediaKey = semibold and "- Roboto SemiBold" or "- Roboto"
    local fontPath = media and media:Fetch("font", mediaKey, true)
    if (type(fontPath) ~= "string" or fontPath == "") and ns.HAS_FAFNYIRMEDIA then
        fontPath = semibold
            and "Interface\\AddOns\\FafnyirMedia\\fonts\\Roboto-SemiBold.ttf"
            or "Interface\\AddOns\\FafnyirMedia\\fonts\\Roboto-Regular.ttf"
    end
    if type(fontPath) ~= "string" or fontPath == "" then
        fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    end
    fontPaths[weight] = fontPath
    return fontPaths[weight]
end

local function SetColor(region, color)
    region:SetColorTexture(color[1], color[2], color[3], color[4] or 1)
end

local function AddPixelBorder(frame, color)
    local border = {}
    for i = 1, 4 do
        border[i] = frame:CreateTexture(nil, "BORDER")
        SetColor(border[i], color or COLORS.highlight)
    end
    border[1]:SetPoint("TOPLEFT"); border[1]:SetPoint("TOPRIGHT"); border[1]:SetHeight(1)
    border[2]:SetPoint("BOTTOMLEFT"); border[2]:SetPoint("BOTTOMRIGHT"); border[2]:SetHeight(1)
    border[3]:SetPoint("TOPLEFT"); border[3]:SetPoint("BOTTOMLEFT"); border[3]:SetWidth(1)
    border[4]:SetPoint("TOPRIGHT"); border[4]:SetPoint("BOTTOMRIGHT"); border[4]:SetWidth(1)
    return border
end

local function AddBackground(frame, color)
    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    SetColor(bg, color or COLORS.surface)
    return bg
end

local function BackdropTemplate()
    return BackdropTemplateMixin and "BackdropTemplate" or nil
end

local function AddTooltip(frame, text)
    if not text or text == "" then return end
    frame:EnableMouse(true)
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(text)
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

local function Disabled(descriptor)
    if type(descriptor.disabled) == "function" then
        local ok, value = pcall(descriptor.disabled)
        return ok and value == true
    end
    return descriptor.disabled == true
end

local function SafeValue(descriptor, fallback)
    if type(descriptor.getValue) ~= "function" then return fallback end
    local ok, value = pcall(descriptor.getValue)
    if ok then return value end
    return fallback
end

local function AddControl(control)
    activeControls[#activeControls + 1] = control
    return control
end

local function Label(parent, text, size)
    local fs = parent:CreateFontString(nil, "ARTWORK")
    fs:SetFont(FontPath(size == true), size and 16 or 13, "")
    fs:SetTextColor(unpack(COLORS.text))
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetWordWrap(true)
    fs:SetText(text or "")
    return fs
end

local function CreateButton(parent, caption)
    local button = CreateFrame("Button", nil, parent)
    local bg = AddBackground(button, COLORS.surfaceLight)
    local border = AddPixelBorder(button, COLORS.controlBorder)
    local fs = button:CreateFontString(nil, "ARTWORK")
    fs:SetFont(FontPath(true), 13, "")
    fs:SetTextColor(unpack(COLORS.text))
    fs:SetPoint("CENTER", 0, 0)
    button:SetFontString(fs)
    button:SetText(caption or "")
    button:SetScript("OnEnter", function(self)
        if self:IsEnabled() and not self._selected then SetColor(bg, COLORS.primary) end
    end)
    button:SetScript("OnLeave", function(self)
        SetColor(bg, self._sidebar and COLORS.background or COLORS.surfaceLight)
    end)
    button:HookScript("OnDisable", function()
        SetColor(bg, COLORS.surfaceLight)
        fs:SetTextColor(unpack(COLORS.muted))
        for _, line in ipairs(border) do line:SetAlpha(0.35) end
    end)
    button:HookScript("OnEnable", function()
        SetColor(bg, button._sidebar and COLORS.background or COLORS.surfaceLight)
        fs:SetTextColor(unpack(COLORS.text))
        for _, line in ipairs(border) do line:SetAlpha(1) end
    end)
    function button:SetSelected(selected)
        self._selected = selected == true
        SetColor(bg, self._sidebar and COLORS.background or COLORS.surfaceLight)
        fs:SetTextColor(unpack(self._selected and COLORS.secondary or COLORS.text))
        if self._selectionAccent then self._selectionAccent:SetShown(self._selected) end
    end
    function button:SetSidebarStyle()
        self._sidebar = true
        SetColor(bg, COLORS.background)
        for _, line in ipairs(border) do line:SetAlpha(0) end
        local accent = CreateFrame("Frame", nil, self)
        accent:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 0)
        accent:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
        accent:SetHeight(3)
        accent:SetFrameLevel(self:GetFrameLevel() + 10)
        AddBackground(accent, COLORS.secondary)
        accent:Hide()
        self._selectionAccent = accent
    end
    return button
end

local function BuildLabel(parent, descriptor)
    local fs = Label(parent, descriptor.text)
    fs:SetJustifyV("MIDDLE")
    fs:SetPoint("TOPLEFT", 8, -6)
    fs:SetPoint("BOTTOMRIGHT", -8, 6)
    AddTooltip(fs, descriptor.tooltip)
end

local function BuildButton(parent, descriptor)
    local caption = descriptor.buttonText or descriptor.text or "Button"
    local hasSeparateLabel = descriptor.buttonText and descriptor.text and descriptor.text ~= ""
    if hasSeparateLabel then
        local fs = Label(parent, descriptor.text)
        fs:SetPoint("TOPLEFT", 8, -5)
        fs:SetPoint("TOPRIGHT", -8, -5)
        fs:SetHeight(18)
    end
    local button = AddControl(CreateButton(parent, caption))
    button:SetSize(math.min(210, math.max(110, #caption * 7 + 26)), 24)
    button:SetPoint("TOPLEFT", 8, hasSeparateLabel and -27 or -16)
    button:SetText(caption)
    button:SetEnabled(not Disabled(descriptor))
    button:SetScript("OnClick", function()
        if type(descriptor.onClick) == "function" then descriptor.onClick() end
    end)
    AddTooltip(button, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
end

local function BuildToggle(parent, descriptor)
    local check = AddControl(CreateFrame("CheckButton", nil, parent))
    check:SetSize(22, 22)
    AddBackground(check, COLORS.surfaceLight)
    AddPixelBorder(check, COLORS.controlBorder)
    local checked = check:CreateTexture(nil, "ARTWORK")
    checked:SetPoint("TOPLEFT", 4, -4)
    checked:SetPoint("BOTTOMRIGHT", -4, 4)
    SetColor(checked, COLORS.secondary)
    check:SetCheckedTexture(checked)
    check:SetPoint("TOPLEFT", 4, -12)
    check:SetChecked(SafeValue(descriptor, false) == true)
    check:SetEnabled(not Disabled(descriptor))
    local fs = Label(parent, descriptor.text)
    fs:SetJustifyV("MIDDLE")
    fs:SetPoint("LEFT", check, "RIGHT", 6, 0)
    fs:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
    fs:SetHeight(22)
    check:SetScript("OnClick", function(self)
        if type(descriptor.setValue) == "function" then
            descriptor.setValue(self:GetChecked() == true)
        end
    end)
    AddTooltip(check, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
    AddTooltip(fs, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
end

local function BuildDropdown(parent, descriptor)
    local fs = Label(parent, descriptor.text)
    fs:SetPoint("TOPLEFT", 8, -5)
    fs:SetPoint("TOPRIGHT", -8, -5)
    fs:SetHeight(18)
    local button = AddControl(CreateButton(parent, ""))
    button:SetPoint("TOPLEFT", 8, -27)
    button:SetPoint("TOPRIGHT", -8, -27)
    button:SetHeight(24)
    local order = descriptor.order or {}
    local values = descriptor.values or {}
    local function Repaint()
        local value = SafeValue(descriptor, order[1])
        button:SetText((values[value] or tostring(value or "")) .. "  ›")
        button:SetEnabled(not Disabled(descriptor) and #order > 0)
    end
    button:SetScript("OnClick", function()
        if #order == 0 then return end
        local current = SafeValue(descriptor, order[1])
        local nextIndex = 1
        for i, value in ipairs(order) do
            if value == current then nextIndex = (i % #order) + 1; break end
        end
        if type(descriptor.setValue) == "function" then descriptor.setValue(order[nextIndex]) end
        Repaint()
    end)
    Repaint()
    AddTooltip(button, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
end

local function BuildInput(parent, descriptor)
    local fs = Label(parent, descriptor.text)
    fs:SetPoint("TOPLEFT", 8, -5)
    fs:SetPoint("TOPRIGHT", -8, -5)
    fs:SetHeight(18)
    local box = AddControl(CreateFrame("EditBox", nil, parent, BackdropTemplate()))
    AddBackground(box, COLORS.background)
    AddPixelBorder(box, COLORS.controlBorder)
    box:SetFont(FontPath(false), 13, "")
    box:SetTextColor(unpack(COLORS.text))
    box:SetTextInsets(7, 7, 0, 0)
    box:SetAutoFocus(false)
    box:SetPoint("TOPLEFT", 12, -29)
    box:SetPoint("TOPRIGHT", -12, -29)
    box:SetHeight(22)
    box:SetText(tostring(SafeValue(descriptor, "") or ""))
    box:SetEnabled(not Disabled(descriptor))
    box:SetScript("OnEnterPressed", function(self)
        if type(descriptor.setValue) == "function" then descriptor.setValue(self:GetText()) end
        self:ClearFocus()
    end)
    box:SetScript("OnEditFocusLost", function(self)
        if type(descriptor.setValue) == "function" then descriptor.setValue(self:GetText()) end
    end)
    AddTooltip(box, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
end

local function BuildSlider(parent, descriptor)
    local fs = Label(parent, descriptor.text)
    fs:SetPoint("TOPLEFT", 8, -5)
    fs:SetPoint("TOPRIGHT", -8, -5)
    fs:SetHeight(18)
    local slider = AddControl(CreateFrame("Slider", nil, parent))
    slider:SetOrientation("HORIZONTAL")
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", 0, 0); track:SetPoint("RIGHT", 0, 0); track:SetHeight(4)
    SetColor(track, COLORS.surfaceLight)
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb = slider:GetThumbTexture()
    thumb:SetSize(12, 20); SetColor(thumb, COLORS.secondary)
    slider:SetPoint("TOPLEFT", 14, -31)
    slider:SetPoint("TOPRIGHT", -58, -31)
    slider:SetHeight(16)
    slider:SetMinMaxValues(descriptor.min or 0, descriptor.max or 100)
    slider:SetValueStep(descriptor.step or 1)
    slider:SetObeyStepOnDrag(true)
    local valueText = Label(parent, "")
    valueText:SetJustifyH("CENTER")
    valueText:SetJustifyV("MIDDLE")
    valueText:SetPoint("RIGHT", parent, "RIGHT", -8, -31)
    valueText:SetSize(42, 20)

    local function FormatValue(value)
        local step = tonumber(descriptor.step) or 1
        if step >= 1 then return tostring(math.floor(value + 0.5)) end
        return string.format("%.2f", value)
    end

    local initialValue = tonumber(SafeValue(descriptor, descriptor.min or 0)) or 0
    slider:SetValue(initialValue)
    valueText:SetText(FormatValue(initialValue))
    slider:SetEnabled(not Disabled(descriptor))
    slider:SetScript("OnValueChanged", function(_, value)
        valueText:SetText(FormatValue(value))
        if type(descriptor.setValue) == "function" then descriptor.setValue(value) end
    end)
    AddTooltip(slider, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
end

local function BuildColor(parent, descriptor)
    local fs = Label(parent, descriptor.text)
    fs:SetJustifyV("MIDDLE")
    fs:SetPoint("LEFT", 8, 0)
    fs:SetPoint("RIGHT", parent, "RIGHT", -48, 0)
    fs:SetHeight(22)

    local button = AddControl(CreateButton(parent, ""))
    button:SetSize(30, 22)
    button:SetPoint("RIGHT", -8, 0)
    local swatch = button:CreateTexture(nil, "ARTWORK")
    swatch:SetPoint("TOPLEFT", 3, -3)
    swatch:SetPoint("BOTTOMRIGHT", -3, 3)

    local function Current()
        local value = SafeValue(descriptor, {})
        return tonumber(value.r) or 1, tonumber(value.g) or 1,
            tonumber(value.b) or 1, tonumber(value.a) or 1
    end
    local function Repaint()
        swatch:SetColorTexture(Current())
        button:SetEnabled(not Disabled(descriptor))
    end
    local function SetValue(r, g, b, a)
        if type(descriptor.setValue) == "function" then
            descriptor.setValue(r, g, b, a)
        end
        Repaint()
    end
    local invertedAlpha = WOW_PROJECT_ID ~= nil
        and WOW_PROJECT_MAINLINE ~= nil
        and WOW_PROJECT_ID ~= WOW_PROJECT_MAINLINE
        and (WOW_PROJECT_CAMELOT == nil or WOW_PROJECT_ID ~= WOW_PROJECT_CAMELOT)
    local function ToPickerAlpha(alpha)
        alpha = tonumber(alpha) or 1
        return invertedAlpha and (1 - alpha) or alpha
    end
    local function FromPickerAlpha(alpha)
        alpha = tonumber(alpha) or 1
        return invertedAlpha and (1 - alpha) or alpha
    end
    button:SetScript("OnClick", function()
        local r, g, b, a = Current()
        local previous = { r, g, b, a }
        if ColorPickerFrame and ColorPickerFrame.SetupColorPickerAndShow then
            ColorPickerFrame:SetupColorPickerAndShow({
                r = r, g = g, b = b,
                opacity = ToPickerAlpha(a),
                hasOpacity = true,
                swatchFunc = function()
                    local cr, cg, cb = ColorPickerFrame:GetColorRGB()
                    SetValue(cr, cg, cb, FromPickerAlpha(ColorPickerFrame:GetColorAlpha()))
                end,
                opacityFunc = function()
                    local cr, cg, cb = ColorPickerFrame:GetColorRGB()
                    SetValue(cr, cg, cb, FromPickerAlpha(ColorPickerFrame:GetColorAlpha()))
                end,
                cancelFunc = function() SetValue(unpack(previous)) end,
            })
        elseif ColorPickerFrame then
            ColorPickerFrame.hasOpacity = true
            ColorPickerFrame.opacity = ToPickerAlpha(a)
            ColorPickerFrame.previousValues = previous
            ColorPickerFrame.func = function()
                local cr, cg, cb = ColorPickerFrame:GetColorRGB()
                SetValue(cr, cg, cb, FromPickerAlpha(OpacitySliderFrame:GetValue()))
            end
            ColorPickerFrame.opacityFunc = ColorPickerFrame.func
            ColorPickerFrame.cancelFunc = function(values) SetValue(unpack(values or previous)) end
            ColorPickerFrame:SetColorRGB(r, g, b)
            ColorPickerFrame:Hide()
            ColorPickerFrame:Show()
        end
    end)
    Repaint()
    AddTooltip(button, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
end

local function BuildDescriptor(parent, descriptor)
    descriptor = descriptor or { type = "label", text = "" }
    if descriptor.type == "button" then BuildButton(parent, descriptor)
    elseif descriptor.type == "toggle" then BuildToggle(parent, descriptor)
    elseif descriptor.type == "dropdown" then BuildDropdown(parent, descriptor)
    elseif descriptor.type == "input" then BuildInput(parent, descriptor)
    elseif descriptor.type == "slider" then BuildSlider(parent, descriptor)
    elseif descriptor.type == "color" then BuildColor(parent, descriptor)
    else BuildLabel(parent, descriptor) end
end

function UI.Widgets:SectionHeader(parent, text, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    frame:SetHeight(30)
    local fs = Label(frame, text, true)
    fs:SetTextColor(unpack(COLORS.secondary))
    fs:SetPoint("BOTTOMLEFT", 8, 5)
    fs:SetPoint("RIGHT", -8, 0)
    local line = frame:CreateTexture(nil, "BACKGROUND")
    SetColor(line, COLORS.divider)
    line:SetPoint("BOTTOMLEFT", 8, 1)
    line:SetPoint("BOTTOMRIGHT", -8, 1)
    line:SetHeight(1)
    return frame, 30
end

function UI.Widgets:DualRow(parent, y, left, right)
    local leftIsLabel = not left or left.type == nil or left.type == "label"
    local rightIsLabel = not right or right.type == nil or right.type == "label"
    local rowHeight = leftIsLabel and rightIsLabel and 44 or 58
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    row:SetHeight(rowHeight)
    AddBackground(row, COLORS.surface)
    local leftCell = CreateFrame("Frame", nil, row)
    leftCell:SetPoint("TOPLEFT")
    if right then
        leftCell:SetPoint("BOTTOMRIGHT", row, "BOTTOM", -4, 0)
    else
        leftCell:SetPoint("BOTTOMRIGHT")
    end
    BuildDescriptor(leftCell, left)
    if right then
        local divider = row:CreateTexture(nil, "BORDER")
        divider:SetPoint("TOP", row, "TOP", 0, -8)
        divider:SetPoint("BOTTOM", row, "BOTTOM", 0, 8)
        divider:SetWidth(1)
        SetColor(divider, COLORS.divider)
        local rightCell = CreateFrame("Frame", nil, row)
        rightCell:SetPoint("TOPLEFT", row, "TOP", 4, 0)
        rightCell:SetPoint("BOTTOMRIGHT")
        BuildDescriptor(rightCell, right)
    end
    return row, rowHeight
end

function UI.Widgets:TripleRow(parent, y, first, second, third)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    row:SetHeight(58)
    AddBackground(row, COLORS.surface)

    local descriptors = { first, second, third }
    local cells = {}
    local previous
    for index, descriptor in ipairs(descriptors) do
        local cell = CreateFrame("Frame", nil, row)
        cells[index] = cell
        if index == 1 then
            cell:SetPoint("TOPLEFT")
        else
            cell:SetPoint("TOPLEFT", previous, "TOPRIGHT", 0, 0)
        end
        cell:SetHeight(58)
        BuildDescriptor(cell, descriptor)

        if previous then
            local divider = row:CreateTexture(nil, "BORDER")
            divider:SetPoint("TOP", cell, "TOPLEFT", 0, -8)
            divider:SetPoint("BOTTOM", cell, "BOTTOMLEFT", 0, 8)
            divider:SetWidth(1)
            SetColor(divider, COLORS.divider)
        end
        previous = cell
    end

    local function ResizeCells(_, width)
        width = tonumber(width) or (row.GetWidth and row:GetWidth()) or 0
        if width <= 0 then return end
        local cellWidth = width / 3
        cells[1]:SetWidth(cellWidth)
        cells[2]:SetWidth(cellWidth)
        cells[3]:SetWidth(width - (cellWidth * 2))
    end
    row:SetScript("OnSizeChanged", ResizeCells)
    ResizeCells(row, parent.GetWidth and parent:GetWidth() or 820)
    return row, 58
end

function UI.MakeFont(parent, size, _, r, g, b, a)
    local fs = parent:CreateFontString(nil, "ARTWORK")
    fs:SetFont(FontPath(false), size or 12, "")
    fs:SetTextColor(r or 1, g or 1, b or 1, a or 1)
    return fs
end

local function ClearPage()
    if not window or not window.pageHost then return end
    if window.pageContent then
        window.pageContent:Hide()
        window.pageContent = nil
    end
    wipe(activeControls)
end

local function SetActivePageButton(pageName, clickedButton)
    for _, button in pairs(pageButtons) do
        button:SetSelected(false)
    end

    local selected = clickedButton
    if not selected or selected._pageName ~= pageName then
        selected = nil
        for _, button in pairs(pageButtons) do
            if button._pageName == pageName then selected = button; break end
        end
    end
    if selected then
        selected:SetSelected(true)
    end
    UI._activePage = pageName
end

local function ShowPage(pageName, clickedButton)
    if not window or not config then return end
    currentPage = pageName or currentPage or config.pages[1]
    ClearPage()
    local content = CreateFrame("Frame", nil, window.pageHost)
    local hostWidth = window.pageHost.GetWidth and window.pageHost:GetWidth() or nil
    content:SetWidth(math.max(1, (hostWidth or 856) - CONTENT_GUTTER))
    content:SetHeight(1)
    window.pageHost:SetScrollChild(content)
    window.pageContent = content
    local ok, height = pcall(config.buildPage, currentPage, content, -8)
    if not ok then
        ns:Print("Could not build " .. tostring(currentPage) .. " options: " .. tostring(height))
        height = 0
    end
    content:SetHeight(math.max(height + 24, window.pageHost:GetHeight()))
    SetActivePageButton(currentPage, clickedButton)
end

local function WindowSettings()
    local db = ns:GetDatabase()
    db.standaloneWindow = db.standaloneWindow or {}
    return db.standaloneWindow
end

local function Clamp(value, minimum, maximum, fallback)
    value = tonumber(value) or fallback
    return math.max(minimum, math.min(maximum, value))
end

local function SaveWindowSize()
    if not window then return end
    local settings = WindowSettings()
    settings.width = math.floor(window:GetWidth() + 0.5)
    settings.height = math.floor(window:GetHeight() + 0.5)
end

function UI:ResetWindowSize()
    local settings = WindowSettings()
    settings.width = DEFAULT_WIDTH
    settings.height = DEFAULT_HEIGHT
    if window then
        window:SetSize(DEFAULT_WIDTH, DEFAULT_HEIGHT)
        ShowPage(currentPage)
    end
end

local function MakeWindow()
    if window then return window end
    window = CreateFrame("Frame", "FafnyirToolsStandaloneFrame", UIParent, BackdropTemplate())
    local settings = WindowSettings()
    local savedWidth = Clamp(settings.width, MIN_WIDTH, MAX_WIDTH, DEFAULT_WIDTH)
    local savedHeight = Clamp(settings.height, MIN_HEIGHT, MAX_HEIGHT, DEFAULT_HEIGHT)
    settings.width = savedWidth
    settings.height = savedHeight
    window:SetSize(savedWidth, savedHeight)
    window:SetScale(0.86)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    if window.SetResizable then window:SetResizable(true) end
    if window.SetResizeBounds then
        window:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)
    else
        if window.SetMinResize then window:SetMinResize(MIN_WIDTH, MIN_HEIGHT) end
        if window.SetMaxResize then window:SetMaxResize(MAX_WIDTH, MAX_HEIGHT) end
    end
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    AddBackground(window, COLORS.background)
    AddPixelBorder(window, COLORS.controlBorder)
    local header = CreateFrame("Frame", nil, window)
    header:SetPoint("TOPLEFT", 1, -1); header:SetPoint("TOPRIGHT", -1, -1); header:SetHeight(46)
    AddBackground(header, COLORS.surface)
    local headerLine = header:CreateTexture(nil, "ARTWORK")
    headerLine:SetPoint("BOTTOMLEFT"); headerLine:SetPoint("BOTTOMRIGHT"); headerLine:SetHeight(1)
    SetColor(headerLine, COLORS.controlBorder)
    local brand = Label(header, "Fafnyir", true)
    brand:SetFont(FontPath(true), 18, "")
    brand:SetTextColor(unpack(COLORS.secondary))
    brand:SetPoint("LEFT", 14, 0)
    brand:SetSize(68, 22)
    local title = Label(header, "Tools", true)
    title:SetFont(FontPath(true), 18, "")
    title:SetTextColor(unpack(COLORS.text))
    title:SetPoint("LEFT", brand, "RIGHT", 4, 0)
    title:SetPoint("RIGHT", -160, 0)
    title:SetHeight(22)
    local version = Label(header, "v2.0.0")
    version:SetTextColor(unpack(COLORS.muted))
    version:SetPoint("RIGHT", -48, 0)
    version:SetSize(88, 20)
    version:SetJustifyH("RIGHT")
    local close = CreateButton(header, "×")
    close:SetSize(26, 26)
    close:GetFontString():SetFont(FontPath(true), 18, "")
    close:SetPoint("RIGHT", -8, 0)
    close:SetScript("OnClick", function() window:Hide() end)
    local sidebar = CreateFrame("Frame", nil, window)
    sidebar:SetPoint("TOPLEFT", 1, -47)
    sidebar:SetPoint("TOPRIGHT", -1, -47)
    sidebar:SetHeight(48)
    AddBackground(sidebar, COLORS.background)
    local tabLine = sidebar:CreateTexture(nil, "BORDER")
    tabLine:SetPoint("BOTTOMLEFT"); tabLine:SetPoint("BOTTOMRIGHT"); tabLine:SetHeight(1)
    SetColor(tabLine, COLORS.controlBorder)
    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 30, -112)
    scroll:SetPoint("BOTTOMRIGHT", -34, 18)
    window.pageHost = scroll
    window.sidebar = sidebar

    local resizeGrip = CreateFrame("Button", nil, window)
    resizeGrip:SetSize(22, 22)
    resizeGrip:SetPoint("BOTTOMRIGHT", -2, 2)
    resizeGrip:SetFrameLevel(window:GetFrameLevel() + 20)
    local gripA = resizeGrip:CreateTexture(nil, "ARTWORK")
    gripA:SetColorTexture(unpack(COLORS.muted))
    gripA:SetSize(12, 1)
    gripA:SetPoint("BOTTOMRIGHT", -3, 4)
    local gripB = resizeGrip:CreateTexture(nil, "ARTWORK")
    gripB:SetColorTexture(unpack(COLORS.muted))
    gripB:SetSize(7, 1)
    gripB:SetPoint("BOTTOMRIGHT", -3, 8)
    resizeGrip:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" and window.StartSizing then
            window:StartSizing("BOTTOMRIGHT")
        end
    end)
    resizeGrip:SetScript("OnMouseUp", function()
        window:StopMovingOrSizing()
        SaveWindowSize()
        ShowPage(currentPage)
    end)
    window.resizeGrip = resizeGrip
    window:Hide()
    return window
end

local function BuildSidebar()
    if not config then return end
    MakeWindow()
    for _, button in pairs(pageButtons) do button:Hide() end
    wipe(pageButtons)
    UI._tabButtons = pageButtons
    local previous
    for _, page in ipairs(config.pages or {}) do
        local pageName = page
        local button = CreateButton(window.sidebar, pageName)
        button._pageName = pageName
        button:SetSize(math.max(115, #pageName * 9 + 34), 40)
        button:SetSidebarStyle()
        if previous then button:SetPoint("LEFT", previous, "RIGHT", 4, 0)
        else button:SetPoint("LEFT", 18, 0) end
        button:SetScript("OnClick", function(clicked)
            ShowPage(clicked._pageName, clicked)
        end)
        pageButtons[pageName] = button
        previous = button
    end
end

function UI:RegisterModule(_, moduleConfig)
    config = moduleConfig
    BuildSidebar()
    currentPage = currentPage or config.pages[1]
    return true
end

function UI:RefreshPage()
    if window and window:IsShown() then ShowPage(currentPage) end
end

function UI:ToggleOptions()
    MakeWindow()
    if window:IsShown() then window:Hide()
    else ShowPage(currentPage or (config and config.pages[1])); window:Show() end
end

function UI:NavigateToElementSettings(_, page)
    MakeWindow()
    ShowPage(page or currentPage or (config and config.pages[1]))
    window:Show()
end

local function ShowTextDialog(title, prompt, text, editable, onAccept)
    local dialog = CreateFrame("Frame", nil, UIParent, BackdropTemplate())
    dialog:SetSize(620, 250)
    dialog:SetPoint("CENTER")
    dialog:SetFrameStrata("TOOLTIP")
    AddBackground(dialog, COLORS.background)
    AddPixelBorder(dialog, COLORS.highlight)
    local heading = Label(dialog, title, true)
    heading:SetTextColor(unpack(COLORS.bright))
    heading:SetPoint("TOPLEFT", 22, -18); heading:SetPoint("TOPRIGHT", -22, -18); heading:SetHeight(24)
    local help = Label(dialog, prompt)
    help:SetPoint("TOPLEFT", 22, -48); help:SetPoint("TOPRIGHT", -22, -48); help:SetHeight(22)
    local box = CreateFrame("EditBox", nil, dialog, BackdropTemplate())
    AddBackground(box, COLORS.surface)
    AddPixelBorder(box, COLORS.highlight)
    box:SetMultiLine(true); box:SetAutoFocus(true); box:SetFont(FontPath(false), 12, "")
    box:SetTextColor(unpack(COLORS.text)); box:SetTextInsets(8, 8, 6, 6)
    box:SetPoint("TOPLEFT", 26, -78); box:SetPoint("BOTTOMRIGHT", -26, 55)
    box:SetText(text or ""); box:HighlightText(); box:SetCursorPosition(0)
    if not editable then box:SetScript("OnTextChanged", function(self) if self:GetText() ~= (text or "") then self:SetText(text or ""); self:HighlightText() end end) end
    local accept = CreateButton(dialog, editable and "Import" or "Close")
    accept:SetSize(110, 24); accept:SetPoint("BOTTOMRIGHT", -22, 20); accept:SetText(editable and "Import" or "Close")
    accept:SetScript("OnClick", function() if onAccept then onAccept(box:GetText()) end; dialog:Hide() end)
    if editable then
        local cancel = CreateButton(dialog, "Cancel")
        cancel:SetSize(110, 24); cancel:SetPoint("RIGHT", accept, "LEFT", -8, 0); cancel:SetText("Cancel")
        cancel:SetScript("OnClick", function() dialog:Hide() end)
    end
end

function UI:ShowCopyPopup(title, prompt, text)
    ShowTextDialog(title, prompt, text, false)
end

function UI:ShowImportPopup(callback)
    ShowTextDialog("Import Fafnyir Tools Settings", "Paste a settings string below.", "", true, callback)
end


function UI:ShowConfirmPopup(info)
    local dialog = CreateFrame("Frame", nil, UIParent, BackdropTemplate())
    dialog:SetSize(480, 190); dialog:SetPoint("CENTER"); dialog:SetFrameStrata("TOOLTIP")
    AddBackground(dialog, COLORS.background)
    AddPixelBorder(dialog, COLORS.highlight)
    local heading = Label(dialog, info.title or "Confirm", true)
    heading:SetTextColor(unpack(COLORS.bright))
    heading:SetPoint("TOPLEFT", 22, -18); heading:SetPoint("TOPRIGHT", -22, -18); heading:SetHeight(26)
    local body = Label(dialog, info.message or "")
    body:SetPoint("TOPLEFT", 22, -52); body:SetPoint("TOPRIGHT", -22, -52); body:SetHeight(70)
    local yes = CreateButton(dialog, info.confirmText or "Confirm")
    yes:SetSize(130, 24); yes:SetPoint("BOTTOMRIGHT", -22, 20); yes:SetText(info.confirmText or "Confirm")
    yes:SetScript("OnClick", function()
        if info.onConfirm then info.onConfirm() end
        dialog:Hide()
        if info.reload and ReloadUI then ReloadUI() end
    end)
    local no = CreateButton(dialog, info.cancelText or "Cancel")
    no:SetSize(130, 24); no:SetPoint("RIGHT", yes, "LEFT", -8, 0); no:SetText(info.cancelText or "Cancel")
    no:SetScript("OnClick", function() dialog:Hide() end)
end

