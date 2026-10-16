local ADDON_NAME, ns = ...
local function T(key, ...) return ns.Text and ns:Text(key, ...) or key end
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
            title = T("BAGS_INVENTORY.REMOVE_CACHED_CHARACTER"),
            message = "Remove "..label.." and its cached bags, bank, mail, auctions, currencies, and gold totals?",
            confirmText = T("BAGS_INVENTORY.REMOVE"),
            cancelText = T("BAGS_INVENTORY.CANCEL"),
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
            title = T("BAGS_INVENTORY.RESET_ALL_TRACKED_CHARACTERS"),
            message = T("BAGS_INVENTORY.CLEAR_EVERY_CHARACTER_S_CACHED_BAGS_BANK_MAIL_AUCTIONS_"),
            confirmText = T("BAGS_INVENTORY.RESET_ALL"),
            cancelText = T("BAGS_INVENTORY.CANCEL"),
            onConfirm = action,
        })
    else
        action()
    end
end
function feature:BuildOptions(parent,yOffset)
    local W=EllesmereUI.Widgets; local y=yOffset; local h
    parent._showRowDivider=true
    _,h=W:SectionHeader(parent,T("BAGS_INVENTORY.BAGS_INVENTORY"),y); y=y-h
    _,h=W:DualRow(parent,y,
        {type="toggle",text=T("BAGS_INVENTORY.ENABLE_INVENTORY_TRACKING"),getValue=function() return DB().enabled end,setValue=function(v) DB().enabled=v; if v then feature:Refresh() end end},
        {type="toggle",text=T("BAGS_INVENTORY.SHOW_ITEM_LOCATIONS_IN_TOOLTIPS"),getValue=function() return DB().tooltips end,setValue=function(v) DB().tooltips=v end})
    y=y-h
    _,h=W:SectionHeader(parent,T("BAGS_INVENTORY.ACCOUNT_SUMMARY"),y); y=y-h
    local chars=0; for _ in pairs(DB().characters) do chars=chars+1 end
    _,h=W:DualRow(parent,y,
        {type="label",text=T("BAGS_INVENTORY.CHARACTERS_CACHED").." "..chars},
        {type="label",text=T("BAGS_INVENTORY.TOTAL_GOLD").." "..Money(feature:GetTotalGold())}); y=y-h
    _,h=W:SectionHeader(parent,T("BAGS_INVENTORY.CHARACTER_CACHE"),y); y=y-h
    local characterValues, characterOrder = CharacterChoices()
    local selectedCharacter = characterOrder[1]
    _,h=W:DualRow(parent,y,
        {type="dropdown",text=T("BAGS_INVENTORY.CACHED_CHARACTER"),values=characterValues,order=characterOrder,
         disabled=function() return #characterOrder==0 end,
         disabledTooltip="No other cached characters are available.",
         getValue=function() return selectedCharacter end,
         setValue=function(v) selectedCharacter=v end},
        {type="button",text=T("BAGS_INVENTORY.REMOVE_CHARACTER"),buttonText=T("BAGS_INVENTORY.REMOVE"),
         disabled=function() return selectedCharacter==nil end,
         onClick=function() if selectedCharacter then ConfirmRemove(selectedCharacter,characterValues[selectedCharacter] or selectedCharacter) end end})
    y=y-h
    _,h=W:DualRow(parent,y,
        {type="button",text=T("BAGS_INVENTORY.RESET_ALL_CHARACTERS"),buttonText=T("BAGS_INVENTORY.RESET_ALL"),onClick=ConfirmResetAll},
        {type="label",text=T("BAGS_INVENTORY.THE_LOGGED_IN_CHARACTER_IS_EXCLUDED_FROM_INDIVIDUAL_REM")})
    y=y-h
    _,h=W:SectionHeader(parent,T("BAGS_INVENTORY.SEARCH"),y); y=y-h
    _,h=W:DualRow(parent,y,
        {type="label",text=T("BAGS_INVENTORY.SEARCH_INDEX_FOUNDATION_IS_ENABLED_FULL_SEARCH_UI_FOLLO")},
        {type="button",text=T("BAGS_INVENTORY.REFRESH_CURRENT_CHARACTER"),buttonText=T("BAGS_INVENTORY.REFRESH"),onClick=function() feature:Refresh(); RefreshOptions() end})
    y=y-h
    return math.abs(y)
end
