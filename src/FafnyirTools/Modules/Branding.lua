local ADDON_NAME, ns = ...

local feature = {
    key = "Branding",
    page = "About",
    searchTerms = { "logo", "branding", "header" },
}

ns:RegisterFeature(feature.key, feature)

local HEADER_TEXTURE = "Interface\\AddOns\\FafnyirTools\\Media\\Header"
local HEADER_ICON_SIZE = 52
local MODULE_KEY = "FafnyirTools"
local MODULE_TITLE = "Fafnyir Tools"
local headerIcon

local function FindHeaderTitle()
    local clickArea = EllesmereUI and EllesmereUI._clickArea
    if not clickArea or type(clickArea.GetChildren) ~= "function" then
        return nil
    end

    for _, child in ipairs({ clickArea:GetChildren() }) do
        local title = child and child._title
        if title
            and child._desc
            and type(title.GetText) == "function"
            and title:GetText() == MODULE_TITLE
        then
            return title
        end
    end
end

local function SetHeaderIconShown(shown)
    if not shown then
        if headerIcon then
            headerIcon:Hide()
        end
        return
    end

    local title = FindHeaderTitle()
    if not title then
        return
    end

    local parent = title:GetParent()
    if not headerIcon or headerIcon:GetParent() ~= parent then
        if headerIcon then
            headerIcon:Hide()
        end
        headerIcon = parent:CreateTexture(nil, "ARTWORK")
        headerIcon:SetTexture(HEADER_TEXTURE)
        -- The supplied header is a centered square mark on a 4:1 canvas.
        headerIcon:SetTexCoord(0.375, 0.625, 0, 1)
        headerIcon:SetSize(HEADER_ICON_SIZE, HEADER_ICON_SIZE)
    end

    headerIcon:ClearAllPoints()
    headerIcon:SetPoint("RIGHT", title, "LEFT", -10, 0)
    headerIcon:Show()
end

function feature:Initialize()
    if self._hooked
        or not EllesmereUI
        or type(EllesmereUI.SelectModule) ~= "function"
        or type(hooksecurefunc) ~= "function"
    then
        return
    end

    self._hooked = true
    hooksecurefunc(EllesmereUI, "SelectModule", function(_, folderName)
        SetHeaderIconShown(folderName == MODULE_KEY)
    end)
end

function feature:BuildOptions(parent, yOffset)
    return math.abs(yOffset)
end
