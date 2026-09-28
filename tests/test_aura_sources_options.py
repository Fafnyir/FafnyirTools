from pathlib import Path
import sys,zipfile
from lupa.lua51 import LuaRuntime
root=Path(__file__).resolve().parents[1]/'src/FafnyirTools'
setup='''
SlashCmdList={}; ns={}; source='blizzard'; loaded=true; calls=0; rows={}; created={}; timers={}
C_AddOns={IsAddOnLoaded=function() return loaded end}
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
STANDARD_TEXT_FONT='test'
function newFrame()
 return {RegisterEvent=function() end,SetScript=function(self,_,fn) self.event=fn end,
 HookScript=function(self,_,fn) self.hook=fn end,GetFrameLevel=function() return 1 end,
 ClearAllPoints=function() end,SetPoint=function() end,SetAuraGroupMaxFrameCount=function() end,
 SetAuraGroupLayout=function() end,SetShown=function(self,v) self.shown=v end,
 Hide=function(self) self.shown=false end,UpdateAllAuras=function(self) self.updates=(self.updates or 0)+1 end}
end
CreateFrame=function() eventFrameMock=newFrame(); return eventFrameMock end
native={alpha=1,SetAlpha=function(self,v) self.alpha=v end}
TargetFrame=newFrame(); TargetFrame.GetAuraContainer=function() return native end
EllesmereUI={_ModuleNS={EllesmereUIUnitFrames={GetUnitFrameSource=function(unit)
 assert(unit=='target'); calls=calls+1; return source end}},Widgets={}}
EllesmereUI.GetBorderTextureDropdown=function() return {},{} end
EllesmereUI.Widgets.SectionHeader=function() return {},20 end
EllesmereUI.Widgets.DualRow=function(_,_,_,left,right) rows[#rows+1]={left,right}; return {},40 end
EllesmereUI.AuraKit={styles={},CreateContainerShell=function(parent)
 assert(parent==TargetFrame); local f=newFrame(); created[#created+1]=f; return f end,
 SetContainerRowWidth=function(container,width) container.rowWidth=width end,AddGroupToContainer=function() end,FinishContainer=function(_,unit) assert(unit=='target') end}
'''
def runtime(source='blizzard',loaded=True):
 l=LuaRuntime(unpack_returned_tuples=True); l.execute(setup)
 l.globals().source=source; l.globals().loaded=loaded
 run=l.eval('function(s,ns) assert(loadstring(s))("FafnyirTools",ns) end')
 for n in ['Core/Bootstrap.lua','Modules/AuraSkins.lua']: run((root/n).read_text(),l.globals().ns)
 return l
for source,loaded,available in [('blizzard',True,True),('eui',True,False),('hidden',True,False),('invalid',True,False),('eui',False,True)]:
 l=runtime(source,loaded)
 l.globals().expected=available
 l.execute('''
 FafnyirToolsDB.auraSkins.enabled=true
 local f=ns.modules.AuraSkins
 assert(f:IsAvailable()==expected); f:Initialize(); f:BuildOptions({},0)
 if expected then
  assert(#created==2 and native.alpha==0 and rows[1][1].type=='toggle')
  assert(rows[1][1].text=='Enable Target Aura Skins' and rows[1][2].text=='Target Aura Size')
  assert(rows[2][1].text=='Target Buff Icon Zoom' and rows[2][2].text=='Target Debuff Icon Zoom')
  assert(rows[3][1].text=='Show Target Duration Text' and rows[3][2].text=='Target Aura Text Size')
  assert(rows[4][1].text=='Target Duration Format' and rows[4][2].type=='label')
  assert(created[1].shown and created[2].shown)
  for _,size in ipairs({16,32,60}) do
   FafnyirToolsDB.auraSkins.targetIconSize=size; f:Refresh()
   for _,container in ipairs(created) do
    assert(math.abs(container.rowWidth-(6*size+5+0.4))<0.0001)
    assert(6*size+5 <= container.rowWidth and 7*size+6 > container.rowWidth)
   end
  end
  local updates=created[1].updates
  eventFrameMock.event(nil,'PLAYER_TARGET_CHANGED'); assert(created[1].updates==updates+1)
  FafnyirToolsDB.auraSkins.enabled=false
  eventFrameMock.event(nil,'PLAYER_TARGET_CHANGED'); assert(created[1].updates==updates+1)
  FafnyirToolsDB.auraSkins.enabled=true
  TargetFrame.hook(); FafnyirToolsDB.auraSkins.enabled=false
  for _,fn in ipairs(timers) do fn() end
  assert(created[1].updates==updates+1)
  FafnyirToolsDB.auraSkins.enabled=true; FafnyirToolsDB.auraSkins.targetAuras=false; f:Refresh()
  assert(not created[1].shown and not created[2].shown and native.alpha==1)
 else assert(#created==0 and native.alpha==1 and rows[1][1].type=='label') end
 ''')
