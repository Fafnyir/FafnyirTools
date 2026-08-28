local ADDON_NAME, ns = ...

local DEVICE_DEFAULT = 0
local SPEC_DEFAULT = -1

local feature = {
    key = "DeviceLayout",
    page = "Layouts",
    searchTerms = {
        "device", "layout", "preset", "edit mode", "resolution",
        "computer", "machine", "laptop", "desktop", "specialization", "spec",
    },
}

ns:RegisterFeature(feature.key, feature)

local loginPending = true
local applyQueued = false
local lastAppliedIndex

local function DB()
    return ns:GetDatabase().deviceLayout
end

local function CurrentSpecID()
    if PlayerUtil and PlayerUtil.GetCurrentSpecID then
        return PlayerUtil.GetCurrentSpecID()
    end
    if GetSpecialization and GetSpecializationInfo then
        local index = GetSpecialization()
        if index then
            return GetSpecializationInfo(index)
        end
    end
end

local function GetLayouts()
    if EditModeManagerFrame and EditModeManagerFrame.GetLayouts then
        local ok, layouts = pcall(EditModeManagerFrame.GetLayouts, EditModeManagerFrame)
        if ok and type(layouts) == "table" then
            return layouts
        end
    end
    return {}
end

local function LayoutValues(includeSpecDefault)
    local values, order = {}, {}

    if includeSpecDefault then
        values[SPEC_DEFAULT] = "Use Device Default"
        order[#order + 1] = SPEC_DEFAULT
    else
        values[DEVICE_DEFAULT] = "Do Not Change"
        order[#order + 1] = DEVICE_DEFAULT
    end

    local layouts = GetLayouts()
    for i, layout in ipairs(layouts) do
        values[i] = layout.layoutName or ("Layout " .. i)
        order[#order + 1] = i
    end

    return values, order
end

local function DesiredLayout()
    local db = DB()
    local desired = tonumber(db.presetIndex) or DEVICE_DEFAULT
    local source = "device"

    local specID = CurrentSpecID()
    local override = specID and db.specOverrides and db.specOverrides[tostring(specID)]
    if override ~= nil then
        override = tonumber(override)
        if override and override ~= SPEC_DEFAULT then
            desired = override
            source = "specialization"
        end
    end

    return desired, source
end

local function LayoutName(index)
    local layouts = GetLayouts()
    local rec = layouts[index]
    return rec and rec.layoutName or ("Layout " .. tostring(index))
end

function feature:ApplyDesired(silent)
    local db = DB()
    if db.enabled == false then return false end
    if InCombatLockdown and InCombatLockdown() then
        applyQueued = true
        return false
    end

    local desired, source = DesiredLayout()
    if not desired or desired <= DEVICE_DEFAULT then
        applyQueued = false
        return false
    end

    local layouts = GetLayouts()
    if #layouts == 0 then
        return false
    end

    if desired > #layouts then
        if not silent then
            ns:Print("Device Layout: saved layout is no longer available.")
        end
        return false
    end

    if not (EditModeManagerFrame and EditModeManagerFrame.SelectLayout) then
        return false
    end

    local current
    if EditModeManagerFrame.GetActiveLayout then
        local ok, active = pcall(EditModeManagerFrame.GetActiveLayout, EditModeManagerFrame)
        if ok then current = active end
    end

    if current == desired or lastAppliedIndex == desired then
        applyQueued = false
        loginPending = false
        return true
    end

    local ok = pcall(EditModeManagerFrame.SelectLayout, EditModeManagerFrame, desired)
    if ok then
        lastAppliedIndex = desired
        applyQueued = false
        loginPending = false
        if not silent then
            ns:Print("Loaded \"" .. LayoutName(desired) .. "\" Layout.")
        end
        return true
    end

    return false
end

local function QueueApply(delay, silent)
    C_Timer.After(delay or 0, function()
        feature:ApplyDesired(silent)
    end)
end

function feature:Initialize()
    loginPending = true
    applyQueued = false
    lastAppliedIndex = nil

    -- Edit Mode is not always ready at PLAYER_LOGIN. These are fallbacks;
    -- EDIT_MODE_LAYOUTS_UPDATED remains the authoritative early trigger.
    QueueApply(0.5, false)
    QueueApply(1.5, false)
end

function feature:Reset()
    local db = DB()
    db.enabled = ns.defaults.deviceLayout.enabled
    db.presetIndex = ns.defaults.deviceLayout.presetIndex
    db.specOverrides = {}
end

local function GetClassSpecs()
    local specs = {}
    local _, _, classID = UnitClass("player")
    if not classID then return specs end

    local count
    if C_SpecializationInfo and C_SpecializationInfo.GetNumSpecializationsForClassID then
        count = C_SpecializationInfo.GetNumSpecializationsForClassID(classID)
    elseif GetNumSpecializations then
        count = GetNumSpecializations()
    end

    for i = 1, (count or 0) do
        local specID, specName
        if C_SpecializationInfo and C_SpecializationInfo.GetSpecializationInfo then
            specID, specName = C_SpecializationInfo.GetSpecializationInfo(i, false, false)
        elseif GetSpecializationInfo then
            specID, specName = GetSpecializationInfo(i)
        end
        if specID then
            specs[#specs + 1] = {
                id = specID,
                name = specName or ("Specialization " .. i),
            }
        end
    end

    return specs
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "DEVICE LAYOUT", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable Device Layout",
            tooltip = "Automatically select the saved Blizzard Edit Mode layout when you log in on this installation.",
            getValue = function()
                return DB().enabled ~= false
            end,
            setValue = function(value)
                DB().enabled = value
                if value then
                    lastAppliedIndex = nil
                    feature:ApplyDesired(false)
                end
            end,
        },
        {
            type = "label",
            text = "Saved per WoW installation.\nChoose a different layout on each device.",
        }
    )
    y = y - h

    local layoutValues, layoutOrder = LayoutValues(false)

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "dropdown",
            text = "Device Default Layout",
            tooltip = "The Blizzard Edit Mode layout Fafnyir Tools will select when you log in on this device.",
            values = layoutValues,
            order = layoutOrder,
            getValue = function()
                return tonumber(DB().presetIndex) or DEVICE_DEFAULT
            end,
            setValue = function(value)
                DB().presetIndex = tonumber(value) or DEVICE_DEFAULT
                lastAppliedIndex = nil
                feature:ApplyDesired(false)
            end,
        },
        {
            type = "label",
            text = "This setting is applied automatically after Blizzard Edit Mode finishes loading.",
        }
    )
    y = y - h

    _, h = W:SectionHeader(parent, "SPECIALIZATION OVERRIDES", y)
    y = y - h

    local specValues, specOrder = LayoutValues(true)
    local specs = GetClassSpecs()

    if #specs == 0 then
        _, h = W:DualRow(
            parent,
            y,
            { type = "label", text = "Specialization information is not available yet." },
            { type = "label", text = "" }
        )
        y = y - h
    else
        for i = 1, #specs, 2 do
            local leftSpec = specs[i]
            local rightSpec = specs[i + 1]

            local function SpecWidget(spec)
                if not spec then
                    return { type = "label", text = "" }
                end
                local key = tostring(spec.id)
                return {
                    type = "dropdown",
                    text = spec.name,
                    tooltip = "Choose a layout for " .. spec.name .. ", or use the device default.",
                    values = specValues,
                    order = specOrder,
                    getValue = function()
                        local v = DB().specOverrides[key]
                        if v == nil then return SPEC_DEFAULT end
                        return tonumber(v) or SPEC_DEFAULT
                    end,
                    setValue = function(value)
                        DB().specOverrides[key] = tonumber(value) or SPEC_DEFAULT
                        if CurrentSpecID() == spec.id then
                            lastAppliedIndex = nil
                            feature:ApplyDesired(false)
                        end
                    end,
                }
            end

            _, h = W:DualRow(parent, y, SpecWidget(leftSpec), SpecWidget(rightSpec))
            y = y - h
        end
    end

    return math.abs(y)
end

function feature:HandleEvent(event, ...)
    if event == "EDIT_MODE_LAYOUTS_UPDATED" then
        if loginPending then
            self:ApplyDesired(false)
        end
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        local unit = ...
        if unit == nil or unit == "player" then
            lastAppliedIndex = nil
            QueueApply(0.2, false)
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        loginPending = true
        lastAppliedIndex = nil
        QueueApply(0.5, false)
    elseif event == "PLAYER_REGEN_ENABLED" and applyQueued then
        lastAppliedIndex = nil
        self:ApplyDesired(false)
    end
end
