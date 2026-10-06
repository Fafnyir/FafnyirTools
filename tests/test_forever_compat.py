"""WoW Forever client detection and temporary SavedVariables safety gates."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};prints={};sourceWrites=0;rows={};cvars={volumeFog='1'};queue={};consoleCalls={}
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
C_CVar={
 GetCVar=function(key) return cvars[key] end,
 SetCVar=function(key,value) cvars[key]=tostring(value) end,
}
C_Timer={After=function(_,fn) queue[#queue+1]=fn end}
function flush() local q=queue;queue={};for _,fn in ipairs(q) do fn() end end
function ConsoleExec(command)
 consoleCalls[#consoleCalls+1]=command
 local value=command:match('volumeFog%s+(%d)');if value then cvars.volumeFog=value end
 return true
end
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right)
 rows[#rows+1]=left;rows[#rows+1]=right;return {},40
end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/GlobalSettings.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/ForeverFog.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
assert(ns.IS_FOREVER and ns:ForeverSavedVariablesUnsafe())
ns:GetDatabase().xpBar={enabled=false}
local before=ns:GetDatabase().xpBar.enabled
local payload={settings={xpBar={enabled=not before}}}
assert(ns.modules.GlobalSettings:ApplyImport(payload)==false)
assert(ns:GetDatabase().xpBar.enabled==before and sourceWrites==0)
ns:GetDatabase().globalSettingsImportBackup={settings={xpBar={enabled=true}}}
ns.modules.GlobalSettings:ShowRestore()
assert(#prints>=1 and prints[#prints]:find('not reliably saving'))

rows={}
local fog=ns.modules.ForeverFog
assert(fog:BuildOptions({},-20)==20 and #rows==0)
fog:Initialize();flush();assert(cvars.volumeFog=='1' and #consoleCalls==0)
fog:HandleEvent('PLAYER_ENTERING_WORLD');flush();assert(cvars.volumeFog=='1' and #consoleCalls==0)
fog:Reset();assert(ns:GetDatabase().foreverFog.enabled==true)
assert(ns:GetDatabase().foreverFog.initialized==false and #consoleCalls==0)
ns.IS_FOREVER=false;rows={};assert(fog:BuildOptions({},-37)==37 and #rows==0)
''')

resting = (ROOT / "Modules/Resting.lua").read_text()
assert "MAX_LEVEL" not in resting
assert "GetMaxLevelForPlayerExpansion" in resting
assert "IsPlayerAtEffectiveMaxLevel" in resting
print("PASS Forever detection, dormant fog compatibility, interface metadata, dynamic max level and SavedVariables safety gates")
