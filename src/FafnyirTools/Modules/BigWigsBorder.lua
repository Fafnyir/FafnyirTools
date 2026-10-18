local ADDON_NAME, ns = ...
local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "BigWigsBorder",
    page = T("CORE.QOL"),
    searchTerms = { "bigwigs", "border", "timer bars", "boss bars" },
}
ns:RegisterFeature(feature.key, feature)

local trackedBars = setmetatable({}, { __mode = "k" })
local trackedMessageIcons = setmetatable({}, { __mode = "k" })
local messagesRegistered = false

local function DB()
    return ns:GetDatabase().bigWigsBorder
end

local function Enabled()
    return DB().enabled == true
end

local function BigWigsAvailable()
    return BigWigsLoader and type(BigWigsLoader.RegisterMessage) == "function"
end

local function HideBorder(target, field)
    local border = target and target[field]
    if border then border:Hide() end
end

local function ReadPoints(region)
    local points = {}
    for i = 1, region:GetNumPoints() do
        local point, relativeTo, relativePoint, x, y = region:GetPoint(i)
        points[i] = { point, relativeTo, relativePoint, x or 0, y or 0 }
    end
    return points
end

local function CaptureBarLayout(bar)
    if not bar or not bar.candyBarIconFrame or not bar.candyBarBar then return end
    local ok, iconPoints, statusPoints = pcall(function()
        return ReadPoints(bar.candyBarIconFrame), ReadPoints(bar.candyBarBar)
    end)
    if ok then
        bar._fafnyirBigWigsNativeLayout = {
            icon = iconPoints,
            status = statusPoints,
        }
    end
end

local function SetPoints(region, points, globalOffset, relativeRegion, relativeOffset)
    region:ClearAllPoints()
    for i = 1, #points do
        local point = points[i]
        local x = point[4] + (globalOffset or 0)
        if relativeRegion and point[2] == relativeRegion then
            x = x + (relativeOffset or 0)
        end
        region:SetPoint(point[1], point[2], point[3], x, point[5])
    end
end

local function RestoreBarLayout(bar)
    local layout = bar and bar._fafnyirBigWigsNativeLayout
    if not layout then return end
    SetPoints(bar.candyBarBar, layout.status, 0)
end

local function ApplyBarOffset(bar)
    local icon = bar and bar.candyBarIconFrame
    local status = bar and bar.candyBarBar
    local layout = bar and bar._fafnyirBigWigsNativeLayout
    if not icon or not status or not layout then return end

    RestoreBarLayout(bar)
    local offset = math.max(0, tonumber(DB().iconOffset) or 0)
    if not Enabled() or offset == 0 or not icon:IsShown() then return end

    local position = type(bar.GetIconPosition) == "function" and bar:GetIconPosition() or "LEFT"
    local direction = position == "RIGHT" and -1 or 1
    SetPoints(status, layout.status, direction * offset)
end

local function ApplyBorder(owner, target, field, context)
    if not target then return end
    if not Enabled() or not EllesmereUI or type(EllesmereUI.ApplyBorderStyle) ~= "function" then
        HideBorder(target, field)
        return
    end

    local border = target[field]
    if not border then
        border = CreateFrame("Frame", nil, owner)
        target[field] = border
    end

    border:ClearAllPoints()
    border:SetPoint("TOPLEFT", target, "TOPLEFT", 0, 0)
    border:SetPoint("BOTTOMRIGHT", target, "BOTTOMRIGHT", 0, 0)
    local texture = DB().texture or "pixels"
    local size = EllesmereUI.GetBorderDefaultSize
        and EllesmereUI.GetBorderDefaultSize(context, texture)
        or 1
    local color, behind
    if EllesmereUI.GetBorderStyleSelectDefaults then
        color, behind = EllesmereUI.GetBorderStyleSelectDefaults(texture)
    end
    color = color or { r = 1, g = 1, b = 1 }
    border:SetFrameLevel(math.max(0, owner:GetFrameLevel() + (behind and -1 or 8)))
    local exactPixels = EllesmereUI.BorderPx
        and EllesmereUI.BorderPx(nil, size, texture)

    EllesmereUI.ApplyBorderStyle(
        border,
        size,
        color.r or 1,
        color.g or 1,
        color.b or 1,
        1,
        texture,
        nil,
        nil,
        nil,
        nil,
        context,
        size,
        nil,
        exactPixels
    )
    border:SetShown(owner:IsShown() and target:IsShown())
