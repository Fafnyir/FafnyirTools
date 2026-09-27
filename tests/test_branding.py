from pathlib import Path

from lupa.lua51 import LuaRuntime


root = Path(__file__).resolve().parents[1]
addon = root / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("""
ns={modules={}}
function ns:RegisterFeature(key, feature) self.modules[key]=feature end
parent={}
title={}
function title:GetText() return 'Fafnyir Tools' end
function title:GetParent() return parent end
parent._title=title
parent._desc={}
function parent:CreateTexture()
  local texture={}
  function texture:SetTexture(path) self.path=path end
  function texture:SetSize(width,height) self.width=width;self.height=height end
  function texture:SetPoint(...) self.point={...} end
  function texture:SetTexCoord(...) self.texCoord={...} end
  function texture:ClearAllPoints() self.point=nil end
  function texture:GetParent() return parent end
  function texture:Show() self.shown=true end
  function texture:Hide() self.shown=false end
  self.texture=texture
  return texture
end
EllesmereUI={}
clickArea={}
function clickArea:GetChildren() return parent end
EllesmereUI._clickArea=clickArea
function EllesmereUI:SelectModule() end
function hooksecurefunc(owner,key,callback) hook=callback end
""")
lua.execute((addon / "Modules/Branding.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute("""
local feature=ns.modules.Branding
assert(feature and feature.page=='About')
assert(feature:BuildOptions(parent,-37)==37)
feature:Initialize();assert(hook)
hook(EllesmereUI,'FafnyirTools')
assert(parent.texture.path==[[Interface\AddOns\FafnyirTools\Media\Header]])
assert(parent.texture.width==52 and parent.texture.height==52)
assert(parent.texture.texCoord[1]==0.375 and parent.texture.texCoord[2]==0.625)
assert(parent.texture.point[1]=='RIGHT' and parent.texture.point[2]==title and parent.texture.point[3]=='LEFT')
assert(parent.texture.shown)
hook(EllesmereUI,'EllesmereUIUnitFrames');assert(not parent.texture.shown)
""")
header = addon / "Media/Header.tga"
assert header.is_file()
assert header.read_bytes()[:3] != b""
print("PASS module-header logo path, crop, dimensions, placement, visibility and bundled asset")
