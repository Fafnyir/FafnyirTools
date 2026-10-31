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

local COLORS = {
    background = { 0x02 / 255, 0x06 / 255, 0x29 / 255, 0.97 },
    surface = { 0x0B / 255, 0x14 / 255, 0x4B / 255, 0.96 },
    surfaceLight = { 0x12 / 255, 0x21 / 255, 0x6A / 255, 1 },
    primary = { 0x24 / 255, 0x47 / 255, 0xAC / 255, 1 },
    secondary = { 0x63 / 255, 0x58 / 255, 0xB8 / 255, 1 },
    highlight = { 0x4A / 255, 0xA0 / 255, 0xE5 / 255, 1 },
    bright = { 0xA7 / 255, 0xE9 / 255, 0xF9 / 255, 1 },
    text = { 0.93, 0.96, 1, 1 },
    muted = { 0.62, 0.68, 0.82, 1 },
}

local fontPath
local function FontPath()
    if fontPath then return fontPath end
    local media = LibStub and LibStub("LibSharedMedia-3.0", true)
    fontPath = media and media:Fetch("font", "- THE FONT", true)
    if (type(fontPath) ~= "string" or fontPath == "") and ns.HAS_FAFNYIRMEDIA then
        fontPath = "Interface\\AddOns\\FafnyirMedia\\fonts\\Fafnyir-Regular.ttf"
    end
    if type(fontPath) ~= "string" or fontPath == "" then
        fontPath = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    end
    return fontPath
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
        GameTooltip:SetText(text, 1, 1, 1, true)
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
    fs:SetFont(FontPath(), size and 16 or 13, "")
    fs:SetTextColor(unpack(COLORS.text))
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetWordWrap(true)
    fs:SetText(text or "")
    return fs
end

local function CreateButton(parent, caption)
    local button = CreateFrame("Button", nil, parent)
    local bg = AddBackground(button, COLORS.primary)
    local border = AddPixelBorder(button, COLORS.highlight)
    local fs = button:CreateFontString(nil, "ARTWORK")
    fs:SetFont(FontPath(), 13, "")
    fs:SetTextColor(unpack(COLORS.text))
    fs:SetPoint("CENTER", 0, 0)
    button:SetFontString(fs)
    button:SetText(caption or "")
    button:SetScript("OnEnter", function(self)
        if self:IsEnabled() and not self._selected then SetColor(bg, COLORS.secondary) end
    end)
    button:SetScript("OnLeave", function(self)
        local color = self._selected and COLORS.secondary
            or (self:IsEnabled() and COLORS.primary or COLORS.surfaceLight)
        SetColor(bg, color)
    end)
    button:HookScript("OnDisable", function()
        SetColor(bg, COLORS.surfaceLight)
        fs:SetTextColor(unpack(COLORS.muted))
        for _, line in ipairs(border) do line:SetAlpha(0.35) end
    end)
    button:HookScript("OnEnable", function()
        SetColor(bg, button._selected and COLORS.secondary or COLORS.primary)
        fs:SetTextColor(unpack(COLORS.text))
        for _, line in ipairs(border) do line:SetAlpha(1) end
    end)
    function button:SetSelected(selected)
        self._selected = selected == true
        SetColor(bg, self._selected and COLORS.secondary or COLORS.primary)
        fs:SetTextColor(unpack(self._selected and COLORS.bright or COLORS.text))
    end
    return button
end

local function BuildLabel(parent, descriptor)
    local fs = Label(parent, descriptor.text)
    fs:SetPoint("TOPLEFT", 8, -8)
    fs:SetPoint("TOPRIGHT", -8, -8)
    fs:SetHeight(44)
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
    AddPixelBorder(check, COLORS.highlight)
    local checked = check:CreateTexture(nil, "ARTWORK")
    checked:SetPoint("TOPLEFT", 4, -4)
    checked:SetPoint("BOTTOMRIGHT", -4, 4)
    SetColor(checked, COLORS.bright)
    check:SetCheckedTexture(checked)
    check:SetPoint("TOPLEFT", 4, -12)
    check:SetChecked(SafeValue(descriptor, false) == true)
    check:SetEnabled(not Disabled(descriptor))
    local fs = Label(parent, descriptor.text)
    fs:SetPoint("LEFT", check, "RIGHT", 0, 0)
    fs:SetPoint("RIGHT", parent, "RIGHT", -8, 0)
    fs:SetHeight(36)
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
    AddPixelBorder(box, COLORS.highlight)
    box:SetFont(FontPath(), 13, "")
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
    local track = slider:CreateTexture(nil, "BACKGROUND")
    track:SetPoint("LEFT", 0, 0); track:SetPoint("RIGHT", 0, 0); track:SetHeight(4)
    SetColor(track, COLORS.surfaceLight)
    slider:SetThumbTexture("Interface\\Buttons\\WHITE8X8")
    local thumb = slider:GetThumbTexture()
    thumb:SetSize(12, 20); SetColor(thumb, COLORS.bright)
    slider:SetPoint("TOPLEFT", 14, -31)
    slider:SetPoint("TOPRIGHT", -18, -31)
    slider:SetHeight(16)
    slider:SetMinMaxValues(descriptor.min or 0, descriptor.max or 100)
    slider:SetValueStep(descriptor.step or 1)
    slider:SetObeyStepOnDrag(true)
    slider:SetValue(tonumber(SafeValue(descriptor, descriptor.min or 0)) or 0)
    slider:SetEnabled(not Disabled(descriptor))
    slider:SetScript("OnValueChanged", function(_, value)
        if type(descriptor.setValue) == "function" then descriptor.setValue(value) end
    end)
    AddTooltip(slider, descriptor.tooltip or (Disabled(descriptor) and descriptor.disabledTooltip))
end

