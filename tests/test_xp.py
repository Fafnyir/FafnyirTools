"""XP ownership retirement: no runtime, events, controls or settings mutations."""
from pathlib import Path
from lupa.lua51 import LuaRuntime
root=Path(__file__).resolve().parents[1]/'src/FafnyirTools'
assert not (root/'Modules/XPBar.lua').exists()
for name in ['Core/Options.lua','FafnyirTools.toc']:
    assert 'XPBar' not in (root/name).read_text()
events=(root/'Core/Events.lua').read_text()
for event in ['PLAYER_XP_UPDATE','UPDATE_EXHAUSTION','QUEST_LOG_UPDATE','QUEST_WATCH_UPDATE','QUEST_ACCEPTED','QUEST_REMOVED','QUEST_TURNED_IN','QUEST_DATA_LOAD_RESULT']:
    assert event not in events
assert 'PLAYER_LEVEL_UP' in events  # Resting still needs this event.
lua=LuaRuntime(unpack_returned_tuples=True)
lua.execute("ns={};SlashCmdList={};FafnyirToolsDB={xpBar={questEnabled=false,restedEnabled=true,questColor={r=.2,a=.4},future='keep'}};saved=FafnyirToolsDB.xpBar")
lua.execute((root/'Core/Bootstrap.lua').read_text(),'FafnyirTools',lua.globals().ns)
lua.execute("assert(ns.defaults.xpBar==nil and ns.modules.XPBar==nil);ns:InitializeDatabase();assert(FafnyirToolsDB.xpBar==saved and saved.questColor.a==.4 and saved.questEnabled==false and saved.future=='keep');FafnyirToolsDB=nil;ns:InitializeDatabase();assert(FafnyirToolsDB.xpBar==nil)")
print('PASS XP module/options/events retired, legacy settings preserved, fresh installs omit XP defaults')
