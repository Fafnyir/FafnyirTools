local ADDON_NAME, ns = ...
local feature=ns.modules.Inventory
if not feature then return end
local function DB() return ns:GetDatabase().inventory end
local function Money(c)
    c=c or 0
    return string.format("%dg %ds %dc",math.floor(c/10000),math.floor((c%10000)/100),c%100)
end
local function RefreshOptions()
    if EllesmereUI.RefreshPage then EllesmereUI:RefreshPage(true) end
end
local function CharacterChoices()
    local values, order = {}, {}
    local current = feature:GetCurrentCharacterKey()
    for key, character in pairs(DB().characters) do
        if key ~= current then
            local name = character.name or key
            local realm = character.realm
            values[key] = realm and (name.." - "..realm) or name
            order[#order+1] = key
        end
    end
    table.sort(order, function(a,b) return values[a] < values[b] end)
    return values, order
end
local function ConfirmRemove(key, label)
    if not key then return end
    local action = function()
        feature:RemoveCharacter(key)
        RefreshOptions()
    end
    if EllesmereUI.ShowConfirmPopup then
        EllesmereUI:ShowConfirmPopup({
            title = "Remove Cached Character?",
            message = "Remove "..label.." and its cached bags, bank, mail, auctions, currencies, and gold totals?",
            confirmText = "Remove",
            cancelText = "Cancel",
            onConfirm = action,
        })
    else
        action()
    end
end
local function ConfirmResetAll()
    local action = function()
        feature:ResetAllCharacters()
        RefreshOptions()
    end
    if EllesmereUI.ShowConfirmPopup then
        EllesmereUI:ShowConfirmPopup({
            title = "Reset All Tracked Characters?",
            message = "Clear every character's cached bags, bank, mail, auctions, currencies, and gold totals? The current character will be scanned again immediately when tracking is enabled. Warband and guild caches are kept.",
            confirmText = "Reset All",
            cancelText = "Cancel",
            onConfirm = action,
        })
    else
        action()
    end
end
function feature:BuildOptions(parent,yOffset)
    local W=EllesmereUI.Widgets; local y=yOffset; local h
    parent._showRowDivider=true
    _,h=W:SectionHeader(parent,"BAGS & INVENTORY",y); y=y-h
    _,h=W:DualRow(parent,y,
        {type="toggle",text="Enable Inventory Tracking",getValue=function() return DB().enabled end,setValue=function(v) DB().enabled=v; if v then feature:Refresh() end end},
        {type="toggle",text="Show Item Locations in Tooltips",getValue=function() return DB().tooltips end,setValue=function(v) DB().tooltips=v end})
    y=y-h
    _,h=W:SectionHeader(parent,"ACCOUNT SUMMARY",y); y=y-h
    local chars=0; for _ in pairs(DB().characters) do chars=chars+1 end
    _,h=W:DualRow(parent,y,{type="label",text="Characters Cached: "..chars},{type="label",text="Total Gold: "..Money(feature:GetTotalGold())}); y=y-h
    _,h=W:SectionHeader(parent,"CHARACTER CACHE",y); y=y-h
    local characterValues, characterOrder = CharacterChoices()
    local selectedCharacter = characterOrder[1]
    _,h=W:DualRow(parent,y,
        {type="dropdown",text="Cached Character",values=characterValues,order=characterOrder,
         disabled=function() return #characterOrder==0 end,
         disabledTooltip="No other cached characters are available.",
         getValue=function() return selectedCharacter end,
         setValue=function(v) selectedCharacter=v end},
        {type="button",text="Remove Character",buttonText="Remove",
         disabled=function() return selectedCharacter==nil end,
         onClick=function() if selectedCharacter then ConfirmRemove(selectedCharacter,characterValues[selectedCharacter] or selectedCharacter) end end})
    y=y-h
    _,h=W:DualRow(parent,y,
        {type="button",text="Reset All Characters",buttonText="Reset All",onClick=ConfirmResetAll},
        {type="label",text="The logged-in character is excluded from individual removal."})
    y=y-h
    _,h=W:SectionHeader(parent,"SEARCH",y); y=y-h
    _,h=W:DualRow(parent,y,
        {type="label",text="Search index foundation is enabled; full search UI follows."},
        {type="button",text="Refresh Current Character",buttonText="Refresh",onClick=function() feature:Refresh(); RefreshOptions() end})
    y=y-h
    return math.abs(y)
end
