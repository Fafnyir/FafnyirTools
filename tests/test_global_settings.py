from pathlib import Path
from lupa.lua51 import LuaRuntime

root = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("SlashCmdList={}; ns={}; function time() return 12345 end")
lua.execute((root / "Core/Bootstrap.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute((root / "Modules/GlobalSettings.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute(r'''
local f=ns.modules.GlobalSettings
local db=ns:GetDatabase()
db.blizzardBarArt={enabled=false,scaleMultiplier=1.01}
db.unitFrameSources={player='hidden',target='blizzard'}
db.xpBar.enabled=true
db.xpBar.startColor={r=.2,g=.3,b=.4,a=.5,unknown="drop"}
db.xpBar.borderSize=3
db.xpBar.borderColor={r=.8,g=.6,b=.4,a=.2}
db.xpBar.customTextEnabled=false
db.foreverFog.enabled=false
db.permanentCompanionPet.enabled=true
db.permanentCompanionPet.characters={['Tester-Realm']={mode='specific',petName='Secret Pet'}}
db.inventory.characters={['Tester-Realm']={money=999,items={123}}}
db.inventory.tooltips=false
db.deviceLayout.presetIndex=7
db.futureSetting={keep=true}
db.sharedArtwork={arrow='background:- Arrow Glow',roles=true,unknown='keep'}

local exported=f:Export()
assert(exported:sub(1,15)=='FAFNYIRTOOLS:1:')
local payload,err=f:Decode(exported);assert(payload and not err)
assert(payload.addonVersion=='v1.1.6' and payload.format==1)
assert(payload.settings.xpBar.enabled==true and payload.settings.xpBar.startColor.a==.5)
assert(payload.settings.xpBar.startColor.unknown==nil)
assert(payload.settings.xpBar.borderSize==nil and payload.settings.xpBar.borderColor==nil)
assert(payload.settings.xpBar.customTextEnabled==nil)
assert(payload.settings.blizzardBarArt==nil and payload.settings.unitFrameSources==nil)
assert(payload.settings.foreverFog.enabled==false and payload.settings.foreverFog.initialized==nil)
assert(payload.settings.permanentCompanionPet.enabled==true)
assert(payload.settings.permanentCompanionPet.characters==nil)
assert(payload.settings.inventory.tooltips==false and payload.settings.inventory.characters==nil)
assert(payload.settings.deviceLayout==nil and payload.settings.futureSetting==nil)
assert(payload.settings.sharedArtwork.arrow=='background:- Arrow Glow' and payload.settings.sharedArtwork.roles)
assert(payload.settings.sharedArtwork.unknown==nil)

db.xpBar.enabled=false;db.xpBar.startColor.a=.9;db.inventory.tooltips=true
db.sharedArtwork.arrow='native';db.sharedArtwork.roles=false
f:ApplyImport(payload)
assert(db.sharedArtwork.arrow=='background:- Arrow Glow' and db.sharedArtwork.roles and db.sharedArtwork.unknown=='keep')
assert(db.xpBar.enabled==true and db.xpBar.startColor.a==.5 and db.inventory.tooltips==false)
assert(db.xpBar.borderSize==3 and db.xpBar.borderColor.a==.2)
assert(db.xpBar.customTextEnabled==false)
assert(db.deviceLayout.presetIndex==7 and db.futureSetting.keep)
assert(db.blizzardBarArt.enabled==false and db.blizzardBarArt.scaleMultiplier==1.01)
assert(db.unitFrameSources.player=='hidden' and db.unitFrameSources.target=='blizzard')
assert(db.permanentCompanionPet.characters['Tester-Realm'].petName=='Secret Pet')
assert(db.inventory.characters['Tester-Realm'].money==999)
assert(db.globalSettingsImportBackup.created==12345)
assert(db.globalSettingsImportBackup.settings.xpBar.enabled==false)
assert(f:RestoreBackup() and db.xpBar.enabled==false and db.xpBar.startColor.a==.9)
assert(db.sharedArtwork.arrow=='native' and not db.sharedArtwork.roles)

assert(not f:Decode(''))
assert(not f:Decode('OTHER:1:T0:'))
assert(not f:Decode(exported..'junk'))
assert(not f:Decode('FAFNYIRTOOLS:1:T1:S6:formatN1:2'))
''')
print("PASS: global settings round-trip, exclusions, validation, merge, preservation and rollback")
