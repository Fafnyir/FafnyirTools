local _, ns = ...
local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end

local feature = {
    key = "CursorReticle",
    page = T("CORE.QOL"),
    searchTerms = { "cursor", "reticle", "click", "mouse" },
}
ns:RegisterFeature(feature.key, feature)

local watcher = CreateFrame("Frame")
local applyHooked = false

local function DB()
    return ns:GetDatabase().cursorReticle
end

local function CursorProfile()
    local db = _G._ECL_AceDB
    return db and db.profile and db.profile.cursor
end

local function NativeReticleEnabled()
    local profile = CursorProfile()
    return profile and profile.reticle == true
end

local function FindReticle()
    local frame = _G.EllesmereUICursorFrame
    if not frame or not frame.GetRegions then return nil end
    for _, region in ipairs({ frame:GetRegions() }) do
        if region and region.GetObjectType and region:GetObjectType() == "Texture"
            and region.GetNumMaskTextures then
            local ok, count = pcall(region.GetNumMaskTextures, region)
            if ok and count and count > 0 then return region end
        end
    end
end

local function MouseDown()
    if not IsMouseButtonDown then return false end
    return IsMouseButtonDown("LeftButton") or IsMouseButtonDown("RightButton")
end

local function UpdateReticle()
    if not DB().enabled or not NativeReticleEnabled() then return end
    local reticle = FindReticle()
    if reticle then reticle:SetShown(MouseDown()) end
end

local function UpdateEvents()
    watcher:UnregisterEvent("GLOBAL_MOUSE_DOWN")
    watcher:UnregisterEvent("GLOBAL_MOUSE_UP")
    if DB().enabled and NativeReticleEnabled() then
        watcher:RegisterEvent("GLOBAL_MOUSE_DOWN")
        watcher:RegisterEvent("GLOBAL_MOUSE_UP")
    end
end

local function InstallApplyHook()
    if applyHooked or not hooksecurefunc or type(_G._ECL_Apply) ~= "function" then return end
    hooksecurefunc("_ECL_Apply", UpdateReticle)
    applyHooked = true
end

watcher:SetScript("OnEvent", function(_, event, addonName)
    if event == "ADDON_LOADED" then
        if addonName ~= "EllesmereUIQoL" then return end
        InstallApplyHook()
        UpdateEvents()
    end
    UpdateReticle()
end)
watcher:RegisterEvent("ADDON_LOADED")

function feature:Initialize()
    InstallApplyHook()
    UpdateEvents()
    UpdateReticle()
end

function feature:Refresh()
    InstallApplyHook()
    UpdateEvents()
    if not DB().enabled and type(_G._ECL_Apply) == "function" then
        _G._ECL_Apply()
    else
        UpdateReticle()
    end
end

function feature:Reset()
    DB().enabled = ns.defaults.cursorReticle.enabled
    self:Refresh()
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, T("QOL.CURSOR_RETICLE"), y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type = "toggle",
            text = T("QOL.RETICLE_ONLY_WHILE_CLICKING"),
            tooltip = T("QOL.SHOW_ELLESMEREUI_CENTER_RETICLE_ONLY_WHILE_CLICKING"),
            disabled = function() return not NativeReticleEnabled() end,
            disabledTooltip = T("QOL.ENABLE_CENTER_RETICLE_IN_ELLESMEREUI_FIRST"),
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value and true or false
                feature:Refresh()
            end,
        },
        nil)
    y = y - h
    return math.abs(y)
end

