local ADDON_NAME, ns = ...

local feature = {
    key = "GlobalSettings",
    page = "About",
    searchTerms = { "export", "import", "backup", "global settings", "transfer" },
}
ns:RegisterFeature(feature.key, feature)

local FORMAT = 1
local PREFIX = "FAFNYIRTOOLS:1:"
local MAX_IMPORT_BYTES = 100000
local MAX_DEPTH = 12
local MAX_ENTRIES = 2000

-- Only user preferences belong in a global export. Runtime inventories,
-- per-character companion choices and machine-specific Edit Mode layouts do not.
local SCHEMA = {
    blizzardBarArt = true,
    flyoutFix = true,
    permanentCompanionPet = { enabled = true, disableInPvP = true },
    resting = true,
    rightClickSelfCast = true,
    unitFrameSources = true,
    inventory = { enabled = true, tooltips = true },
    xpBar = true,
    auraSkins = true,
}

local function Copy(value)
    if type(value) ~= "table" then return value end
    local result = {}
    for key, child in pairs(value) do result[Copy(key)] = Copy(child) end
    return result
end

local function SelectShape(value, shape)
    if type(shape) ~= "table" then return Copy(value) end
    local result = {}
    if type(value) ~= "table" then return result end
    for key, childShape in pairs(shape) do
        if value[key] ~= nil then result[key] = SelectShape(value[key], childShape) end
    end
    return result
end

local function Select(source, schema, defaults)
    local result = {}
    for key, rule in pairs(schema) do
        local value = source[key]
        if rule == true then
            if type(value) == "table" and type(defaults[key]) == "table" then
                result[key] = SelectShape(value, defaults[key])
            elseif value ~= nil then
                result[key] = Copy(value)
            end
        elseif type(rule) == "table" and type(value) == "table" then
            result[key] = Select(value, rule, defaults[key] or {})
        end
    end
    return result
end

