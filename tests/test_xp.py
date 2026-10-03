from pathlib import Path
import sys
from lupa.lua51 import LuaRuntime
lua=LuaRuntime(unpack_returned_tuples=True)
root=Path(__file__).resolve().parents[1]/'src/FafnyirTools'
for p in root.rglob('*.lua'):
    lua.execute('assert(loadstring(...))',p.read_text())
print('PASS: all active Lua files compile under Lua 5.1')
toc=(root/'FafnyirTools.toc').read_text()
for line in toc.splitlines():
    if line and not line.startswith('#'): assert (root/line.replace('\\','/')).is_file(),line
assert '## Version: v1.1.6' in toc
lua.execute('''
ns={}; SlashCmdList={}; queue={}; tickers={}; frames={}; rows={}
C_Timer={After=function(_,f) table.insert(queue,f) end, NewTicker=function(_,f)
 local t={callback=f,Cancel=function(self) self.cancelled=true end}; table.insert(tickers,t); return t end}
function flush() local q=queue;queue={};for _,f in ipairs(q) do f() end end
function CreateFrame()
 local f={scripts={},events={},level=1,w=200,h=10,shown=true}
 function f:RegisterEvent(e) self.events[e]=true end
 function f:SetScript(e,fn) self.scripts[e]=fn end
 function f:HookScript(e,fn) self.scripts[e]=fn end
 function f:GetFrameLevel() return self.level end
 function f:SetFrameLevel(v) self.level=v end
 function f:EnableMouse(v) self.mouse=v end
 function f:SetAllPoints(v) self.allPoints=v or true end
 function f:GetParent() return self.parent end
 function f:CreateFontString() local x=CreateFrame();x.parent=self;return x end
 function f:GetText() return self.text end
 function f:SetText(v) self.text=v end
 function f:GetFont() return self.fontPath or 'font',self.fontSize or 9,self.fontFlags or '' end
 function f:SetFont(p,s,fl) self.fontPath=p;self.fontSize=s;self.fontFlags=fl end
 function f:GetTextColor() return 1,1,1,1 end
 function f:SetTextColor(...) self.textColor={...} end
 function f:GetShadowColor() return 0,0,0,1 end
 function f:SetShadowColor(...) self.shadowColor={...} end
 function f:GetShadowOffset() return 1,-1 end
 function f:SetShadowOffset(...) self.shadowOffset={...} end
 function f:SetJustifyH(v) self.justify=v end
 function f:GetPoint() if self.point then return unpack(self.point) end end
 function f:GetSize() return self.w,self.h end
 function f:SetValue(v) self.value=v end
 function f:SetStatusBarColor(...) self.color={...} end
 function f:GetStatusBarTexture() return self.texture end
 function f:Hide() self.shown=false end
 function f:Show() self.shown=true end
 function f:SetPoint(...) self.point={...} end
 function f:ClearAllPoints() self.point=nil end
 function f:SetSize(w,h) self.w=w;self.h=h end
 function f:SetColorTexture(...) self.color={...} end
 function f:SetVertexColor(...) self.vertex={...} end
 function f:SetGradient(o,a,b) self.gradient={o,a,b} end
 function f:SetDrawLayer(layer,sublevel) self.drawLayer=layer;self.drawSublevel=sublevel end
 function f:CreateTexture(_,layer,_,sublevel) self.overlay=CreateFrame();self.overlay:SetDrawLayer(layer,sublevel);return self.overlay end
 table.insert(frames,f);return f
end
function hooksecurefunc(obj,key,fn) local old=obj[key];obj[key]=function(...) local ret=old(...);fn(...);return ret end end
function CreateColor(r,g,b,a) return {r=r,g=g,b=b,a=a} end
current=200;maximum=1000;level=40;cap=90;disabled=false
function UnitXP() return current end
function UnitXPMax() return maximum end
function UnitLevel() return level end
restedXP=300
function GetXPExhaustion() return restedXP end
function AbbreviateLargeNumbers(v) return tostring(v) end
LEVEL='Level';RESTED='Rested'
function GetMaxLevelForPlayerExpansion() return cap end
function IsPlayerAtEffectiveMaxLevel() return level>=cap end
function IsXPUserDisabled() return disabled end
quests={{isHeader=true},{questID=1},{questID=2},{questID=3},{questID=1},{questID=4,isHidden=true}}
rewards={[1]=150,[2]=250,[3]=900,[4]=800}; completed={[1]=true,[2]=true,[4]=true}
C_QuestLog={GetNumQuestLogEntries=function() return #quests end,GetInfo=function(i) return quests[i] end,IsComplete=function(id) return completed[id] end}
function GetQuestLogRewardXP(id) assert(id);return rewards[id] end
holder=CreateFrame();nativeBorder=CreateFrame();nativeBorder.parent=holder
textHost=CreateFrame();textHost.parent=holder
holder._text=textHost:CreateFontString();holder._text:SetPoint('CENTER',textHost,'CENTER',0,0);holder._text:SetText('native')
holder._border={_frame=nativeBorder,edges=CreateFrame()}
bar=CreateFrame();bar.parent=holder;bar.texture=CreateFrame()
rested=CreateFrame();rested.texture=CreateFrame()
bar.texture:SetDrawLayer('ARTWORK',4);rested.texture:SetDrawLayer('ARTWORK',2)
EllesmereEAB_XPBar_Bar=bar;EllesmereEAB_XPBar_Rested=rested
holder._updateFunc=function() bar:SetStatusBarColor(1,1,1);rested:SetStatusBarColor(1,1,1);holder._text:SetText('native') end
borderApplyCalls=0
EllesmereUI={Widgets={},BuildColorSwatch=function() return CreateFrame(),function() end end,
 GetBorderTextureDropdown=function() error('XP border options belong to EllesmereUI') end,
 ApplyBorderStyle=function() borderApplyCalls=borderApplyCalls+1 end}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:Spacer() return {},18 end
function EllesmereUI.Widgets:DualRow(parent,y,left,right)
 table.insert(rows,left);table.insert(rows,right);return {_leftRegion=CreateFrame(),_rightRegion=CreateFrame()},30 end
function EllesmereUI:RegisterModule(key,config) registered=config end
''')
def run(path):lua.execute((root/path).read_text(),'FafnyirTools',lua.globals().ns)
run('Core/Bootstrap.lua');run('Modules/XPBar.lua')
lua.execute('''
f=ns.modules.XPBar;db=ns:GetDatabase().xpBar
assert(db.startColor.r==85/255 and db.startColor.g==99/255 and db.endColor.r==197/255 and db.endColor.g==97/255)
assert(db.restedStartColor.r==79/255 and db.restedStartColor.g==143/255 and db.restedStartColor.a==1 and db.restedEndColor.a==1)
assert(db.questColor.r==1 and db.questColor.g==150/255 and db.questColor.b==0 and db.questColor.a==1)
f:Initialize();o=bar.overlay;assert(o.shown and o.w==80 and o.point[4]==40) -- 400 quest XP, excludes incomplete/hidden/duplicate
assert(bar.texture.drawSublevel==4 and rested.texture.drawSublevel==2 and o.drawLayer=='ARTWORK' and o.drawSublevel==1)
flush();assert(holder._text.text=='native')
assert(borderApplyCalls==0 and nativeBorder.level==1)
assert(db.enabled==false) -- quest segment independent of gradient
current=900;bar:SetValue(current);assert(o.w==20 and o.point[4]==180)
bar.w=400;bar.scripts.OnSizeChanged();assert(o.w==40 and o.point[4]==360)
level=90;f:Refresh();assert(not o.shown)
level=40;maximum=0;f:Refresh();assert(not o.shown)
maximum=1000;completed={};f:Refresh();assert(not o.shown)
completed={[1]=true};current=200;f:Refresh();assert(o.shown and o.w==60)
disabled=true;f:Refresh();assert(not o.shown);disabled=false
f:BuildOptions(CreateFrame(),0)
for _,r in ipairs(rows) do assert(r.text~='Enable Three-Zone XP Text') end
for _,r in ipairs(rows) do if r.text=='Enable Quest XP Overlay' then toggle=r end end
assert(toggle and toggle.getValue());toggle.setValue(false);assert(not o.shown);toggle.setValue(true);assert(o.shown)
for _,r in ipairs(rows) do assert(r.text~='Border Size' and r.text~='Border Style') end
db.startColor={r=.2,g=.3,b=.4,a=.5};db.questColor={r=.8,g=.7,b=.6,a=.4};db.questEnabled=false
db.borderColor={r=.8,g=.6,b=.4,a=.2};db.customTextEnabled=false;ns:InitializeDatabase();assert(db.startColor.a==.5 and db.questColor.g==.7 and db.questEnabled==false and db.borderColor.a==.2 and db.customTextEnabled==false)
assert(ns.defaults.xpBar.borderColor==nil and ns.defaults.xpBar.borderSize==nil and ns.defaults.xpBar.customTextEnabled==nil and borderApplyCalls==0)
db.questEnabled=true;db.enabled=true;f:Refresh();assert(o.color[4]==.4 and bar.texture.gradient[2].r==.2)
flush();assert(holder._text.text=='native')
''')
print('PASS: totals, clipping, resizing, max level, zero XP, disabled XP, toggle, defaults, saved settings, gradients')
# Fill feature slots so the real options registration can be exercised independently of other module APIs.
lua.execute('''
for _,k in ipairs({'About','GlobalSettings','ForeverFog','PermanentCompanionPet','UnitFrameNames','FocusHeader','Resting','RightClickSelfCast','FlyoutButtonMatch','IconHistoryBorder','DeviceLayout','AuraSkins','Inventory'}) do ns.modules[k]={page=k=='GlobalSettings' and 'About' or ((k=='UnitFrameNames' or k=='FocusHeader') and 'Unit Frames' or k)} end
ns.Sidebar={Install=function() return true end}
''')
run('Core/Options.lua');run('Core/Events.lua')
lua.execute('''
ev=frames[#frames];ev.scripts.OnEvent(ev,'PLAYER_LOGIN');flush();assert(ns.state.optionsRegistered and registered)
local hasXP=false;for _,p in ipairs(registered.pages) do if p=='XP & Progression' then hasXP=true end end;assert(hasXP)
assert(registered.buildPage('XP & Progression',CreateFrame(),0)>0)
for _,e in ipairs({'PLAYER_ENTERING_WORLD','PLAYER_XP_UPDATE','PLAYER_LEVEL_UP','UPDATE_EXHAUSTION','QUEST_LOG_UPDATE','QUEST_WATCH_UPDATE','QUEST_ACCEPTED','QUEST_REMOVED','QUEST_TURNED_IN','QUEST_DATA_LOAD_RESULT'}) do
 assert(ev.events[e],e);completed={};ev.scripts.OnEvent(ev,e);flush();assert(not o.shown,e)
 completed={[2]=true};ev.scripts.OnEvent(ev,e);flush();assert(o.shown and o.w==100,e)
end
-- Late bar creation: initialization retries and installs hooks once available.
EllesmereEAB_XPBar_Bar=nil;f:Refresh();assert(#tickers>0)
EllesmereEAB_XPBar_Bar=bar;tickers[#tickers].callback();assert(tickers[#tickers].cancelled)
''')
print('PASS: login, all quest/XP events, options registration/build, delayed bar availability')
