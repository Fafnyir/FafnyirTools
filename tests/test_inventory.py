"""Inventory cache supports targeted character removal and a safe reset-all action."""
from pathlib import Path
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={};SlashCmdList={};rows={};prompts={};refreshes=0
function wipe(t) for k in pairs(t) do t[k]=nil end return t end
function UnitName() return 'Current' end
function GetNormalizedRealmName() return 'Realm' end
function GetRealmName() return 'Realm' end
function UnitClass() return 'Warrior','WARRIOR' end
function GetMoney() return 12345 end
function time() return 100 end
NUM_BAG_SLOTS=4
C_Container={GetContainerNumSlots=function() return 0 end,GetContainerItemInfo=function() end}
C_CurrencyInfo={GetCurrencyListSize=function() return 0 end,GetCurrencyListInfo=function() end}
C_Timer={After=function(_,fn) fn() end}
EllesmereUI={Widgets={}}
function EllesmereUI.Widgets:SectionHeader() return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]=left;rows[#rows+1]=right;return {},40 end
function EllesmereUI:ShowConfirmPopup(p) prompts[#prompts+1]=p end
function EllesmereUI:RefreshPage() refreshes=refreshes+1 end
''')
ns = lua.globals().ns
lua.execute((ROOT / "Core/Bootstrap.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/Inventory/Core.lua").read_text(), "FafnyirTools", ns)
lua.execute((ROOT / "Modules/Inventory/Options.lua").read_text(), "FafnyirTools", ns)
lua.execute(r'''
local f=ns.modules.Inventory
local d=ns:GetDatabase().inventory
d.characters['Current-Realm']={name='Current',realm='Realm',money=12345,bags={},bank={},currencies={}}
d.characters['Alt-Realm']={name='Alt',realm='Realm',money=50000,bags={[1]=2},bank={},currencies={}}
d.characters['Old-Other']={name='Old',realm='Other',money=70000,bags={},bank={},currencies={}}
d.mail['Alt-Realm']={[1]=3};d.auctions['Alt-Realm']={[1]=4}
d.warband.items[1]=9;d.guilds.Guild={items={[1]=8}}
f:BuildOptions({},0)
assert(rows[5].text=='Cached Character' and rows[6].text=='Remove Character')
assert(rows[7].text=='Reset All Characters')
assert(rows[5].values['Alt-Realm']=='Alt - Realm')
assert(rows[5].values['Old-Other']=='Old - Other')
assert(rows[5].values['Current-Realm']==nil)
rows[5].setValue('Alt-Realm');rows[6].onClick()
assert(prompts[1].title=='Remove Cached Character?')
prompts[1].onConfirm()
assert(d.characters['Alt-Realm']==nil and d.mail['Alt-Realm']==nil and d.auctions['Alt-Realm']==nil)
assert(d.characters['Current-Realm'] and d.characters['Old-Other'])
rows[7].onClick();assert(prompts[2].title=='Reset All Tracked Characters?')
prompts[2].onConfirm()
assert(d.characters['Old-Other']==nil)
assert(d.characters['Current-Realm'] and d.characters['Current-Realm'].money==12345)
assert(next(d.mail)==nil and next(d.auctions)==nil)
assert(d.warband.items[1]==9 and d.guilds.Guild.items[1]==8)
assert(refreshes==2)
''')
print("PASS inventory targeted removal, confirmations, reset-all, current rescan, and shared-cache preservation")
