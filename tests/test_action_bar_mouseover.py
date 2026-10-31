#!/usr/bin/env python3
"""Verify reversible standalone mouseover opacity for Blizzard action bars."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};FafnyirToolsDB={};timers={}
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70000","",120105 end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
function Region()
    local r={alpha=1,hovered=false,scripts={}}
    function r:SetAlpha(value) self.alpha=value end
    function r:IsMouseOver() return self.hovered end
    function r:HookScript(name,fn) self.scripts[name]=fn end
    return r
end
MainActionBar=Region()
for i=1,12 do _G["ActionButton"..i]=Region() end
MultiBarBottomLeft=Region()
for i=1,12 do _G["MultiBarBottomLeftButton"..i]=Region() end
''')
ns = lua.globals().ns
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Modules/ActionBarMouseover.lua").read_text(), "FafnyirTools", ns)

lua.execute(r'''
assert(ns.modules.ActionBarMouseover)
assert(FafnyirToolsDB.actionBarMouseover.enabled==false)
assert(FafnyirToolsDB.actionBarMouseover.fadedOpacity==0)
assert(FafnyirToolsDB.actionBarMouseover.bars.main==true)
assert(FafnyirToolsDB.actionBarMouseover.bars.bar8==true)
assert(FafnyirToolsDB.actionBarMouseover.bars.pet==true)
ns.modules.ActionBarMouseover:Initialize()
assert(MainActionBar.alpha==1 and MultiBarBottomLeft.alpha==1)

FafnyirToolsDB.actionBarMouseover.enabled=true
FafnyirToolsDB.actionBarMouseover.fadedOpacity=0.2
ns.modules.ActionBarMouseover:Refresh()
assert(MainActionBar.alpha==0.2 and MultiBarBottomLeft.alpha==0.2)
FafnyirToolsDB.actionBarMouseover.bars.bar2=false
ns.modules.ActionBarMouseover:Refresh()
assert(MainActionBar.alpha==0.2 and MultiBarBottomLeft.alpha==1)
FafnyirToolsDB.actionBarMouseover.bars.bar2=true
ns.modules.ActionBarMouseover:Refresh()

ActionButton1.hovered=true
ActionButton1.scripts.OnEnter(ActionButton1)
assert(MainActionBar.alpha==1 and MultiBarBottomLeft.alpha==0.2)
ActionButton1.hovered=false
ActionButton1.scripts.OnLeave(ActionButton1)
timers[#timers]()
assert(MainActionBar.alpha==0.2)

FafnyirToolsDB.actionBarMouseover.enabled=false
ns.modules.ActionBarMouseover:Refresh()
assert(MainActionBar.alpha==1 and MultiBarBottomLeft.alpha==1)
''')

source = (ADDON / "Modules/ActionBarMouseover.lua").read_text()
assert "if ns.HAS_ELLESMEREUI then return end" in source
for frame in ("MainActionBar", "MainMenuBar", "MultiBarBottomLeft", "MultiBar7", "PetActionBar", "StanceBar"):
    assert frame in source
assert "SetAttribute" not in source
assert "RegisterForClicks" not in source
assert "InCombatLockdown" not in source
assert 'message = T("ACTION_BARS.MOUSEOVER_ENABLE_RELOAD")' in source
assert "reload = true" in source
for key in ("main", "bar2", "bar3", "bar4", "bar5", "bar6", "bar7", "bar8", "pet", "stance"):
    assert f'BarToggle("{key}"' in source

schema = (ADDON / "Modules/GlobalSettings.lua").read_text()
assert "actionBarMouseover = {" in schema
assert "fadedOpacity = true" in schema
assert "bar8 = true, pet = true, stance = true" in schema

print("PASS standalone Blizzard action-bar mouseover opacity, hover, restore and ownership")
