local ADDON_NAME, ns = ...

local feature = {
    key = "FlyoutButtonMatch",
    page = "Action Bars",
    searchTerms = ns.IS_FOREVER and {} or {
        "flyout", "flyout fix", "action bar", "border",
    },
}
ns:RegisterFeature(feature.key, feature)

-- Never write native button size, scale, anchors, icon or cooldown geometry.
-- Blizzard owns the pooled buttons and can change their dimensions at any time.
local hookedFlyout
local hookedEUI
local updating = false
local queued = false
local textureStates = {}
local borderStates = {}
local textureHooks = setmetatable({}, { __mode = "k" })
local borderHooks = setmetatable({}, { __mode = "k" })
local buttonHooks = setmetatable({}, { __mode = "k" })
local MatchFlyoutButtons

local function DB()
    return ns:GetDatabase().flyoutFix
end

local function InCombat()
    return InCombatLockdown and InCombatLockdown()
end

local function IsEllesmereButton(button)
    local name = button and button:GetName()
    return name and name:match("^EABButton") ~= nil
end

local function IsActive()
    local flyout = _G.SpellFlyout
    return not ns.IS_FOREVER and DB().enabled and flyout
        and flyout:IsShown() and IsEllesmereButton(flyout:GetParent())
end

local function QueueRefresh()
    if queued then return end
    queued = true
    C_Timer.After(0, function()
        queued = false
        MatchFlyoutButtons()
    end)
end

local function SetManagedAlpha(texture, target)
    if not texture or not texture.SetAlpha then return end
    local state = textureStates[texture]
    if not state then
        state = { original = texture:GetAlpha(), target = target }
        textureStates[texture] = state
    end
    state.target = target
    if not textureHooks[texture] then
        textureHooks[texture] = true
        hooksecurefunc(texture, "SetAlpha", function(self, alpha)
            local current = textureStates[self]
            if current and not updating and IsActive() and alpha ~= current.target then
                -- Defer instead of recursively fighting another addon's alpha hook.
                QueueRefresh()
            end
        end)
    end
    if texture:GetAlpha() ~= target then texture:SetAlpha(target) end
end

local function RestoreTexture(texture)
    local state = textureStates[texture]
    if not state then return end
    textureStates[texture] = nil -- Disable our hook before restoring.
    if texture:GetAlpha() == state.target then
        texture:SetAlpha(state.original)
    end
end

local function RestoreBackground(flyout)
    local background = flyout.Background
    if not background then return end
    for i = 1, background:GetNumRegions() do
        local region = select(i, background:GetRegions())
        if region and region:IsObjectType("Texture") then
            SetManagedAlpha(region, 1)
        end
    end
    -- Do not Show() every region: Blizzard hides direction-specific artwork.
end

local function BorderFor(button)
    local data = EllesmereUI and EllesmereUI._bdBorderData
    return data and data[button]
end

local function CopyBackdrop(info)
    if not info then return nil end
    local copy = {}
    for key, value in pairs(info) do
        if type(value) == "table" then
            local nested = {}
            for k, v in pairs(value) do nested[k] = v end
            copy[key] = nested
        else
            copy[key] = value
        end
    end
    return copy
end

local function TrackBorder(button)
    local frame = BorderFor(button)
    if not frame or frame == button or borderStates[frame] then return end
    local state = { button = button, points = {}, shown = frame:IsShown(),
        level = frame:GetFrameLevel(), width = frame:GetWidth(), height = frame:GetHeight() }
    for i = 1, frame:GetNumPoints() do
        state.points[i] = { frame:GetPoint(i) }
    end
    if frame.GetBackdrop then
        state.backdrop = CopyBackdrop(frame:GetBackdrop())
        state.backdropKey = frame._euiBdKey
        if frame.GetBackdropBorderColor then
            state.borderColor = { frame:GetBackdropBorderColor() }
        end
    end
    borderStates[frame] = state
    if not borderHooks[frame] then
        borderHooks[frame] = true
        for _, method in ipairs({ "SetSize", "SetWidth", "SetHeight", "SetPoint", "SetAllPoints", "ClearAllPoints", "SetBackdrop" }) do
            hooksecurefunc(frame, method, function()
                if borderStates[frame] and not updating and IsActive() then QueueRefresh() end
            end)
        end
    end
end

