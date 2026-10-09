"""EllesmereUI owns all frame-name formatting; legacy data remains untouched."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"

assert not (ADDON / "Modules/UnitFrameNames.lua").exists()
toc = (ADDON / "FafnyirTools.toc").read_text()
options = (ADDON / "Core/Options.lua").read_text()
bootstrap = (ADDON / "Core/Bootstrap.lua").read_text()
global_settings = (ADDON / "Modules/GlobalSettings.lua").read_text()

assert "Modules\\UnitFrameNames.lua" not in toc
assert "ns.modules.UnitFrameNames" not in options
assert "unitFrameNames =" not in bootstrap
assert "unitFrameNames =" not in global_settings
active_lua = "\n".join(path.read_text() for path in ADDON.rglob("*.lua"))
assert "WithSurname" not in active_lua

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(
    r'''
    SlashCmdList={}
    ns={}
    FafnyirToolsDB={unitFrameNames={mode='last',future='keep'}}
    function GetBuildInfo() return '', '', '', 16001 end
    '''
)
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute(
    r'''
    ns:InitializeDatabase()
    assert(FafnyirToolsDB.unitFrameNames.mode=='last')
    assert(FafnyirToolsDB.unitFrameNames.future=='keep')
    '''
)

print("PASS EllesmereUI-owned name formatting, retired hooks/options/defaults/export, and legacy data preservation")
