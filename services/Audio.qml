pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
    id: root

    property real volume: 0
    property bool muted: false
    property real inputVolume: 0
    property bool inputMuted: false
    property bool mixerAvailable: false
    property var outputs: []
    property var inputs: []
    property var apps: []
    readonly property var defaultOutput: {
        const selected = outputs.find(function(node) { return node.isDefault; });
        return selected || (outputs.length > 0 ? outputs[0] : null);
    }
    readonly property string defaultOutputName: defaultOutput && defaultOutput.name
        ? defaultOutput.name : "Default output"
    readonly property string defaultOutputDetail: defaultOutput && defaultOutput.description
        ? defaultOutput.description : "PipeWire audio path"
    readonly property int percent: Math.round(volume * 100)
    readonly property int inputPercent: Math.round(inputVolume * 100)
    readonly property string helperPath: {
        const value = Qt.resolvedUrl("../scripts/audio-state.py").toString();
        return value.indexOf("file://") === 0
            ? decodeURIComponent(value.substring(7)) : value;
    }

    function refresh() {
        if (!readProcess.running)
            readProcess.running = true;
        if (!sourceReadProcess.running)
            sourceReadProcess.running = true;
        refreshMixer();
    }

    function refreshMixer() {
        if (!mixerProcess.running)
            mixerProcess.running = true;
    }

    function scheduleRefresh() {
        actionRefreshTimer.restart();
        mixerRefreshTimer.restart();
    }

    function change(delta) {
        Osd.show("volume", Math.max(0, Math.min(150, percent + delta)),
            muted ? "OUTPUT MUTED" : "OUTPUT VOLUME", muted);
        actionProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@",
            Math.abs(delta) + "%" + (delta >= 0 ? "+" : "-")];
        actionProcess.running = true;
        scheduleRefresh();
    }

    function toggleMute() {
        Osd.show("volume", percent, muted ? "OUTPUT VOLUME" : "OUTPUT MUTED", !muted);
        actionProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SINK@", "toggle"];
        actionProcess.running = true;
        scheduleRefresh();
    }

    function toggleMicrophone() {
        Osd.show("microphone", inputPercent,
            inputMuted ? "MICROPHONE LIVE" : "MICROPHONE MUTED", !inputMuted);
        actionProcess.command = ["wpctl", "set-mute", "@DEFAULT_AUDIO_SOURCE@", "toggle"];
        actionProcess.running = true;
        scheduleRefresh();
    }

    function setVolume(percent) {
        const target = Math.max(0, Math.min(150, percent));
        Osd.show("volume", target, "OUTPUT VOLUME", false);
        actionProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SINK@", target + "%"];
        actionProcess.running = true;
        scheduleRefresh();
    }

    function setMicrophoneVolume(percent) {
        const target = Math.max(0, Math.min(150, percent));
        Osd.show("microphone", target, "MICROPHONE GAIN", inputMuted);
        actionProcess.command = ["wpctl", "set-volume", "@DEFAULT_AUDIO_SOURCE@", target + "%"];
        actionProcess.running = true;
        scheduleRefresh();
    }

    function pactlOperation(kind, action) {
        if (kind === "outputs")
            return "set-sink-" + action;
        if (kind === "inputs")
            return "set-source-" + action;
        return "set-sink-input-" + action;
    }

    function setNodeVolume(kind, id, percent) {
        if (!id)
            return;
        const target = Math.max(0, Math.min(150, Math.round(percent)));
        Quickshell.execDetached(["pactl", pactlOperation(kind, "volume"), String(id), target + "%"]);
        Osd.show(kind === "inputs" ? "microphone" : "volume", target,
            kind === "apps" ? "APPLICATION STREAM" : kind === "inputs" ? "INPUT GAIN" : "OUTPUT VOLUME", false);
        scheduleRefresh();
    }

    function toggleNodeMute(kind, id, currentlyMuted) {
        if (!id)
            return;
        Quickshell.execDetached(["pactl", pactlOperation(kind, "mute"), String(id), "toggle"]);
        Osd.show(kind === "inputs" ? "microphone" : "volume", 0,
            currentlyMuted ? "STREAM LIVE" : "STREAM MUTED", !currentlyMuted);
        scheduleRefresh();
    }

    function setDefaultNode(kind, nodeName) {
        if (!nodeName || kind === "apps")
            return;
        Quickshell.execDetached(["pactl",
            kind === "inputs" ? "set-default-source" : "set-default-sink", nodeName]);
        scheduleRefresh();
    }

    property Process readProcess: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SINK@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/Volume:\s*([0-9.]+)/);
                if (match)
                    root.volume = parseFloat(match[1]);
                root.muted = text.indexOf("MUTED") >= 0;
            }
        }
    }

    property Process sourceReadProcess: Process {
        command: ["wpctl", "get-volume", "@DEFAULT_AUDIO_SOURCE@"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                const match = text.match(/Volume:\s*([0-9.]+)/);
                if (match)
                    root.inputVolume = parseFloat(match[1]);
                root.inputMuted = text.indexOf("MUTED") >= 0;
            }
        }
    }

    property Process mixerProcess: Process {
        command: ["python3", root.helperPath]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text);
                    root.mixerAvailable = data.available === true;
                    root.outputs = data.outputs || [];
                    root.inputs = data.inputs || [];
                    root.apps = data.apps || [];
                } catch (error) {
                    root.mixerAvailable = false;
                    console.warn("[Astralith/Audio] Mixer decode failed:", error);
                }
            }
        }
    }

    property Process actionProcess: Process {}

    property Timer actionRefreshTimer: Timer {
        interval: 180
        onTriggered: {
            if (!root.readProcess.running)
                root.readProcess.running = true;
            if (!root.sourceReadProcess.running)
                root.sourceReadProcess.running = true;
        }
    }

    property Timer mixerRefreshTimer: Timer {
        interval: 260
        onTriggered: root.refreshMixer()
    }

    property Timer refreshTimer: Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: root.refresh()
    }
}
