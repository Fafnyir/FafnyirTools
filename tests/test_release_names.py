"""Exercise upload metadata so display names retain the packaged ZIP identity."""
import json
import os
from pathlib import Path
import re
import tempfile
import textwrap

ROOT = Path(__file__).resolve().parents[1]
workflow = (ROOT / '.github/workflows/release.yml').read_text()
repair = (ROOT / '.github/workflows/repair-release-name.yml').read_text()
snippet = re.search(r"python - <<'PY'\n(.*?)\n          PY", workflow, re.S).group(1)
name = 'Fafnyir_Tools_for_EllesmereUI_v1.1.7_e744c79.zip'
with tempfile.TemporaryDirectory() as temp:
    previous = Path.cwd()
    os.chdir(temp)
    try:
        notes = Path('src/FafnyirTools/RELEASE-NOTES.txt')
        notes.parent.mkdir(parents=True)
        notes.write_text('release notes')
        os.environ.update(ARTIFACT_NAME=name, CURSEFORGE_RELEASE_TYPE='release')
        exec(textwrap.dedent(snippet))
        metadata = json.loads(Path('curseforge-metadata.json').read_text())
        assert metadata['displayName'] == name
        assert metadata['releaseType'] == 'release'
        os.environ.update(RELEASE_TAG='release/v1.1.7', CURSEFORGE_FILE_ID='9049889')
        Path('release-assets.json').write_text(json.dumps({'assets': [{'name': name}]}))
        repair_snippet = re.search(r"python - <<'PY'\n(.*?)\n          PY", repair, re.S).group(1)
        exec(textwrap.dedent(repair_snippet))
        assert json.loads(Path('metadata.json').read_text()) == {'fileID': 9049889, 'displayName': name}
        assert Path('artifact-name.txt').read_text() == name
    finally:
        os.chdir(previous)
assert '--title "Fafnyir_Tools_for_EllesmereUI_${ADDON_VERSION}_${GITHUB_SHA:0:7}.zip"' in workflow
assert 'filename=$artifact_name' in workflow and 'export ARTIFACT_NAME="$artifact_name"' in workflow
print('PASS GitHub/CurseForge display names and upload filename match the revision-stamped ZIP')
