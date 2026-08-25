pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import ".."

QtObject {
    id: root

    readonly property string helperPath: {
        const value = Qt.resolvedUrl("../scripts/system-telemetry.py").toString();
        return value.indexOf("file://") === 0
            ? decodeURIComponent(value.substring(7)) : value;
    }
    property int cpuPercent: 0
    property int memoryPercent: 0
    property real memoryUsedGb: 0
    property real memoryTotalGb: 0
    property int cpuTemperature: 0
    property int gpuTemperature: 0
    property int diskPercent: 0
    property real diskUsedGb: 0
    property real diskTotalGb: 0
    property real networkDown: 0
    property real networkUp: 0
    property int uptimeSeconds: 0
    property string hostname: "ASTRALITH"
    property string kernel: ""
    property real loadAverage: 0
    property int processCount: 0
    property var folders: []
    readonly property bool folderDetailActive: ShellState.ephemerisVisible
        && ShellState.ephemerisTab === "system"

    property real previousCpuTotal: 0
    property real previousCpuIdle: 0
    property real previousRxTotal: 0
    property real previousTxTotal: 0
    property double previousSampleMs: 0

    readonly property string uptimeLabel: {
        const days = Math.floor(uptimeSeconds / 86400);
        const hours = Math.floor((uptimeSeconds % 86400) / 3600);
        const minutes = Math.floor((uptimeSeconds % 3600) / 60);
        return days > 0 ? days + "D " + hours + "H"
            : hours > 0 ? hours + "H " + minutes + "M" : minutes + "M";
    }
    readonly property string networkDownLabel: formatRate(networkDown)
    readonly property string networkUpLabel: formatRate(networkUp)

    function bytesToGb(bytes) {
        return Math.round(bytes / 1073741824 * 10) / 10;
    }

    function formatBytes(bytes) {
        if (!bytes || bytes <= 0)
            return "0 B";
        const units = ["B", "KB", "MB", "GB", "TB"];
        const index = Math.min(units.length - 1,
            Math.floor(Math.log(bytes) / Math.log(1024)));
        return (bytes / Math.pow(1024, index)).toFixed(index > 1 ? 1 : 0)
            + " " + units[index];
    }

    function formatRate(bytes) {
        return formatBytes(bytes) + "/s";
    }

    function applySnapshot(data) {
        const now = Date.now();
        const total = Number(data.cpu_total || 0);
        const idle = Number(data.cpu_idle || 0);
        const totalDelta = total - previousCpuTotal;
        const idleDelta = idle - previousCpuIdle;
        if (previousCpuTotal > 0 && totalDelta > 0)
            cpuPercent = Math.round((1 - idleDelta / totalDelta) * 100);

        const elapsed = previousSampleMs > 0
            ? Math.max(0.25, (now - previousSampleMs) / 1000) : 0;
        const rx = Number(data.rx_total || 0);
        const tx = Number(data.tx_total || 0);
        if (elapsed > 0 && previousRxTotal > 0) {
            networkDown = Math.max(0, (rx - previousRxTotal) / elapsed);
            networkUp = Math.max(0, (tx - previousTxTotal) / elapsed);
        }

        previousCpuTotal = total;
        previousCpuIdle = idle;
        previousRxTotal = rx;
        previousTxTotal = tx;
        previousSampleMs = now;

        const memoryTotal = Number(data.memory_total || 0);
        const memoryUsed = Number(data.memory_used || 0);
        memoryPercent = memoryTotal > 0
            ? Math.round(memoryUsed / memoryTotal * 100) : 0;
        memoryUsedGb = bytesToGb(memoryUsed);
        memoryTotalGb = bytesToGb(memoryTotal);
        cpuTemperature = Number(data.cpu_temp || 0);
        gpuTemperature = Number(data.gpu_temp || 0);

        const diskTotal = Number(data.disk_total || 0);
        const diskUsed = Number(data.disk_used || 0);
        diskPercent = diskTotal > 0
            ? Math.round(diskUsed / diskTotal * 100) : 0;
        diskUsedGb = bytesToGb(diskUsed);
        diskTotalGb = bytesToGb(diskTotal);
        uptimeSeconds = Number(data.uptime || 0);
        hostname = data.hostname || "ASTRALITH";
        kernel = data.kernel || "";
        loadAverage = data.load && data.load.length > 0
            ? Number(data.load[0]) : 0;
        processCount = Number(data.processes || 0);
    }

    function refresh() {
        if (!snapshotProcess.running)
            snapshotProcess.running = true;
    }

    function refreshFolders() {
        if (!folderProcess.running)
            folderProcess.running = true;
    }

    property Process snapshotProcess: Process {
        command: ["python3", "-u", root.helperPath, "--watch", "2"]
        running: true
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
                try {
                    root.applySnapshot(JSON.parse(String(data)));
                } catch (error) {
                    console.warn("[Astralith/System] Telemetry decode failed:", error);
                }
            }
        }
        onRunningChanged: if (!running) root.snapshotRestart.restart()
    }

    property Process folderProcess: Process {
        command: ["python3", root.helperPath, "--folders"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.folders = JSON.parse(text).folders || [];
                } catch (error) {
                    console.warn("[Astralith/System] Folder telemetry decode failed:", error);
                }
            }
        }
    }

    property Timer snapshotRestart: Timer {
        interval: 2000
        onTriggered: root.refresh()
    }

    property Timer folderTimer: Timer {
        interval: 300000
        running: root.folderDetailActive
        repeat: true
        triggeredOnStart: true
        onTriggered: root.refreshFolders()
    }
}