end

local function ApplyToMessageIcon(icon, owner)
    if not icon or not owner then return end
    local state = trackedMessageIcons[icon]
    if not state then
        local ok, points = pcall(ReadPoints, icon)
        if not ok then return end
        state = { owner = owner, points = points }
        trackedMessageIcons[icon] = state
    end
    SetPoints(icon, state.points, 0)
    local offset = math.max(0, tonumber(DB().iconOffset) or 0)
    if Enabled() and offset > 0 then SetPoints(icon, state.points, -offset) end
    ApplyBorder(owner, icon, "_fafnyirBigWigsMessageBorder", "bigwigs_message_icon")
    local border = icon._fafnyirBigWigsMessageBorder
    if border and not border._fafnyirAlphaSync then
        border._fafnyirAlphaSync = true
        border:SetScript("OnUpdate", function(self)
            if not Enabled() then
                self:Hide()
                return
            end
            self:Show()
            local visible = owner:IsShown() and icon:IsShown()
            self:SetAlpha(visible and (icon.GetAlpha and icon:GetAlpha() or 1) or 0)
        end)
    end
    if border and Enabled() then
        border:Show()
        border:SetAlpha(owner:IsShown() and icon:IsShown()
            and (icon.GetAlpha and icon:GetAlpha() or 1) or 0)
    end
end

