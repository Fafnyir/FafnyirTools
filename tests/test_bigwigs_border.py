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
    function frameMethods:SetScript(event,callback) self.scripts=self.scripts or {};self.scripts[event]=callback end
    function frameMethods:ClearAllPoints() self.points={} end
    function frameMethods:SetPoint(...) self.points=self.points or {};self.points[#self.points+1]={...} end
    function frameMethods:GetNumPoints() return #(self.points or {}) end
    function frameMethods:GetPoint(index)
        local p=self.points[index];return p[1],p[2],p[3],p[4],p[5]
    end
    function frameMethods:SetFrameLevel(value) self.level=value end
    function frameMethods:GetFrameLevel() return self.level or 1 end
    function frameMethods:IsShown() return self.shown ~= false end
    function frameMethods:SetShown(value) self.shown=value end
    function frameMethods:Hide() self.shown=false end
    function frameMethods:Show() self.shown=true end
    function frameMethods:SetAlpha(value) self.alpha=value end
    function frameMethods:GetAlpha() return self.alpha or 1 end
    function frameMethods:GetWidth() return self.width end
    function frameMethods:GetHeight() return self.height end
    function frameMethods:GetFrameStrata() return self.strata end
    function frameMethods:GetObjectType() return self.objectType or "Frame" end
    function frameMethods:GetRegions() return unpack(self.regions or {}) end
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
            return context=="bigwigs_icon" and 2 or 1
        end,
        GetBorderStyleSelectDefaults=function(texture)
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
    assert(ns:GetDatabase().bigWigsBorder.texture=="pixels")
    feature:Initialize()
    assert(registrations.BigWigs_BarCreated and registrations.BigWigs_BarEmphasized and registrations.BigWigs_Message)

    local bar=CreateFrame("Frame")
    bar.candyBarBar=CreateFrame("StatusBar",nil,bar)
    bar.candyBarIconFrame=CreateFrame("Frame",nil,bar)
    bar.iconPosition="LEFT"
    function bar:GetIconPosition() return self.iconPosition end
    function bar:SetIconPosition(position)
        self.iconPosition=position;self.restoreCalls=(self.restoreCalls or 0)+1
        self.candyBarIconFrame:ClearAllPoints();self.candyBarBar:ClearAllPoints()
    end
    bar.candyBarIconFrame:SetPoint("TOPLEFT",bar,"TOPLEFT",0,0)
    bar.candyBarBar:SetPoint("TOPLEFT",bar.candyBarIconFrame,"TOPRIGHT",0,0)
    bar.candyBarBar:SetPoint("TOPRIGHT",bar,"TOPRIGHT",0,0)
    registrations.BigWigs_BarCreated.callback("BigWigs_BarCreated",{},bar)
    assert(#applied==0)

    ns:GetDatabase().bigWigsBorder.enabled=true
    registrations.BigWigs_BarCreated.callback("BigWigs_BarCreated",{},bar)
    assert(#applied==2)
    assert(applied[1].texture=="pixels" and applied[2].texture=="pixels")
    assert(bar.candyBarBar._fafnyirBigWigsBorder.shown)
    assert(bar.candyBarIconFrame._fafnyirBigWigsIconBorder.shown)

    ns:GetDatabase().bigWigsBorder.iconOffset=3
    feature:Refresh()
    assert(bar.candyBarIconFrame.points[1][4]==0)
    assert(bar.candyBarBar.points[1][4]==3)

    ns:GetDatabase().bigWigsBorder.texture="solid"
    feature:Refresh()
    assert(applied[#applied].texture=="solid")

    -- BigWigs reapplies its native style before sending the emphasized message.
    bar.candyBarIconFrame:ClearAllPoints();bar.candyBarBar:ClearAllPoints()
    bar.candyBarIconFrame:SetPoint("TOPLEFT",bar,"TOPLEFT",0,0)
    bar.candyBarBar:SetPoint("TOPLEFT",bar.candyBarIconFrame,"TOPRIGHT",0,0)
    bar.candyBarBar:SetPoint("TOPRIGHT",bar,"TOPRIGHT",0,0)
    registrations.BigWigs_BarEmphasized.callback("BigWigs_BarEmphasized",{},bar)
    assert(#applied==8)
    ns:GetDatabase().bigWigsBorder.enabled=false
    feature:Refresh()
    assert(not bar.candyBarBar._fafnyirBigWigsBorder.shown)
    assert(not bar.candyBarIconFrame._fafnyirBigWigsIconBorder.shown)
    assert(bar.candyBarIconFrame.points[1][4]==0)
    assert(bar.candyBarBar.points[1][4]==0)
    feature:Reset()
    assert(ns:GetDatabase().bigWigsBorder.enabled==false)
    assert(ns:GetDatabase().bigWigsBorder.texture=="pixels")
    assert(ns:GetDatabase().bigWigsBorder.iconOffset==0)

    local messageFrame=CreateFrame("Frame")
    messageFrame.width=2000;messageFrame.height=80;messageFrame.strata="FULLSCREEN_DIALOG";messageFrame.level=20
    messageFrame.regions={}
    for i=1,4 do
        local icon=CreateFrame("Texture",nil,messageFrame);icon.objectType="Texture";icon.shown=false
        local label=CreateFrame("FontString",nil,messageFrame);label.objectType="FontString"
        icon:SetPoint("RIGHT",label,"LEFT",0,0)
        messageFrame.regions[i]=icon
    end
    UIParent={GetChildren=function() return end}
    function EnumerateFrames(previous)
        if previous==nil then return messageFrame end
        return nil
    end
    ns:GetDatabase().bigWigsBorder.enabled=true
    ns:GetDatabase().bigWigsBorder.iconOffset=3
    registrations.BigWigs_Message.callback("BigWigs_Message",{},1,"Test","yellow",123,false)
    assert(#applied==12)
    for i=1,4 do
        local border=messageFrame.regions[i]._fafnyirBigWigsMessageBorder
        assert(border and border.scripts.OnUpdate and border.alpha==0)
        assert(messageFrame.regions[i].points[1][4]==-3)
    end
    ns:GetDatabase().bigWigsBorder.enabled=false
    feature:Refresh()
    for i=1,4 do assert(messageFrame.regions[i].points[1][4]==0) end

    -- Controls refresh the page only after their click/menu lifecycle finishes.
    local capturedToggleSetter,capturedBorderSetter
    local pageRefreshes,delays=0,{}
    EllesmereUI.GetBorderTextureDropdown=function()
        return {pixels="Pixels",glow="Glow"},{"pixels","glow"}
    end
    EllesmereUI.RefreshPage=function() pageRefreshes=pageRefreshes+1 end
    EllesmereUI.Widgets={
        SectionHeader=function() return {},40 end,
        DualRow=function(_,_,_,left,right)
            if right and right.type=="dropdown" then
                capturedToggleSetter=left.setValue
                capturedBorderSetter=right.setValue
                assert(left.disabled==nil and left.disabledTooltip==nil)
                assert(right.disabled==nil and right.disabledTooltip==nil)
                return {},50
            end
            return {},50
        end,
    }
    C_Timer={After=function(delay,callback) delays[#delays+1]=delay;callback() end}
    feature:BuildOptions({},0)
    capturedBorderSetter("glow")
    assert(ns:GetDatabase().bigWigsBorder.texture=="glow")
    capturedToggleSetter(false)
    capturedToggleSetter(true)
    assert(ns:GetDatabase().bigWigsBorder.enabled==true)
    assert(pageRefreshes==1 and #delays==1 and delays[1]==0.05)
    '''
)

source = MODULE.read_text()
assert 'DB().texture or "pixels"' in source
assert "BigWigs3DB" not in source
assert "BigWigs_StartNameplate" not in source
assert "BigWigs_BarCreated" in source and "BigWigs_BarEmphasized" in source
assert '"bigwigs_message_icon"' in source and "ScanMessageIcons" in source
assert "EnumerateFrames" in source
assert "RefreshOptionsAfterDropdown()" in source and "C_Timer.After(0.05, refresh)" in source
assert "RefreshWidgetsAfterToggle" not in source
assert "borderStyleControl" not in source

print("PASS BigWigs bar/message borders, styles, bar-body offset, fades, restore, and isolation")
