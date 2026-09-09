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
assert '## Version: v1.1.2' in toc
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
 function f:CreateTexture() self.overlay=CreateFrame();return self.overlay end
 table.insert(frames,f);return f
end
function hooksecurefunc(obj,key,fn) local old=obj[key];obj[key]=function(...) local ret=old(...);fn(...);return ret end end
function CreateColor(r,g,b,a) return {r=r,g=g,b=b,a=a} end
current=200;maximum=1000;level=40;cap=90;disabled=false
function UnitXP() return current end
function UnitXPMax() return maximum end
function UnitLevel() return level end
function GetMaxLevelForPlayerExpansion() return cap end
function IsPlayerAtEffectiveMaxLevel() return level>=cap end
function IsXPUserDisabled() return disabled end
quests={{isHeader=true},{questID=1},{questID=2},{questID=3},{questID=1},{questID=4,isHidden=true}}
rewards={[1]=150,[2]=250,[3]=900,[4]=800}; completed={[1]=true,[2]=true,[4]=true}
C_QuestLog={GetNumQuestLogEntries=function() return #quests end,GetInfo=function(i) return quests[i] end,IsComplete=function(id) return completed[id] end}
function GetQuestLogRewardXP(id) assert(id);return rewards[id] end
holder=CreateFrame();nativeBorder=CreateFrame();nativeBorder.parent=holder
holder._border={_frame=nativeBorder,edges=CreateFrame()}
bar=CreateFrame();bar.parent=holder;bar.texture=CreateFrame()
rested=CreateFrame();rested.texture=CreateFrame()
EllesmereEAB_XPBar_Bar=bar;EllesmereEAB_XPBar_Rested=rested
holder._updateFunc=function() bar:SetStatusBarColor(1,1,1);rested:SetStatusBarColor(1,1,1) end
EllesmereUI={Widgets={},BuildColorSwatch=function() return CreateFrame(),function() end end,
 GetBorderTextureDropdown=function() return {solid='Solid'},{'solid'} end,
 GetBorderStyleSelectDefaults=function() return {r=.1,g=.2,b=.3,a=.4},false end,
 GetBorderDefaultSize=function() return 2 end,
 ApplyBorderStyle=function(frame,size,r,g,b,a,texture,offsetX,offsetY,shiftX,shiftY,addonKey)
  frame.appliedBorder={size,r,g,b,a,texture,offsetX=offsetX,offsetY=offsetY,addonKey=addonKey}
 end}
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
border=nativeBorder;assert(border.level==bar.level+1 and border.appliedBorder[1]==1 and border.appliedBorder[2]==0 and border.appliedBorder[6]=='solid')
assert(db.enabled==false) -- quest segment independent of gradient
current=900;bar:SetValue(current);assert(o.w==20 and o.point[4]==180)
bar.w=400;bar.scripts.OnSizeChanged();assert(o.w==40 and o.point[4]==360)
level=90;f:Refresh();assert(not o.shown)
level=40;maximum=0;f:Refresh();assert(not o.shown)
maximum=1000;completed={};f:Refresh();assert(not o.shown)
completed={[1]=true};current=200;f:Refresh();assert(o.shown and o.w==60)
disabled=true;f:Refresh();assert(not o.shown);disabled=false
f:BuildOptions(CreateFrame(),0)
for _,r in ipairs(rows) do if r.text=='Enable Quest XP Overlay' then toggle=r end end
assert(toggle and toggle.getValue());toggle.setValue(false);assert(not o.shown);toggle.setValue(true);assert(o.shown)
for _,r in ipairs(rows) do if r.text=='Border Size' then borderSize=r elseif r.text=='Border Style' then borderStyle=r end end
assert(borderSize and borderStyle);borderSize.setValue(0);assert(border.appliedBorder[1]==0)
borderStyle.setValue('solid');assert(db.borderSize==0 and db.borderColor.r==.1 and db.borderColor.a==.4)
assert(border.appliedBorder.addonKey==nil) -- use each texture's built-in offset defaults
db.startColor={r=.2,g=.3,b=.4,a=.5};db.questColor={r=.8,g=.7,b=.6,a=.4};db.questEnabled=false
db.borderColor={r=.8,g=.6,b=.4,a=.2};ns:InitializeDatabase();assert(db.startColor.a==.5 and db.questColor.g==.7 and db.questEnabled==false and db.borderColor.a==.2)
db.questEnabled=true;db.enabled=true;f:Refresh();assert(o.color[4]==.4 and bar.texture.gradient[2].r==.2)
''')
print('PASS: totals, clipping, resizing, max level, zero XP, disabled XP, toggle, defaults, saved settings, gradients')
# Fill feature slots so the real options registration can be exercised independently of other module APIs.
lua.execute('''
for _,k in ipairs({'About','PermanentCompanionPet','Resting','RightClickSelfCast','BlizzardBarArt','FlyoutButtonMatch','UnitFrameSources','DeviceLayout','AuraSkins','Inventory'}) do ns.modules[k]={page=k} end
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
