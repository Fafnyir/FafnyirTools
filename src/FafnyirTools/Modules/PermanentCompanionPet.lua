local ADDON_NAME, ns = ...

local feature = {
    key = "PermanentCompanionPet",
    page = "QoL",
    searchTerms = {
        "companion pet",
        "battle pet",
        "permanent pet",
        "random favorite pet",
    },
}
ns:RegisterFeature(feature.key, feature)

local checkPending = false
local lastCheck = 0
local lastMissingName

local function DB()
    return ns:GetDatabase().permanentCompanionPet
end

local function CharacterKey()
    local name, realm = UnitFullName("player")
    if not name then name = UnitName("player") or "Unknown" end
    if not realm or realm == "" then realm = GetNormalizedRealmName() or GetRealmName() or "Unknown" end
    return name .. "-" .. realm
end

local function CharacterDB()
    local settings = DB()
    settings.characters = settings.characters or {}

    local key = CharacterKey()
    local character = settings.characters[key]
    if not character then
        -- Preserve the old shared selection for the first character loaded
        -- after upgrading. Every later character starts independently.
        local inheritLegacy = not settings.characterMigrationComplete
        character = {
            mode = inheritLegacy and (settings.mode or "randomFavorite") or "randomFavorite",
            petName = inheritLegacy and (settings.petName or "") or "",
        }
        settings.characters[key] = character
        settings.characterMigrationComplete = true
    end

    return character
end

local function NormalizeName(value)
    value = tostring(value or ""):match("^%s*(.-)%s*$") or ""
    return value:lower()
end

local function SummoningIsBlocked()
    if InCombatLockdown() or UnitAffectingCombat("player") then return true end
    if UnitIsDeadOrGhost("player") then return true end
    if IsMounted() or IsStealthed() then return true end
    if UnitOnTaxi("player") or UnitInVehicle("player") then return true end
    if C_PetBattles and C_PetBattles.IsInBattle and C_PetBattles.IsInBattle() then return true end

    if DB().disableInPvP then
        local inInstance, instanceType = IsInInstance()
        if inInstance and (instanceType == "pvp" or instanceType == "arena") then
            return true
        end
    end

    return false
end

local function FindSpecificPet(wantedName)
    if not C_PetJournal or not C_PetJournal.GetNumPets then return end

    local count = C_PetJournal.GetNumPets() or 0
    for index = 1, count do
        local petID, _, isOwned, customName = C_PetJournal.GetPetInfoByIndex(index)
        if petID and isOwned then
            local _, _, _, _, _, _, _, speciesName = C_PetJournal.GetPetInfoByPetID(petID)
            if NormalizeName(customName) == wantedName or NormalizeName(speciesName) == wantedName then
                return petID
            end
        end
    end
end

