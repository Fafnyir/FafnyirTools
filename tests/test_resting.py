from pathlib import Path

from lupa.lua51 import LuaRuntime


root = Path(__file__).resolve().parents[1] / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute(
    r'''
SlashCmdList = {}
ns = {}
IsResting = function() return false end
UnitLevel = function() return 1 end

local function Animation()
    return {
        SetLooping = function() end,
        CreateAnimation = function()
            return {
                SetDuration = function() end,
                SetOrder = function() end,
                SetFlipBookFrames = function() end,
                SetFlipBookRows = function() end,
                SetFlipBookColumns = function() end,
            }
        end,
        IsPlaying = function() return false end,
        Play = function() end,
        Stop = function() end,
    }
end

local function Frame()
    return {
        SetAllPoints = function() end,
        EnableMouse = function() end,
        SetSize = function() end,
        ClearAllPoints = function() end,
        SetPoint = function(_, point, relative, relativePoint, x, y)
            restingPoint = { point, relativePoint, x, y }
        end,
        GetFrameLevel = function() return 1 end,
        GetChildren = function() end,
        GetFrameStrata = function() return "MEDIUM" end,
        SetFrameStrata = function() end,
        SetFrameLevel = function() end,
        Show = function() end,
        Hide = function() end,
        CreateTexture = function()
            return {
                SetAtlas = function() end,
                SetAllPoints = function() end,
                ClearAllPoints = function() end,
                CreateAnimationGroup = Animation,
            }
        end,
    }
end

CreateFrame = function() return Frame() end
EllesmereUIUnitFrames_Player = Frame()
'''
)
lua.execute((root / "Core/Bootstrap.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute((root / 'Localization/Core.lua').read_text(), 'FafnyirTools', lua.globals().ns)
lua.execute((root / 'Localization/enUS.lua').read_text(), 'FafnyirTools', lua.globals().ns)
lua.execute((root / "Modules/Resting.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute(
    r'''
local feature = ns.modules.Resting
local db = ns:GetDatabase().resting
assert(db.side == "right")

feature:Initialize()
assert(restingPoint[1] == "BOTTOMRIGHT")
assert(restingPoint[2] == "TOPRIGHT")
assert(restingPoint[3] == 20 and restingPoint[4] == -15)

db.side = "left"
feature:ApplyLayout()
assert(restingPoint[1] == "BOTTOMLEFT")
assert(restingPoint[2] == "TOPLEFT")
assert(restingPoint[3] == -20 and restingPoint[4] == -15)

db.offsetX = -12
feature:ApplyLayout()
assert(restingPoint[3] == 12)

db.side = "unsupported"
feature:ApplyLayout()
assert(restingPoint[1] == "BOTTOMRIGHT")
assert(restingPoint[2] == "TOPRIGHT")
assert(restingPoint[3] == -12)

feature:Reset()
assert(db.side == "right")
assert(restingPoint[1] == "BOTTOMRIGHT")
'''
)

source = (root / "Modules/Resting.lua").read_text()
assert 'text = T("UNIT_FRAMES.RESTING_INDICATOR_SIDE")' in source
assert 'left = T("UNIT_FRAMES.LEFT")' in source and 'right = T("UNIT_FRAMES.RIGHT")' in source

print("PASS: resting indicator right/left anchors, mirrored offsets, fallback and reset")
