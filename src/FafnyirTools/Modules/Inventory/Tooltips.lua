local ADDON_NAME, ns = ...
local feature=ns.modules.Inventory
if not feature then return end
local function DB() return ns:GetDatabase().inventory end
local function Hook(tip,data)
    if not DB().enabled or not DB().tooltips or not data or not data.id then return end
    if issecretvalue and issecretvalue(data.id) then return end
    local loc,total=feature:GetItemLocations(data.id)
    if total<=0 then return end
    tip:AddLine(" ")
    for _,v in ipairs(loc) do
        local p={}
        if (v.bags or 0)>0 then p[#p+1]="Bags: "..v.bags end
        if (v.bank or 0)>0 then p[#p+1]="Bank: "..v.bank end
        if (v.mail or 0)>0 then p[#p+1]="Mail: "..v.mail end
        if (v.auctions or 0)>0 then p[#p+1]="Auctions: "..v.auctions end
        if (v.warband or 0)>0 then p[#p+1]=tostring(v.warband) end
        if (v.guild or 0)>0 then p[#p+1]=tostring(v.guild) end
        local r,g,b=1,1,1
        if v.class and RAID_CLASS_COLORS and RAID_CLASS_COLORS[v.class] then
            local color=RAID_CLASS_COLORS[v.class]
            r,g,b=color.r,color.g,color.b
        end
        tip:AddDoubleLine(v.label,table.concat(p,"  "),r,g,b,0.75,0.85,1)
    end
    tip:AddDoubleLine("Total",tostring(total),1,0.82,0,1,0.82,0)
end
if TooltipDataProcessor and Enum.TooltipDataType then TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item,Hook) end
