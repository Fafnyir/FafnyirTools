#!/usr/bin/env python3
"""Verify optional dependency metadata and standalone feature gating."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
SlashCmdList={}; FafnyirToolsDB={}; printed={}; ns={}
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70000","",120105 end
function print(message) printed[#printed+1]=message end
''')
ns = lua.globals().ns
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Core/StandaloneUI.lua").read_text(), "FafnyirTools", ns)

lua.execute(r'''
assert(ns.HAS_ELLESMEREUI==false)
assert(EllesmereUI and EllesmereUI.__fafnyirStandalone==true)
assert(type(EllesmereUI.RegisterModule)=="function")
assert(type(EllesmereUI.ToggleOptions)=="function")
assert(type(EllesmereUI.Widgets.SectionHeader)=="function")
assert(type(EllesmereUI.Widgets.DualRow)=="function")

ns:RegisterFeature("LevelingForecast",{portable=true})
ns:RegisterFeature("RightClickSelfCast",{portable=true})
ns:RegisterFeature("DeviceLayout",{portable=true})
ns:RegisterFeature("AuraSkins",{eui=true})
ns:RegisterFeature("Resting",{eui=true})
ns:RegisterFeature("BigWigsBorder",{eui=true})
assert(ns.modules.LevelingForecast and ns.modules.RightClickSelfCast and ns.modules.DeviceLayout)
assert(ns.modules.AuraSkins==nil and ns.modules.Resting==nil and ns.modules.BigWigsBorder==nil)

timers={};combat=false
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
function InCombatLockdown() return combat end
function NativeButton()
    local b={attrs={}}
    function b:RegisterForClicks() end
    function b:SetAttribute(key,value) self.attrs[key]=value end
    return b
end
ActionButton1=NativeButton()
''')

lua.execute((ADDON / "Modules/RightClickSelfCast.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
ns.modules.RightClickSelfCast:Refresh()
assert(ActionButton1.attrs.type2=="action" and ActionButton1.attrs.unit2=="player")

function wipe(tableValue) for key in pairs(tableValue) do tableValue[key]=nil end end
UIParent={};STANDARD_TEXT_FONT="Fonts\\FRIZQT__.TTF";ChatFontNormal={};BackdropTemplateMixin={}
GameTooltip={SetOwner=function() end,SetText=function() end,Show=function() end,Hide=function() end}
function Region()
    local r={shown=false,text="",checked=false,height=500,scripts={}}
    function r:SetSize() end;function r:SetPoint() end;function r:SetFrameStrata() end
    function r:SetMovable() end;function r:EnableMouse() end;function r:RegisterForDrag() end
    function r:SetScript(key,fn) self.scripts[key]=fn end;function r:HookScript(key,fn) self.scripts[key]=fn end
    function r:SetBackdrop() end;function r:SetWidth() end;function r:SetHeight(v) self.height=v end
    function r:GetHeight() return self.height end;function r:SetScrollChild(child) self.child=child end
    function r:SetParent() end;function r:Hide() self.shown=false end;function r:Show() self.shown=true end
    function r:IsShown() return self.shown end;function r:SetEnabled() end
    function r:SetText(v) self.text=v end;function r:GetText() return self.text end
    function r:SetChecked(v) self.checked=v end;function r:GetChecked() return self.checked end
    function r:SetAutoFocus() end;function r:SetMultiLine() end;function r:SetFontObject() end
    function r:SetFont() end;function r:SetTextColor() end;function r:SetJustifyH() end
    function r:SetJustifyV() end;function r:SetWordWrap() end;function r:GetStringHeight() return 14 end
    function r:SetColorTexture() end;function r:SetMinMaxValues() end;function r:SetValueStep() end
    function r:SetObeyStepOnDrag() end;function r:SetValue() end;function r:HighlightText() end
    function r:SetCursorPosition() end;function r:ClearFocus() end
    function r:CreateFontString() return Region() end;function r:CreateTexture() return Region() end
    return r
end
function CreateFrame() return Region() end

local sampleValue=false
EllesmereUI:RegisterModule("FafnyirTools",{
    pages={"About"},
    buildPage=function(page,parent,y)
        local W=EllesmereUI.Widgets;local h
        _,h=W:SectionHeader(parent,"Standalone",y);y=y-h
        _,h=W:DualRow(parent,y,
            {type="toggle",text="Toggle",getValue=function() return sampleValue end,setValue=function(v) sampleValue=v end},
            {type="button",text="Refresh",onClick=function() end});y=y-h
        _,h=W:DualRow(parent,y,
            {type="dropdown",text="Choice",values={a="A",b="B"},order={"a","b"},getValue=function() return "a" end},
            {type="input",text="Name",getValue=function() return "Fafnyir" end});y=y-h
        return math.abs(y)
    end,
})
EllesmereUI:ToggleOptions()
EllesmereUI:RefreshPage(true)
SlashCmdList.FAFNYIRTOOLS()
''')

toc = (ADDON / "FafnyirTools.toc").read_text()
assert "## Dependencies:" not in toc
assert "## OptionalDeps: EllesmereUI, FafnyirMedia" in toc
assert "Core\\StandaloneUI.lua" in toc

right_click = (ADDON / "Modules/RightClickSelfCast.lua").read_text()
for native_prefix in (
    "ActionButton",
    "MultiBarBottomLeftButton",
    "MultiBarBottomRightButton",
    "MultiBarRightButton",
    "MultiBarLeftButton",
):
    assert f'"{native_prefix}"' in right_click

print("PASS standalone dependency metadata, native UI shim, feature gating, and Blizzard action-bar support")
