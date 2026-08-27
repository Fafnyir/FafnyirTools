local ADDON_NAME, ns = ...

local feature = {
    key = "FlyoutButtonMatch",
    page = "Action Bars",
    searchTerms = {
        "flyout",
        "flyout fix",
        "action bar",
        "border",
    },
}
ns:RegisterFeature(feature.key, feature)

local hooked = false
local suppressedTextures = setmetatable({}, { __mode = "k" })

local function DB()
    return ns:GetDatabase().flyoutFix
end

local function SuppressNativeBorder(button)
    local texture = button.NormalTexture or button:GetNormalTexture()
    if not texture then return end

    if not suppressedTextures[texture] then
        hooksecurefunc(texture, "SetAlpha", function(self, alpha)
            if alpha ~= 0 then self:SetAlpha(0) end
        end)
        suppressedTextures[texture] = true
    end

    texture:SetAlpha(0)
end

local function IsEllesmereButton(button)
    local name = button and button:GetName()
    return name and name:match("^EABButton") ~= nil
end

local function ApplySelectedBorderStyle(button, caller)
    local moduleNS = EllesmereUI
        and EllesmereUI._ModuleNS
        and EllesmereUI._ModuleNS.EllesmereUIActionBars
    local EAB = moduleNS and moduleNS.EAB
    local EFD = moduleNS and moduleNS.EFD
    local profile = EAB and EAB.db and EAB.db.profile
    if not (EFD and profile and profile.bars) then return end

    local barKey = EFD(caller).barKey
    local settings = barKey and profile.bars[barKey]
    if not settings then return end

    local shape = settings.buttonShape or "none"
    local textureKey = settings.borderTexture or "solid"
    if (shape ~= "none" and shape ~= "cropped") or textureKey == "solid" then
        return
    end

    local resolveSize = moduleNS.ResolveBorderThickness
    local size = resolveSize and resolveSize(settings) or settings.borderSize or 1
    local color = settings.borderColor or { r = 1, g = 1, b = 1, a = 1 }
    local r, g, b, a = color.r or 1, color.g or 1, color.b or 1, color.a or 1

    if settings.borderClassColor then
        local _, class = UnitClass("player")
        local classColor = class and RAID_CLASS_COLORS[class]
        if classColor then r, g, b = classColor.r, classColor.g, classColor.b end
    end

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
        local level = button:GetFrameLevel()
        borderFrame:SetFrameLevel(settings.borderBehind and math.max(0, level - 1) or level)
    end
end

local function RestoreOriginalPresentation(button)
    pcall(button.SetScale, button, 1)
    pcall(button.SetSize, button, 45, 45)

    local borderData = EllesmereUI and EllesmereUI._bdBorderData
    local borderFrame = borderData and borderData[button]
    if borderFrame then borderFrame:Hide() end
end

local function MatchFlyoutButtons()
    local flyout = _G.SpellFlyout
    if not flyout or not flyout:IsShown() then return end

    local caller = flyout:GetParent()
    if not IsEllesmereButton(caller) then return end

    local width, height = caller:GetWidth(), caller:GetHeight()
    if not width or width <= 0 or not height or height <= 0 then return end

    for i = 1, flyout:GetNumChildren() do
        local child = select(i, flyout:GetChildren())
        if child and child:IsShown() and (child.icon or child.Icon) then
            if not DB().enabled then
                RestoreOriginalPresentation(child)
            else
                SuppressNativeBorder(child)

                -- SpellFlyout is parented to the calling EABButton and therefore
                -- already inherits its effective scale. Match only its local
                -- dimensions so custom-sized buttons do not remain native 45x45.
                pcall(child.SetScale, child, 1)
                pcall(child.SetSize, child, width, height)
                ApplySelectedBorderStyle(child, caller)

                if child.cooldown and not child.cooldown:IsForbidden() then
                    pcall(child.cooldown.SetAllPoints, child.cooldown, child)
                end
            end
        end
    end
end

local function InstallHook()
    local flyout = _G.SpellFlyout
    if hooked or not flyout then return hooked end

    flyout:HookScript("OnShow", function()
        -- Ellesmere's own OnShow hook applies shape, border, and zoom first.
        -- Run once immediately and once after Blizzard finishes pool layout.
        MatchFlyoutButtons()
        C_Timer.After(0, MatchFlyoutButtons)
    end)

    hooked = true
    return true
end

function feature:Initialize()
    if InstallHook() then return end

    C_Timer.After(0.5, InstallHook)
    C_Timer.After(1, InstallHook)
    C_Timer.After(2, InstallHook)
end

function feature:HandleEvent(event)
    if event == "PLAYER_ENTERING_WORLD" then
        InstallHook()
    elseif event == "PLAYER_REGEN_ENABLED" then
        MatchFlyoutButtons()
    end
end

function feature:Refresh()
    MatchFlyoutButtons()
end

function feature:Reset()
    DB().enabled = ns.defaults.flyoutFix.enabled
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
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
            tooltip = "Match spell flyout button size and border style to the parent EllesmereUI action bar.",
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
