from __future__ import annotations

import importlib.util
import subprocess
import tempfile
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MODULE_PATH = ROOT / "scripts" / "umbra-greeter-palette.py"
SPEC = importlib.util.spec_from_file_location("umbra_greeter_palette", MODULE_PATH)
assert SPEC and SPEC.loader
PALETTE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(PALETTE)


class UmbraGreeterPaletteTests(unittest.TestCase):
    def test_stage_contains_every_greeter_qml_component(self) -> None:
        theme_dir = ROOT / "modules" / "umbra" / "greeter"
        with tempfile.TemporaryDirectory() as temporary_directory:
            staged = Path(temporary_directory)
            subprocess.run(
                [str(ROOT / "scripts" / "umbra-greeter"), "stage", str(staged)],
                check=True,
                stdout=subprocess.DEVNULL,
            )
            source_qml = {
                path.relative_to(theme_dir) for path in theme_dir.rglob("*.qml")
            }
            staged_qml = {
                path.relative_to(staged) for path in staged.rglob("*.qml")
            }
            self.assertEqual(source_qml, staged_qml)

    def test_sddm_library_imports_are_versioned(self) -> None:
        theme_dir = ROOT / "modules" / "umbra" / "greeter"
        for path in sorted(theme_dir.glob("*.qml")):
            for line_number, line in enumerate(path.read_text().splitlines(), 1):
                if not line.startswith("import "):
                    continue
                parts = line.split()
                self.assertGreaterEqual(
                    len(parts),
                    3,
                    f"{path.name}:{line_number}: SDDM requires a versioned library import",
                )

    def test_fallback_palette_is_complete(self) -> None:
        rendered = PALETTE.render({})
        self.assertTrue(rendered.startswith("[General]\n"))
        for name, value in PALETTE.FALLBACKS.items():
            self.assertIn(f"{name}={value}\n", rendered)

    def test_matugen_material_roles_are_mapped(self) -> None:
        payload = {
            "ok": True,
            "palette": {
                "colors": {
                    "primary": {"default": {"color": "#112233"}},
                    "secondary": {"dark": {"color": "#445566"}},
                    "error": {"default": {"color": "#aa0011"}},
                }
            },
        }
        rendered = PALETTE.render(payload)
        self.assertIn("accent=#112233\n", rendered)
        self.assertIn("secondary=#445566\n", rendered)
        self.assertIn("danger=#aa0011\n", rendered)


if __name__ == "__main__":
    unittest.main()
