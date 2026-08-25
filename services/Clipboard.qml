pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property bool available: false
    property bool loading: false
    property var entries: []
    readonly property string helperPath: {
        const value = Qt.resolvedUrl("../scripts/clipboard-index.py").toString();
        return value.indexOf("file://") === 0 ? decodeURIComponent(value.substring(7)) : value;
    }
    readonly property string cachePath: {
        const xdg = Quickshell.env("XDG_CACHE_HOME") || "";
        const home = Quickshell.env("HOME") || "/tmp";
        return (xdg.length > 0 ? xdg : home + "/.cache")
            + "/astralith/clipboard";
    }

    function refresh() {
        if (!available || fetchProcess.running)
            return;
        loading = true;
        fetchProcess.running = true;
    }

    function copy(entryId) {
        if (!available)
            return;
        Quickshell.execDetached(["sh", "-c",
            "cliphist decode \"$1\" | wl-copy", "astralith", String(entryId)]);
    }

    function clear() {
        if (!available || wipeProcess.running)
            return;
        wipeProcess.running = true;
    }

    property Process probeProcess: Process {
        command: ["sh", "-c", "command -v cliphist >/dev/null && command -v wl-paste >/dev/null && command -v wl-copy >/dev/null && printf READY || printf MISSING"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                root.available = text === "READY";
                if (root.available)
                    root.refresh();
            }
        }
    }

    property Process textWatcher: Process {
        command: ["wl-paste", "--type", "text", "--watch", "cliphist", "store"]
        running: root.available
    }

    property Process imageWatcher: Process {
        command: ["wl-paste", "--type", "image", "--watch", "cliphist", "store"]
        running: root.available
    }

    property Process fetchProcess: Process {
        command: ["python3", root.helperPath, root.cachePath]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.entries = JSON.parse(text.length > 0 ? text : "[]");
                } catch (error) {
                    root.entries = [];
                }
                root.loading = false;
            }
        }
    }

    property Process wipeProcess: Process {
        command: ["cliphist", "wipe"]
        onRunningChanged: {
            if (!running) {
                root.entries = [];
                root.refreshDelay.restart();
            }
        }
    }

    property Timer refreshDelay: Timer {
        interval: 180
        onTriggered: root.refresh()
    }

    property Timer refreshTimer: Timer {
        interval: 2200
        running: root.available
        repeat: true
        onTriggered: root.refresh()
    }
}
