"""Regression tests for low-overhead runtime helper paths."""

from __future__ import annotations

import importlib.util
from pathlib import Path
import unittest
from unittest import mock


ROOT = Path(__file__).resolve().parents[1]


def load_script(name: str):
    path = ROOT / "scripts" / name
    spec = importlib.util.spec_from_file_location(name.replace("-", "_"), path)
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Unable to load {path}")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


network_state = load_script("network-state.py")
system_telemetry = load_script("system-telemetry.py")


class NetworkSummaryTests(unittest.TestCase):
    def test_active_wifi_returns_only_connected_row(self) -> None:
        rows = ":Other:WPA2:81:2412\n*:Connected\\:SSID:WPA3:67:5785\n"
        with mock.patch.object(network_state, "run", return_value=rows):
            self.assertEqual(network_state.active_wifi(), [{
                "ssid": "Connected:SSID",
                "security": "WPA3",
                "secure": True,
                "signal": 67,
                "frequency": "5785",
                "connected": True,
                "saved": True,
            }])

    def test_active_wifi_handles_no_connection(self) -> None:
        with mock.patch.object(
            network_state, "run", return_value=":Other:WPA2:81:2412\n"
        ):
            self.assertEqual(network_state.active_wifi(), [])


class SystemTelemetryTests(unittest.TestCase):
    def test_snapshot_reuses_slow_sample(self) -> None:
        slow = {
            "disk_total": 10,
            "disk_used": 4,
            "cpu_temp": 52,
            "gpu_temp": 61,
            "processes": 100,
            "hostname": "test-host",
            "kernel": "test-kernel",
        }
        with (
            mock.patch.object(system_telemetry, "cpu_sample", return_value=(10, 4)),
            mock.patch.object(system_telemetry, "memory", return_value=(20, 8)),
            mock.patch.object(system_telemetry, "network_totals", return_value=(30, 12)),
            mock.patch.object(system_telemetry, "read_text", return_value="90.0 0.0"),
            mock.patch.object(system_telemetry.os, "getloadavg", return_value=(1, 2, 3)),
            mock.patch.object(system_telemetry, "slow_snapshot") as slow_probe,
        ):
            payload = system_telemetry.snapshot(slow)
        slow_probe.assert_not_called()
        self.assertEqual(payload["hostname"], "test-host")
        self.assertEqual(payload["memory_used"], 8)
        self.assertEqual(payload["rx_total"], 30)


if __name__ == "__main__":
    unittest.main()
