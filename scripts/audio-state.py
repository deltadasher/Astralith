#!/usr/bin/env python3
"""Return PipeWire/Pulse devices and application streams as JSON."""

from __future__ import annotations

import json
import subprocess


def run(args: list[str]) -> str:
    try:
        return subprocess.run(
            args, capture_output=True, text=True, timeout=4, check=False
        ).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def run_json(args: list[str]):
    try:
        return json.loads(run(args) or "[]")
    except json.JSONDecodeError:
        return []


def first_string(*values) -> str:
    for value in values:
        if value is not None and str(value).strip().lower() not in ("", "null", "none"):
            return str(value).strip()
    return ""


def default_name(target: str) -> str:
    for line in run(["wpctl", "inspect", target]).splitlines():
        if "node.name" in line and "=" in line:
            return line.split("=", 1)[1].strip().strip('"')
    return ""


def volume_percent(node: dict) -> int:
    volume = node.get("volume", {})
    if not isinstance(volume, dict):
        return 0
    channel = volume.get("front-left") or volume.get("mono")
    if not channel and volume:
        channel = next(iter(volume.values()))
    try:
        return int(str((channel or {}).get("value_percent", "0%")).rstrip("%"))
    except (TypeError, ValueError):
        return 0


def format_node(node: dict, kind: str, default: str = "") -> dict[str, object]:
    props = node.get("properties", {}) or {}
    internal_name = first_string(node.get("name"), props.get("node.name"))
    is_app = kind == "apps"
    if is_app:
        title = first_string(
            props.get("application.name"), props.get("application.process.binary"),
            props.get("application.id"), "Unknown application",
        )
        detail = first_string(
            props.get("media.name"), props.get("window.title"),
            props.get("media.role"), "Audio stream",
        )
    else:
        title = first_string(
            props.get("device.description"), props.get("node.description"),
            node.get("description"), internal_name, "Unknown device",
        )
        detail = first_string(
            props.get("device.product.name"), internal_name, "PipeWire node",
        )
    return {
        "id": str(node.get("index", "")),
        "nodeName": internal_name,
        "name": title,
        "description": detail,
        "volume": volume_percent(node),
        "mute": bool(node.get("mute", False)),
        "isDefault": bool(default and internal_name == default),
        "icon": first_string(
            props.get("application.icon_name"), props.get("device.icon_name"),
            "audio-card",
        ),
        "kind": kind,
    }


def main() -> None:
    pactl_info = run(["pactl", "-f", "json", "info"])
    sinks = run_json(["pactl", "-f", "json", "list", "sinks"])
    sources = run_json(["pactl", "-f", "json", "list", "sources"])
    streams = run_json(["pactl", "-f", "json", "list", "sink-inputs"])
    default_sink = default_name("@DEFAULT_AUDIO_SINK@")
    default_source = default_name("@DEFAULT_AUDIO_SOURCE@")

    inputs = []
    for source in sources if isinstance(sources, list) else []:
        props = source.get("properties", {}) or {}
        if props.get("device.class") == "monitor" or str(source.get("name", "")).endswith(".monitor"):
            continue
        inputs.append(format_node(source, "inputs", default_source))

    apps = []
    for stream in streams if isinstance(streams, list) else []:
        props = stream.get("properties", {}) or {}
        app_id = str(props.get("application.id", "")).lower()
        if "pavucontrol" not in app_id:
            apps.append(format_node(stream, "apps"))

    payload = {
        "available": bool(pactl_info.strip()),
        "outputs": [format_node(node, "outputs", default_sink) for node in sinks] if isinstance(sinks, list) else [],
        "inputs": inputs,
        "apps": apps,
    }
    print(json.dumps(payload, separators=(",", ":")))


if __name__ == "__main__":
    main()
