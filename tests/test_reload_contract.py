"""Reload prompts use EllesmereUI's secure Forever reload contract."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1] / "src/FafnyirTools"

expected = {
    "Modules/UnitFrameSources.lua": 1,
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

unit_sources = (ROOT / "Modules/UnitFrameSources.lua").read_text()
assert "onConfirm = ReloadUI" not in unit_sources

print("PASS all EllesmereUI reload prompts use the secure Forever reload contract")