local function IsMessagesFrame(frame)
    if not frame or not frame.GetRegions then return false end
    local textures = {}
    for _, region in ipairs({ frame:GetRegions() }) do
        if region.GetObjectType and region:GetObjectType() == "Texture" then
            local ok, point, relativeTo, relativePoint = pcall(region.GetPoint, region, 1)
            if ok and point == "RIGHT" and relativePoint == "LEFT"
                and relativeTo and relativeTo.GetObjectType
                and relativeTo:GetObjectType() == "FontString" then
                textures[#textures + 1] = region
            end
        end
    end
    if #textures ~= 4 then return false end
    for i = 1, #textures do ApplyToMessageIcon(textures[i], frame) end
    return true
end

local function ScanMessageIcons()
    if EnumerateFrames then
        local frame = EnumerateFrames()
        while frame do
            if IsMessagesFrame(frame) then return true end
            frame = EnumerateFrames(frame)
        end
        return false
    end
    if UIParent and UIParent.GetChildren then
        for _, frame in ipairs({ UIParent:GetChildren() }) do
            if IsMessagesFrame(frame) then return true end
        end
    end
    return false
end

local function QueueMessageScan()
    if not C_Timer or not C_Timer.After then
        ScanMessageIcons()
        return
    end
    for _, delay in ipairs({ 0, 0.2, 0.5, 1 }) do
        C_Timer.After(delay, ScanMessageIcons)
    end
end

local function ApplyToBar(bar, captureLayout)
    if not bar then return end
    trackedBars[bar] = true
    if captureLayout then CaptureBarLayout(bar) end
    ApplyBarOffset(bar)
    ApplyBorder(bar, bar.candyBarBar, "_fafnyirBigWigsBorder", "bigwigs_bar")
    ApplyBorder(bar, bar.candyBarIconFrame, "_fafnyirBigWigsIconBorder", "bigwigs_icon")
end

local function HideBarBorders(bar)
    HideBorder(bar and bar.candyBarBar, "_fafnyirBigWigsBorder")
    HideBorder(bar and bar.candyBarIconFrame, "_fafnyirBigWigsIconBorder")
    RestoreBarLayout(bar)
end

local function OnBarCreated(_, _, bar)
    ApplyToBar(bar, true)
end

local function OnBarEmphasized(_, _, bar)
    ApplyToBar(bar, true)
end

local function OnBigWigsMessage()
    QueueMessageScan()
end

local function RegisterMessages()
    if messagesRegistered or not BigWigsAvailable() then return false end
    BigWigsLoader.RegisterMessage(feature, "BigWigs_BarCreated", OnBarCreated)
    BigWigsLoader.RegisterMessage(feature, "BigWigs_BarEmphasized", OnBarEmphasized)
    BigWigsLoader.RegisterMessage(feature, "BigWigs_Message", OnBigWigsMessage)
    messagesRegistered = true
    return true
end

function feature:Initialize()
    RegisterMessages()
    QueueMessageScan()
end

function feature:Refresh()
    RegisterMessages()
    for bar in pairs(trackedBars) do
        if Enabled() then
            ApplyToBar(bar)
        else
            HideBarBorders(bar)
        end
    end
    for icon, state in pairs(trackedMessageIcons) do
        if Enabled() then
            ApplyToMessageIcon(icon, state.owner)
        else
            SetPoints(icon, state.points, 0)
            HideBorder(icon, "_fafnyirBigWigsMessageBorder")
        end
    end
    if Enabled() then ScanMessageIcons() end
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then QueueMessageScan() end
end

function feature:Reset()
    DB().enabled = ns.defaults.bigWigsBorder.enabled
    DB().texture = ns.defaults.bigWigsBorder.texture
    DB().iconOffset = ns.defaults.bigWigsBorder.iconOffset
    self:Refresh()
end

local function RefreshWidgetsAfterToggle()
    local function refresh()
        local widgets = EllesmereUI and EllesmereUI._widgetRefreshList
        if not widgets then return end
        for i = 1, #widgets do widgets[i]() end
    end
    if C_Timer and C_Timer.After then
        C_Timer.After(0, refresh)
    else
        refresh()
    end
end

local function RefreshOptionsAfterDropdown()
    local function refresh()
        if EllesmereUI and EllesmereUI.RefreshPage then
            EllesmereUI:RefreshPage(true)
        end
    end
    if C_Timer and C_Timer.After then
        -- Let the active toggle/dropdown finish its own click and menu-close
        -- lifecycle before EllesmereUI rebuilds the page from saved values.
        C_Timer.After(0.05, refresh)
    else
        refresh()
    end
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, T("QOL.BIGWIGS_PIXEL_BORDER"), y)
    y = y - h
    local values, order
    if EllesmereUI.GetBorderTextureDropdown then
        values, order = EllesmereUI.GetBorderTextureDropdown()
    else
        values, order = {
            solid = T("QOL.SOLID"),
            pixels = T("QOL.PIXELS"),
        }, { "solid", "pixels" }
    end
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = T("QOL.ENABLE_BIGWIGS_PIXEL_BORDER"),
            tooltip = T("QOL.APPLY_THE_ELLESMEREUI_PIXELS_BORDER_TO_BIGWIGS_TIMER"),
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value and true or false
                feature:Refresh()
                RefreshWidgetsAfterToggle()
            end,
        },
        {
            type = "dropdown",
            text = T("QOL.BORDER_STYLE"),
            values = values,
            order = order,
            disabled = function() return not DB().enabled end,
            disabledTooltip = T("QOL.ENABLE_BIGWIGS_PIXEL_BORDER"),
            getValue = function() return DB().texture or "pixels" end,
            setValue = function(value)
                DB().texture = value
                feature:Refresh()
                RefreshOptionsAfterDropdown()
            end,
        })
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "slider",
            text = T("QOL.BIGWIGS_ICON_OFFSET"),
            tooltip = T("QOL.MOVE_BIGWIGS_SPELL_ICONS_AWAY_FROM_THE_TIMER_BAR"),
            min = 0,
            max = 10,
            step = 1,
            disabled = function() return not DB().enabled end,
            disabledTooltip = T("QOL.ENABLE_BIGWIGS_PIXEL_BORDER"),
            getValue = function() return DB().iconOffset or 0 end,
            setValue = function(value)
                DB().iconOffset = value
                feature:Refresh()
            end,
        },
        nil)
    y = y - h
    return math.abs(y)
end

local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(_, _, addonName)
    if addonName == "BigWigs" or addonName == "BigWigs_Plugins" then
        RegisterMessages()
        QueueMessageScan()
    end
end)
