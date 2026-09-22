local ADDON_NAME, ns = ...

local feature = {
    key = "About",
    page = "About",
    searchTerms = {"about","version","changelog","credits","patreon","support"},
}

ns:RegisterFeature(feature.key, feature)

local VERSION = "v1.1.4"
local PATREON_URL = "https://www.patreon.com/cw/fafnyir"

local CHANGELOG = {
    { version = "v1.1.4", lines = {
        "Added guarded WoW Forever beta compatibility.",
        "Added a Forever-only Volumetric Fog toggle under QoL.",
        "The fog choice uses the persistent client CVar and does not depend on addon SavedVariables.",
        "Removed Unit Frame Sources, Aura Skins, and Resting; EllesmereUI now owns those options.",
    }},
    { version = "v1.1.3", lines = {
        "Added global settings export and import with validation and rollback backup.",
        "Excluded per-character data, inventory caches, and device-specific layouts from transfers.",
    }},
    { version = "v1.1.2", lines = {
        "Limited Aura Skins controls to Target; EllesmereUI owns Player buffs and debuffs.",
        "Added Pet Frame to selective Unit Frame source controls.",
        "Added Player, Target, Target of Target, Focus, and Boss frame source controls.",
        "Choose EllesmereUI, Blizzard Default, or Hidden; source changes require a reload.",
        "Existing inherited choices display the effective EllesmereUI frame source.",
        "Moved Aura Skins into Unit Frames and grouped action controls under Action Bars.",
        "Restored Blizzard Bar Art and Flyout Fix controls.",
        "Enabled Aura Skins for Blizzard Target frames while other EUI frames remain active.",
        "Target buffs and debuffs wrap after six icons per row.",
        "Restored Permanent Companion Pet with per-character choices under QoL.",
        "Restored completed Quest XP overlay, toggle and color controls.",
        "Preserved legacy Quest XP settings and all existing custom colors.",
        "Consolidated Resting under Unit Frames, with XP & Progression and Layouts pages.",
    }},
    { version = "v1.1.1", lines = {
        "Reorganized options into dedicated Fafnyir Tools categories.",
        "Moved Permanent Companion Pet to the new Fafnyir Tools QoL section.",
    }},
    { version = "v1.1.0", lines = {
        "Updated the default XP gradient to #5563FF through #C561FF.",
        "Updated the default Rested XP color to #4F8FFF at full opacity.",
        "Added a configurable #FF9600 overlay for XP from completed quests in the quest log.",
        "Added Quest XP updates for login, world entry, quest-log changes, and XP changes.",
        "Quest XP automatically hides at maximum level or when no completed quest XP is available.",
    }},
    { version = "v1.0.9", lines = {
        "Added Permanent Companion Pet controls to UI Tweaks.",
        "Permanent Companion Pet idea by Eiya (twitch.tv/eiya).",
        "Based on the original Permanent Companion Pet WeakAura by raine (wago.io/3It1XU72A).",
        "Supports a random favorite pet or a specific species/custom pet name.",
        "Stores pet choice and specific pet name separately for each character.",
        "Avoids summoning while mounted, stealthed, in combat, on a taxi, or in disabled PvP instances.",
    }},
    { version = "v1.0.8", lines = {
        "Added optional Blizzard decorative artwork for EllesmereUI Bar 1.",
        "Added automatic Blizzard bar-art scaling and alignment for custom button sizes.",
        "Added Flyout Fix to match spell flyout button size and border style to its parent action bar.",
        "Added persistent toggles for Blizzard Bar Art and Flyout Fix.",
        "Renamed XP Bar to UI Tweaks and consolidated related visual options there.",
    }},
    { version = "v1.0.7", lines = {
        "Rebuilt Blizzard TargetFrame aura skinning for the WoW 12.1 AuraKit system.",
        "Added independent Target Aura Size control.",
        "Added Target Buff filters: All Buffs, Stealable, Big Defensive, and Dispellable.",
        "Added Target Debuff filters: All Debuffs, Own Only, and Important.",
        "Added Target Buff Filter: All Buffs, Own Only, and Important.",
        "Added a separate Target Aura Size control.",
        "Automatically hides Blizzard target and focus status textures.",
    }},
    { version = "v1.0.6", lines = {
        "Added Device Layout automatic Blizzard Edit Mode layout switching.",
        "Added a per-device default Edit Mode layout.",
        "Added optional per-specialization layout overrides.",
        "Added automatic layout switching when changing specialization.",
        "Retained the Right-Click Self Cast compatibility fix for current EllesmereUI action bars.",
    }},
    { version = "v1.0.5", lines = {
        "Fixed Right-Click Self Cast for current EllesmereUI EABButton action bars.",
        "Added Aura Skins module.",
        "Added skinning for Blizzard player buffs and debuffs.",
        "Added skinning for Blizzard target buffs and debuffs.",
        "Added Target Frame Auras toggle.",
        "Added compatibility lockout when EllesmereUI Unit Frames is enabled.",
        "Fixed target aura skinning for pooled target aura buttons.",
        "Added reload confirmation when Aura Skins is enabled or disabled.",
        "Removed the Fafnyir Tools header from Bags & Inventory item tooltips.",
    }},
    { version = "v1.0.4", lines = {
        "Added class colors to character names in item-location tooltips.",
        "Updated About page credit to Envisioned by Fafnyir.",
    }},
    { version = "v1.0.3", lines = {
        "Added About page.",
        "Added version information.",
        "Added changelog.",
        "Added credits.",
        "Added Patreon support button.",
        "Added Bags & Inventory tracking foundation.",
        "Added bag and bank item caching.",
        "Added account gold summary.",
        "Added currency caching.",
        "Added item-location tooltip counts.",
    }},
    { version = "v1.0.2", lines = {
        "Fixed XP Bar gradient flickering.",
        "Fixed Rested XP gradient restoring to white.",
        "Updated project description.",
    }},
    { version = "v1.0.1", lines = {
        "Added XP Bar Gradient.",
        "Added Rested XP Gradient.",
        "Added gradient direction.",
        "Added color pickers.",
    }},
    { version = "v1.0.0", lines = {
        "Initial release.",
        "Added Resting Indicator.",
        "Added Right-Click Self Cast.",
        "Added native EllesmereUI integration.",
    }},
}

