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
    local fs = parent:CreateFontString(nil, "ARTWORK", size and "GameFontNormalLarge" or "GameFontNormal")
    fs:SetJustifyH("LEFT")
    fs:SetJustifyV("TOP")
    fs:SetWordWrap(true)
    fs:SetText(text or "")
    return fs
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
    local button = AddControl(CreateFrame("Button", nil, parent, "UIPanelButtonTemplate"))
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
    local check = AddControl(CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate"))
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
    local button = AddControl(CreateFrame("Button", nil, parent, "UIPanelButtonTemplate"))
    button:SetPoint("TOPLEFT", 8, -27)
    button:SetPoint("TOPRIGHT", -8, -27)
    button:SetHeight(24)
    local order = descriptor.order or {}
    local values = descriptor.values or {}
    local function Repaint()
        local value = SafeValue(descriptor, order[1])
        button:SetText(values[value] or tostring(value or ""))
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
    local box = AddControl(CreateFrame("EditBox", nil, parent, "InputBoxTemplate"))
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
    local slider = AddControl(CreateFrame("Slider", nil, parent, "OptionsSliderTemplate"))
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
    fs:SetPoint("BOTTOMLEFT", 8, 5)
    fs:SetPoint("RIGHT", -8, 0)
    local line = frame:CreateTexture(nil, "BACKGROUND")
    line:SetColorTexture(0.29, 0.63, 0.9, 0.7)
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
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    local font = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"
    fs:SetFont(font, size or 12)
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
    content:SetWidth(700)
    content:SetHeight(1)
    window.pageHost:SetScrollChild(content)
    window.pageContent = content
    local height = config.buildPage(currentPage, content, -8)
    content:SetHeight(math.max(height + 24, window.pageHost:GetHeight()))
    for page, button in pairs(pageButtons) do
        button:SetEnabled(page ~= currentPage)
    end
end

local function MakeWindow()
    if window then return window end
    window = CreateFrame("Frame", "FafnyirToolsStandaloneFrame", UIParent, BackdropTemplate())
    window:SetSize(920, 650)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetMovable(true)
    window:EnableMouse(true)
    window:RegisterForDrag("LeftButton")
    window:SetScript("OnDragStart", window.StartMoving)
    window:SetScript("OnDragStop", window.StopMovingOrSizing)
    if window.SetBackdrop then
        window:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 24,
            insets = { left = 8, right = 8, top = 8, bottom = 8 } })
    end
    local title = Label(window, "Fafnyir Tools", true)
    title:SetPoint("TOPLEFT", 22, -18)
    title:SetPoint("TOPRIGHT", -60, -18)
    title:SetHeight(28)
    local close = CreateFrame("Button", nil, window, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -7, -7)
    local subtitle = Label(window, "Standalone mode — EllesmereUI enhancements appear when EllesmereUI is installed.")
    subtitle:SetPoint("TOPLEFT", 22, -48)
    subtitle:SetPoint("TOPRIGHT", -22, -48)
    subtitle:SetHeight(20)
    local sidebar = CreateFrame("Frame", nil, window)
    sidebar:SetPoint("TOPLEFT", 18, -78)
    sidebar:SetPoint("BOTTOMLEFT", 18, 18)
    sidebar:SetWidth(180)
    local scroll = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 12, 0)
    scroll:SetPoint("BOTTOMRIGHT", -34, 20)
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
        local button = CreateFrame("Button", nil, window.sidebar, "UIPanelButtonTemplate")
        button:SetSize(170, 28)
        if previous then button:SetPoint("TOP", previous, "BOTTOM", 0, -7)
        else button:SetPoint("TOP", 0, -2) end
        button:SetText(page)
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
    if dialog.SetBackdrop then
        dialog:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 24 })
    end
    local heading = Label(dialog, title, true)
    heading:SetPoint("TOPLEFT", 22, -18); heading:SetPoint("TOPRIGHT", -22, -18); heading:SetHeight(24)
    local help = Label(dialog, prompt)
    help:SetPoint("TOPLEFT", 22, -48); help:SetPoint("TOPRIGHT", -22, -48); help:SetHeight(22)
    local box = CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    box:SetMultiLine(true); box:SetAutoFocus(true); box:SetFontObject(ChatFontNormal)
    box:SetPoint("TOPLEFT", 26, -78); box:SetPoint("BOTTOMRIGHT", -26, 55)
    box:SetText(text or ""); box:HighlightText(); box:SetCursorPosition(0)
    if not editable then box:SetScript("OnTextChanged", function(self) if self:GetText() ~= (text or "") then self:SetText(text or ""); self:HighlightText() end end) end
    local accept = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    accept:SetSize(110, 24); accept:SetPoint("BOTTOMRIGHT", -22, 20); accept:SetText(editable and "Import" or "Close")
    accept:SetScript("OnClick", function() if onAccept then onAccept(box:GetText()) end; dialog:Hide() end)
    if editable then
        local cancel = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
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
    if dialog.SetBackdrop then
        dialog:SetBackdrop({ bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border", edgeSize = 24 })
    end
    local heading = Label(dialog, info.title or "Confirm", true)
    heading:SetPoint("TOPLEFT", 22, -18); heading:SetPoint("TOPRIGHT", -22, -18); heading:SetHeight(26)
    local body = Label(dialog, info.message or "")
    body:SetPoint("TOPLEFT", 22, -52); body:SetPoint("TOPRIGHT", -22, -52); body:SetHeight(70)
    local yes = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    yes:SetSize(130, 24); yes:SetPoint("BOTTOMRIGHT", -22, 20); yes:SetText(info.confirmText or "Confirm")
    yes:SetScript("OnClick", function()
        if info.onConfirm then info.onConfirm() end
        dialog:Hide()
        if info.reload and ReloadUI then ReloadUI() end
    end)
    local no = CreateFrame("Button", nil, dialog, "UIPanelButtonTemplate")
    no:SetSize(130, 24); no:SetPoint("RIGHT", yes, "LEFT", -8, 0); no:SetText(info.cancelText or "Cancel")
    no:SetScript("OnClick", function() dialog:Hide() end)
end

