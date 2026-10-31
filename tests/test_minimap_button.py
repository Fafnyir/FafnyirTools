#!/usr/bin/env python3
"""Verify the standalone minimap launcher, click action and local drag position."""
from pathlib import Path
import struct

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};FafnyirToolsDB={};timers={};cursorX=600;cursorY=400
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70000","",120105 end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
function GetCursorPosition() return cursorX,cursorY end
function Region()
    local r={scripts={},shown=false,points={}}
    function r:SetSize(w,h) self.width=w;self.height=h end
    function r:GetWidth() return self.width or 140 end
    function r:GetHeight() return self.height or 140 end
    function r:GetCenter() return 500,400 end
    function r:GetEffectiveScale() return 1 end
    function r:GetFrameLevel() return 2 end
    function r:SetFrameLevel(value) self.frameLevel=value end
    function r:SetFrameStrata(value) self.strata=value end
    function r:SetClampedToScreen() end
    function r:SetMovable() end
    function r:RegisterForClicks(value) self.clicks=value end
    function r:RegisterForDrag(value) self.drags=value end
    function r:SetScript(name,fn) self.scripts[name]=fn end
    function r:ClearAllPoints() self.points={} end
    function r:SetPoint(...) self.points={...} end
    function r:CreateTexture() return Region() end
    function r:SetTexture(value) self.texture=value end
    function r:SetVertexColor() end
    function r:SetTexCoord() end
    function r:SetHighlightTexture(value) self.highlight=value end
    function r:LockHighlight() self.locked=true end
    function r:UnlockHighlight() self.locked=false end
    function r:Show() self.shown=true end
    return r
end
Minimap=Region();Minimap:SetSize(140,140)
function CreateFrame() return Region() end
GameTooltip={}
function GameTooltip:Hide() end
function GameTooltip:SetOwner() end
function GameTooltip:AddLine() end
function GameTooltip:Show() end
''')
ns = lua.globals().ns
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Modules/MinimapButton.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
assert(ns.modules.MinimapButton)
assert(FafnyirToolsDB.minimapButton.angle==220)
toggleCount=0
EllesmereUI={ToggleOptions=function() toggleCount=toggleCount+1 end}
ns.modules.MinimapButton:Initialize()
local button=ns.modules.MinimapButton:GetButton()
assert(button and button.shown==true)
assert(button.clicks=="LeftButtonUp" and button.drags=="LeftButton")
button.scripts.OnClick(button,"LeftButton")
assert(toggleCount==1)
button.scripts.OnDragStart(button)
assert(button.scripts.OnUpdate)
button.scripts.OnUpdate(button)
button.scripts.OnDragStop(button)
assert(math.abs(FafnyirToolsDB.minimapButton.angle)<0.001)
assert(button.scripts.OnUpdate==nil)
''')

source = (ADDON / "Modules/MinimapButton.lua").read_text()
assert "if ns.HAS_ELLESMEREUI then return end" in source
assert 'EllesmereUI:ToggleOptions()' in source
assert 'RegisterForDrag("LeftButton")' in source
assert 'DB().angle = GetAngle()' in source
assert 'Interface\\\\AddOns\\\\FafnyirTools\\\\Media\\\\Logo.tga' in source

logo = ADDON / "Media/Logo.tga"
header = logo.read_bytes()[:18]
assert logo.is_file() and len(header) == 18
assert struct.unpack("<HH", header[12:16]) == (512, 512)
assert header[16] == 32
assert "'.tga'" in (ROOT / "tools/package.py").read_text()

schema = (ADDON / "Modules/GlobalSettings.lua").read_text()
schema_body = schema.split("local SCHEMA = {", 1)[1].split("local function Copy", 1)[0]
assert "minimapButton" not in schema_body

print("PASS standalone minimap button click, drag persistence, local-only position and ownership")
