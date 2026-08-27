local ADDON_NAME, ns = ...
local feature=ns.modules.Inventory
if not feature then return end
local function DB() return ns:GetDatabase().inventory end
local function Money(c)
    c=c or 0
    return string.format("%dg %ds %dc",math.floor(c/10000),math.floor((c%10000)/100),c%100)
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
    _,h=W:SectionHeader(parent,"SEARCH",y); y=y-h
    _,h=W:DualRow(parent,y,
        {type="label",text="Search index foundation is enabled; full search UI follows."},
        {type="button",text="Refresh Current Character",buttonText="Refresh",onClick=function() feature:Refresh(); if EllesmereUI.RefreshPage then EllesmereUI:RefreshPage(true) end end})
    y=y-h
    return math.abs(y)
end
