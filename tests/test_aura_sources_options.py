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
l=LuaRuntime(); compile=l.eval('function(s) local f,e=loadstring(s); assert(f,e) end')
for p in root.rglob('*.lua'): compile(p.read_text())

l=runtime()
run=l.eval('function(s,ns) assert(loadstring(s))("FafnyirTools",ns) end')
for n in ['Modules/RightClickSelfCast.lua','Modules/FlyoutButtonMatch.lua']:
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
assert(#headers==2 and #rows==2 and bottom==132)
assert(headers[2]=='FLYOUT FIX' and rows[2][1].getValue()==true)
-- Existing saved choices survive adding defaults.
FafnyirToolsDB.flyoutFix.enabled=false
ns:InitializeDatabase()
assert(not FafnyirToolsDB.flyoutFix.enabled)
headers={}; rows={}; previousY=nil
bottom=config.buildPage('Unit Frames',{},-12)
assert(headers[1]=='AURA SKINS')
assert(bottom>0 and bottom==-previousY)
assert(rows[1][1].text=='Enable Target Aura Skins')
local terms={}; for _,v in ipairs(config.searchTerms) do terms[v]=true end
assert(terms['aura skins'] and terms['flyout fix'] and not terms['bar art'] and not terms['frame source'])
''')
print('PASS deduplicated pages, retired options absent, active layout offsets and search terms')
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
