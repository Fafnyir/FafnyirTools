"""External artwork retains native visibility, lifecycle and saved preferences."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / 'src/FafnyirTools'
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={}; SlashCmdList={}; rows={}; frames={}; timers={}
function CreateFrame()
 local f={events={}}
 function f:RegisterEvent(e) self.events[e]=true end
 function f:SetScript(_,fn) self.callback=fn end
 frames[#frames+1]=f;return f
end
C_Timer={After=function(_,fn) timers[#timers+1]=fn end}
function flush() local t=timers;timers={};for _,fn in ipairs(t) do fn() end end
function hooksecurefunc(obj,key,fn)
 local old=obj[key];obj[key]=function(...) old(...);fn(...) end
end
function texture(path)
 local t={path=path,coords={.1,.9,.2,.8},shown=true,w=11,color='native'}
 function t:GetTexture() return self.path end
 function t:GetTexCoord() return unpack(self.coords) end
 function t:SetTexture(p) self.path=p end
 function t:SetTexCoord(...) self.coords={...} end
 function t:IsShown() return self.shown end
 return t
end
media={data={}}
function media.RegisterCallback(owner,event,fn) media.callback=fn end
function media:Register(category,key,value)
 self.data[category]=self.data[category] or {};if not self.data[category][key] then
 self.data[category][key]=value;if self.callback then self.callback('LibSharedMedia_Registered',category,key) end end
end
function media:Fetch(category,key) return (self.data[category] or {})[key] end
function media:List(category) local keys={};for k in pairs(self.data[category] or {}) do keys[#keys+1]=k end;table.sort(keys);return keys end
function LibStub() return media end
media:Register('background','- Arrow Glow','Interface\\AddOns\\FafnyirMedia\\Textures\\arrow_glow.tga')
media:Register('background','- Tank','registered-Tank.tga')
media:Register('background','- Healer','registered-Healer.tga')
media:Register('background','- DPS','registered-DPS.tga')
media:Register('background','- Combat','registered-Combat.tga')
function issecretvalue(v) return v=='SECRET' end
plate={leftArrow=texture('left.png'),rightArrow=texture('right.png')}
enp={plates={nameplate1=plate},RefreshAllSettings=function() end}
role='TANK';unit='party1';d={roleIcon=texture('native-role')};s={}
erf={}
function erf._UpdateRoleIcon(data,settings,token) data.roleIcon:SetTexture('native-role');data.roleIcon:SetTexCoord(.1,.9,.2,.8) end
function erf._UpdateRoleIcons() erf._UpdateRoleIcon(d,s,unit) end
EllesmereUI={Widgets={},_ModuleNS={EllesmereUINameplates=enp,EllesmereUIRaidFrames=erf},UnitEffectiveRole=function() return role end}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,a,b) rows={a,b};return {},40 end
''')
ns = lua.globals().ns
for file in ['Core/Bootstrap.lua', 'Modules/SharedArtwork.lua']:
    lua.execute((ROOT / file).read_text(), 'FafnyirTools', ns)
lua.execute(r'''
local f=ns.modules.SharedArtwork;local db=ns:GetDatabase().sharedArtwork
assert(db.arrow=='native' and db.roles==false)
f:Initialize();assert(plate.leftArrow.path=='left.png' and d.roleIcon.path=='native-role')
f:BuildOptions({},0);assert(rows[1].values['background:- Arrow Glow']=='- Arrow Glow')
for _,key in ipairs({'- Tank','- Healer','- DPS','- Combat'}) do
 assert(rows[1].values['background:'..key]==nil)
end
db.arrow='background:- Tank';f:Refresh();f:BuildOptions({},0)
assert(plate.leftArrow.path=='left.png' and db.arrow=='background:- Tank')
assert(rows[1].values['background:- Tank']==nil and rows[1].getValue()=='native')
rows[1].setValue('background:- Arrow Glow');assert(plate.leftArrow.path:find('arrow_glow.tga',1,true))
assert(plate.leftArrow.coords[1]==0 and plate.rightArrow.coords[1]==1)
assert(plate.leftArrow.w==11 and plate.leftArrow.color=='native' and plate.leftArrow.shown)
plate.leftArrow:SetTexture('new-left.png');assert(plate.leftArrow.path:find('arrow_glow',1,true))
rows[1].setValue('native');assert(plate.leftArrow.path=='new-left.png' and plate.leftArrow.coords[1]==.1)
media:Register('targetarrow','Paired',{left='custom-left.tga',right='custom-right.tga'})
db.arrow='Paired';f:Refresh();assert(plate.leftArrow.path=='custom-left.tga' and plate.rightArrow.path=='custom-right.tga')
db.arrow='Missing';f:Refresh();assert(plate.leftArrow.path=='new-left.png' and db.arrow=='Missing')
f:BuildOptions({},0);assert(rows[1].values.Missing=='Missing (unavailable)')
db.arrow='background:Late Arrow';f:Refresh();assert(plate.leftArrow.path=='new-left.png')
media:Register('background','Late Arrow','late.tga');assert(plate.leftArrow.path=='late.tga')
rows[2].setValue(true);assert(d.roleIcon.path=='registered-Tank.tga')
role='HEALER';erf._UpdateRoleIcons();assert(d.roleIcon.path:find('Healer',1,true))
role='DAMAGER';unit='raid3';erf._UpdateRoleIcons();assert(d.roleIcon.path:find('DPS',1,true))
unit='player';erf._UpdateRoleIcons();assert(d.roleIcon.path=='native-role')
d._isParty=true;erf._UpdateRoleIcons();assert(d.roleIcon.path=='registered-DPS.tga')
d._isParty=nil;unit='party1';d._isExtra=true;erf._UpdateRoleIcons();assert(d.roleIcon.path=='native-role');d._isExtra=nil
unit='party1';d.roleIcon.shown=false;erf._UpdateRoleIcons();assert(d.roleIcon.path=='native-role' and not d.roleIcon.shown)
d.roleIcon.shown=true;role='SECRET';erf._UpdateRoleIcons();assert(d.roleIcon.path=='native-role')
role='TANK';unit='SECRET';erf._UpdateRoleIcons();assert(d.roleIcon.path=='native-role')
unit='party1';rows[2].setValue(false);assert(d.roleIcon.path=='native-role' and d.roleIcon.coords[1]==.1)
-- Native lazy arrow creation after first target change, then pooled reuse.
local loader=frames[1];assert(loader.events.PLAYER_TARGET_CHANGED)
local fresh={leftArrow=texture('lazy-left'),rightArrow=texture('lazy-right')}
enp.plates.nameplate2=fresh;db.arrow='Paired'
loader.callback(loader,'PLAYER_TARGET_CHANGED');flush();assert(fresh.leftArrow.path=='custom-left.tga')
fresh.leftArrow:SetTexture('reused-native');assert(fresh.leftArrow.path=='custom-left.tga')
f:Reset();assert(fresh.leftArrow.path=='reused-native' and db.arrow=='native' and not db.roles)
-- Missing host/library is inert, saved choices survive and install later.
EllesmereUI._ModuleNS={};LibStub=nil;db.arrow='Paired';db.roles=true;f:Refresh()
ns:InitializeDatabase();assert(db.arrow=='Paired' and db.roles)
EllesmereUI._ModuleNS.EllesmereUIRaidFrames=erf;f:Refresh()
assert(d.roleIcon.path:find('Tank',1,true))
''')
print('PASS SharedMedia arrows, paired/mirrored paths, native restoration, lazy pools, Party/Raid roles, visibility and secret guards')
