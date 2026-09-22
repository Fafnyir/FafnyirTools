"""Blizzard Bar Art survives runtime bar-state changes and artwork replacement."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};queue={};frames={};rows={}
function flush()
 local q=queue;queue={}
 for _,fn in ipairs(q) do fn() end
end
function flushAll()
 local guard=0
 while #queue>0 do guard=guard+1;assert(guard<20,'timer loop');flush() end
end
C_Timer={After=function(_,fn) queue[#queue+1]=fn end}
UIParent={GetEffectiveScale=function() return 1 end}
EllesmereUI={Widgets={}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right)
 rows[#rows+1]=left;rows[#rows+1]=right;return {},40
end
function newFrame(name,w,h)
 local f={name=name,w=w or 100,h=h or 40,scale=1,shown=true,alpha=1,events={},scripts={},points={}}
 function f:GetParent() return self.parent end
 function f:SetParent(v) self.parent=v end
 function f:GetWidth() return self.w end
 function f:GetHeight() return self.h end
 function f:SetSize(a,b) self.w=a;self.h=b end
 function f:GetScale() return self.scale end
 function f:SetScale(v) self.scale=v end
 function f:GetEffectiveScale() return self.scale end
 function f:GetNumPoints() return #self.points end
 function f:GetPoint(i) return unpack(self.points[i]) end
 function f:ClearAllPoints() self.points={} end
 function f:SetPoint(...) self.points={{...}} end
 function f:SetFrameStrata(v) self.strata=v end
 function f:SetFrameLevel(v) self.level=v end
 function f:EnableMouse(v) self.mouse=v end
 function f:SetAlpha(v) self.alpha=v end
 function f:Show() self.shown=true end
 function f:Hide() self.shown=false;if self.scripts.OnHide then self.scripts.OnHide(self) end end
 function f:HookScript(k,fn) self.scripts[k]=fn end
 function f:RegisterEvent(e) self.events[e]=true end
 function f:SetScript(k,fn) self.scripts[k]=fn end
 frames[#frames+1]=f;return f
end
function CreateFrame(_,name,parent)
 local f=newFrame(name);f.parent=parent
 if name then _G[name]=f end
 return f
end
function hooksecurefunc(obj,key,hook)
 local old=obj[key]
 obj[key]=function(self,...)
  local out={old(self,...)};hook(self,...);return unpack(out)
 end
end
EABBar_MainBar=newFrame('target',540,45)
EABButton1=newFrame('button',45,45)
MainActionBar=newFrame('source',540,45)
MainActionBar.BorderArt=newFrame('border',600,80)
MainActionBar.EndCaps=newFrame('caps',650,100)
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/BlizzardBarArt.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.BlizzardBarArt
f:Initialize();eventFrame=frames[#frames];flushAll()
local holder=FafnyirToolsBlizzardBarArt
local oldBorder=MainActionBar.BorderArt
assert(holder.shown and oldBorder.parent==holder and oldBorder.shown and oldBorder.alpha==1)
assert(math.abs(oldBorder.w-636)<0.001) -- 600 * default 1.06 calibration

-- Calibration is adjustable per installation without editing Lua.
f:BuildOptions({},0)
assert(rows[1].text=='Enable Blizzard Bar Art' and rows[2].text=='Art Scale')
assert(rows[2].min==1.00 and rows[2].max==1.10 and rows[2].step==0.01)
rows[2].setValue(1.01);flushAll()
assert(rows[2].getValue()==1.01 and math.abs(oldBorder.w-606)<0.001)

-- A Blizzard/EllesmereUI hide or alpha reset is repaired without a reload.
oldBorder:Hide();flushAll();assert(oldBorder.shown and oldBorder.parent==holder)
oldBorder:SetAlpha(0);flushAll();assert(oldBorder.alpha==1)

-- Runtime transitions reacquire replacement artwork instead of using stale refs.
local replacement=newFrame('replacement',610,82)
MainActionBar.BorderArt=replacement
assert(eventFrame.events.ACTIONBAR_PAGE_CHANGED)
assert(eventFrame.events.UPDATE_VEHICLE_ACTIONBAR)
assert(eventFrame.events.UPDATE_OVERRIDE_ACTIONBAR)
assert(eventFrame.events.PLAYER_SPECIALIZATION_CHANGED)
assert(eventFrame.events.EDIT_MODE_LAYOUTS_UPDATED)
eventFrame.scripts.OnEvent(eventFrame,'ACTIONBAR_PAGE_CHANGED');flushAll()
assert(replacement.parent==holder and replacement.shown and replacement.alpha==1)

-- Turning the option off still wins over the self-healing hooks.
ns:GetDatabase().blizzardBarArt.enabled=false
f:Refresh();flushAll();assert(not holder.shown)
replacement:Hide();flushAll();assert(not holder.shown and not replacement.shown)
''')
print("PASS bar art self-heals after hides, alpha resets, transitions, and artwork replacement")