local function EncodeValue(value, out, depth)
    if depth > MAX_DEPTH then error("settings are nested too deeply") end
    local kind = type(value)
    if kind == "boolean" then
        out[#out + 1] = value and "B1" or "B0"
    elseif kind == "number" then
        if value ~= value or value == math.huge or value == -math.huge then error("invalid number") end
        local text = string.format("%.17g", value)
        out[#out + 1] = "N" .. #text .. ":" .. text
    elseif kind == "string" then
        out[#out + 1] = "S" .. #value .. ":" .. value
    elseif kind == "table" then
        local keys = {}
        for key in pairs(value) do
            if type(key) ~= "string" and type(key) ~= "number" then error("invalid table key") end
            keys[#keys + 1] = key
        end
        table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
        out[#out + 1] = "T" .. #keys .. ":"
        for _, key in ipairs(keys) do
            EncodeValue(key, out, depth + 1)
            EncodeValue(value[key], out, depth + 1)
        end
    else
        error("unsupported value type")
    end
end

local function DecodeValue(text, pos, depth, state)
    if depth > MAX_DEPTH then return nil, pos, "settings are nested too deeply" end
    local tag = text:sub(pos, pos)
    pos = pos + 1
    if tag == "B" then
        local bit = text:sub(pos, pos)
        if bit ~= "0" and bit ~= "1" then return nil, pos, "invalid boolean" end
        return bit == "1", pos + 1
    end
    local colon = text:find(":", pos, true)
    if not colon then return nil, pos, "missing length separator" end
    local count = tonumber(text:sub(pos, colon - 1))
    if not count or count < 0 or count ~= math.floor(count) then return nil, pos, "invalid length" end
    pos = colon + 1
    if tag == "S" then
        local last = pos + count - 1
        if last > #text then return nil, pos, "truncated string" end
        return text:sub(pos, last), last + 1
    elseif tag == "N" then
        local last = pos + count - 1
        local value = tonumber(text:sub(pos, last))
        if last > #text or not value or value ~= value or value == math.huge or value == -math.huge then
            return nil, pos, "invalid number"
        end
        return value, last + 1
    elseif tag == "T" then
        state.entries = state.entries + count
        if state.entries > MAX_ENTRIES then return nil, pos, "too many settings" end
        local result = {}
        for _ = 1, count do
            local key, nextPos, err = DecodeValue(text, pos, depth + 1, state)
            if err then return nil, pos, err end
            if type(key) ~= "string" and type(key) ~= "number" then return nil, pos, "invalid table key" end
            local value
            value, pos, err = DecodeValue(text, nextPos, depth + 1, state)
            if err then return nil, pos, err end
            result[key] = value
        end
        return result, pos
    end
    return nil, pos, "unknown value type"
end

local function MergeRecognized(target, incoming, schema, defaults)
    for key, rule in pairs(schema) do
        local value = incoming[key]
        if value ~= nil then
            if rule == true then
                local expected = defaults[key]
                if type(value) == type(expected) then
                    if type(value) == "table" then
                        if type(target[key]) ~= "table" then target[key] = {} end
                        for childKey, childDefault in pairs(expected) do
                            local child = value[childKey]
                            if child ~= nil and type(child) == type(childDefault) then
                                if type(child) == "table" then
                                    if type(target[key][childKey]) ~= "table" then target[key][childKey] = {} end
                                    for leafKey, leafDefault in pairs(childDefault) do
                                        local leaf = child[leafKey]
                                        if leaf ~= nil and type(leaf) == type(leafDefault) then
                                            target[key][childKey][leafKey] = Copy(leaf)
                                        end
                                    end
                                else
                                    target[key][childKey] = child
                                end
                            end
                        end
                    else
                        target[key] = value
                    end
                end
            elseif type(rule) == "table" and type(value) == "table" then
                if type(target[key]) ~= "table" then target[key] = {} end
                MergeRecognized(target[key], value, rule, defaults[key] or {})
            end
        end
    end
end

local function SyncUnitFrameSources()
    local sources = ns.modules and ns.modules.UnitFrameSources
    if sources and type(sources.ApplySaved) == "function" then
        return sources:ApplySaved()
    end
    return false
end

function feature:Export()
    local payload = {
        format = FORMAT,
        addonVersion = "v1.1.3",
        settings = Select(ns:GetDatabase(), SCHEMA, ns.defaults),
    }
    local out = {}
    EncodeValue(payload, out, 0)
    return PREFIX .. table.concat(out)
end

function feature:Decode(text)
    text = type(text) == "string" and text:match("^%s*(.-)%s*$") or ""
    if #text == 0 then return nil, "The import string is empty." end
    if #text > MAX_IMPORT_BYTES then return nil, "The import string is too large." end
    if text:sub(1, #PREFIX) ~= PREFIX then return nil, "This is not a FafnyirTools settings string." end
    local payload, pos, err = DecodeValue(text, #PREFIX + 1, 0, { entries = 0 })
    if err then return nil, "Invalid import string: " .. err .. "." end
    if pos ~= #text + 1 then return nil, "Invalid import string: unexpected trailing data." end
    if type(payload) ~= "table" or payload.format ~= FORMAT or type(payload.settings) ~= "table" then
        return nil, "This settings format is not supported."
    end
    return payload
end

function feature:ApplyImport(payload)
    if ns:ForeverSavedVariablesUnsafe() then
        ns:PrintForeverSavedVariablesWarning()
        return false
    end
    local db = ns:GetDatabase()
    db.globalSettingsImportBackup = {
        created = time and time() or 0,
        addonVersion = "v1.1.3",
        settings = Select(db, SCHEMA, ns.defaults),
    }
    MergeRecognized(db, payload.settings, SCHEMA, ns.defaults)
    ns:InitializeDatabase()
    -- EllesmereUI owns a separate source profile that its frame constructor
    -- reads during startup. Write imported choices there before ReloadUI;
    -- deferring this to PLAYER_LOGIN would require a second reload.
    SyncUnitFrameSources()
    return true
end

function feature:RestoreBackup()
    if ns:ForeverSavedVariablesUnsafe() then
        ns:PrintForeverSavedVariablesWarning()
        return false
    end
    local db = ns:GetDatabase()
    local backup = db.globalSettingsImportBackup
    if type(backup) ~= "table" or type(backup.settings) ~= "table" then return false end
    MergeRecognized(db, backup.settings, SCHEMA, ns.defaults)
    SyncUnitFrameSources()
    return true
end

local function ConfirmImport(payload)
    if not EllesmereUI.ShowConfirmPopup then return end
    EllesmereUI:ShowConfirmPopup({
        title = "Import FafnyirTools Settings?",
        message = "Recognized global settings will be merged. Character data, inventory caches and device layouts are excluded. Your current global settings will be backed up. A reload is required.",
        confirmText = "Import & Reload",
        cancelText = "Cancel",
        onConfirm = function()
            feature:ApplyImport(payload)
            ReloadUI()
        end,
    })
end

function feature:ShowExport()
    if EllesmereUI.ShowCopyPopup then
        EllesmereUI:ShowCopyPopup("Export FafnyirTools Settings", "Copy this global-settings string", self:Export())
    end
end

function feature:ShowImport()
    if ns:ForeverSavedVariablesUnsafe() then
        ns:PrintForeverSavedVariablesWarning()
        return
    end
    if not EllesmereUI.ShowImportPopup then return end
    EllesmereUI:ShowImportPopup(function(text)
        local payload, err = feature:Decode(text)
        if not payload then ns:Print(err); return end
        ConfirmImport(payload)
    end, "Import FafnyirTools Settings", "Paste a FafnyirTools global-settings string")
end

function feature:ShowRestore()
    local backup = ns:GetDatabase().globalSettingsImportBackup
    if type(backup) ~= "table" or type(backup.settings) ~= "table" then
        ns:Print("No import backup is available.")
        return
    end
    if not EllesmereUI.ShowConfirmPopup then return end
    EllesmereUI:ShowConfirmPopup({
        title = "Restore Pre-Import Settings?",
        message = "This restores the global settings saved immediately before the last import. A reload is required.",
        confirmText = "Restore & Reload",
        cancelText = "Cancel",
        onConfirm = function()
            if feature:RestoreBackup() then ReloadUI() end
        end,
    })
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y, h = yOffset
    _, h = W:SectionHeader(parent, "GLOBAL SETTINGS", y)
    y = y - h
    _, h = W:DualRow(parent, y,
        { type = "button", text = "Export Global Settings", buttonText = "Export", onClick = function() feature:ShowExport() end },
        { type = "button", text = "Import Global Settings", buttonText = "Import", onClick = function() feature:ShowImport() end })
    y = y - h
    _, h = W:DualRow(parent, y,
        { type = "button", text = "Restore Last Import Backup", buttonText = "Restore", onClick = function() feature:ShowRestore() end },
        { type = "label", text = "Excludes character data, inventory caches, and device layouts." })
    y = y - h
    return math.abs(y)
end
