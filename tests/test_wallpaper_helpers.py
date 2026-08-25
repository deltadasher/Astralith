from __future__ import annotations

import importlib.util
from pathlib import Path
import tempfile
import unittest


PROJECT_ROOT = Path(__file__).resolve().parents[1]


def load_script(name: str):
    path = PROJECT_ROOT / "scripts" / name
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Could not load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class WallpaperValidationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.library = load_script("wallpaper-library.py")
        cls.online = load_script("wallpaper-online.py")

    def test_supported_signatures(self) -> None:
        self.assertTrue(self.online.valid_image_bytes(b"\xff\xd8\xff" + b"0" * 29))
        self.assertTrue(self.online.valid_image_bytes(b"\x89PNG\r\n\x1a\n" + b"0" * 24))
        self.assertTrue(self.online.valid_image_bytes(b"RIFF0000WEBP" + b"0" * 20))

    def test_html_disguised_as_image_is_rejected(self) -> None:
        self.assertFalse(self.online.valid_image_bytes(b"<!doctype html><html>error</html>"))
        with tempfile.TemporaryDirectory() as directory:
            fake_image = Path(directory) / "error.jpg"
            fake_image.write_text("<!doctype html><html>error</html>", encoding="utf-8")
            self.assertFalse(self.library.valid_image(fake_image))

    def test_bundled_wallpapers_have_valid_signatures(self) -> None:
        wallpaper_root = PROJECT_ROOT / "assets" / "wallpapers"
        for wallpaper in wallpaper_root.glob("*.png"):
            with self.subTest(wallpaper=wallpaper.name):
                self.assertTrue(self.library.valid_image(wallpaper))

    def test_color_buckets(self) -> None:
        self.assertEqual(self.library.color_bucket("#777777"), "Mono")
        self.assertEqual(self.library.color_bucket("#7040B0"), "Purple")
        self.assertEqual(self.library.color_bucket("#2088C0"), "Blue")


if __name__ == "__main__":
    unittest.main()
