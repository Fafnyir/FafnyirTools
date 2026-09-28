#!/usr/bin/env python3
"""Run addon contracts and inherited Lua 5.1 behavior tests; no game installation."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
ADDON = ROOT / 'src/FafnyirTools'


def check(baseline=False):
    try:
        from lupa.lua51 import LuaRuntime
    except ImportError:
        raise SystemExit('Missing Lupa: install requirements-dev.txt in your Python environment.')
    lua = LuaRuntime(unpack_returned_tuples=True)
    compile_lua = lua.eval('function(s) local f,e=loadstring(s); assert(f,e) end')
    toc = (ADDON / 'FafnyirTools.toc').read_text()
    entries = [line.strip().replace('\\', '/') for line in toc.splitlines()
               if line.strip() and not line.lstrip().startswith('#')]
    assert len(entries) == len(set(entries)), 'Duplicate TOC entry'
    assert all((ADDON / p).is_file() for p in entries), 'Missing TOC file'
    scripts = {p.relative_to(ADDON).as_posix() for p in ADDON.rglob('*.lua')}
    assert set(entries) == scripts, 'An active Lua file is missing from the TOC (or unexpected non-Lua entry)'
    for name in entries:
        compile_lua((ADDON / name).read_text())
    fingerprint = json.loads((ROOT / 'docs/baselines/v1.1.2-quest-xp-fixed.json').read_text())
    expected = {p.removeprefix('FafnyirTools/') for p in fingerprint['files']}
    actual_files = {p.relative_to(ADDON).as_posix() for p in ADDON.rglob('*') if p.is_file()}
    retired = {'Modules/BlizzardBarArt.lua', 'Modules/UnitFrameSources.lua'}
    assert expected - retired <= actual_files, 'Baseline module/file removed; reconcile feature inventory explicitly'
    assert retired.isdisjoint(actual_files), 'EllesmereUI-owned retired module restored unexpectedly'
    required = {
        'Modules/PermanentCompanionPet.lua': ('PermanentCompanionPet', 'QoL'),
        'Modules/About.lua': ('About', 'About'),
        'Modules/GlobalSettings.lua': ('GlobalSettings', 'About'),
        'Modules/ForeverFog.lua': ('ForeverFog', 'QoL'),
        'Modules/Resting.lua': ('Resting', 'Unit Frames'),
        'Modules/RightClickSelfCast.lua': ('RightClickSelfCast', 'Action Bars'),
        'Modules/FlyoutButtonMatch.lua': ('FlyoutButtonMatch', 'Action Bars'),
        'Modules/FocusHeader.lua': ('FocusHeader', 'Unit Frames'),
        'Modules/UnitFrameNames.lua': ('UnitFrameNames', 'Unit Frames'),
        'Modules/DeviceLayout.lua': ('DeviceLayout', 'Layouts'),
        'Modules/XPBar.lua': ('XPBar', 'XP & Progression'),
        'Modules/AuraSkins.lua': ('AuraSkins', 'Unit Frames'),
        'Modules/Inventory/Core.lua': ('Inventory', 'Bags & Inventory'),
    }
    for name, (key, page) in required.items():
        text = (ADDON / name).read_text()
        assert re.search(r'key\s*=\s*"' + re.escape(key) + '"', text), name
        assert re.search(r'page\s*=\s*"' + re.escape(page) + '"', text), name
        assert f'ns.modules.{key}' in (ADDON / 'Core/Options.lua').read_text(), f'Feature not ordered in options: {key}'
    version = re.search(r'^## Version: (.+)$', toc, re.M).group(1).strip()
    assert version == re.search(r'local VERSION = "([^"]+)"', (ADDON / 'Modules/About.lua').read_text()).group(1)
    assert '## SavedVariables: FafnyirToolsDB' in toc
    assert '## Dependencies: EllesmereUI, FafnyirMedia' in toc
    assert '16001' in re.search(r'^## Interface: (.+)$', toc, re.M).group(1), 'Forever interface missing'
    assert entries.index('Core/Bootstrap.lua') < entries.index('Modules/XPBar.lua') < entries.index('Core/Events.lua')
    lua.execute('SlashCmdList={}; ns={}')
    lua.execute((ADDON / 'Core/Bootstrap.lua').read_text(), 'FafnyirTools', lua.globals().ns)
    lua.execute('''
      for _,key in ipairs({'foreverFog','flyoutFix','resting','rightClickSelfCast',
          'deviceLayout','inventory','xpBar','auraSkins','permanentCompanionPet'}) do
        assert(type(FafnyirToolsDB[key])=='table',key)
      end
      FafnyirToolsDB.unrecognizedFutureSetting={keep=true}
      ns:InitializeDatabase(); assert(FafnyirToolsDB.unrecognizedFutureSetting.keep)
    ''')
    release = ROOT / 'releases' / fingerprint['archive']
    assert hashlib.sha256(release.read_bytes()).hexdigest() == fingerprint['sha256'], 'Original release changed'
    if baseline:
        actual = {p.relative_to(ROOT / 'src').as_posix(): hashlib.sha256(p.read_bytes()).hexdigest()
                  for p in ADDON.rglob('*') if p.is_file()}
        assert actual == fingerprint['files'], 'Source differs from adopted baseline'
        print('PASS source byte-identical to user-confirmed baseline', flush=True)
    print(f'PASS {len(entries)} Lua files, complete/unique TOC, expected features/pages/default sections, metadata', flush=True)
    for test in ['test_xp.py', 'test_aura_sources_options.py', 'test_reload_contract.py', 'test_companion.py',
                 'test_global_settings.py', 'test_inventory.py', 'test_unit_frame_names.py', 'test_focus_header.py',
                 'test_icon_history_border.py', 'test_forever_compat.py']:
        subprocess.run([sys.executable, str(ROOT / 'tests' / test)], cwd=ROOT, check=True)
    print('ALL OFFLINE CHECKS PASSED (in-game rendering/combat still require manual QA)', flush=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--baseline', action='store_true', help='Also require original source fingerprint equality')
    check(parser.parse_args().baseline)
