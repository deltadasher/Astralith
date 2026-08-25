pragma Singleton

import QtQuick
import Quickshell.Io

QtObject {
    id: root

    property string preset: "Flat"
    property var bands: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    property bool available: false
    property bool busy: false
    property string error: ""
    readonly property string helperPath: {
        const value = Qt.resolvedUrl("../scripts/equalizer-state.py").toString();
        return value.indexOf("file://") === 0
            ? decodeURIComponent(value.substring(7)) : value;
    }

    function consume(text) {
        try {
            const data = JSON.parse(String(text).trim());
            preset = data.preset || "Flat";
            bands = data.bands || bands;
            available = data.available === true;
            error = "";
        } catch (decodeError) {
            error = String(decodeError);
        }
    }

    function refresh() {
        if (!readProcess.running)
            readProcess.running = true;
    }

    function applyPreset(name) {
        const recipes = {
            "Flat": [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
            "Bass": [5, 7, 5, 2, 1, 0, 0, 0, 1, 2],
            "Treble": [-2, -1, 0, 1, 2, 3, 4, 5, 6, 6],
            "Vocal": [-2, -1, 1, 3, 5, 5, 4, 2, 1, 0],
            "Pop": [2, 4, 2, 0, 1, 2, 4, 2, 1, 2],
            "Rock": [5, 4, 2, -1, -2, -1, 2, 4, 5, 6],
            "Jazz": [3, 3, 1, 1, 1, 1, 2, 1, 2, 3],
            "Classic": [0, 1, 2, 2, 2, 2, 1, 2, 3, 4]
        };
        if (!recipes[name] || actionProcess.running)
            return;
        preset = name;
        bands = recipes[name];
        busy = true;
        actionProcess.command = ["python3", helperPath, "preset", name];
        actionProcess.running = true;
    }

    function setBand(index, value) {
        if (actionProcess.running)
            return;
        const next = bands.slice();
        next[index] = Math.max(-12, Math.min(12, Math.round(value)));
        bands = next;
        preset = "Custom";
        busy = true;
        actionProcess.command = ["python3", helperPath, "band", String(index), String(next[index])];
        actionProcess.running = true;
    }

    property Process readProcess: Process {
        command: ["python3", root.helperPath, "get"]
        running: true
        stdout: StdioCollector { onStreamFinished: root.consume(text) }
    }

    property Process actionProcess: Process {
        stdout: StdioCollector { onStreamFinished: root.consume(text) }
        onRunningChanged: if (!running) root.busy = false
    }
}
