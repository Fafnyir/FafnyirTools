#!/usr/bin/env python3
"""Verify the three author-owned legacy addon integrations in standalone mode."""
import hashlib
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};FafnyirToolsDB={};STANDARD_TEXT_FONT="Fonts\\FRIZQT__.TTF"
DAMAGE_TEXT_FONT="Fonts\\OriginalDamage.ttf"
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70000","",120105 end
UIParent={GetCenter=function() return 500,400 end}
frames={};tickerCallbacks={}
function Region()
    local r={shown=false,scripts={},cx=500,cy=400,textValue=""}
    function r:SetSize() end
    function r:SetClampedToScreen() end
    function r:SetMovable() end
    function r:EnableMouse() end
    function r:RegisterForDrag() end
    function r:SetScript(key,fn) self.scripts[key]=fn end
    function r:StartMoving() self.moving=true end
    function r:StopMovingOrSizing() self.moving=false end
    function r:GetCenter() return self.cx,self.cy end
    function r:ClearAllPoints() end
    function r:SetPoint(_,_,_,x,y) self.cx=500+(x or 0);self.cy=400+(y or 0) end
    function r:CreateFontString() local f=Region();self.fontString=f;return f end
    function r:SetTextColor() end
    function r:SetFont(path,size,flags) self.font={path,size,flags} end
    function r:SetFormattedText(format,...) self.textValue=string.format(format,...) end
    function r:Show() self.shown=true end
    function r:Hide() self.shown=false end
    return r
end
function CreateFrame() local f=Region();frames[#frames+1]=f;return f end
function GetFramerate() return 144.5 end
function GetNetStats() return 0,0,10,42 end
C_Timer={NewTicker=function(_,fn)
    tickerCallbacks[#tickerCallbacks+1]=fn
    return {Cancel=function(self) self.cancelled=true end}
end}
''')
ns = lua.globals().ns
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Modules/FPSDisplay.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Modules/NicerDamage.lua").read_text(), "FafnyirTools", ns)

lua.execute(r'''
assert(ns.modules.FPSDisplay and ns.modules.NicerDamage)
assert(FafnyirToolsDB.fpsDisplay.enabled==false)
assert(FafnyirToolsDB.nicerDamage.enabled==false)
ns.modules.FPSDisplay:Initialize()
local fpsFrame=frames[1]
assert(fpsFrame.shown==false)
FafnyirToolsDB.fpsDisplay.enabled=true
ns.modules.FPSDisplay:Refresh()
assert(fpsFrame.shown==true)
assert(fpsFrame.fontString.textValue=="144.5 FPS  |  42 ms")
assert(fpsFrame.fontString.font[2]==18)
fpsFrame.cx=525;fpsFrame.cy=390
fpsFrame.scripts.OnDragStop(fpsFrame)
assert(FafnyirToolsDB.fpsDisplay.position.x==25 and FafnyirToolsDB.fpsDisplay.position.y==-10)
ns.modules.FPSDisplay:ResetPosition()
assert(FafnyirToolsDB.fpsDisplay.position==nil and fpsFrame.cx==500 and fpsFrame.cy==400)
FafnyirToolsDB.fpsDisplay.enabled=false
ns.modules.FPSDisplay:Refresh()
assert(fpsFrame.shown==false)

assert(DAMAGE_TEXT_FONT=="Fonts\\OriginalDamage.ttf")
FafnyirToolsDB.nicerDamage.enabled=true
ns.modules.NicerDamage:Refresh()
assert(DAMAGE_TEXT_FONT=="Interface\\AddOns\\FafnyirTools\\Media\\NicerDamage.ttf")
FafnyirToolsDB.nicerDamage.enabled=false
ns.modules.NicerDamage:Refresh()
assert(DAMAGE_TEXT_FONT=="Fonts\\OriginalDamage.ttf")
''')

hide_source = (ADDON / "Modules/HideStatusTextures.lua").read_text()
assert "TargetFrame" in hide_source and "FocusFrame" in hide_source
assert 'RegisterEvent("PLAYER_TARGET_CHANGED")' in hide_source
assert 'RegisterEvent("PLAYER_FOCUS_CHANGED")' in hide_source

fps_source = (ADDON / "Modules/FPSDisplay.lua").read_text()
nicer_source = (ADDON / "Modules/NicerDamage.lua").read_text()
assert "if not ns:StandaloneFPSAvailable() then return end" in fps_source
assert "if ns.HAS_ELLESMEREUI then return end" in nicer_source
assert 'SLASH_FAFNYIRTOOLSFPS1 = "/fpsdisplay"' in fps_source

font = ADDON / "Media/NicerDamage.ttf"
assert font.is_file()
assert hashlib.sha256(font.read_bytes()).hexdigest() == "fbe683091b0db0faa8f38e5227ad3bc17dc67f119f27ff10a63d72f5f9bb9da3"
assert (ADDON / "Media/Apache-2.0.txt").is_file()
assert "'.ttf'" in (ROOT / "tools/package.py").read_text()

schema = (ADDON / "Modules/GlobalSettings.lua").read_text()
assert "fpsDisplay = { enabled = true, showLatency = true, fontSize = true }" in schema
assert "nicerDamage = { enabled = true }" in schema
assert "position" not in schema.split("local SCHEMA = {", 1)[1].split("}", 1)[0]

print("PASS legacy Hide Target Rep Color, FPS Display and Nicer Damage standalone integrations")
