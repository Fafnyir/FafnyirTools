from pathlib import Path

from lupa.lua51 import LuaRuntime


root = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(r'''
SlashCmdList={}; FafnyirToolsDB={}; ns={}; maxLevel=false; resting=true
C_AddOns={IsAddOnLoaded=function() return false end}
function GetBuildInfo() return "12.1.5","70000","",120105 end
function UnitLevel() return maxLevel and 90 or 80 end
function IsPlayerAtEffectiveMaxLevel() return maxLevel end
function IsResting() return resting end

PlayerRestIcon={points={{"TOPLEFT",nil,"TOPLEFT",4,-6}},shown=true}
function PlayerRestIcon:GetNumPoints() return #self.points end
function PlayerRestIcon:GetPoint(i) return unpack(self.points[i]) end
function PlayerRestIcon:ClearAllPoints() self.points={} end
function PlayerRestIcon:SetPoint(...) self.points[#self.points+1]={...} end
function PlayerRestIcon:Hide() self.shown=false end
function PlayerRestIcon:Show() self.shown=true end

function PlayerFrame_UpdateStatus()
    PlayerRestIcon.shown=resting
    if statusHook then statusHook() end
end
function hooksecurefunc(name,fn) statusHook=fn end
''')
ns = lua.globals().ns
for path in ("Core/Bootstrap.lua", "Localization/Core.lua", "Localization/enUS.lua", "Modules/NativeResting.lua"):
    lua.execute((root / path).read_text(), "FafnyirTools", ns)

lua.execute(r'''
local feature=ns.modules.NativeResting
local db=ns:GetDatabase().nativeResting
assert(feature and db.enabled==false and db.hideAtMaxLevel==false)
feature:Initialize()
assert(PlayerRestIcon.points[1][4]==4 and PlayerRestIcon.points[1][5]==-6)

db.enabled=true;db.offsetX=12;db.offsetY=-8
feature:Refresh()
assert(PlayerRestIcon.points[1][4]==16 and PlayerRestIcon.points[1][5]==-14)

maxLevel=true;db.hideAtMaxLevel=true
feature:Refresh()
assert(PlayerRestIcon.shown==false)

maxLevel=false
feature:Refresh()
assert(PlayerRestIcon.shown==true)

db.enabled=false
feature:Refresh()
assert(PlayerRestIcon.points[1][4]==4 and PlayerRestIcon.points[1][5]==-6)
assert(PlayerRestIcon.shown==true)

db.enabled=true;db.offsetX=-3;db.offsetY=5
PlayerFrame_UpdateStatus()
assert(PlayerRestIcon.points[1][4]==1 and PlayerRestIcon.points[1][5]==-1)

feature:Reset()
assert(db.enabled==false and db.offsetX==0 and db.offsetY==0)
assert(PlayerRestIcon.points[1][4]==4 and PlayerRestIcon.points[1][5]==-6)
''')

print("PASS native resting defaults, offsets, max-level hiding, hook and restoration")
