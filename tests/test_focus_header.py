"""The Blizzard-style Focus reaction header is independently configurable."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};rows={};reloads=0
function GetBuildInfo() return '', '', '', 16001 end
focusSettings={blizzColoredHeader=false}
EllesmereUI={Widgets={},_ModuleNS={EllesmereUIUnitFrames={}}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI._ModuleNS.EllesmereUIUnitFrames.UF_GetSettings(unit) assert(unit=='focus');return focusSettings end
function EllesmereUI._ModuleNS.EllesmereUIUnitFrames.ReloadFrames() reloads=reloads+1 end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/FocusHeader.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.FocusHeader
local db=ns:GetDatabase().focusHeader
assert(db.enabled==true and db.initialized==false)
f:Initialize()
assert(db.enabled==false and db.initialized==true) -- adopt existing EUI choice
f:BuildOptions({},0)
assert(rows[1].text=='Blizz Colored Focus Header' and rows[1].getValue()==false)
rows[1].setValue(true)
assert(db.enabled==true and focusSettings.blizzColoredHeader==nil and reloads==1)
rows[1].setValue(false)
assert(db.enabled==false and focusSettings.blizzColoredHeader==false and reloads==2)
f:Reset()
assert(db.enabled==true and focusSettings.blizzColoredHeader==nil and reloads==3)
''')
print("PASS Focus header adoption, independent toggle, native setting mapping, immediate refresh, and reset")
