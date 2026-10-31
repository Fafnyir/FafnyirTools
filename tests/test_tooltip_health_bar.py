#!/usr/bin/env python3
"""Verify standalone ownership and reversible default-tooltip health-bar hiding."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};FafnyirToolsDB={}
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70000","",120105 end
GameTooltipStatusBar={shown=true,alpha=1,hooks={}}
function GameTooltipStatusBar:SetAlpha(value) self.alpha=value end
function GameTooltipStatusBar:Show()
    self.shown=true
    if self.hooks.Show then self.hooks.Show(self) end
end
function hooksecurefunc(object,method,fn) object.hooks[method]=fn end
''')
ns = lua.globals().ns
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Modules/TooltipHealthBar.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
assert(ns.modules.TooltipHealthBar)
assert(FafnyirToolsDB.tooltipHealthBar.hidden==false)
ns.modules.TooltipHealthBar:Initialize()
assert(GameTooltipStatusBar.alpha==1)
FafnyirToolsDB.tooltipHealthBar.hidden=true
ns.modules.TooltipHealthBar:Refresh()
assert(GameTooltipStatusBar.alpha==0 and GameTooltipStatusBar.shown==true)
GameTooltipStatusBar.alpha=1
GameTooltipStatusBar:Show()
assert(GameTooltipStatusBar.alpha==0)
FafnyirToolsDB.tooltipHealthBar.hidden=false
ns.modules.TooltipHealthBar:Refresh()
assert(GameTooltipStatusBar.alpha==1)
''')

source = (ADDON / "Modules/TooltipHealthBar.lua").read_text()
assert "if ns.HAS_ELLESMEREUI then return end" in source
assert "GameTooltipStatusBar" in source
assert 'hooksecurefunc(bar, "Show"' in source
assert "bar:SetAlpha(DB().hidden and 0 or 1)" in source
assert "TooltipDataProcessor" not in source

schema = (ADDON / "Modules/GlobalSettings.lua").read_text()
assert "tooltipHealthBar = { hidden = true }" in schema

print("PASS standalone default-tooltip health bar hide/show restoration and ownership")
