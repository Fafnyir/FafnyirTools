#!/usr/bin/env python3
"""Verify the optional BigWigs Pixels-border bridge."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"
MODULE = ADDON / "Modules/BigWigsBorder.lua"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(
    r'''
    SlashCmdList={}; ns={}; registrations={}; applied={}
    function GetBuildInfo() return "12.1.5", "1", "", 120105 end
    local frameMethods={}
    function frameMethods:RegisterEvent() end
    function frameMethods:SetScript() end
    function frameMethods:ClearAllPoints() end
    function frameMethods:SetPoint() end
    function frameMethods:SetFrameLevel(value) self.level=value end
    function frameMethods:GetFrameLevel() return self.level or 1 end
    function frameMethods:IsShown() return self.shown ~= false end
    function frameMethods:SetShown(value) self.shown=value end
    function frameMethods:Hide() self.shown=false end
    function CreateFrame(_, _, parent)
        return setmetatable({parent=parent,shown=true},{__index=frameMethods})
    end
    BigWigsLoader={
        RegisterMessage=function(owner,event,callback)
            registrations[event]={owner=owner,callback=callback}
        end,
    }
    EllesmereUI={
        ApplyBorderStyle=function(border,size,r,g,b,a,texture,...)
            applied[#applied+1]={border=border,size=size,texture=texture}
        end,
        GetBorderDefaultSize=function(context,texture)
            assert(texture=="pixels")
            return context=="bigwigs_icon" and 2 or 1
        end,
        GetBorderStyleSelectDefaults=function(texture)
            assert(texture=="pixels")
            return {r=.5,g=.6,b=.7}
        end,
        BorderPx=function(_,size,texture) return size end,
    }
    '''
)
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute(MODULE.read_text(), "FafnyirTools", lua.globals().ns)
lua.execute(
    r'''
    local feature=ns.modules.BigWigsBorder
    assert(ns:GetDatabase().bigWigsBorder.enabled==false)
    feature:Initialize()
    assert(registrations.BigWigs_BarCreated and registrations.BigWigs_BarEmphasized)

    local bar=CreateFrame("Frame")
    bar.candyBarBar=CreateFrame("StatusBar",nil,bar)
    bar.candyBarIconFrame=CreateFrame("Frame",nil,bar)
    registrations.BigWigs_BarCreated.callback("BigWigs_BarCreated",{},bar)
    assert(#applied==0)

    ns:GetDatabase().bigWigsBorder.enabled=true
    registrations.BigWigs_BarCreated.callback("BigWigs_BarCreated",{},bar)
    assert(#applied==2)
    assert(applied[1].texture=="pixels" and applied[2].texture=="pixels")
    assert(bar.candyBarBar._fafnyirBigWigsBorder.shown)
    assert(bar.candyBarIconFrame._fafnyirBigWigsIconBorder.shown)

    registrations.BigWigs_BarEmphasized.callback("BigWigs_BarEmphasized",{},bar)
    assert(#applied==4)
    ns:GetDatabase().bigWigsBorder.enabled=false
    feature:Refresh()
    assert(not bar.candyBarBar._fafnyirBigWigsBorder.shown)
    assert(not bar.candyBarIconFrame._fafnyirBigWigsIconBorder.shown)
    feature:Reset()
    assert(ns:GetDatabase().bigWigsBorder.enabled==false)
    '''
)

source = MODULE.read_text()
assert 'texture = "pixels"' in source
assert "BigWigs3DB" not in source
assert "BigWigs_StartNameplate" not in source
assert "BigWigs_BarCreated" in source and "BigWigs_BarEmphasized" in source

print("PASS BigWigs Pixels border defaults, public callbacks, bar/icon styling, disable restore, and isolation")
