import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../.."
import "../../../../services"
import "../.."

Item {
    ColumnLayout {
        anchors.fill: parent
        spacing: 14

        Text {
            text: "FIELD TOOLS"
            color: Theme.moon
            font.family: Theme.fontDisplay
            font.pixelSize: 20
            font.weight: Font.DemiBold
        }
        GridLayout {
            Layout.fillWidth: true
            columns: 2
            columnSpacing: 10
            rowSpacing: 10

            ToolCard {
                Layout.fillWidth: true
                code: "EPH/GUIDE"
                title: "Astralith flight manual"
                detail: "Browse modules, Niri controls, and the Serpantinum port map"
                onActivated: ShellState.toggleEphemeris("guide")
            }
            ToolCard {
                Layout.fillWidth: true
                code: "EPH/OPTICS"
                title: "Optics bay"
                detail: "Region and output capture, Satty editing, and 60 FPS recording"
                status: Environment.canCaptureRegion ? "ONLINE" : "MISSING"
                available: Environment.canCaptureRegion
                onActivated: ShellState.toggleEphemeris("capture")
            }
            ToolCard {
                Layout.fillWidth: true
                code: "NIR/OVERVIEW"
                title: "Niri overview"
                detail: "Reveal the compositor's workspace and window map"
                onActivated: {
                    ShellState.closeEphemeris();
                    Quickshell.execDetached(["niri", "msg", "action", "toggle-overview"]);
                }
            }
            ToolCard {
                Layout.fillWidth: true
                code: "NIR/PICK"
                title: "Window picker"
                detail: "Open overview before choosing a target window"
                onActivated: {
                    ShellState.closeEphemeris();
                    Quickshell.execDetached(["niri", "msg", "action", "toggle-overview"]);
                }
            }
            ToolCard {
                Layout.fillWidth: true
                code: "QCK/CHRONOS"
                title: "Chronos array"
                detail: "Countdown, lap stopwatch, and focus orbit"
                status: Timekeeper.anyRunning ? Timekeeper.activeDisplay : "READY"
                onActivated: ShellState.openQuickActions("timer")
            }
            ToolCard {
                Layout.fillWidth: true
                code: "EPH/FOCUS"
                title: "Focus orbit"
                detail: "Persistent focus and drift cycles, seven-day totals, and streaks"
                status: Focus.running ? Focus.displayTime : Focus.phaseLabel
                onActivated: ShellState.toggleEphemeris("focus")
            }
            ToolCard {
                Layout.fillWidth: true
                code: "SYS/OBS"
                title: "System observatory"
                detail: "Inspect thermals, memory, storage, network throughput, and uptime"
                status: SysStats.cpuTemperature > 0 ? SysStats.cpuTemperature + "°C" : "ONLINE"
                onActivated: ShellState.toggleEphemeris("system")
            }
            ToolCard {
                Layout.fillWidth: true
                code: "SYS/POWER"
                title: "Reactor telemetry"
                detail: "Battery health, wattage, capacity, and power flight mode"
                status: DeviceState.batteryAvailable ? DeviceState.batteryPercent + "%"
                    : DeviceState.powerProfileAvailable ? DeviceState.powerProfile.toUpperCase() : "DESKTOP"
                onActivated: ShellState.toggleEphemeris("battery")
            }
            ToolCard {
                Layout.fillWidth: true
                code: "QCK/LIVE"
                title: "Telemetry rail"
                detail: "Open the compact animated system constellation"
                status: SysStats.cpuPercent + "% CPU"
                onActivated: ShellState.openQuickActions("telemetry")
            }
            ToolCard {
                Layout.fillWidth: true
                code: "OPT/SCREEN"
                title: "Capture output"
                detail: "Save a timestamped full-output image"
                status: Environment.canCaptureScreen ? "ONLINE" : "MISSING"
                available: Environment.canCaptureScreen
                onActivated: { ShellState.closeEphemeris(); Environment.captureScreen(); }
            }
            ToolCard {
                Layout.fillWidth: true
                code: "UMB/LOCK"
                title: "Lock session"
                detail: "Engage Astralith's secure fluid Wayland session veil"
                status: Umbra.secure ? "SECURED" : "READY"
                onActivated: {
                    ShellState.closeEphemeris();
                    Umbra.launchLock();
                }
            }
            ToolCard {
                Layout.fillWidth: true
                code: "SYS/TERM"
                title: "Terminology"
                detail: "Open the nEri terminal"
                onActivated: { ShellState.closeEphemeris(); Quickshell.execDetached([Settings.terminal]); }
            }
        }
        Item { Layout.fillHeight: true }
    }
}