local function BuildDescriptor(parent, descriptor)
    descriptor = descriptor or { type = "label", text = "" }
    if descriptor.type == "button" then BuildButton(parent, descriptor)
    elseif descriptor.type == "toggle" then BuildToggle(parent, descriptor)
    elseif descriptor.type == "dropdown" then BuildDropdown(parent, descriptor)
    elseif descriptor.type == "input" then BuildInput(parent, descriptor)
    elseif descriptor.type == "slider" then BuildSlider(parent, descriptor)
    else BuildLabel(parent, descriptor) end
end

function UI.Widgets:SectionHeader(parent, text, y)
    local frame = CreateFrame("Frame", nil, parent)
    frame:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    frame:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    frame:SetHeight(34)
    local fs = Label(frame, text, true)
    fs:SetTextColor(unpack(COLORS.bright))
    fs:SetPoint("BOTTOMLEFT", 8, 5)
    fs:SetPoint("RIGHT", -8, 0)
    local line = frame:CreateTexture(nil, "BACKGROUND")
    SetColor(line, COLORS.highlight)
    line:SetPoint("BOTTOMLEFT", 8, 1)
    line:SetPoint("BOTTOMRIGHT", -8, 1)
    line:SetHeight(1)
    return frame, 34
end

function UI.Widgets:DualRow(parent, y, left, right)
    local row = CreateFrame("Frame", nil, parent)
    row:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
    row:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, y)
    row:SetHeight(64)
    local leftCell = CreateFrame("Frame", nil, row)
    leftCell:SetPoint("TOPLEFT")
    leftCell:SetPoint("BOTTOMRIGHT", row, "BOTTOM", -4, 0)
    BuildDescriptor(leftCell, left)
    if right then
        local rightCell = CreateFrame("Frame", nil, row)
        rightCell:SetPoint("TOPLEFT", row, "TOP", 4, 0)
        rightCell:SetPoint("BOTTOMRIGHT")
        BuildDescriptor(rightCell, right)
    end
    return row, 64
end

function UI.MakeFont(parent, size, _, r, g, b, a)
    local fs = parent:CreateFontString(nil, "ARTWORK")
    fs:SetFont(FontPath(), size or 12, "")
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

local function ShowPage(pageName)
    if not window or not config then return end
    currentPage = pageName or currentPage or config.pages[1]
    ClearPage()
    local content = CreateFrame("Frame", nil, window.pageHost)
    content:SetWidth(610)
    content:SetHeight(1)
    window.pageHost:SetScrollChild(content)
    window.pageContent = content
    local height = config.buildPage(currentPage, content, -8)
    content:SetHeight(math.max(height + 24, window.pageHost:GetHeight()))
    for page, button in pairs(pageButtons) do
        button:SetSelected(page == currentPage)
    end
end

local function MakeWindow()
    if window then return window end
    window = CreateFrame("Frame", "FafnyirToolsStandaloneFrame", UIParent, BackdropTemplate())
    window:SetSize(860, 620)
    window:SetScale(0.86)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    AddBackground(window, COLORS.background)
    AddPixelBorder(window, COLORS.highlight)
    local header = CreateFrame("Frame", nil, window)
    header:SetPoint("TOPLEFT", 1, -1); header:SetPoint("TOPRIGHT", -1, -1); header:SetHeight(72)
    AddBackground(header, COLORS.surface)
    local headerLine = header:CreateTexture(nil, "ARTWORK")
    headerLine:SetPoint("BOTTOMLEFT"); headerLine:SetPoint("BOTTOMRIGHT"); headerLine:SetHeight(2)
    SetColor(headerLine, COLORS.secondary)
    local title = Label(window, "Fafnyir Tools", true)
    title:SetFont(FontPath(), 22, "")
    title:SetTextColor(unpack(COLORS.bright))
    title:SetPoint("TOPLEFT", 24, -15)
    title:SetPoint("TOPRIGHT", -60, -18)
    title:SetHeight(28)
    local close = CreateButton(window, "×")
    close:SetSize(30, 30)
    close:GetFontString():SetFont(FontPath(), 20, "")
    close:SetPoint("TOPRIGHT", -16, -14)
    close:SetScript("OnClick", function() window:Hide() end)
    local subtitle = Label(window, "Standalone mode — EllesmereUI enhancements appear when EllesmereUI is installed.")
    subtitle:SetTextColor(unpack(COLORS.muted))
    subtitle:SetPoint("TOPLEFT", 24, -43)
    subtitle:SetPoint("TOPRIGHT", -22, -48)
    subtitle:SetHeight(20)
    local sidebar = CreateFrame("Frame", nil, window)
    sidebar:SetPoint("TOPLEFT", 14, -86)
    sidebar:SetPoint("BOTTOMLEFT", 14, 14)
    sidebar:SetWidth(170)
    AddBackground(sidebar, COLORS.surface)
    AddPixelBorder(sidebar, COLORS.surfaceLight)
    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 18, 0)
    scroll:SetPoint("BOTTOMRIGHT", -34, 18)
    window.pageHost = scroll
    window.sidebar = sidebar
    window:Hide()
    return window
end

local function BuildSidebar()
    if not config then return end
    MakeWindow()
    for _, button in pairs(pageButtons) do button:Hide() end
    wipe(pageButtons)
    local previous
    for _, page in ipairs(config.pages or {}) do
        local button = CreateButton(window.sidebar, page)
        button:SetSize(148, 32)
        if previous then button:SetPoint("TOP", previous, "BOTTOM", 0, -7)
        else button:SetPoint("TOP", 0, -12) end
        button:SetScript("OnClick", function() ShowPage(page) end)
        pageButtons[page] = button
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
    box:SetMultiLine(true); box:SetAutoFocus(true); box:SetFont(FontPath(), 12, "")
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

