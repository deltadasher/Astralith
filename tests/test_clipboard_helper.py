"""Safety tests for the clipboard cache helper CLI."""

from __future__ import annotations

import subprocess
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


class ClipboardHelperTests(unittest.TestCase):
    def test_help_does_not_create_a_literal_help_directory(self) -> None:
        accidental = ROOT / "--help"
        self.assertFalse(accidental.exists())
        result = subprocess.run(
            ["python3", str(ROOT / "scripts" / "clipboard-index.py"), "--help"],
            cwd=ROOT,
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(result.returncode, 0)
        self.assertIn("cache_dir", result.stdout)
        self.assertFalse(accidental.exists())


if __name__ == "__main__":
    unittest.main()