local function FindRandomFavoritePet()
    if not C_PetJournal or not C_PetJournal.GetNumPets then return end

    local favorites = {}
    local count = C_PetJournal.GetNumPets() or 0
    for index = 1, count do
        local petID, _, isOwned, _, _, isFavorite = C_PetJournal.GetPetInfoByIndex(index)
        if petID and isOwned and isFavorite then
            favorites[#favorites + 1] = petID
        end
    end

    if #favorites > 0 then
        return favorites[math.random(1, #favorites)]
    end
end

local function CheckCompanionPet()
    checkPending = false

    local settings = DB()
    if not settings.enabled or SummoningIsBlocked() then return end
    if not C_PetJournal or not C_PetJournal.SummonPetByGUID then return end

    local now = GetTime()
    if now - lastCheck < 2 then return end
    lastCheck = now

    local summoned = C_PetJournal.GetSummonedPetGUID and C_PetJournal.GetSummonedPetGUID()
    local petID
    local character = CharacterDB()

    if character.mode == "specific" then
        local wantedName = NormalizeName(character.petName)
        if wantedName == "" then return end

        petID = FindSpecificPet(wantedName)
        if not petID then
            if lastMissingName ~= wantedName then
                lastMissingName = wantedName
                ns:Print("Permanent Companion Pet could not find: " .. tostring(character.petName))
            end
            return
        end

        lastMissingName = nil
        if summoned == petID then return end
    else
        if summoned then return end

        -- Use Blizzard's own random-favorite selector when available so pet
        -- journal search filters do not limit the candidate pool.
        if C_PetJournal.SummonRandomPet then
            pcall(C_PetJournal.SummonRandomPet, true)
            return
        end

        petID = FindRandomFavoritePet()
        if not petID then return end
    end

    pcall(C_PetJournal.SummonPetByGUID, petID)
end

local function QueueCheck(delay)
    if checkPending then return end
    checkPending = true
    C_Timer.After(delay or 0.25, CheckCompanionPet)
end

function feature:Initialize()
    QueueCheck(1)
end

function feature:Refresh()
    lastCheck = 0
    QueueCheck(0)
end

function feature:Reset()
    local defaults = ns.defaults.permanentCompanionPet
    local settings = DB()
    settings.enabled = defaults.enabled
    settings.disableInPvP = defaults.disableInPvP
    local character = CharacterDB()
    character.mode = defaults.mode
    character.petName = defaults.petName
    self:Refresh()
end

function feature:HandleEvent(event, companionType)
    if event == "COMPANION_UPDATE" and companionType and companionType ~= "CRITTER" then
        return
    end

    if event == "PLAYER_STARTED_MOVING"
        or event == "PLAYER_ENTERING_WORLD"
        or event == "ZONE_CHANGED_NEW_AREA"
        or event == "PLAYER_MOUNT_DISPLAY_CHANGED"
        or event == "PLAYER_CONTROL_GAINED"
        or event == "PLAYER_REGEN_ENABLED"
        or event == "PET_JOURNAL_LIST_UPDATE"
        or event == "COMPANION_UPDATE"
    then
        QueueCheck(0.35)
    end
end

function feature:BuildOptions(parent, yOffset)
    local W = EllesmereUI.Widgets
    local y = yOffset
    local h

    parent._showRowDivider = true

    _, h = W:SectionHeader(parent, "PERMANENT COMPANION PET", y)
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "toggle",
            text = "Enable Permanent Companion Pet",
            tooltip = "Keep a companion pet summoned whenever conditions allow.",
            getValue = function() return DB().enabled end,
            setValue = function(value)
                DB().enabled = value
                feature:Refresh()
            end,
        },
        {
            type = "dropdown",
            text = "Pet Choice (This Character)",
            values = {
                randomFavorite = "Random Favorite",
                specific = "Specific Pet",
            },
            order = { "randomFavorite", "specific" },
            getValue = function() return CharacterDB().mode or "randomFavorite" end,
            setValue = function(value)
                CharacterDB().mode = value
                feature:Refresh()
                if EllesmereUI and EllesmereUI.RefreshPage then EllesmereUI:RefreshPage(true) end
            end,
        }
    )
    y = y - h

    _, h = W:DualRow(
        parent,
        y,
        {
            type = "input",
            text = "Specific Pet Name (This Character)",
            inputWidth = 170,
            inputStyle = "popup",
            placeholder = "Species or custom name",
            disabled = function() return CharacterDB().mode ~= "specific" end,
            disabledTooltip = "Set Pet Choice to Specific Pet first.",
            getValue = function() return CharacterDB().petName or "" end,
            setValue = function(value)
                CharacterDB().petName = tostring(value or ""):match("^%s*(.-)%s*$") or ""
                lastMissingName = nil
                feature:Refresh()
            end,
        },
        {
            type = "toggle",
            text = "Disable in PvP Instances",
            tooltip = "Do not summon companion pets in battlegrounds or arenas.",
            getValue = function() return DB().disableInPvP end,
            setValue = function(value)
                DB().disableInPvP = value
                feature:Refresh()
            end,
        }
    )
    y = y - h

    return math.abs(y)
end
