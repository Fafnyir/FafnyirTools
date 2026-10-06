"""Companion restoration, legacy XP migration and real feature page registration."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
ROOT = Path(__file__).resolve().parents[1]/'src/FafnyirTools'
l=LuaRuntime(unpack_returned_tuples=True)
l.execute('''
ns={};SlashCmdList={};rows={};frames={};queue={};now=100;name='Alpha';realm='Realm'
flags={};summons={};randomCalls=0
function UnitFullName() return name,realm end
function UnitName() return name end
function GetRealmName() return realm end
function GetNormalizedRealmName() return realm end
function GetTime() return now end
function InCombatLockdown() return flags.combat end
function UnitAffectingCombat() return flags.affecting end
function UnitIsDeadOrGhost() return flags.dead end
function IsMounted() return flags.mounted end
function IsStealthed() return flags.stealth end
function UnitOnTaxi() return flags.taxi end
function UnitInVehicle() return flags.vehicle end
function IsInInstance() return flags.pvp,'arena' end
C_PetBattles={IsInBattle=function() return flags.battle end}
C_Timer={After=function(delay,fn) queue[#queue+1]=fn end}
function flush() local q=queue;queue={};for _,f in ipairs(q) do f() end end
pets={{id='one',species='Cat',custom='Kitty',owned=true,favorite=true},
      {id='two',species='Dog',owned=true,favorite=false},
      {id='three',species='Cat',owned=false,favorite=true}}
C_PetJournal={GetNumPets=function() return #pets end,
 GetPetInfoByIndex=function(i) local p=pets[i];return p.id,0,p.owned,p.custom,0,p.favorite end,
 GetPetInfoByPetID=function(id) for _,p in ipairs(pets) do if p.id==id then return 0,0,0,0,0,0,0,p.species end end end,
 GetSummonedPetGUID=function() return summoned end,
 SummonPetByGUID=function(id) summons[#summons+1]=id end,
 SummonRandomPet=function(favorite) assert(favorite);randomCalls=randomCalls+1 end}
function CreateFrame()
 local f={events={}};function f:RegisterEvent(e) self.events[e]=true end
 function f:SetScript(_,fn) self.event=fn end
 frames[#frames+1]=f;return f
end
EllesmereUI={Widgets={},_ModuleNS={}}
function EllesmereUI.Widgets:SectionHeader(_,text,y) return {},20 end
function EllesmereUI.Widgets:DualRow(_,y,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI:RegisterModule(key,c) config=c end
''')
def load(path):l.execute((ROOT/path).read_text(),'FafnyirTools',l.globals().ns)
# Upgrade direct from v1.1.1 preserves old colors, false toggle, and companion settings.
l.execute('''FafnyirToolsDB={xpBar={questXPEnabled=false,questXPColor={r=.2,g=.3,b=.4,a=.5}},
 permanentCompanionPet={enabled=true,mode='specific',petName='Kitty'}}''')
load('Core/Bootstrap.lua');load('Modules/PermanentCompanionPet.lua')
l.execute('''
f=ns.modules.PermanentCompanionPet;db=FafnyirToolsDB.permanentCompanionPet
assert(FafnyirToolsDB.xpBar.questXPEnabled==false and FafnyirToolsDB.xpBar.questXPColor.a==.5)
assert(FafnyirToolsDB.xpBar.questEnabled==nil and FafnyirToolsDB.xpBar.questColor==nil)
f:BuildOptions({},0);assert(#rows==4 and rows[1].getValue())
assert(rows[2].getValue()=='specific' and rows[3].getValue()=='Kitty')
assert(db.characterMigrationComplete and db.characters['Alpha-Realm'].petName=='Kitty')
f:Initialize();flush();assert(summons[1]=='one')
-- Existing per-character choices survive, while later characters do not inherit the first.
name='Beta';assert(rows[2].getValue()=='randomFavorite' and rows[3].getValue()=='')
rows[2].setValue('specific');rows[3].setValue('  Dog  ');flush();assert(summons[#summons]=='two')
name='Alpha';assert(rows[3].getValue()=='Kitty');f:Refresh();flush();assert(summons[#summons]=='one')
local before=#summons;summoned='one';f:Refresh();flush();assert(#summons==before);summoned=nil
-- Every safety guard is checked at execution time, including after a queued event.
for _,guard in ipairs({'combat','affecting','dead','mounted','stealth','taxi','vehicle','battle','pvp'}) do
 flags[guard]=true;f:Refresh();flush();assert(#summons==before,guard);flags[guard]=nil
end
f:HandleEvent('PLAYER_STARTED_MOVING');flags.combat=true;flush();assert(#summons==before);flags.combat=nil
f:HandleEvent('COMPANION_UPDATE','MOUNT');assert(#queue==0)
for _,event in ipairs({'PLAYER_STARTED_MOVING','PLAYER_ENTERING_WORLD','ZONE_CHANGED_NEW_AREA',
 'PLAYER_MOUNT_DISPLAY_CHANGED','PLAYER_CONTROL_GAINED','PLAYER_REGEN_ENABLED','PET_JOURNAL_LIST_UPDATE','COMPANION_UPDATE'}) do
 now=now+3;local count=#summons;f:HandleEvent(event,'CRITTER');flush();assert(#summons==count+1,event)
end
local count=#summons;f:HandleEvent('PLAYER_STARTED_MOVING');f:HandleEvent('PLAYER_STARTED_MOVING');assert(#queue==1)
flush();assert(#summons==count) -- two-second throttle
rows[1].setValue(false);flush();assert(#summons==count);rows[1].setValue(true);flush()
rows[2].setValue('randomFavorite');flush();assert(randomCalls==1)
summoned='two';f:Refresh();flush();assert(randomCalls==1);summoned=nil
C_PetJournal.SummonRandomPet=nil;f:Refresh();flush();assert(summons[#summons]=='one')
rows[2].setValue('specific');rows[3].setValue('absent');count=#summons;flush();assert(#summons==count)
name='Beta';f:Reset();flush();assert(rows[2].getValue()=='randomFavorite' and rows[3].getValue()=='')
name='Alpha';assert(rows[3].getValue()=='absent') -- reset only clears current character
-- Forever/current collection API does not require the legacy indexed methods.
C_PetJournal.GetOwnedPetIDs=function() return {'forever-one','forever-two'} end
C_PetJournal.GetPetInfoTableByPetID=function(id)
 if id=='forever-one' then return {name='Fox',customName='Copper',isFavorite=true} end
 return {name='Owl',isFavorite=false}
end
C_PetJournal.GetNumPets=nil;C_PetJournal.GetPetInfoByIndex=nil
rows[1].setValue(true);flush();rows[3].setValue('Copper');now=now+3;flush()
assert(summons[#summons]=='forever-one')
rows[2].setValue('randomFavorite');C_PetJournal.SummonRandomPet=nil;now=now+3;flush()
assert(summons[#summons]=='forever-one')
local saved=C_PetJournal;C_PetJournal=nil;db.enabled=true;f:Refresh();flush();C_PetJournal=saved
''')
print('PASS companion migration, per-character choices/reset, all safety guards, throttle/coalescing, events, modes and missing API')
# Real metadata from all features; no fake feature slots in this registration check.
for path in ['Modules/About.lua','Modules/GlobalSettings.lua','Modules/ForeverFog.lua','Modules/UnitFrameNames.lua','Modules/FocusHeader.lua','Modules/SharedArtwork.lua','Modules/AuraSkins.lua','Modules/Resting.lua',
             'Modules/RightClickSelfCast.lua','Modules/FlyoutButtonMatch.lua','Modules/IconHistoryBorder.lua',
             'Modules/Inventory/Core.lua','Modules/DeviceLayout.lua']:
    load(path)
l.execute('ns.Sidebar={Install=function() return true end}')
load('Core/Options.lua')
l.execute('''
assert(ns.Options:Register());local expected={'About','QoL','Unit Frames','Action Bars','Bags & Inventory','Layouts'}
assert(#config.pages==#expected);for i,p in ipairs(expected) do assert(config.pages[i]==p,p) end
rows={};assert(config.buildPage('QoL',{},0)==160 and #rows==6)
-- Restored About history wraps without assuming a fixed 22-pixel text height.
fonts={}
function EllesmereUI.MakeFont()
 local fs={SetPoint=function() end,SetJustifyH=function() end,SetWordWrap=function() end,
 SetText=function(self,text) self.text=text end,GetStringHeight=function() return 44 end,
 SetHeight=function(self,h) self.height=h end}
 fonts[#fonts+1]=fs;return fs
end
assert(config.buildPage('About',{},0)>0)
local credit=false
for _,fs in ipairs(fonts) do assert(fs.height==48);if fs.text:find('raine') then credit=true end end
assert(credit)
-- Slash navigation follows Resting into Unit Frames.
function EllesmereUI:NavigateToElementSettings(key,page) navigated=page end
SlashCmdList.FAFNYIRTOOLS();assert(navigated=='Unit Frames')
-- Isolate event dispatch from unrelated feature initializers.
ns.modules={PermanentCompanionPet=f};ns.Options=nil
''')
load('Core/Events.lua')
l.execute('''
ev=frames[#frames];db.enabled=true;db.characters['Alpha-Realm'].mode='randomFavorite';now=now+3
for _,e in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_STARTED_MOVING','ZONE_CHANGED_NEW_AREA',
 'PLAYER_MOUNT_DISPLAY_CHANGED','PLAYER_CONTROL_GAINED','PLAYER_REGEN_ENABLED','PET_JOURNAL_LIST_UPDATE','COMPANION_UPDATE'}) do
 assert(ev.events[e],e);local count=#summons;now=now+3;ev.event(ev,e,'CRITTER');flush();assert(#summons==count+1,e)
end
''')
print('PASS restored QoL in six real feature pages, slash navigation, legacy XP preference preservation and core companion event dispatch')
