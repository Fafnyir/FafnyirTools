"""WoW Forever client detection and temporary SavedVariables safety gates."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};prints={};sourceWrites=0;rows={}
function GetBuildInfo() return '1.60.1','69913','Sep 17 2026',16001 end
function print(value) prints[#prints+1]=tostring(value) end
function ReloadUI() error('ReloadUI must remain blocked while SV is unsafe') end
function time() return 123 end
EllesmereUI={FOREVER_SV_BUG=true,Widgets={},_ModuleNS={
 EllesmereUIUnitFrames={
  SetUnitFrameSource=function() sourceWrites=sourceWrites+1 end,
  GetUnitFrameSource=function() return 'eui' end,
 }
}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right)
 rows[#rows+1]=left;rows[#rows+1]=right;return {},40
end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/UnitFrameSources.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/GlobalSettings.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
assert(ns.IS_FOREVER and ns:ForeverSavedVariablesUnsafe())
local sources=ns.modules.UnitFrameSources
assert(sources:ApplySaved() and sourceWrites==0)
sources:BuildOptions({},0)
assert(rows[1].disabled() and rows[1].disabledTooltip:find('Forever beta'))
local before=ns:GetDatabase().xpBar.enabled
local payload={settings={xpBar={enabled=not before}}}
assert(ns.modules.GlobalSettings:ApplyImport(payload)==false)
assert(ns:GetDatabase().xpBar.enabled==before and sourceWrites==0)
assert(#prints>=1 and prints[#prints]:find('not reliably saving'))
''')

resting = (ROOT / "Modules/Resting.lua").read_text()
assert "MAX_LEVEL" not in resting
assert "GetMaxLevelForPlayerExpansion" in resting
assert "IsPlayerAtEffectiveMaxLevel" in resting
print("PASS Forever detection, interface metadata, dynamic max level and SavedVariables safety gates")
