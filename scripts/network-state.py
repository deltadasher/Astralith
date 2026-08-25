#!/usr/bin/env python3
"""Collect Wi-Fi, Bluetooth, and Ethernet state for Astralith Link Array."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys


def run(args: list[str], timeout: int = 6) -> str:
    try:
        return subprocess.run(
            args, capture_output=True, text=True, timeout=timeout, check=False
        ).stdout
    except (OSError, subprocess.TimeoutExpired):
        return ""


def split_escaped(line: str) -> list[str]:
    fields: list[str] = []
    current: list[str] = []
    escaped = False
    for char in line:
        if escaped:
            current.append(char)
            escaped = False
        elif char == "\\":
            escaped = True
        elif char == ":":
            fields.append("".join(current))
            current = []
        else:
            current.append(char)
    fields.append("".join(current))
    return fields


def saved_wifi_names() -> set[str]:
    names = set()
    output = run(["nmcli", "-t", "--escape", "yes", "-f", "NAME,TYPE", "connection", "show"])
    for line in output.splitlines():
        fields = split_escaped(line)
        if len(fields) >= 2 and fields[-1] in ("802-11-wireless", "wifi"):
            names.add(fields[0])
    return names


def wifi_networks() -> list[dict[str, object]]:
    saved = saved_wifi_names()
    output = run([
        "nmcli", "-t", "--escape", "yes", "-f",
        "IN-USE,SSID,SECURITY,SIGNAL,FREQ", "device", "wifi", "list", "--rescan", "auto",
    ])
    strongest: dict[str, dict[str, object]] = {}
    for line in output.splitlines():
        fields = split_escaped(line)
        if len(fields) < 5:
            continue
        active, ssid, security, signal, frequency = fields[:5]
        if not ssid:
            continue
        try:
            strength = int(signal)
        except ValueError:
            strength = 0
        row = {
            "ssid": ssid,
            "security": security if security and security != "--" else "OPEN",
            "secure": bool(security and security != "--"),
            "signal": strength,
            "frequency": frequency,
            "connected": active.strip() == "*",
            "saved": ssid in saved,
        }
        previous = strongest.get(ssid)
        if previous is None or row["connected"] or strength > int(previous["signal"]):
            strongest[ssid] = row
    return sorted(
        strongest.values(),
        key=lambda row: (not bool(row["connected"]), -int(row["signal"]), str(row["ssid"]).lower()),
    )


def active_wifi() -> list[dict[str, object]]:
    """Return only the connected Wi-Fi row for the always-visible bar."""

    output = run([
        "nmcli", "-t", "--escape", "yes", "-f",
        "IN-USE,SSID,SECURITY,SIGNAL,FREQ", "device", "wifi", "list", "--rescan", "no",
    ])
    for line in output.splitlines():
        fields = split_escaped(line)
        if len(fields) < 5 or fields[0].strip() != "*":
            continue
        _, ssid, security, signal, frequency = fields[:5]
        try:
            strength = int(signal)
        except ValueError:
            strength = 0
        return [{
            "ssid": ssid,
            "security": security if security and security != "--" else "OPEN",
            "secure": bool(security and security != "--"),
            "signal": strength,
            "frequency": frequency,
            "connected": True,
            "saved": True,
        }]
    return []


def parse_bluetooth_devices(output: str) -> dict[str, str]:
    devices: dict[str, str] = {}
    for line in output.splitlines():
        parts = line.strip().split(" ", 2)
        if len(parts) == 3 and parts[0] == "Device":
            devices[parts[1]] = parts[2]
    return devices


def bluetooth_devices() -> tuple[bool, list[dict[str, object]]]:
    show = run(["bluetoothctl", "show"])
    powered = "Powered: yes" in show
    known = parse_bluetooth_devices(run(["bluetoothctl", "devices"]))
    paired = set(parse_bluetooth_devices(run(["bluetoothctl", "devices", "Paired"])).keys())
    connected = set(parse_bluetooth_devices(run(["bluetoothctl", "devices", "Connected"])).keys())
    rows = [
        {
            "address": address,
            "name": name,
            "paired": address in paired,
            "connected": address in connected,
        }
        for address, name in known.items()
    ]
    rows.sort(key=lambda row: (not bool(row["connected"]), not bool(row["paired"]), str(row["name"]).lower()))
    return powered, rows


def ethernet_devices() -> list[dict[str, object]]:
    output = run([
        "nmcli", "-t", "--escape", "yes", "-f",
        "DEVICE,TYPE,STATE,CONNECTION", "device", "status",
    ])
    rows = []
    for line in output.splitlines():
        fields = split_escaped(line)
        if len(fields) < 4 or fields[1] != "ethernet":
            continue
        rows.append({
            "device": fields[0],
            "state": fields[2],
            "connection": fields[3] if fields[3] != "--" else "",
            "connected": fields[2] == "connected",
        })
    return rows


def main() -> None:
    manager_available = shutil.which("nmcli") is not None
    if "--summary" in sys.argv:
        print(json.dumps({
            "available": manager_available,
            "summary": True,
            "wifi": active_wifi() if manager_available else [],
        }, separators=(",", ":")))
        return
    bluetooth_powered, bluetooth = bluetooth_devices()
    payload = {
        "available": manager_available,
        "wifi": wifi_networks() if manager_available else [],
        "bluetoothPowered": bluetooth_powered,
        "bluetooth": bluetooth,
        "ethernet": ethernet_devices(),
    }
    print(json.dumps(payload, separators=(",", ":")))


if __name__ == "__main__":
    main()