print('PASS availability matrix, target container initialization, options gating, aura updates, disabled/deferred guards, native restoration')
for source in ['eui','blizzard','hidden']:
 l=runtime(source)
 l.execute("local f=ns.modules.AuraSkins; local before=f:IsAvailable(); source=source=='blizzard' and 'eui' or 'blizzard'; assert(f:IsAvailable()==before and calls==1)")
print('PASS pending source changes retain current-session ownership until reload')
l=runtime(); l.execute('''
local euf=EllesmereUI._ModuleNS; EllesmereUI._ModuleNS=nil
local f=ns.modules.AuraSkins; assert(not f:IsAvailable()); f:Initialize(); assert(eventFrameMock==nil)
EllesmereUI._ModuleNS=euf; FafnyirToolsDB.auraSkins.enabled=true
f:HandleEvent('PLAYER_ENTERING_WORLD'); assert(f:IsAvailable() and #created==2)
''')
print('PASS unavailable namespace safely retries on entering world')
l=runtime(); l.execute('''
FafnyirToolsDB.unitFrameSources.target='inherit'
assert(ns.modules.AuraSkins:IsAvailable())
''')
print('PASS inherited Blizzard source resolved through native getter')
l=LuaRuntime(); compile=l.eval('function(s) local f,e=loadstring(s); assert(f,e) end')
for p in root.rglob('*.lua'): compile(p.read_text())

l=runtime()
run=l.eval('function(s,ns) assert(loadstring(s))("FafnyirTools",ns) end')
for n in ['Modules/RightClickSelfCast.lua','Modules/BlizzardBarArt.lua','Modules/FlyoutButtonMatch.lua','Modules/UnitFrameSources.lua']:
 run((root/n).read_text(),l.globals().ns)
