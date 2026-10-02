"""Right-click self cast avoids action-slot/binding event refresh storms."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};timers={};rows={};combat=false
function GetBuildInfo() return '', '', '', 120100 end
function InCombatLockdown() return combat end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
EllesmereUI={Widgets={}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
local function Button()
  local b={attrs={},registrations=0}
  function b:RegisterForClicks() self.registrations=self.registrations+1 end
  function b:SetAttribute(k,v) self.attrs[k]=v end
  return b
end
EABButton1=Button();EABButton2=Button()
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/RightClickSelfCast.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.RightClickSelfCast
f:Initialize();assert(#timers==2)
for _,fn in ipairs(timers) do fn() end
assert(EABButton1.attrs.type2=='action' and EABButton1.attrs.action2==nil and EABButton1.attrs.unit2=='player')
local timerCount=#timers
f:HandleEvent('ACTIONBAR_SLOT_CHANGED');f:HandleEvent('UPDATE_BINDINGS')
assert(#timers==timerCount)
combat=true;f:Refresh();combat=false;f:HandleEvent('PLAYER_REGEN_ENABLED')
assert(EABButton1.attrs.type2=='action')
f:BuildOptions({},0);assert(rows[1].text=='Enable Right-Click Self Cast')
rows[1].setValue(false)
assert(EABButton1.attrs.type2==nil and EABButton1.attrs.unit2==nil)
rows[1].setValue(true);assert(EABButton1.attrs.type2=='action')
''')

events = (ROOT / "Core/Events.lua").read_text()
assert 'RegisterEvent("ACTIONBAR_SLOT_CHANGED")' not in events
assert 'RegisterEvent("UPDATE_BINDINGS")' not in events
print("PASS right-click self cast without action-slot/binding refresh storms")
