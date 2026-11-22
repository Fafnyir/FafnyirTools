"""Naowh Forever icon borders are gated, default off, and target supported bars."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={}; SlashCmdList={}; timers={}; rows={}; borders={}; hooks={}; ctrlDown=false
function GetBuildInfo() return '', '', '', 16001 end
C_AddOns={IsAddOnLoaded=function(name) return name=='EllesmereUI' or name=='NaowhForever' or name=='NaowhForever_Combat' end}
function InCombatLockdown() return false end
function IsControlKeyDown() return ctrlDown end
function hooksecurefunc(store,key,fn) hooks[#hooks+1]={store=store,key=key,fn=fn} end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}

local function Frame(parent)
  local f={shown=true,level=2,children={},scripts={}}
  if parent then parent.children[#parent.children+1]=f end
  function f:GetChildren() return unpack(self.children) end
  function f:IsShown() return self.shown end
  function f:SetShown(v) self.shown=v end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:SetAllPoints() self.allPoints=true end
  function f:SetFrameLevel(v) self.level=v end
  function f:GetFrameLevel() return self.level end
  function f:HookScript(k,fn) self.scripts[k]=fn end
  function f:RegisterEvent(event) self.events=self.events or {};self.events[event]=true end
  function f:SetScript(k,fn) self.scripts[k]=fn end
  function f:GetScript(k) return self.scripts[k] end
  function f:RegisterForClicks(...) self.registeredClicks={...} end
  function f:SetAttribute(k,v) self.attributes=self.attributes or {};self.attributes[k]=v end
  function f:GetAttribute(k) return self.attributes and self.attributes[k] end
  return f
end
UIParent=Frame()
function CreateFrame(_,_,parent)
  local f=Frame(parent)
  f.isFafnyirBorder=true
  borders[#borders+1]=f
  return f
end
local function Icon(parent,field)
  local f=Frame(parent); f[field or 'icon']={}; return f
end

NaowhForever={QoLSettings={Set=function() end,Get=function(key) return key=='enabled' or key=='fishingKey' end},Blessings={Settings={Set=function() end}},
  AuraBuffs={Settings={Set=function() end},CampBag={Sync=function() end}}}
NaowhForever.FishingData={SPELLS={[7620]=1,[7731]=2,[7732]=3,[18248]=4}}
C_SpellBook={IsSpellKnown=function(id) return id==7620 or id==18248 end}
NaowhForeverFoodBarFood=Frame(); NaowhForeverFoodBarDrink=Frame()
NaowhForeverConsumableBar=Frame(); consumable=Icon(NaowhForeverConsumableBar)
NaowhForeverGearBar=Frame(); gear=Icon(NaowhForeverGearBar)
NaowhForeverTrinkets=Frame(); trinket=Icon(NaowhForeverTrinkets)
NaowhForeverBlessingBar=Frame(); blessing=Icon(NaowhForeverBlessingBar)
NaowhForeverGearReminders=Frame()
fishingReminder=Frame(NaowhForeverGearReminders); fishingReminder.texture={}; fishingReminder.slot=16
fishingReminder:SetScript('OnMouseUp',function() dismissed=(dismissed or 0)+1 end)
otherReminder=Frame(NaowhForeverGearReminders); otherReminder.texture={}; otherReminder.slot=13
bag=Icon(UIParent,'tex'); bag.cooldown={}; bag.count={}
function bag:GetAttribute(key) if key=='item1' then return 'item:211527' end end

EllesmereUI={Widgets={}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI.BorderPxStep(px,texture) assert(px==24 and texture=='pixels');return 3 end
function EllesmereUI.GetBorderDefaultSize(context,texture) assert(context=='naowh_forever_icon');return texture=='blizz' and 4 or 1 end
function EllesmereUI.GetBorderStyleSelectDefaults() return {r=.5,g=.6,b=.7},false end
function EllesmereUI.GetBorderTextureDropdown() return {pixels='Pixels',blizz='Blizzard'},{'pixels','blizz'} end
function EllesmereUI.BorderPx(_,size) return size end
function EllesmereUI.ApplyBorderStyle(frame,size,r,g,b,a,texture,_,_,_,_,context,_,_,exactPixels)
  frame.applied={size=size,r=r,g=g,b=b,a=a,texture=texture,context=context,exactPixels=exactPixels}
end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/NaowhForeverIconBorders.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.NaowhForeverIconBorders
assert(f and ns:GetDatabase().naowhForeverIconBorders.enabled==false)
f:Refresh(); assert(#borders==1 and borders[1].applied==nil) -- module event frame only
f:BuildOptions({},0)
assert(rows[1].text=='Enable Naowh Forever Icon Borders')
assert(rows[2].text=='Border Style' and rows[2].getValue()=='pixels' and rows[2].disabled())
assert(rows[2].values.blizz=='Blizzard')
assert(rows[3].text=='Clickable Fishing Pole Reminder' and rows[3].getValue()==false and not rows[3].disabled())
rows[1].setValue(true)
assert(#borders==9,#borders) -- seven supported icons + the fishing reminder + module event frame
assert(fishingReminder.children[1] and fishingReminder.children[1].isFafnyirBorder)
assert(#otherReminder.children==0)
for _,border in ipairs(borders) do
  if border.applied then
    assert(border.applied.texture=='pixels' and border.applied.size==3)
    assert(border.applied.context=='naowh_forever_icon' and border.applied.exactPixels==24)
  end
end
assert(#hooks==4)
rows[3].setValue(true)
assert(ns:GetDatabase().naowhForeverIconBorders.clickableFishingPole==true)
assert(#borders==10,#borders)
local click=fishingReminder._fafnyirFishingClick
assert(click and click.attributes.type1=='spell' and click.attributes.spell1==18248)
assert(click.attributes['*type1']==nil and click.attributes['*clickbutton1']==nil)
assert(click.attributes['ctrl-type1']=='')
assert(click.attributes.useOnKeyDown==true)
assert(click.registeredClicks[1]=='AnyDown' and click.registeredClicks[2]=='AnyUp')
ctrlDown=true;click.scripts.PostClick(click,'LeftButton',true);assert(dismissed==nil)
click.scripts.PostClick(click,'LeftButton',false);ctrlDown=false
assert(dismissed==1)
rows[2].setValue('blizz')
for _,border in ipairs(borders) do
  if border.applied then
    assert(border.applied.texture=='blizz' and border.applied.size==4)
    assert(border.applied.exactPixels==nil)
  end
end
rows[1].setValue(false)
for _,border in ipairs(borders) do if border.applied then assert(border.shown==false) end end
f:Reset(); assert(ns:GetDatabase().naowhForeverIconBorders.enabled==false)
assert(ns:GetDatabase().naowhForeverIconBorders.texture=='pixels')
assert(ns:GetDatabase().naowhForeverIconBorders.clickableFishingPole==false)
''')
print("PASS Naowh Forever icon borders gate, targets, Pixels rendering, hooks, toggle, and reset")
