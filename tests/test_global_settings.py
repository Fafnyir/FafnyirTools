from pathlib import Path
from lupa.lua51 import LuaRuntime

root = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("SlashCmdList={}; ns={}; function time() return 12345 end")
lua.execute((root / "Core/Bootstrap.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute((root / "Modules/GlobalSettings.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute(r'''
local f=ns.modules.GlobalSettings
sourceSyncs=0
ns.modules.UnitFrameSources={ApplySaved=function() sourceSyncs=sourceSyncs+1;return true end}
ns.modules.UnitFrameSources.Refresh=ns.modules.UnitFrameSources.ApplySaved
local db=ns:GetDatabase()
db.xpBar.enabled=true
db.xpBar.startColor={r=.2,g=.3,b=.4,a=.5,unknown="drop"}
db.unitFrameSources.pet="hidden"
db.permanentCompanionPet.enabled=true
db.permanentCompanionPet.characters={['Tester-Realm']={mode='specific',petName='Secret Pet'}}
db.inventory.characters={['Tester-Realm']={money=999,items={123}}}
db.inventory.tooltips=false
db.deviceLayout.presetIndex=7
db.futureSetting={keep=true}

local exported=f:Export()
assert(exported:sub(1,15)=='FAFNYIRTOOLS:1:')
local payload,err=f:Decode(exported);assert(payload and not err)
assert(payload.addonVersion=='v1.1.3' and payload.format==1)
assert(payload.settings.xpBar.enabled==true and payload.settings.xpBar.startColor.a==.5)
assert(payload.settings.xpBar.startColor.unknown==nil)
assert(payload.settings.permanentCompanionPet.enabled==true)
assert(payload.settings.permanentCompanionPet.characters==nil)
assert(payload.settings.inventory.tooltips==false and payload.settings.inventory.characters==nil)
assert(payload.settings.deviceLayout==nil and payload.settings.futureSetting==nil)

db.xpBar.enabled=false;db.xpBar.startColor.a=.9;db.inventory.tooltips=true
f:ApplyImport(payload)
assert(sourceSyncs==1)
assert(db.xpBar.enabled==true and db.xpBar.startColor.a==.5 and db.inventory.tooltips==false)
assert(db.deviceLayout.presetIndex==7 and db.futureSetting.keep)
assert(db.permanentCompanionPet.characters['Tester-Realm'].petName=='Secret Pet')
assert(db.inventory.characters['Tester-Realm'].money==999)
assert(db.globalSettingsImportBackup.created==12345)
assert(db.globalSettingsImportBackup.settings.xpBar.enabled==false)
assert(f:RestoreBackup() and sourceSyncs==2 and db.xpBar.enabled==false and db.xpBar.startColor.a==.9)

assert(not f:Decode(''))
assert(not f:Decode('OTHER:1:T0:'))
assert(not f:Decode(exported..'junk'))
assert(not f:Decode('FAFNYIRTOOLS:1:T1:S6:formatN1:2'))

db.xpBar.startColor.r=.123;db.inventory.characters={Keep={money=77}}
ns:DisableAllFeatures()
assert(sourceSyncs==3 and db.xpBar.startColor.r==.123 and db.inventory.characters.Keep.money==77)
assert(not db.blizzardBarArt.enabled and not db.flyoutFix.enabled and not db.permanentCompanionPet.enabled)
assert(not db.resting.enabled and not db.rightClickSelfCast.enabled and not db.deviceLayout.enabled)
assert(not db.inventory.enabled and not db.xpBar.enabled and not db.xpBar.questEnabled and not db.xpBar.restedEnabled)
assert(not db.auraSkins.enabled and not db.auraSkins.targetAuras)
for _,unit in ipairs({'player','target','targettarget','focus','boss','pet'}) do assert(db.unitFrameSources[unit]=='eui') end

ns:ResetDatabase();db=ns:GetDatabase();assert(sourceSyncs==4)
for _,unit in ipairs({'player','target','targettarget','focus','boss','pet'}) do assert(db.unitFrameSources[unit]=='eui') end
assert(db.blizzardBarArt.enabled and db.flyoutFix.enabled and db.rightClickSelfCast.enabled)
''')
print("PASS: global settings round-trip, exclusions, validation, merge, rollback, disable-all and reset defaults")