local function AddText(parent, text, y, size, alpha)
    local fs = EllesmereUI.MakeFont(parent, size or 12, nil, 1, 1, 1, alpha or 1)
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", 8, y)
    fs:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -8, y)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(true)
    fs:SetText(text)
    fs:SetHeight(0)
    local height = math.max(22, fs:GetStringHeight() + 4)
    fs:SetHeight(height)
    return height
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "FAFNYIR TOOLS FOR ELLESMEREUI", y)
    y = y - h
    h = AddText(parent, "A collection of enhancements for EllesmereUI.", y - 4, 13, 0.85)
    y = y - h - 10

    _, h = W:SectionHeader(parent, "VERSION", y)
    y = y - h
    _, h = W:DualRow(parent, y,
        { type="label", text=VERSION },
        { type="label", text="" })
    y = y - h

    _, h = W:SectionHeader(parent, "CHANGELOG", y)
    y = y - h
    for _, entry in ipairs(CHANGELOG) do
        h = AddText(parent, entry.version, y - 2, 12, 1)
        y = y - h
        for _, line in ipairs(entry.lines) do
            h = AddText(parent, "• " .. line, y - 1, 11, 0.78)
            y = y - h
        end
        y = y - 8
    end

    _, h = W:SectionHeader(parent, "CREDITS", y)
    y = y - h
    h = AddText(parent, "Envisioned by Fafnyir", y - 2, 12, 1)
    y = y - h
    h = AddText(parent, "Special thanks to Ellesmere, creator of EllesmereUI.", y - 1, 11, 0.78)
    y = y - h - 8

    h = AddText(parent, "Permanent Companion Pet idea by Eiya — twitch.tv/eiya", y - 1, 11, 0.78)
    y = y - h

    h = AddText(parent, "Original Companion Pet WeakAura: raine (wago.io/3It1XU72A).", y - 1, 11, 0.78)
    y = y - h

    _, h = W:SectionHeader(parent, "SUPPORT DEVELOPMENT", y)
    y = y - h
    _, h = W:DualRow(parent, y,
        {
            type="button",
            text="Support on Patreon",
            buttonText="Open Patreon",
            onClick=function()
                if C_Browser and C_Browser.OpenExternalLink then
                    C_Browser.OpenExternalLink(PATREON_URL)
                elseif LaunchURL then
                    LaunchURL(PATREON_URL)
                else
                    ns:Print(PATREON_URL)
                end
            end,
        },
        { type="label", text=PATREON_URL })
    y = y - h

    return math.abs(y)
end
