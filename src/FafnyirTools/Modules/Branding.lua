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
local retryGeneration = 0

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
        return true
    end

    local title = FindHeaderTitle()
    if not title then
        return false
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
    return true
end

local function ScheduleHeaderRetry()
    if not C_Timer or type(C_Timer.After) ~= "function" then
        return
    end

    retryGeneration = retryGeneration + 1
    local generation = retryGeneration
    local attempts = 0

    local function TryHeader()
        if generation ~= retryGeneration then
            return
        end
        if not EllesmereUI
            or type(EllesmereUI.GetActiveModule) ~= "function"
            or EllesmereUI:GetActiveModule() ~= MODULE_KEY
        then
            return
        end
        if SetHeaderIconShown(true) then
            return
        end
        attempts = attempts + 1
        if attempts < 50 then
            C_Timer.After(0.1, TryHeader)
        end
    end

    C_Timer.After(0, TryHeader)
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
        if folderName == MODULE_KEY then
            ScheduleHeaderRetry()
        else
            retryGeneration = retryGeneration + 1
            SetHeaderIconShown(false)
        end
    end)

    ScheduleHeaderRetry()
end

function feature:BuildOptions(parent, yOffset)
    -- Page construction can occur after the initial SelectModule call (for
    -- example when the panel restores FafnyirTools on login), so apply the
    -- header here as well as from the module-switch hook.
    ScheduleHeaderRetry()
    return math.abs(yOffset)
end
