pragma Singleton

import QtQuick
import ".."

QtObject {
    id: root

    readonly property var entries: [
        { "id": "resonance", "code": "MPR", "name": "Resonance",
            "detail": "MPRIS audio and video capsule", "enabled": Settings.showMedia,
            "available": Media.available, "status": Media.playerCount + " PLAYERS" },
        { "id": "parallax", "code": "WAL", "name": "Parallax",
            "detail": "Wallpaper archive and switcher", "enabled": true,
            "available": Environment.canSetWallpaper,
            "status": Environment.wallpapers.length + " WORLDS" },
        { "id": "devices", "code": "DEV", "name": "Device array",
            "detail": "Bluetooth, brightness, battery, and microphone", "enabled": Settings.showBluetooth || Settings.showBrightness || Settings.showBattery || Settings.showMicrophone,
            "available": DeviceState.bluetoothAvailable || DeviceState.brightnessAvailable || DeviceState.batteryAvailable,
            "status": "NATIVE" },
        { "id": "telemetry", "code": "TEL", "name": "Telemetry",
            "detail": "CPU, memory, audio, and network readouts", "enabled": Settings.showSystemStats,
            "available": true, "status": "ONLINE" },
        { "id": "relay", "code": "SNI", "name": "Status relay",
            "detail": "StatusNotifier system tray bridge", "enabled": Settings.showTray,
            "available": true, "status": "ONLINE" },
        { "id": "transit", "code": "SIG", "name": "Transit",
            "detail": "Notification toasts, history, unread state, and DND", "enabled": true,
            "available": true, "status": Notifications.history.count + " SIGNALS" },
        { "id": "clipboard", "code": "CLP", "name": "Clipboard orbit",
            "detail": "Searchable cliphist text and image archive", "enabled": true,
            "available": Clipboard.available, "status": Clipboard.entries.length + " CLIPS" },
        { "id": "optics", "code": "OPT", "name": "Optics",
            "detail": "Screenshots, Satty editing, and portal recording", "enabled": true,
            "available": Environment.canCaptureRegion,
            "status": Environment.recording ? "RECORDING"
                : Environment.canRecord ? "CAPTURE + VIDEO" : Environment.canCaptureRegion ? "CAPTURE" : "MISSING" },
        { "id": "quickactions", "code": "QCK", "name": "Quick actions",
            "detail": "On-demand timer and performance telemetry",
            "enabled": Settings.quickActionsEnabled, "available": true,
            "status": Timekeeper.anyRunning ? Timekeeper.activeDisplay : "READY" }
    ]

    function toggle(id) {
        if (id === "resonance")
            Settings.showMedia = !Settings.showMedia;
        else if (id === "devices") {
            const enable = !(Settings.showBluetooth || Settings.showBrightness
                || Settings.showBattery || Settings.showMicrophone);
            Settings.showBluetooth = enable;
            Settings.showBrightness = enable;
            Settings.showBattery = enable;
            Settings.showMicrophone = enable;
        } else if (id === "telemetry")
            Settings.showSystemStats = !Settings.showSystemStats;
        else if (id === "relay")
            Settings.showTray = !Settings.showTray;
        else if (id === "quickactions") {
            Settings.quickActionsEnabled = !Settings.quickActionsEnabled;
            if (!Settings.quickActionsEnabled)
                ShellState.hideQuickActions();
        }
    }
}
