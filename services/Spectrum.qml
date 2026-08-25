pragma Singleton

import QtQuick
import Quickshell.Io
import ".."

QtObject {
    id: root

    property var values: Array(28).fill(0)
    property bool available: false
    property string error: ""
    readonly property bool requested: ShellState.ephemerisVisible
        && (ShellState.ephemerisTab === "media" || ShellState.ephemerisTab === "audio")
    readonly property string configPath: {
        const value = Qt.resolvedUrl("../config/cava-raw.conf").toString();
        return value.indexOf("file://") === 0
            ? decodeURIComponent(value.substring(7)) : value;
    }

    function consume(frame) {
        const parts = String(frame).trim().split(";");
        if (parts.length < 8)
            return;
        const next = [];
        for (let index = 0; index < 28; index++) {
            const raw = index < parts.length ? Number(parts[index]) : 0;
            next.push(isFinite(raw) ? Math.max(0, Math.min(1, raw / 100)) : 0);
        }
        values = next;
        available = true;
        error = "";
    }

    property Process cavaProcess: Process {
        command: ["cava", "-p", root.configPath]
        running: root.requested && Media.available
        stdout: SplitParser {
            splitMarker: "\n"
            onRead: function(data) { root.consume(data); }
        }
        stderr: SplitParser {
            splitMarker: "\n"
            onRead: function(data) {
                const message = String(data).trim();
                if (message.length)
                    root.error = message;
            }
        }
        onRunningChanged: {
            if (!running && (!root.requested || !Media.available)) {
                root.available = false;
                root.values = Array(28).fill(0);
            }
        }
    }
}
