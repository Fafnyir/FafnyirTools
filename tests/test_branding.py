from pathlib import Path

from lupa.lua51 import LuaRuntime


root = Path(__file__).resolve().parents[1]
addon = root / "src/FafnyirTools"
lua = LuaRuntime(unpack_returned_tuples=True)
lua.execute("""
ns={modules={}}
function ns:RegisterFeature(key, feature) self.modules[key]=feature end
parent={}
function parent:CreateTexture()
  local texture={}
  function texture:SetTexture(path) self.path=path end
  function texture:SetSize(width,height) self.width=width;self.height=height end
  function texture:SetPoint(...) self.point={...} end
  self.texture=texture
  return texture
end
""")
lua.execute((addon / "Modules/Branding.lua").read_text(), "FafnyirTools", lua.globals().ns)
lua.execute("""
local feature=ns.modules.Branding
assert(feature and feature.page=='About')
assert(feature:BuildOptions(parent,0)==140)
assert(parent.texture.path==[[Interface\AddOns\FafnyirTools\Media\Header]])
assert(parent.texture.width==512 and parent.texture.height==128)
assert(parent.texture.point[1]=='TOP' and parent.texture.point[3]=='TOP')
""")
header = addon / "Media/Header.tga"
assert header.is_file()
assert header.read_bytes()[:3] != b""
print("PASS About header texture path, dimensions, placement and bundled asset")