local function ConstrainBorder(button, textureKey)
    local frame = BorderFor(button)
    if not frame or frame == button or InCombat() then return end
    -- Start from native bounds; below, compensate only for transparent art
    -- padding so the visible border, rather than its texture canvas, fits them.
    frame:ClearAllPoints()
    frame:SetAllPoints(button)

    -- BackdropTemplate corners have explicit edgeSize dimensions. Reanchoring
    -- the frame alone does NOT shrink them; two large corners overlap on a
    -- small flyout button, producing crossed/misaligned artwork.
    local info = frame.GetBackdrop and frame:GetBackdrop()
    local edge = info and info.edgeSize
    local width, height = button:GetWidth(), button:GetHeight()
    if not edge or edge <= 0 or width <= 0 or height <= 0 then return end
    local extent = math.min(width, height)
    local scale = frame.GetEffectiveScale and frame:GetEffectiveScale() or 1
    local pixel = scale > 0 and 1 / scale or 1
    -- Leave space for the straight edge between the two corner cells.
    local limit = (extent - math.min(pixel, extent / 2)) / 2
    if edge > limit then
        local fitted = CopyBackdrop(info)
        fitted.edgeSize = limit
        local color = frame.GetBackdropBorderColor and { frame:GetBackdropBorderColor() }
        frame:SetBackdrop(fitted)
        if color then frame:SetBackdropBorderColor(unpack(color)) end
        -- EUI caches texture + edge size. Invalidate after changing its backdrop
        -- so the next style/layout update starts from the selected size instead
        -- of repeatedly shrinking an already fitted edge.
        frame._euiBdKey = nil
        edge = limit
    end

    -- EUI records the transparent inset of each border texture as fractions
    -- of its edge cell. A zero-offset canvas shrinks the visible outline by
    -- these insets. Expand the canvas asymmetrically where required (Blizzard's
    -- right inset differs from its left), aligning the ink to the native bounds.
    -- This changes only the decorative child, never the native button geometry.
    local ink = textureKey and EllesmereUI._borderInk
        and EllesmereUI._borderInk[textureKey]
    if ink then
        frame:ClearAllPoints()
        frame:SetPoint("TOPLEFT", button, "TOPLEFT", -ink[1] * edge, ink[3] * edge)
        frame:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", ink[2] * edge, -ink[4] * edge)
    end
end

local function RestoreBorder(frame, state)
    borderStates[frame] = nil
    if state.created then
        frame:Hide()
        return
    end
    if frame.SetBackdrop and state.backdrop then
        frame:SetBackdrop(CopyBackdrop(state.backdrop))
        if state.borderColor then frame:SetBackdropBorderColor(unpack(state.borderColor)) end
        frame._euiBdKey = state.backdropKey
    end
    frame:ClearAllPoints()
    frame:SetSize(state.width, state.height) -- EUI border only, never the button.
    for _, point in ipairs(state.points) do frame:SetPoint(unpack(point)) end
    frame:SetFrameLevel(state.level)
    if state.shown then frame:Show() else frame:Hide() end
end

local function RestoreOriginalPresentation()
    for texture in pairs(textureStates) do RestoreTexture(texture) end
    for frame, state in pairs(borderStates) do RestoreBorder(frame, state) end
end

local function ApplySelectedBorderStyle(button, caller)
    local moduleNS = EllesmereUI
        and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS.EllesmereUIActionBars
    local EAB = moduleNS and moduleNS.EAB
    local EFD = moduleNS and moduleNS.EFD
    local profile = EAB and EAB.db and EAB.db.profile
    if not (EFD and profile and profile.bars and EllesmereUI.ApplyBorderStyle) then return false end

    local callerData = EFD(caller)
    local barKey = callerData and callerData.barKey
    local settings = barKey and profile.bars[barKey]
    if not settings then return end

    local shape = settings.buttonShape or "none"
    local textureKey = settings.borderTexture or "solid"
    if (shape ~= "none" and shape ~= "cropped") or textureKey == "solid" then
        return
    end

    local resolveSize = moduleNS.ResolveBorderThickness
    local size = resolveSize and resolveSize(settings) or settings.borderSize or 1
    -- ApplyBorderStyle hides its owner for size zero; our owner is a native
    -- secure button, so leave the disabled-border case to EUI's flyout skin.
    if not size or size <= 0 then return false end
    local color = settings.borderColor or { r = 1, g = 1, b = 1, a = 1 }
    local r, g, b, a = color.r or 1, color.g or 1, color.b or 1, color.a or 1

    if settings.borderClassColor then
        local _, class = UnitClass("player")
        local classColor = class and RAID_CLASS_COLORS[class]
        if classColor then r, g, b = classColor.r, classColor.g, classColor.b end
    end

    TrackBorder(button)
    EllesmereUI.ApplyBorderStyle(
        button,
        size,
        r, g, b, a,
        textureKey,
        settings.borderTextureOffset,
        settings.borderTextureOffsetY,
        settings.borderTextureShiftX,
        settings.borderTextureShiftY,
        "actionbars",
        settings.borderThickness or "thin"
    )

    local borderData = EllesmereUI._bdBorderData
    local borderFrame = borderData and borderData[button]
    if borderFrame then
        TrackBorder(button)
        ConstrainBorder(button, textureKey)
        local level = button:GetFrameLevel()
        borderFrame:SetFrameLevel(settings.borderBehind and math.max(0, level - 1) or level)
    end
    return borderFrame ~= nil
