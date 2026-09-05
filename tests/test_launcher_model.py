"""Behavioral checks for the command palette's pure JavaScript model."""

from pathlib import Path
import json
import shutil
import subprocess
import unittest


ROOT = Path(__file__).resolve().parents[1]
MODEL = ROOT / "src/quickshell/modules/ephemeris/widgets/catalog/LauncherModel.js"
NODE = shutil.which("node")


@unittest.skipUnless(NODE, "Node.js is needed to execute the QML JavaScript model")
class LauncherModelTests(unittest.TestCase):
    def evaluate(self, expression):
        program = MODEL.read_text().replace(".pragma library", "", 1)
        program += """
const installed = [
    {id: 'firefox.desktop', name: 'Firefox', command: 'firefox', comment: 'Web browser'},
    {id: 'terminal.desktop', name: 'Terminal', command: 'terminal', comment: 'Terminal emulator'},
    {id: 'files.desktop', name: 'Files', command: 'files', comment: 'File manager'}
];
const actions = surfaceCommands([
    {id: 'apps', title: 'Blackhole'},
    {id: 'walls', title: 'Parallax library'},
    {id: 'audio', title: 'Acoustic routing'}
]);
const entries = applications(installed).concat(actions);
"""
        program += "\nconsole.log(JSON.stringify(" + expression + "));"
        result = subprocess.run([NODE, "-e", program], capture_output=True, text=True, check=True)
        return json.loads(result.stdout)

    def test_discovery_order_does_not_move_existing_apps(self):
        result = self.evaluate("[applications(installed).map(e => e.id), applications(installed.slice().reverse()).map(e => e.id)]")
        self.assertEqual(result[0], result[1])

    def test_search_preserves_relative_order_and_selected_identity(self):
        result = self.evaluate("(() => { const before = filter(entries, '', 'apps', []); const after = filter(entries, 'fi', 'apps', []); return [before.filter(e => after.some(a => a.id === e.id)).map(e => e.id), after.map(e => e.id), selectedId(after, 'app:files.desktop')]; })()")
        self.assertEqual(result[0], result[1])
        self.assertEqual(result[2], "app:files.desktop")

    def test_missing_selection_recovers_without_stale_activation(self):
        result = self.evaluate("[selectedId(filter(entries, 'terminal', 'apps', []), 'app:files.desktop'), selectedId([], 'app:files.desktop'), moveSelection([], 'app:files.desktop', 1)]")
        self.assertEqual(result, ["app:terminal.desktop", "", ""])

    def test_command_prefix_overrides_app_category(self):
        result = self.evaluate("filter(entries, '> wallpaper', 'apps', []).map(e => e.id)")
        self.assertEqual(result, ["surface:walls"])

    def test_saved_apps_are_a_filter_not_a_sort(self):
        result = self.evaluate("[filter(entries, '', 'saved', ['files.desktop', 'firefox.desktop']).map(e => e.id), applications(installed).filter(e => e.appId !== 'terminal.desktop').map(e => e.id), filter(entries, '', 'saved', []).length]")
        self.assertEqual(result[0], result[1])
        self.assertEqual(result[2], 0)

    def test_arrows_wrap_and_survive_an_empty_model(self):
        result = self.evaluate("(() => { const first = entries[0].id; const last = entries[entries.length-1].id; return [moveSelection(entries, first, -1) === last, moveSelection(entries, last, 1) === first, moveSelection(entries, '', 1) === first]; })()")
        self.assertEqual(result, [True, True, True])

    def test_launch_targets_exclude_helpers_duplicates_and_empty_commands(self):
        result = self.evaluate("applications(installed.concat([installed[0], {id: 'about', name: 'About Xfce', command: 'about'}, {id: 'broken', name: 'Broken', command: ''}])).length")
        self.assertEqual(result, 3)

    def test_unavailable_action_remains_discoverable_but_is_not_default(self):
        result = self.evaluate("(() => { const commands = [{id: 'pause', name: 'Pause', kind: 'media', enabled: false}, {id: 'audio', name: 'Audio', kind: 'surface', enabled: true}]; return [filter(commands, '', 'actions', []).length, selectedId(commands, '')]; })()")
        self.assertEqual(result, [2, "audio"])


if __name__ == "__main__":
    unittest.main()
