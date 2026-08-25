#!/usr/bin/env python3
"""Manage Astralith's original EasyEffects listening profiles."""

from __future__ import annotations

import json
import math
import os
from pathlib import Path
import shutil
import subprocess
import sys


PRESETS: dict[str, list[int]] = {
    "Neutral": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    "Gravity": [6, 5, 3, 1, 0, -1, -1, 0, 1, 1],
    "Air": [-2, -2, -1, 0, 1, 2, 3, 4, 5, 5],
    "Dialogue": [-4, -3, -1, 2, 4, 5, 3, 1, -1, -2],
    "Pulse": [3, 2, 0, -1, 0, 2, 3, 2, 1, 0],
    "Impact": [4, 3, 2, 0, -1, 0, 2, 3, 4, 3],
    "Lounge": [2, 2, 1, 0, 1, 1, 2, 2, 1, 1],
    "Orchestra": [-1, 0, 1, 2, 2, 1, 1, 2, 3, 2],
}
CONTROL_FREQUENCIES = [31.25, 62.5, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
EASY_EFFECTS_FREQUENCIES = [
    32, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630,
    800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000,
    10000, 12500, 16000, 20000, 22000, 24000, 24000,
]
PRESET_NAME = "astralith-live-eq"


def config_home() -> Path:
    return Path(os.environ.get("XDG_CONFIG_HOME", Path.home() / ".config"))


def state_path() -> Path:
    return config_home() / "astralith" / "equalizer.json"


def default_state() -> dict[str, object]:
    return {
        "preset": "Neutral",
        "bands": PRESETS["Neutral"],
        "available": bool(shutil.which("easyeffects")),
    }


def read_state() -> dict[str, object]:
    try:
        data = json.loads(state_path().read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError, TypeError):
        data = default_state()
    bands = data.get("bands", PRESETS["Neutral"])
    if not isinstance(bands, list) or len(bands) != 10:
        bands = PRESETS["Neutral"]
    data["bands"] = [max(-12, min(12, int(float(value)))) for value in bands]
    saved_preset = str(data.get("preset", "Custom"))
    data["preset"] = saved_preset if saved_preset in PRESETS else "Custom"
    data["available"] = bool(shutil.which("easyeffects"))
    return data


def write_state(data: dict[str, object]) -> None:
    path = state_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, separators=(",", ":")), encoding="utf-8")


def interpolated_gain(frequency: float, bands: list[int]) -> float:
    """Interpolate control points on a logarithmic frequency axis."""
    if frequency <= CONTROL_FREQUENCIES[0]:
        return float(bands[0])
    if frequency >= CONTROL_FREQUENCIES[-1]:
        return float(bands[-1])
    target = math.log2(frequency)
    for index in range(1, len(CONTROL_FREQUENCIES)):
        upper = CONTROL_FREQUENCIES[index]
        if frequency > upper:
            continue
        lower = CONTROL_FREQUENCIES[index - 1]
        span = math.log2(upper) - math.log2(lower)
        blend = (target - math.log2(lower)) / span
        return round(float(bands[index - 1]) * (1 - blend) + float(bands[index]) * blend, 2)
    return float(bands[-1])


def easy_effects_preset(bands: list[int]) -> dict[str, object]:
    nodes: dict[str, object] = {}
    for index, frequency in enumerate(EASY_EFFECTS_FREQUENCIES):
        gain = interpolated_gain(frequency, bands)
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
