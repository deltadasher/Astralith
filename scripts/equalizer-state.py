#!/usr/bin/env python3
"""Manage Astralith's live EasyEffects equalizer preset.

The ten-band curve and preset values are adapted from the local Serpantinum
music/equalizer implementation. Astralith owns its state and preset names.
"""

from __future__ import annotations

import json
import os
from pathlib import Path
import shutil
import subprocess
import sys


PRESETS: dict[str, list[int]] = {
    "Flat": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "Bass": [5, 7, 5, 2, 1, 0, 0, 0, 1, 2],
    "Treble": [-2, -1, 0, 1, 2, 3, 4, 5, 6, 6],
    "Vocal": [-2, -1, 1, 3, 5, 5, 4, 2, 1, 0],
    "Pop": [2, 4, 2, 0, 1, 2, 4, 2, 1, 2],
    "Rock": [5, 4, 2, -1, -2, -1, 2, 4, 5, 6],
    "Jazz": [3, 3, 1, 1, 1, 1, 2, 1, 2, 3],
    "Classic": [0, 1, 2, 2, 2, 2, 1, 2, 3, 4],
}
FREQUENCIES = [
    32, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630,
    800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000,
    10000, 12500, 16000, 20000, 22000, 24000, 24000,
]
ANCHORS = {0: 0, 3: 1, 6: 2, 9: 3, 12: 4, 15: 5, 18: 6, 21: 7, 24: 8, 27: 9}
PRESET_NAME = "astralith-live-eq"


def config_home() -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))


def state_path() -> Path:
    return config_home() / "astralith" / "equalizer.json"


def default_state() -> dict[str, object]:
    return {"preset": "Flat", "bands": PRESETS["Flat"], "available": bool(shutil.which("easyeffects"))}


def read_state() -> dict[str, object]:
    try:
        data = json.loads(state_path().read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, TypeError):
        data = default_state()
    bands = data.get("bands", PRESETS["Flat"])
    if not isinstance(bands, list) or len(bands) != 10:
        bands = PRESETS["Flat"]
    data["bands"] = [max(-12, min(12, int(float(value)))) for value in bands]
    data["preset"] = str(data.get("preset", "Custom"))
    data["available"] = bool(shutil.which("easyeffects"))
    return data


def write_state(data: dict[str, object]) -> None:
    path = state_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, separators=(",", ":")), encoding="utf-8")


def easy_effects_preset(bands: list[int]) -> dict[str, object]:
    nodes: dict[str, object] = {}
    for index, frequency in enumerate(FREQUENCIES):
        gain = float(bands[ANCHORS[index]]) if index in ANCHORS else 0.0
        nodes[f"band{index}"] = {
            "frequency": frequency,
            "gain": gain,
            "mode": "Bell",
            "mute": False,
            "q": 1.0,
            "solo": False,
            "width": 1.0,
            "slope": "x1",
        }
    equalizer = {
        "bypass": False,
        "input-gain": 0.0,
        "output-gain": 0.0,
        "left": nodes,
        "right": nodes,
        "mode": "IIR",
        "num-bands": 32,
        "split-channels": False,
    }
    return {"output": {"blocklist": [], "plugins_order": ["equalizer"], "equalizer": equalizer}}


def apply(data: dict[str, object]) -> None:
    if not shutil.which("easyeffects"):
        return
    preset_dir = config_home() / "easyeffects" / "output"
    preset_dir.mkdir(parents=True, exist_ok=True)
    preset_file = preset_dir / f"{PRESET_NAME}.json"
    preset_file.write_text(json.dumps(easy_effects_preset(data["bands"]), indent=2), encoding="utf-8")
    try:
        subprocess.Popen(
            ["easyeffects", "-l", PRESET_NAME],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except OSError:
        pass


def main() -> None:
    command = sys.argv[1] if len(sys.argv) > 1 else "get"
    data = read_state()
    if command == "preset" and len(sys.argv) > 2:
        name = sys.argv[2]
        if name in PRESETS:
            data["preset"] = name
            data["bands"] = PRESETS[name]
            write_state(data)
            apply(data)
    elif command == "band" and len(sys.argv) > 3:
        index = max(0, min(9, int(sys.argv[2])))
        data["bands"][index] = max(-12, min(12, int(float(sys.argv[3]))))
        data["preset"] = "Custom"
        write_state(data)
        apply(data)
    print(json.dumps(data, separators=(",", ":")))


if __name__ == "__main__":
    main()

