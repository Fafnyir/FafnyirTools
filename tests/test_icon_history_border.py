"""Icon History has its own persistent Pixels border toggle."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};hooks={};created={};rows={}
function GetBuildInfo() return '', '', '', 120100 end
function CreateFrame()
  local f={shown=true,level=2,scripts={}}
  function f:SetAllPoints() self.allPoints=true end
  function f:SetFrameLevel(v) self.level=v end
  function f:GetFrameLevel() return self.level end
  function f:SetShown(v) self.shown=v end
  function f:Show() self.shown=true end
  function f:Hide() self.shown=false end
  function f:IsShown() return self.shown end
  function f:HookScript(k,fn) self.scripts[k]=fn end
  function f:RegisterEvent() end
  function f:SetScript() end
  created[#created+1]=f
  return f
end
function hooksecurefunc(t,k,fn) hooks[k]=fn end
icon1=CreateFrame();icon2=CreateFrame();icon2.shown=false
strip={}
function strip:GetChildren() return icon1,icon2 end
EllesmereUIDMIconStrip=strip
EllesmereUI={Widgets={},_ModuleNS={EllesmereUIDamageMeters={
  ApplySpellHistory=function() end,ApplyIconBorder=function() end}}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI.BorderPx(_,size) return size end
function EllesmereUI.GetBorderDefaultSize(_,texture) return texture=='pixels' and 2 or 1 end
function EllesmereUI.GetBorderStyleSelectDefaults(texture)
  if texture=='solid' then return {r=0,g=0,b=0},false end
  return {r=.57,g=.57,b=.57},false
end
function EllesmereUI.GetBorderTextureDropdown()
  return {solid='Solid',pixels='Pixels',blizz='Blizzard'},{'solid','pixels','blizz'}
end
function EllesmereUI.ApplyBorderStyle(frame,size,r,g,b,a,texture)
  frame.applied={size=size,r=r,g=g,b=b,a=a,texture=texture};frame:Show()
end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/IconHistoryBorder.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.IconHistoryBorder
f:Initialize()
assert(hooks.ApplySpellHistory and hooks.ApplyIconBorder)
hooks.ApplySpellHistory()
assert(icon1._fafnyirHistoryBorder==nil)
f:BuildOptions({},0)
assert(rows[1].text=='Enable Icon Border' and rows[1].getValue()==false)
assert(rows[2].text=='Border Style' and rows[2].getValue()=='pixels')
assert(rows[2].values.blizz=='Blizzard' and rows[2].disabled())
rows[1].setValue(true)
assert(icon1._fafnyirHistoryBorder.applied.texture=='pixels')
assert(icon1._fafnyirHistoryBorder.shown==true)
assert(icon2._fafnyirHistoryBorder.shown==false)
rows[2].setValue('blizz')
assert(icon1._fafnyirHistoryBorder.applied.texture=='blizz')
f:Reset()
assert(ns:GetDatabase().iconHistoryBorder.enabled==false)
assert(ns:GetDatabase().iconHistoryBorder.texture=='pixels')
assert(icon1._fafnyirHistoryBorder.shown==false)
''')
print("PASS Icon History border default-off toggle, live style dropdown, rendering, visibility, and reset")
