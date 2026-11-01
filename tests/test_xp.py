"""Standalone native XP styling and EllesmereUI ownership isolation."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / "src/FafnyirTools"


lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
SlashCmdList={};FafnyirToolsDB={};ns={}
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70448","",120105 end
function CreateColor(r,g,b,a) return {r=r,g=g,b=b,a=a} end
function issecretvalue() return false end
function UnitLevel() return 81 end
function UnitXP() return 100 end
function UnitXPMax() return 1000 end
function GetMaxLevelForPlayerExpansion() return 90 end
function IsPlayerAtEffectiveMaxLevel() return false end
function IsLevelAtEffectiveMaxLevel() return false end
function IsXPUserDisabled() return false end

C_Timer={After=function(_,fn) fn() end,NewTicker=function(_,fn)
    return {Cancel=function(self) self.cancelled=true end,Fire=fn}
end}

local function Texture(atlas,path)
    local t={atlas=atlas,path=path,shown=true}
    function t:GetAtlas() return self.atlas end
    function t:GetTexture() return self.path end
    function t:SetAtlas(v) self.atlas=v;self.path=nil end
    function t:SetTexture(v) self.path=v;self.atlas=nil end
    function t:SetVertexColor(...) self.vertex={...} end
    function t:SetGradient(direction,a,b) self.gradient={direction,a,b} end
    function t:SetGradientAlpha(...) self.gradient={...} end
    function t:SetColorTexture(...) self.color={...} end
    function t:AddMaskTexture(mask) self.mask=mask end
    function t:SetAllPoints(relative) self.allPoints=relative end
    function t:ClearAllPoints() self.points={} end
    function t:SetPoint(...) self.point={...} end
    function t:SetSize(w,h) self.width=w;self.height=h end
    function t:SetWidth(w) self.width=w end
    function t:SetHeight(h) self.height=h end
    function t:SetShown(v) self.shown=v end
    function t:SetAlpha(v) self.alpha=v end
    function t:GetAlpha() return self.alpha or 1 end
    function t:Show() self.shown=true end
    function t:Hide() self.shown=false end
    return t
end

fill=Texture("UI-HUD-ExperienceBar-Fill-Experience")
rested=Texture("UI-HUD-ExperienceBar-Fill-Prediction")
background=Texture("UI-HUD-ExperienceBar-Background");background.alpha=1
status={texture=fill,width=800,height=10,Background=background}
function status:GetStatusBarTexture() return self.texture end
function status:GetSize() return self.width,self.height end
function status:CreateTexture(_,layer,_,sublevel)
    local t=Texture();t.layer=layer;t.sublevel=sublevel
    self.clean=self.clean or {};self.clean[#self.clean+1]=t;return t
end
function status:CreateMaskTexture()
    local t=Texture();self.mask=t;return t
end

xpBar={StatusBar=status,ExhaustionLevelFillBar=rested,scripts={},shown=true}
function xpBar:CreateTexture(_,layer,_,sublevel)
    local t=Texture();t.layer=layer;t.sublevel=sublevel;self.created=t;return t
end
function xpBar:HookScript(name,fn) self.scripts[name]=fn end
function xpBar:GetParent() return MainStatusTrackingBarContainer end
function xpBar:IsShown() return self.shown end
function xpBar:UpdateAll() self.updated=(self.updated or 0)+1 end
function xpBar:UpdateStatusBarTextures()
    fill:SetAtlas("UI-HUD-ExperienceBar-Fill-Experience")
end

StatusTrackingBarInfo={BarsEnum={Experience=4}}
MainStatusTrackingBarContainer={bars={[4]=xpBar}}
SecondaryStatusTrackingBarContainer={bars={}}
StatusTrackingBarManager={barContainers={MainStatusTrackingBarContainer,SecondaryStatusTrackingBarContainer}}

function hooksecurefunc(object,name,hook)
    local old=object[name]
    object[name]=function(self,...)
        local values={old(self,...)}
        hook(self,...)
        return unpack(values)
    end
end

C_QuestLog={}
function C_QuestLog.GetNumQuestLogEntries() return 2 end
function C_QuestLog.GetQuestIDForLogIndex(index) return 100+index end
function C_QuestLog.IsComplete() return true end
function GetQuestLogRewardXP(id) return id==101 and 150 or 50 end
''')
ns = lua.globals().ns
lua.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Localization/enUS.lua").read_text(), "FafnyirTools", ns)
lua.execute((ADDON / "Modules/XPBar.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
assert(ns.defaults.xpBar and ns.modules.XPBar)
local defaults=ns.defaults.xpBar
assert(defaults.enabled==false and defaults.questEnabled and defaults.restedEnabled)
assert(math.abs(defaults.startColor.r-(85/255))<.0001)
assert(math.abs(defaults.endColor.r-(197/255))<.0001)
assert(math.abs(defaults.restedStartColor.r-(79/255))<.0001)
assert(defaults.questColor.r==1 and math.abs(defaults.questColor.g-(150/255))<.0001)

local feature=ns.modules.XPBar
feature:Initialize()
assert(fill.atlas=="UI-HUD-ExperienceBar-Fill-Experience")
assert(rested.path=="Interface\\Buttons\\WHITE8X8")
assert(xpBar.created and xpBar.created.shown and xpBar.created.sublevel==-2)
assert(xpBar.created.width==160 and xpBar.created.height==10)
assert(xpBar.created.point[4]==80)
assert(status.mask and status.mask.atlas=="UI-HUD-ExperienceBar-Fill-Experience")
assert(fill.mask==status.mask and rested.mask==status.mask and xpBar.created.mask==status.mask)

FafnyirToolsDB.xpBar.enabled=true
feature:Refresh()
assert(fill.path=="Interface\\Buttons\\WHITE8X8")
assert(fill.gradient[1]=="HORIZONTAL")
xpBar:UpdateStatusBarTextures()
assert(fill.path=="Interface\\Buttons\\WHITE8X8")
assert(fill.mask==status.mask)

FafnyirToolsDB.xpBar.restedEnabled=false
feature:Refresh()
assert(rested.atlas=="UI-HUD-ExperienceBar-Fill-Prediction")

FafnyirToolsDB.xpBar.questEnabled=false
feature:Refresh()
assert(xpBar.created.shown==false)
''')

# EllesmereUI mode must preserve dormant legacy XP data without taking ownership.
eui = LuaRuntime(unpack_returned_tuples=True)
eui.execute(r'''
SlashCmdList={};ns={};EllesmereUI={}
C_AddOns={IsAddOnLoaded=function(_,name) return name=="EllesmereUI" end}
FafnyirToolsDB={xpBar={questEnabled=false,future="keep"}}
saved=FafnyirToolsDB.xpBar
''')
eui_ns = eui.globals().ns
eui.execute((ADDON / "Core/Bootstrap.lua").read_text(), "FafnyirTools", eui_ns)
eui.execute((ADDON / "Modules/XPBar.lua").read_text(), "FafnyirTools", eui_ns)
eui.execute("function time() return 123 end")
eui.execute((ADDON / "Modules/GlobalSettings.lua").read_text(), "FafnyirTools", eui_ns)
eui.execute(r'''
assert(ns.defaults.xpBar==nil and ns.modules.XPBar==nil)
ns:InitializeDatabase()
assert(FafnyirToolsDB.xpBar==saved and saved.questEnabled==false and saved.future=="keep")
local payload=ns.modules.GlobalSettings:Decode(ns.modules.GlobalSettings:Export())
assert(payload.settings.xpBar==nil)
''')

events = (ADDON / "Core/Events.lua").read_text()
assert "if not ns.HAS_ELLESMEREUI then" in events
for event in (
    "PLAYER_XP_UPDATE", "UPDATE_EXHAUSTION", "QUEST_LOG_UPDATE",
    "QUEST_WATCH_UPDATE", "QUEST_ACCEPTED", "QUEST_REMOVED",
    "QUEST_TURNED_IN", "QUEST_DATA_LOAD_RESULT",
):
    assert f'events:RegisterEvent("{event}")' in events

source = (ADDON / "Modules/XPBar.lua").read_text()
assert 'if ns.HAS_ELLESMEREUI then return end' in source
assert 'StatusTrackingBarInfo.BarsEnum.Experience' in source
assert 'overlay = bar:CreateTexture(nil, "ARTWORK", nil, -2)' in source
assert 'bar.StatusBar:GetStatusBarTexture()' in source

print("PASS standalone native XP gradients, quest layering, defaults, restoration and EllesmereUI isolation")
