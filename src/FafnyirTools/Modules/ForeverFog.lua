local ADDON_NAME, ns = ...

local feature = {
    key = "ForeverFog",
    page = "QoL",
    searchTerms = {},
}
ns:RegisterFeature(feature.key, feature)

local function DB()
    return ns:GetDatabase().foreverFog
end

function feature:Initialize()
    -- Blizzard now restores volumeFog immediately after addons change it.
    -- Keep the module and saved data for compatibility, but do not apply the
    -- unsupported CVar or expose a control that cannot persist its choice.
end

function feature:HandleEvent()
end

function feature:Reset()
    local db = DB()
    db.enabled = ns.defaults.foreverFog.enabled
    db.initialized = false
end

function feature:BuildOptions(parent, yOffset)
    return math.abs(yOffset)
end
