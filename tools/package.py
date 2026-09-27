#!/usr/bin/env python3
"""Build only the canonical addon from a clean commit; never install or publish."""
from pathlib import Path
import hashlib
import io
import json
import re
import subprocess
import sys
import zipfile

ROOT = Path(__file__).resolve().parents[1]


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args], text=True).strip()


def package():
    if git('status', '--porcelain'):
        raise SystemExit('Refusing to package uncommitted changes. Review, test and commit first.')
    revision = git('rev-parse', 'HEAD')
    subprocess.run([sys.executable, str(ROOT / 'tools/check.py')], cwd=ROOT, check=True)
    addon = ROOT / 'src/FafnyirTools'
    version = re.search(r'^## Version: (.+)$', (addon / 'FafnyirTools.toc').read_text(), re.M).group(1).strip()
    assert re.fullmatch(r'v[0-9]+\.[0-9]+\.[0-9]+', version), 'Unexpected version format'
    name = f'Fafnyir_Tools_for_EllesmereUI_{version}_{revision[:12]}.zip'
    destination = ROOT / 'dist'
    destination.mkdir(exist_ok=True)
    output = destination / name
    metadata = output.with_suffix('.build.json')
    if output.exists() or metadata.exists():
        raise SystemExit('Artifact already exists; refusing to overwrite it.')
    files = {}
    payload = io.BytesIO()
    with zipfile.ZipFile(payload, 'w', zipfile.ZIP_DEFLATED) as archive:
        for path in sorted(addon.rglob('*')):
            if not path.is_file():
                continue
            relative = path.relative_to(ROOT / 'src').as_posix()
            assert path.suffix.lower() in {'.lua', '.toc', '.txt', '.tga'}, f'Review unexpected addon asset: {relative}'
            content = path.read_bytes()
            info = zipfile.ZipInfo(relative, date_time=(2026, 8, 27, 0, 0, 0))
            info.compress_type = zipfile.ZIP_DEFLATED
            info.external_attr = 0o100644 << 16
            archive.writestr(info, content)
            files[relative] = hashlib.sha256(content).hexdigest()
    content = payload.getvalue()
    with zipfile.ZipFile(io.BytesIO(content)) as archive:
        assert archive.testzip() is None
        assert set(archive.namelist()) == set(files)
        for path, digest in files.items():
            assert hashlib.sha256(archive.read(path)).hexdigest() == digest
    assert git('rev-parse', 'HEAD') == revision and not git('status', '--porcelain'), 'Source changed while packaging'
    with output.open('xb') as handle:
        handle.write(content)
    with metadata.open('x') as handle:
        json.dump({'archive': name, 'version': version, 'git_revision': revision,
                   'sha256': hashlib.sha256(content).hexdigest(), 'files': files,
                   'verification': 'Offline checks passed; packaging does not constitute in-game QA.'}, handle, indent=2)
        handle.write('\n')
    print(f'Created and verified: {output}\nBuild manifest: {metadata}')


if __name__ == '__main__':
    package()
