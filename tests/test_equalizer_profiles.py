from __future__ import annotations

import importlib.util
from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[1]


def load_equalizer():
    path = ROOT / "scripts" / "equalizer-state.py"
    spec = importlib.util.spec_from_file_location("astralith_equalizer", path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class EqualizerProfileTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        cls.equalizer = load_equalizer()

    def test_original_profile_set_has_ten_points_each(self) -> None:
        self.assertEqual(
            set(self.equalizer.PRESETS),
            {"Neutral", "Gravity", "Air", "Dialogue", "Pulse", "Impact", "Lounge", "Orchestra"},
        )
        for profile in self.equalizer.PRESETS.values():
            self.assertEqual(len(profile), 10)
            self.assertTrue(all(-12 <= value <= 12 for value in profile))

    def test_log_interpolation_reaches_control_points(self) -> None:
        profile = self.equalizer.PRESETS["Gravity"]
        for frequency, expected in zip(self.equalizer.CONTROL_FREQUENCIES, profile):
            self.assertEqual(
                self.equalizer.interpolated_gain(frequency, profile),
                float(expected),
            )

    def test_generated_easy_effects_graph_is_continuous(self) -> None:
        graph = self.equalizer.easy_effects_preset(self.equalizer.PRESETS["Air"])
        left = graph["output"]["equalizer"]["left"]
        self.assertEqual(len(left), 32)
        gains = [left[f"band{index}"]["gain"] for index in range(32)]
        self.assertGreater(gains[-1], gains[0])
        self.assertGreater(len({gain for gain in gains}), 10)


if __name__ == "__main__":
    unittest.main()
