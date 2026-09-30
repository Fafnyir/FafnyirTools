"""Forever main-frame names use first/last/whole modes without leaking elsewhere."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};rows={};mainRefreshes=0;raidRefreshes=0;secretValue=false;callerStack='EllesmereUIUnitFrames'
function GetBuildInfo() return '', '', '', 16001 end
function issecretvalue(v) return secretValue and v=='Hidden' end
function debugstack() return callerStack end
Constants={CharacterNameSeparatorConsts={CHARACTERNAME_SURNAME_SEPARATOR=' '}}
EllesmereUI={Widgets={},_ModuleNS={EllesmereUIRaidFrames={}}}
function EllesmereUI.WithSurname(name,surname) return surname and (name..' '..surname) or name end
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI._ModuleNS.EllesmereUIRaidFrames.RefreshAllNames() raidRefreshes=raidRefreshes+1 end
function _EUF_RefreshUnitNames() mainRefreshes=mainRefreshes+1 end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/UnitFrameNames.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.UnitFrameNames
f:Initialize()
assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Arthas Menethil')
f:BuildOptions({},0)
assert(rows[1].text=='Character Name Display')
assert(rows[1].getValue()=='whole')
rows[1].setValue('first');assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Arthas')
assert(EllesmereUI.WithSurname('Mary Jane Proudmoore','Proudmoore')=='Mary Jane')
callerStack='EllesmereUIRaidFrames';assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Arthas Menethil')
callerStack='EllesmereUIUnitFrames'
rows[1].setValue('last');assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Menethil')
callerStack='EllesmereUINameplates';assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Arthas Menethil')
callerStack='SomeOtherAddon';assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Arthas Menethil')
callerStack='EllesmereUIUnitFrames'
assert(EllesmereUI.WithSurname('The Lich King',nil)=='The Lich King')
secretValue=true;assert(EllesmereUI.WithSurname('Hidden','Surname')=='Hidden Surname');secretValue=false
rows[1].setValue('bogus');assert(rows[1].getValue()=='last')
f:Reset();assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Arthas Menethil')
local count=#rows;ns.IS_FOREVER=false
assert(f:BuildOptions({},0)==0 and #rows==count)
ns:GetDatabase().unitFrameNames.mode='last'
assert(EllesmereUI.WithSurname('Arthas','Menethil')=='Arthas Menethil')
assert(mainRefreshes>=4 and raidRefreshes==0)
''')
print("PASS Forever main-frame name modes, Party/Raid/Nameplate exclusion, compound names, secret fallback, refresh, reset, and Retail gate")
