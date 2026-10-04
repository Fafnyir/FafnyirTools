#!/usr/bin/env python3
"""Verify the v1.1.8 privacy-safe support diagnostics report."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ABOUT = ROOT / "src/FafnyirTools/Modules/About.lua"


lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(
    r'''
    captured = nil
    FafnyirToolsDB = {
        auraSkins={enabled=false}, deviceLayout={enabled=true},
        focusHeader={enabled=true}, iconHistoryBorder={enabled=false},
        inventory={enabled=true,tooltips=true},
        permanentCompanionPet={enabled=false},
        xpBar={enabled=false,questEnabled=true,restedEnabled=true},
        resting={enabled=true}, rightClickSelfCast={enabled=true},
        flyoutFix={enabled=true},
    }
    C_AddOns = {
        IsAddOnLoaded=function(name) return name == "EllesmereUI" or name == "FafnyirMedia" end,
        GetAddOnMetadata=function(name, field)
            if name == "EllesmereUI" then return "9.3.0" end
            if name == "FafnyirMedia" then return "1.0.0" end
        end,
    }
    function GetBuildInfo() return "12.1.5", "65432", "Oct 3 2026", 120105 end
    EllesmereUI = {
        RegisterModule=function() end,
        ShowCopyPopup=function(self, title, prompt, text)
            captured={title=title,prompt=prompt,text=text}
        end,
    }
    ns = {
        modules={}, state={optionsRegistered=true}, IS_FOREVER=false,
        RegisterFeature=function(self,key,feature) self.modules[key]=feature end,
        GetDatabase=function() return FafnyirToolsDB end,
        ForeverSavedVariablesUnsafe=function() return false end,
        Print=function() error("copy popup fallback should not be used") end,
    }
    '''
)
lua.execute(ABOUT.read_text(), "FafnyirTools", lua.globals().ns)
lua.execute(
    r'''
    local report=ns.modules.About:GetDiagnostics()
    assert(string.find(report,"Addon: v1.1.8",1,true))
    assert(string.find(report,"Flavor: Retail",1,true))
    assert(string.find(report,"Client: 12.1.5",1,true))
    assert(string.find(report,"Build: 65432",1,true))
    assert(string.find(report,"Interface: 120105",1,true))
    assert(string.find(report,"EllesmereUI: 9.3.0 (loaded)",1,true))
    assert(string.find(report,"FafnyirMedia: 1.0.0 (loaded)",1,true))
    assert(string.find(report,"Quest XP=on",1,true))
    assert(string.find(report,"XP Gradient=off",1,true))
    assert(string.find(report,"Flyout Fix=on",1,true))
    assert(not string.find(report,"character",1,true))
    assert(not string.find(report,"realm",1,true))
    assert(not string.find(report,"account",1,true))
    ns.modules.About:ShowDiagnostics()
    assert(captured and captured.title == "Fafnyir Tools Diagnostics")
    assert(captured.text == report)
    '''
)

# Guard against accidentally adding identity or raw-database APIs to the report.
source = ABOUT.read_text()
for forbidden in ("UnitName(", "GetRealmName(", "BattleTag", "FafnyirToolsDB"):
    assert forbidden not in source, forbidden
assert 'type="button",\n            text="Copy Diagnostics"' in source
assert 'buttonText="Copy Diagnostics"' not in source

print("PASS privacy-safe support diagnostics, dependency versions, feature state, and copy popup")
