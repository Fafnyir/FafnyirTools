local ADDON_NAME, ns = ...
local feature = {
    key="Inventory", page="Bags & Inventory",
    searchTerms={"bags","inventory","bank","warband","items","gold","mail","auctions","guild","currencies"},
}
ns:RegisterFeature(feature.key, feature)

local function DB() return ns:GetDatabase().inventory end
local function Key()
    return (UnitName("player") or "Unknown").."-"..((GetNormalizedRealmName and GetNormalizedRealmName()) or GetRealmName() or "Unknown")
end
local function Char()
    local d=DB(); local k=Key()
    d.characters[k]=d.characters[k] or {name=UnitName("player"),realm=GetRealmName(),money=0,bags={},bank={},currencies={},updated=0}
    local c=d.characters[k]
    c.name=UnitName("player") or c.name
    c.realm=GetRealmName() or c.realm
    c.class=select(2,UnitClass("player")) or c.class
    return c,k
end
local function Add(t,id,n) if id and n and n>0 then t[id]=(t[id] or 0)+n end end

function feature:ScanBags()
    local c=Char(); wipe(c.bags)
    for bag=0,(NUM_BAG_SLOTS or 4) do
        for slot=1,(C_Container.GetContainerNumSlots(bag) or 0) do
            local i=C_Container.GetContainerItemInfo(bag,slot)
            if i then Add(c.bags,i.itemID,i.stackCount or 1) end
        end
    end
    c.money=GetMoney() or 0; c.updated=time()
end

function feature:ScanBank()
    if not BankFrame or not BankFrame:IsShown() then return end
    local c=Char(); wipe(c.bank)
    local bag=BANK_CONTAINER or -1
    for slot=1,(C_Container.GetContainerNumSlots(bag) or 0) do
        local i=C_Container.GetContainerItemInfo(bag,slot)
        if i then Add(c.bank,i.itemID,i.stackCount or 1) end
    end
    local first=(NUM_BAG_SLOTS or 4)+1
    for b=first,first+(NUM_BANKBAGSLOTS or 7)-1 do
        for slot=1,(C_Container.GetContainerNumSlots(b) or 0) do
            local i=C_Container.GetContainerItemInfo(b,slot)
            if i then Add(c.bank,i.itemID,i.stackCount or 1) end
        end
    end
    c.updated=time()
end

function feature:ScanCurrencies()
    if not C_CurrencyInfo or not C_CurrencyInfo.GetCurrencyListSize then return end
    local c=Char(); wipe(c.currencies)
    for x=1,C_CurrencyInfo.GetCurrencyListSize() do
        local i=C_CurrencyInfo.GetCurrencyListInfo(x)
        if i and not i.isHeader and i.currencyTypesID then
            c.currencies[i.currencyTypesID]={quantity=i.quantity or 0,name=i.name,iconFileID=i.iconFileID,isAccountWide=i.isAccountWide}
        end
    end
end

function feature:GetItemLocations(id)
    local d=DB(); local r={}; local total=0
    for k,c in pairs(d.characters) do
        local bags=(c.bags and c.bags[id]) or 0
        local bank=(c.bank and c.bank[id]) or 0
        local mail=(d.mail[k] and d.mail[k][id]) or 0
        local auctions=(d.auctions[k] and d.auctions[k][id]) or 0
        local n=bags+bank+mail+auctions
        if n>0 then r[#r+1]={label=c.name or k,class=c.class,bags=bags,bank=bank,mail=mail,auctions=auctions,total=n}; total=total+n end
    end
    local w=(d.warband.items and d.warband.items[id]) or 0
    if w>0 then r[#r+1]={label="Warband Bank",warband=w,total=w}; total=total+w end
    for name,g in pairs(d.guilds) do
        local n=(g.items and g.items[id]) or 0
        if n>0 then r[#r+1]={label=name,guild=n,total=n}; total=total+n end
    end
    table.sort(r,function(a,b) return a.label<b.label end)
    return r,total
end
function feature:GetTotalGold()
    local n=0; for _,c in pairs(DB().characters) do n=n+(c.money or 0) end; return n
end
function feature:Refresh() self:ScanBags(); self:ScanCurrencies() end
function feature:Initialize() self:Refresh() end
function feature:HandleEvent(e)
    if e=="BAG_UPDATE_DELAYED" or e=="PLAYER_MONEY" or e=="PLAYER_ENTERING_WORLD" then self:ScanBags()
    elseif e=="BANKFRAME_OPENED" or e=="PLAYERBANKSLOTS_CHANGED" then C_Timer.After(0,function() feature:ScanBank() end)
    elseif e=="CURRENCY_DISPLAY_UPDATE" then self:ScanCurrencies() end
end
