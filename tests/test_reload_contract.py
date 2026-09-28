"""Reload prompts use EllesmereUI's secure Forever reload contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"

expected = {
    "Modules/AuraSkins.lua": 1,
    "Modules/GlobalSettings.lua": 2,
    "Core/Options.lua": 1,
}

for relative, count in expected.items():
    source = (ROOT / relative).read_text()
    assert source.count("reload = true") == count, relative

global_settings = (ROOT / "Modules/GlobalSettings.lua").read_text()
assert "feature:ApplyImport(payload)\n            ReloadUI()" not in global_settings
assert "feature:RestoreBackup() then ReloadUI()" not in global_settings

print("PASS all EllesmereUI reload prompts use the secure Forever reload contract")
