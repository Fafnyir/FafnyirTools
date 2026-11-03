#!/usr/bin/env python3
"""Verify conditional minimap-button collection, flyout and ownership."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"
MODULE = ADDON / "Modules/MinimapButtonCollector.lua"

lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};FafnyirToolsDB={};UISpecialFrames={};timers={}
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70000","",120105 end
function InCombatLockdown() return false end
function GetCursorPosition() return 500,400 end
function issecretvalue() return false end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}

function Region(objectType,name,parent)
    local r={objectType=objectType or "Frame",name=name,parent=parent,scripts={},shown=true,points={},children={}}
    if parent and parent.children then parent.children[#parent.children+1]=r end
    function r:GetName() return self.name end
    function r:GetObjectType() return self.objectType end
    function r:IsProtected() return self.protected==true end
    function r:IsShown() return self.shown end
    function r:Show() self.shown=true end
    function r:Hide() self.shown=false end
    function r:SetShown(value) self.shown=value end
    function r:SetSize(w,h) self.width=w;self.height=h end
    function r:GetWidth() return self.width or 32 end
    function r:GetHeight() return self.height or 32 end
    function r:GetCenter() return 500,400 end
    function r:GetEffectiveScale() return 1 end
    function r:GetFrameLevel() return 2 end
    function r:GetFrameStrata() return self.strata or "MEDIUM" end
    function r:SetFrameLevel(value) self.level=value end
    function r:SetFrameStrata(value) self.strata=value end
    function r:GetScale() return self.scale or 1 end
    function r:SetScale(value) self.scale=value end
    function r:SetAlpha(value) self.alpha=value end
    function r:SetClampedToScreen() end
    function r:RegisterForClicks(...) self.clicks={...} end
    function r:RegisterForDrag(value) self.drag=value end
    function r:SetScript(key,fn) self.scripts[key]=fn end
    function r:SetParent(value) self.parent=value end
    function r:GetParent() return self.parent end
    function r:ClearAllPoints() self.points={} end
    function r:SetPoint(...) self.points[#self.points+1]={...} end
    function r:GetNumPoints() return #self.points end
    function r:GetPoint(index) return unpack(self.points[index]) end
    function r:GetChildren() return unpack(self.children) end
    function r:CreateTexture() return Region("Texture",nil,self) end
    function r:SetTexture(value) self.texture=value end
    function r:SetVertexColor() end
    function r:SetColorTexture() end
    function r:SetHighlightTexture() end
    function r:SetBackdrop() end
    function r:SetBackdropColor() end
    function r:SetBackdropBorderColor() end
    return r
end
UIParent=Region("Frame","UIParent")
Minimap=Region("Frame","Minimap",UIParent);Minimap:SetSize(140,140)
MinimapCluster=Region("Frame","MinimapCluster",UIParent)
function CreateFrame(objectType,name,parent)
    local frame=Region(objectType,name,parent)
    if name then _G[name]=frame end
    return frame
end
GameTooltip={SetOwner=function() end,AddLine=function() end,Show=function() end,Hide=function() end}
''')
ns = lua.globals().ns
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
addonOne=CreateFrame("Button","LibDBIcon10_One",Minimap);addonOne:SetSize(31,31);addonOne:SetPoint("CENTER",Minimap,"CENTER",10,10)
addonTwo=CreateFrame("Button","SomeAddonButton",Minimap);addonTwo:SetSize(24,24);addonTwo:SetPoint("CENTER",Minimap,"CENTER",-10,-10)
clusterAddon=CreateFrame("Button","ClusterAddonButton",MinimapCluster);clusterAddon:SetSize(32,32);clusterAddon:SetPoint("CENTER")
libraryAddon=CreateFrame("Button","LibDBIcon10_Library",UIParent);libraryAddon:SetSize(31,31);libraryAddon:SetPoint("CENTER")
libraryAddon.alpha=.1
function LibStub(name,silent)
    if name=="LibDBIcon-1.0" then return {objects={Library=libraryAddon}} end
end
systemButton=CreateFrame("Button","AddonCompartmentFrame",Minimap);systemButton:SetSize(30,30);systemButton:SetPoint("CENTER")
clockButton=CreateFrame("Button","TimeManagerClockButton",MinimapCluster);clockButton:SetSize(30,30);clockButton:SetPoint("CENTER")
protectedButton=CreateFrame("Button","ProtectedAddonButton",Minimap);protectedButton.protected=true;protectedButton:SetPoint("CENTER")
''')
lua.execute(MODULE.read_text(), "FafnyirTools", ns)
lua.execute(r'''
local feature=ns.modules.MinimapButtonCollector
assert(feature and FafnyirToolsDB.minimapButtonCollector.enabled==false)
FafnyirToolsDB.minimapButtonCollector.enabled=true
feature:Initialize()
local button=feature:GetButton()
local panel=feature:GetPanel()
assert(button and panel and button.shown==true and panel.shown==false)
assert(panel.strata=="LOW")
assert(panel.points[1][1]=="TOPRIGHT" and panel.points[1][2]==Minimap)
assert(panel.points[1][3]=="TOPLEFT" and panel.points[1][4]==-6 and panel.points[1][5]==0)
assert(addonOne.parent==FafnyirToolsMinimapCollectorStorage)
assert(addonTwo.parent==FafnyirToolsMinimapCollectorStorage)
assert(clusterAddon.parent==FafnyirToolsMinimapCollectorStorage)
assert(libraryAddon.parent==FafnyirToolsMinimapCollectorStorage)
assert(systemButton.parent==Minimap and protectedButton.parent==Minimap)
assert(clockButton.parent==MinimapCluster)
button.scripts.OnClick(button,"LeftButton")
assert(panel.shown==true and addonOne.parent==panel and addonTwo.parent==panel)
assert(clusterAddon.parent==panel and libraryAddon.parent==panel and libraryAddon.alpha==1)
assert(addonOne.strata=="DIALOG" and addonOne.level==panel:GetFrameLevel()+5)
button.scripts.OnClick(button,"LeftButton")
assert(panel.shown==false and addonOne.parent==FafnyirToolsMinimapCollectorStorage)
button.scripts.OnDragStart(button)
assert(button.scripts.OnUpdate)
button.scripts.OnDragStop(button)
assert(button.scripts.OnUpdate==nil and type(FafnyirToolsDB.minimapButtonCollector.angle)=="number")
feature:Reset()
assert(FafnyirToolsDB.minimapButtonCollector.enabled==false and FafnyirToolsDB.minimapButtonCollector.angle==180)
''')

lua2 = LuaRuntime(unpack_returned_tuples=True)
lua2.execute(r'''
ns={modules={}};C_AddOns={IsAddOnLoaded=function(name) return name=="EllesmereUIMinimap" end}
''')
lua2.execute(MODULE.read_text(), "FafnyirTools", lua2.globals().ns)
assert lua2.globals().ns.modules["MinimapButtonCollector"] is None

source = MODULE.read_text()
assert 'AddOnLoaded("EllesmereUIMinimap")' in source
assert 'AddChildren(Minimap)' in source
assert 'AddChildren(MinimapCluster)' in source
assert 'LibStub("LibDBIcon-1.0", true)' in source
assert 'Interface\\\\AddOns\\\\FafnyirTools\\\\Media\\\\Logo.tga' in source
assert 'frame:IsProtected()' not in source  # access stays behind SafeCall
assert 'minimapButtonCollector = { enabled = true }' in (ADDON / "Modules/GlobalSettings.lua").read_text()

print("PASS conditional minimap button collection, protected exclusions, flyout, drag and reset")
