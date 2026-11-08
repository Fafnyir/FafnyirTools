#!/usr/bin/env python3
"""Fafnyir's login retry retakes the first sidebar position from late plugins."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={HAS_ELLESMEREUI=true,MODULE_KEY="FafnyirTools"}
EllesmereUI={
    _addonInfoByFolder={},
    ADDON_GROUPS={
        {key="naowhui",label="NaowhUI",members={"NaowhUI"}},
        {key="core",label="Core Addons",members={"EllesmereUIActionBars"}},
    },
}
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Sidebar.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
assert(EllesmereUI.ADDON_GROUPS[1].key=="fafnyirtools")
assert(EllesmereUI.ADDON_GROUPS[2].key=="naowhui")

-- Reproduce a later PLAYER_LOGIN plugin inserting itself back at position one.
local faf=table.remove(EllesmereUI.ADDON_GROUPS,1)
table.insert(EllesmereUI.ADDON_GROUPS,2,faf)
assert(EllesmereUI.ADDON_GROUPS[1].key=="naowhui")
assert(ns.Sidebar:Install()==true)
assert(EllesmereUI.ADDON_GROUPS[1].key=="fafnyirtools")
assert(EllesmereUI.ADDON_GROUPS[2].key=="naowhui")
assert(#EllesmereUI.ADDON_GROUPS==3)
assert(#EllesmereUI.ADDON_GROUPS[1].members==1)
assert(EllesmereUI.ADDON_GROUPS[1].members[1]=="FafnyirTools")
''')

print("PASS Fafnyir sidebar group retakes position one after late plugin insertion")
