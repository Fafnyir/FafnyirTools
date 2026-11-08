#!/usr/bin/env python3
"""External owners suppress only the overlapping Fafnyir runtime features."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"


def runtime(loaded=(), qol=None, topbar=None):
    lua = LuaRuntime(unpack_returned_tuples=True)
    loaded_names = ",".join(f'["{name}"]=true' for name in loaded)
    lua.execute(
        f'''ns={{}};SlashCmdList={{}};FafnyirToolsDB={{}}
loaded={{{loaded_names}}}
C_AddOns={{IsAddOnLoaded=function(name) return loaded[name] == true end}}
function GetBuildInfo() return "1.60.1","69913","",16001 end
'''
    )
    if qol is not None or topbar is not None:
        def lua_table(values):
            fields = []
            for key, value in (values or {}).items():
                literal = "true" if value is True else "false" if value is False else "nil"
                fields.append(f'["{key}"]={literal}')
            return "{" + ",".join(fields) + "}"

        lua.execute(f'''
local qol={lua_table(qol)}
local topbar={lua_table(topbar)}
NaowhForever={{
    QoLSettings={{Get=function(key) return qol[key] end}},
    TopBarSettings={{Get=function(key) return topbar[key] end}},
}}
''')
    ns = lua.globals().ns
    lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
    return lua, ns


active, active_ns = runtime(
    loaded=("NaowhForever_QoL",),
    qol={"enabled": True, "xpBar": True, "altCounts": True},
    topbar={"enabled": True, "showSystem": True},
)
active.execute((ROOT / "Modules/XPBar.lua").read_text(), "FafnyirTools", active_ns)
active.execute((ROOT / "Modules/FPSDisplay.lua").read_text(), "FafnyirTools", active_ns)
active.execute((ROOT / "Modules/Inventory/Core.lua").read_text(), "FafnyirTools", active_ns)
active.execute('''
assert(ns.defaults.xpBar == nil and ns.modules.XPBar == nil)
assert(ns.modules.FPSDisplay == nil and ns.modules.Inventory == nil)
assert(type(FafnyirToolsDB.inventory) == "table")
''')

disabled, disabled_ns = runtime(
    loaded=("NaowhForever_QoL",),
    qol={"enabled": True, "xpBar": False, "altCounts": False},
    topbar={"enabled": True, "showSystem": False},
)
disabled.execute((ROOT / "Modules/XPBar.lua").read_text(), "FafnyirTools", disabled_ns)
disabled.execute((ROOT / "Modules/FPSDisplay.lua").read_text(), "FafnyirTools", disabled_ns)
disabled.execute((ROOT / "Modules/Inventory/Core.lua").read_text(), "FafnyirTools", disabled_ns)
disabled.execute('''
assert(ns.defaults.xpBar and ns.modules.XPBar)
assert(ns.modules.FPSDisplay and ns.modules.Inventory)
''')

bags, bags_ns = runtime(loaded=("EllesmereUIBags",))
bags.execute((ROOT / "Modules/Inventory/Core.lua").read_text(), "FafnyirTools", bags_ns)
bags.execute('''
assert(ns.modules.Inventory == nil)
assert(type(FafnyirToolsDB.inventory) == "table")
''')

print("PASS EllesmereUI Bags and active Naowh features suppress only overlapping runtime ownership")
