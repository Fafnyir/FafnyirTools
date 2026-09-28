"""Icon History inherits EllesmereUI Damage Meters' custom icon border."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};hooks={};created={}
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
_EDM_DB={profile={dm={customIconBorder=true,iconBorderSize=2,
  iconBorderTexture='pixels',iconBorderR=.57,iconBorderG=.57,iconBorderB=.57,iconBorderA=1}}}
EllesmereUI={_ModuleNS={EllesmereUIDamageMeters={
  ApplySpellHistory=function() end,ApplyIconBorder=function() end}}}
function EllesmereUI.BorderPx(_,size) return size end
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
assert(icon1._fafnyirHistoryBorder.applied.texture=='pixels')
assert(icon1._fafnyirHistoryBorder.shown==true)
assert(icon2._fafnyirHistoryBorder.shown==false)
_EDM_DB.profile.dm.customIconBorder=false
hooks.ApplyIconBorder()
assert(icon1._fafnyirHistoryBorder.shown==false)
''')
print("PASS Icon History inherits Pixels border and visibility from Damage Meters")