end


local function UpdatePresentation()
    -- Always release owned presentation when disabled, even with the flyout shut.
    if not IsActive() then
        RestoreOriginalPresentation()
        return
    end

    local flyout = _G.SpellFlyout
    local caller = flyout:GetParent()
    RestoreBackground(flyout)
    local liveButtons = {}
    for i = 1, flyout:GetNumChildren() do
        local button = select(i, flyout:GetChildren())
        -- SpellFlyout reuses children across menus of different lengths.
        -- ApplyBorderStyle calls Show() on its owner: never pass an inactive
        -- pooled button or stale spells from the previous menu reappear.
        if button and button:IsShown() and button:IsObjectType("CheckButton")
            and (button.icon or button.Icon) then
            liveButtons[button] = true
            if not buttonHooks[button] then
                buttonHooks[button] = true
                button:HookScript("OnSizeChanged", function()
                    if IsActive() and not updating then QueueRefresh() end
                end)
            end
            local previous = BorderFor(button)
            local applied = ApplySelectedBorderStyle(button, caller)
            local frame = BorderFor(button)
            if frame and frame ~= previous and borderStates[frame] then
                borderStates[frame].created = true
            end
            local normal = button.NormalTexture or button:GetNormalTexture()
            if applied then
                SetManagedAlpha(normal, 0)
            else
                -- Shape/solid styles remain owned by EUI, as in the original feature.
                if normal then RestoreTexture(normal) end
                if frame and borderStates[frame] then RestoreBorder(frame, borderStates[frame]) end
                ConstrainBorder(button)
            end
        end
    end
    -- Release borders for pooled objects no longer attached to this flyout.
    for frame, state in pairs(borderStates) do
        if not liveButtons[state.button] then RestoreBorder(frame, state) end
    end
end

MatchFlyoutButtons = function()
    if ns.IS_FOREVER or updating or InCombat() then return end
    updating = true
    local ok, err = pcall(UpdatePresentation)
    updating = false
    if not ok then geterrorhandler()(err) end
end

local function InstallHook()
    if ns.IS_FOREVER then return false end
    local flyout = _G.SpellFlyout
    if flyout and hookedFlyout ~= flyout then
        hookedFlyout = flyout
        flyout:HookScript("OnShow", function()
            MatchFlyoutButtons()
            QueueRefresh() -- Run again after EUI hooks and Blizzard pool layout.
        end)
        flyout:HookScript("OnHide", QueueRefresh)
    end
    if EllesmereUI and EllesmereUI.ApplyBorderStyle
        and hookedEUI ~= EllesmereUI.ApplyBorderStyle then
        hooksecurefunc(EllesmereUI, "ApplyBorderStyle", function(button)
            if not updating and IsActive() and button
                and button:GetParent() == _G.SpellFlyout then
                QueueRefresh()
            end
        end)
        hookedEUI = EllesmereUI.ApplyBorderStyle
    end
    return flyout ~= nil
end

function feature:Initialize()
    if ns.IS_FOREVER then return end
    InstallHook()
    -- Also cover late loading EUI and Blizzard's flyout frame.
    for _, delay in ipairs({ 0, 0.5, 1, 2 }) do
        C_Timer.After(delay, function() InstallHook(); MatchFlyoutButtons() end)
    end
end

function feature:HandleEvent(event)
    if ns.IS_FOREVER then return end
    if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_REGEN_ENABLED"
        or event == "ADDON_LOADED" then
        InstallHook()
        MatchFlyoutButtons()
    end
end

function feature:Refresh()
    if ns.IS_FOREVER then return end
    InstallHook()
    MatchFlyoutButtons()
end

function feature:Reset()
    if ns.IS_FOREVER then return end
    DB().enabled = ns.defaults.flyoutFix.enabled
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    if ns.IS_FOREVER then return math.abs(yOffset) end
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "FLYOUT FIX", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable Flyout Fix",
            tooltip = "Preserve Blizzard's native flyout layout and background, and fit the selected EllesmereUI border style to each flyout button.",
            getValue = function()
                return DB().enabled
            end,
            setValue = function(value)
                DB().enabled = value
                feature:Refresh()
            end,
        },
        {
            type = "label",
            text = "",
        }
    )
    y = y - h

    return math.abs(y)
end
