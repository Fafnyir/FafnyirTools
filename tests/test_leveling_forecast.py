#!/usr/bin/env python3
"""Verify read-only leveling forecast math and options output."""
from pathlib import Path

from lupa.lua51 import LuaRuntime


ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
ns={modules={}}; rows={}; headers={}; SlashCmdList={}
function ns:RegisterFeature(key, feature) self.modules[key]=feature end
function GetLocale() return 'enUS' end
function UnitLevel() return playerLevel end
function UnitXP() return playerXP end
function UnitXPMax() return playerMax end
function GetMaxLevelForPlayerExpansion() return 90 end
function BreakUpLargeNumbers(value) return tostring(value) end
function issecretvalue(value) return value == secret end
playerLevel=82;playerXP=400;playerMax=1000
quests={101,102,102,0,103,104}
complete={[101]=true,[102]=true,[103]=false,[104]=true}
rewards={[101]={250,200},[102]={500,400},[103]={900,900},[104]={100,nil}}
C_QuestLog={
 GetNumQuestLogEntries=function() return #quests end,
 GetQuestIDForLogIndex=function(index) return quests[index] end,
 IsComplete=function(id) return complete[id] end,
}
function GetQuestLogRewardXP(id) return unpack(rewards[id]) end
EllesmereUI={Widgets={}}
function EllesmereUI.Widgets:SectionHeader(_,text,_) headers[#headers+1]=text;return {},20 end
function EllesmereUI.Widgets:DualRow(_,_,left,right) rows[#rows+1]={left,right};return {},40 end
''')
ns = lua.globals().ns
for file in ("Localization/Core.lua", "Localization/enUS.lua", "Modules/LevelingForecast.lua"):
    lua.execute((ROOT / file).read_text(), "FafnyirTools", ns)

lua.execute(r'''
local f=ns.modules.LevelingForecast
local count,total,base,adjusted=f:GetCompletedQuestXP()
assert(count==3 and total==850 and base==600 and adjusted==750)
local result=f:GetForecast()
assert(result.questCount==3 and result.questXP==850)
assert(result.bonusPercent==25)
assert(result.projectedLevel==83 and result.overflowXP==250)
assert(result.projectedPercent==nil and not result.atMaxLevel)
f:BuildOptions({},-10)
assert(headers[1]=='LEVELING FORECAST' and #rows==7)
assert(rows[2][2].text=='3' and rows[3][2].text=='850')
assert(rows[4][2].text=='+25%')
assert(rows[5][2].text=='Level 83+ — 250 XP beyond next level',rows[5][2].text)
assert(rows[6][1].text:find('Blizzard%-adjusted'))
assert(rows[6][2]==nil and rows[7][1].text=='Reopen this page to refresh.')

playerXP=100;rewards[101]={100,100};rewards[102]={200,200};rewards[104]={0,0}
result=f:GetForecast()
assert(result.questCount==2 and result.questXP==300 and result.bonusPercent==0)
assert(result.projectedLevel==82 and math.abs(result.projectedPercent-40)<0.001)

playerLevel=81;playerXP=418117;playerMax=423390
rewards[101]={604313,483450};rewards[102]={0,0};rewards[104]={0,0}
result=f:GetForecast()
assert(result.projectedLevel==83 and not result.projectedAtMaxLevel)
assert(math.abs(result.projectedPercent-(155645/463740*100))<0.001)
assert(result.overflowXP==nil)

rewards[101]={5000000,4000000}
result=f:GetForecast()
assert(result.projectedLevel==90 and result.projectedAtMaxLevel)
assert(result.projectedPercent==nil and result.overflowXP==nil)

playerMax=423000;rewards[101]={604313,483450}
result=f:GetForecast()
assert(result.projectedLevel==82 and result.projectedPercent==nil)
assert(result.overflowXP==599430)

playerLevel=90;playerXP=0;playerMax=0
result=f:GetForecast();assert(result.atMaxLevel)

playerLevel=82;playerXP=100;playerMax=1000;secret=200
rewards[101]={100,100};rewards[102]={200,200};rewards[104]={0,0}
result=f:GetForecast();assert(result.questCount==1 and result.questXP==100)

local savedQuestLog=C_QuestLog;C_QuestLog=nil
local count,total,base,adjusted=f:GetCompletedQuestXP()
assert(count==0 and total==0 and base==0 and adjusted==0)
C_QuestLog=savedQuestLog
''')

source = (ROOT / "Modules/LevelingForecast.lua").read_text()
for forbidden in ("CreateTexture", "SetStatusBar", "XPBar", "questOverlay"):
    assert forbidden not in source, forbidden

print("PASS completed-quest deduplication, adjusted/base bonus, projection, max-level and secret-value guards")
