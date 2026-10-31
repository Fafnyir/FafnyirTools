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

PlayerRestIcon={points={{"TOPLEFT",nil,"TOPLEFT",99,99}},shown=true}
function PlayerRestIcon:GetNumPoints() return #self.points end
function PlayerRestIcon:GetPoint(i) return unpack(self.points[i]) end
function PlayerRestIcon:ClearAllPoints() self.points={} end
function PlayerRestIcon:SetPoint(...) self.points[#self.points+1]={...} end
function PlayerRestIcon:Hide() self.shown=false end
function PlayerRestIcon:Show() self.shown=true end

PlayerRestLoop={points={{"TOPLEFT",nil,"TOPLEFT",64,-6}},shown=true}
function PlayerRestLoop:GetNumPoints() return #self.points end
function PlayerRestLoop:GetPoint(i) return unpack(self.points[i]) end
function PlayerRestLoop:ClearAllPoints() self.points={} end
function PlayerRestLoop:SetPoint(...) self.points[#self.points+1]={...} end
function PlayerRestLoop:Hide() self.shown=false end
function PlayerRestLoop:Show() self.shown=true end
PlayerFrame={PlayerFrameContent={PlayerFrameContentContextual={PlayerRestLoop=PlayerRestLoop}}}

function PlayerFrame_UpdateStatus()
    PlayerFrame_UpdatePlayerRestLoop(resting)
end
function PlayerFrame_UpdatePlayerRestLoop(state)
    PlayerRestLoop.shown=state
    if restLoopHook then restLoopHook(state) end
end
function hooksecurefunc(name,fn)
    assert(name=="PlayerFrame_UpdatePlayerRestLoop")
    restLoopHook=fn
end
''')
ns = lua.globals().ns
for path in ("Core/Bootstrap.lua", "Localization/Core.lua", "Localization/enUS.lua", "Modules/NativeResting.lua"):
    lua.execute((root / path).read_text(), "FafnyirTools", ns)

lua.execute(r'''
local feature=ns.modules.NativeResting
local db=ns:GetDatabase().nativeResting
assert(feature and db.enabled==false and db.hideAtMaxLevel==false)
feature:Initialize()
assert(PlayerRestLoop.points[1][4]==64 and PlayerRestLoop.points[1][5]==-6)

db.enabled=true;db.offsetX=12;db.offsetY=-8
feature:Refresh()
assert(PlayerRestLoop.points[1][4]==76 and PlayerRestLoop.points[1][5]==-14)

maxLevel=true;db.hideAtMaxLevel=true
feature:Refresh()
assert(PlayerRestLoop.shown==false)

maxLevel=false
feature:Refresh()
assert(PlayerRestLoop.shown==true)

db.enabled=false
feature:Refresh()
assert(PlayerRestLoop.points[1][4]==64 and PlayerRestLoop.points[1][5]==-6)
assert(PlayerRestLoop.shown==true)

db.enabled=true;db.offsetX=-3;db.offsetY=5
PlayerFrame_UpdateStatus()
assert(PlayerRestLoop.points[1][4]==61 and PlayerRestLoop.points[1][5]==-1)

feature:Reset()
assert(db.enabled==false and db.offsetX==0 and db.offsetY==0)
assert(PlayerRestLoop.points[1][4]==64 and PlayerRestLoop.points[1][5]==-6)
''')

print("PASS native resting defaults, offsets, max-level hiding, hook and restoration")

source = (root / "Modules/NativeResting.lua").read_text()
assert "min = -25, max = 130" in source
assert source.count("min = -25, max = 25") == 1
assert "W:TripleRow" in source
