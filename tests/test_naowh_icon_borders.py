"""Naowh Forever icon borders are gated, default off, and target supported bars."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={}; SlashCmdList={}; timers={}; rows={}; borders={}; hooks={}
function GetBuildInfo() return '', '', '', 16001 end
C_AddOns={IsAddOnLoaded=function(name) return name=='EllesmereUI' or name=='NaowhForever' or name=='NaowhForever_Combat' end}
function InCombatLockdown() return false end
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

NaowhForever={QoLSettings={Set=function() end},Blessings={Settings={Set=function() end}},
  AuraBuffs={Settings={Set=function() end},CampBag={Sync=function() end}}}
NaowhForeverFoodBarFood=Frame(); NaowhForeverFoodBarDrink=Frame()
NaowhForeverConsumableBar=Frame(); consumable=Icon(NaowhForeverConsumableBar)
NaowhForeverGearBar=Frame(); gear=Icon(NaowhForeverGearBar)
NaowhForeverTrinkets=Frame(); trinket=Icon(NaowhForeverTrinkets)
NaowhForeverBlessingBar=Frame(); blessing=Icon(NaowhForeverBlessingBar)
bag=Icon(UIParent,'tex'); bag.cooldown={}; bag.count={}
function bag:GetAttribute(key) if key=='item1' then return 'item:211527' end end

EllesmereUI={Widgets={}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI.BorderPxStep(px,texture) assert(px==24 and texture=='pixels');return 3 end
function EllesmereUI.GetBorderStyleSelectDefaults() return {r=.5,g=.6,b=.7},false end
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
f:Refresh(); assert(#borders==0)
f:BuildOptions({},0)
assert(rows[1].text=='Enable Naowh Forever Icon Borders')
rows[1].setValue(true)
assert(#borders==7,#borders)
for _,border in ipairs(borders) do
  assert(border.applied.texture=='pixels' and border.applied.size==3)
  assert(border.applied.context=='naowh_forever_icon' and border.applied.exactPixels==24)
end
assert(#hooks==4)
rows[1].setValue(false)
for _,border in ipairs(borders) do assert(border.shown==false) end
f:Reset(); assert(ns:GetDatabase().naowhForeverIconBorders.enabled==false)
''')
print("PASS Naowh Forever icon borders gate, targets, Pixels rendering, hooks, toggle, and reset")