l.execute('''
for _,key in ipairs({'About','GlobalSettings','ForeverFog','PermanentCompanionPet','UnitFrameNames','FocusHeader','Resting','DeviceLayout','XPBar','Inventory'}) do
 ns.modules[key]={}
 if key~='ForeverFog' then ns.modules[key].page=key=='GlobalSettings' and 'About' or ((key=='UnitFrameNames' or key=='FocusHeader') and 'Unit Frames' or key) end
end
ns.Sidebar={Install=function() return true end}
function EllesmereUI:RegisterModule(key,c) config=c end
''')
run((root/'Core/Options.lua').read_text(),l.globals().ns)
l.execute('''
assert(ns.Options:Register())
local expected={'About','PermanentCompanionPet','Unit Frames','Resting','Action Bars','XPBar','Inventory','DeviceLayout'}
assert(#config.pages==#expected)
for i,name in ipairs(expected) do assert(config.pages[i]==name) end
-- Record actual widget positions to ensure combined sections never overlap.
headers={}; previousY=nil
EllesmereUI.Widgets.SectionHeader=function(_,parent,text,y)
 assert(previousY==nil or y<=previousY); previousY=y-20
 headers[#headers+1]=text; return {},20
end
EllesmereUI.Widgets.DualRow=function(_,parent,y,left,right)
 assert(previousY==nil or y<=previousY); previousY=y-40
 rows[#rows+1]={left,right}; return {},40
end
rows={}; local bottom=config.buildPage('Action Bars',{},-12)
assert(#headers==3 and #rows==3 and bottom==192)
assert(headers[2]=='BLIZZARD BAR ART' and headers[3]=='FLYOUT FIX')
assert(rows[2][1].getValue()==true and rows[3][1].getValue()==true)
-- Existing saved choices survive adding the restored defaults.
FafnyirToolsDB.blizzardBarArt.enabled=false; FafnyirToolsDB.flyoutFix.enabled=false
ns:InitializeDatabase()
assert(not FafnyirToolsDB.blizzardBarArt.enabled and not FafnyirToolsDB.flyoutFix.enabled)
headers={}; rows={}; previousY=nil
bottom=config.buildPage('Unit Frames',{},-12)
assert(headers[1]=='UNIT FRAME SOURCES' and headers[2]=='AURA SKINS')
assert(bottom>212 and bottom==-previousY)
assert(rows[1][1].text=='Player Frame' and rows[2][1].text=='Target of Target')
assert(rows[3][1].text=='Boss Frames' and rows[3][2].text=='Pet Frame')
assert(rows[5][1].text=='Enable Target Aura Skins')
local terms={}; for _,v in ipairs(config.searchTerms) do terms[v]=true end
assert(terms['aura skins'] and terms['flyout fix'] and terms['bar art'])
''')
print('PASS deduplicated pages, Action Bars restored controls, saved defaults, combined Unit Frames/Aura layout offsets and search terms')
# Flyout Fix is a Retail compatibility shim. Forever must not expose it or
# install any SpellFlyout hooks/retry timers, and must preserve the Retail choice.
flyout_source=' '.join((root/'Modules/FlyoutButtonMatch.lua').read_text().split())
assert 'button and button:IsShown() and button:IsObjectType("CheckButton")' in flyout_source
forever=LuaRuntime(unpack_returned_tuples=True)
forever.execute('''
ns={};SlashCmdList={};timers=0;hooks=0
function GetBuildInfo() return '1.60.1','69913','Sep 27 2026',16001 end
C_Timer={After=function() timers=timers+1 end}
SpellFlyout={HookScript=function() hooks=hooks+1 end}
EllesmereUI={Widgets={}}
''')
frun=forever.eval('function(s,ns) assert(loadstring(s))("FafnyirTools",ns) end')
frun((root/'Core/Bootstrap.lua').read_text(),forever.globals().ns)
frun((root/'Modules/FlyoutButtonMatch.lua').read_text(),forever.globals().ns)
forever.execute('''
local f=ns.modules.FlyoutButtonMatch
assert(ns.IS_FOREVER and #f.searchTerms==0)
ns:GetDatabase().flyoutFix.enabled=false
f:Initialize();f:HandleEvent('PLAYER_ENTERING_WORLD');f:Refresh()
assert(f:BuildOptions({},-37)==37 and timers==0 and hooks==0)
f:Reset();assert(ns:GetDatabase().flyoutFix.enabled==false)
''')
print('PASS Flyout Fix remains Retail-only and inert on Forever')
# Source dropdowns: all three choices, native inherited reads, no migration writes.
l=runtime()
run=l.eval('function(s,ns) assert(loadstring(s))("FafnyirTools",ns) end')
l.execute('''
sourceCalls={}; prompts={}; sources={player='blizzard',target='blizzard',targettarget='blizzard',focus='hidden',boss='eui',pet='blizzard'}
local euf=EllesmereUI._ModuleNS.EllesmereUIUnitFrames
function euf.GetUnitFrameSource(unit) return sources[unit] end
function euf.SetUnitFrameSource(unit,value) sourceCalls[#sourceCalls+1]={unit,value}; sources[unit]=value end
ReloadUI=function() reloads=(reloads or 0)+1 end
function EllesmereUI:ShowConfirmPopup(p) prompts[#prompts+1]=p end
StaticPopupDialogs={}; StaticPopup_Show=function(key) fallback=key end
''')
run((root/'Modules/UnitFrameSources.lua').read_text(),l.globals().ns)
l.execute('''
local f=ns.modules.UnitFrameSources
assert(f:BuildOptions({},0)==180 and #rows==4)
local widgets={rows[1][1],rows[1][2],rows[2][1],rows[2][2],rows[3][1],rows[3][2]}
local units={'player','target','targettarget','focus','boss','pet'}
assert(f:ApplySaved() and #sourceCalls==0)
for i,w in ipairs(widgets) do
 assert(w.getValue()==sources[units[i]])
 assert(ns:GetDatabase().unitFrameSources[units[i]]=='inherit')
 assert(#w.order==3 and w.values.inherit==nil)
 for j,value in ipairs({'eui','blizzard','hidden'}) do
  assert(w.order[j]==value)
  sourceCalls={}; prompts={}; w.setValue(value)
  assert(w.getValue()==value and #sourceCalls==1 and sourceCalls[1][1]==units[i] and sourceCalls[1][2]==value)
  assert(#prompts==1 and prompts[1].confirmText=='Reload Now' and prompts[1].cancelText=='Later')
  assert(prompts[1].reload==true and prompts[1].onConfirm==nil)
 end
 local before=w.getValue(); sourceCalls={}; prompts={}
 w.setValue('inherit'); w.setValue(nil); w.setValue('invalid')
 assert(w.getValue()==before and #sourceCalls==0 and #prompts==0)
end
sourceCalls={}; assert(f:ApplySaved() and #sourceCalls==6)
sourceCalls={}; ns:ResetDatabase()
for _,unit in ipairs(units) do assert(ns:GetDatabase().unitFrameSources[unit]=='eui') end
assert(#sourceCalls==0) -- reset itself does not write sources inside the refresh loop
assert(f:ApplySaved() and #sourceCalls==6)
local resetCalls={};for _,call in ipairs(sourceCalls) do resetCalls[call[1]]=call[2] end
for _,unit in ipairs(units) do assert(resetCalls[unit]=='eui') end
-- Legacy/unset choices resolve on each read, preserving EUI profile changes.
local db=ns:GetDatabase().unitFrameSources
db.focus='inherit'; sources.focus='blizzard'; assert(widgets[4].getValue()=='blizzard')
sources.focus='hidden'; assert(widgets[4].getValue()=='hidden')
db.target=nil; assert(widgets[2].getValue()==sources.target)
-- No guess or crash when source API is absent; saved explicit choices still work.
EllesmereUI._ModuleNS=nil
assert(widgets[4].getValue()==nil and widgets[1].getValue()=='eui')
ns.Print=function() end; widgets[4].setValue('blizzard')
assert(db.focus=='blizzard' and not f:ApplySaved())
''')
print('PASS all 18 source choices, legacy/unset reads, no migration writes, invalid-input guards, secure reload contract, missing API')
