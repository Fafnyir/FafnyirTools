"""Forever unit-frame names support first, last, and whole-name modes safely."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};rows={};refreshes=0;secretUnit=false
function GetBuildInfo() return '', '', '', 16001 end
function issecretvalue(v) return secretUnit and v=='Hidden' end
function UnitIsPlayer(unit) return unit~='boss1' end
function UnitName(unit)
 if unit=='player' then return 'Arthas','Menethil' end
 if unit=='compound' then return 'Mary Jane Proudmoore','Proudmoore' end
 if unit=='secret' then return 'Hidden','Surname' end
 return 'The Lich King',nil
end
Constants={CharacterNameSeparatorConsts={CHARACTERNAME_SURNAME_SEPARATOR=' '}}
EllesmereUI={Widgets={},_ModuleNS={EllesmereUIUnitFrames={}}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI._ModuleNS.EllesmereUIUnitFrames.ResolveUnitNickname(unit)
 local n,s=UnitName(unit);return s and (n..' '..s) or n
end
function _EUF_RefreshUnitNames() refreshes=refreshes+1 end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/UnitFrameNames.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.UnitFrameNames
local euf=EllesmereUI._ModuleNS.EllesmereUIUnitFrames
f:Initialize()
assert(euf.ResolveUnitNickname('player')=='Arthas Menethil')
f:BuildOptions({},0)
assert(rows[1].text=='Character Name Display')
assert(rows[1].getValue()=='whole')
rows[1].setValue('first');assert(euf.ResolveUnitNickname('player')=='Arthas')
assert(euf.ResolveUnitNickname('compound')=='Mary Jane')
rows[1].setValue('last');assert(euf.ResolveUnitNickname('player')=='Menethil')
assert(euf.ResolveUnitNickname('boss1')=='The Lich King')
secretUnit=true;assert(euf.ResolveUnitNickname('secret')=='Hidden Surname');secretUnit=false
rows[1].setValue('bogus');assert(rows[1].getValue()=='last')
f:Reset();assert(euf.ResolveUnitNickname('player')=='Arthas Menethil')
local count=#rows;ns.IS_FOREVER=false
assert(f:BuildOptions({},0)==0 and #rows==count)
ns:GetDatabase().unitFrameNames.mode='last'
assert(euf.ResolveUnitNickname('player')=='Arthas Menethil')
assert(refreshes>=4)
''')
print("PASS Forever first/last/whole unit-frame names, compound names, secret fallback, refresh, reset, and Retail gate")
