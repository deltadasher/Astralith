import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../.."

// Directly adapted from Serpantinum's CalendarPopup central hourly orbit.
Item {
    id: root

    property var hours: []
    property var current: ({})
    property string unitSymbol: "°C"
    // CalendarWidget reserves a 320px wing on either side. The remaining
    // center lane owns a deliberate Serpantinum-like ellipse.
    readonly property real sf: Math.max(0.72, Math.min(width / 1480, height / 680))
    readonly property real sideWingWidth: 320
    readonly property real centerLaneWidth: Math.max(420,
        width - sideWingWidth * 2 - 56 * sf)
    readonly property real orbitRadiusX: Math.max(235, Math.min(
        325 * sf, (centerLaneWidth - 72 * sf) / 2))
    readonly property real orbitRadiusY: Math.max(120, Math.min(
        150 * sf, (height - 150 * sf) / 2))
    property real introClock: 0
    property real introAmbient: 0
    property real globalOrbitAngle: 0
    property real secondPulse: 1

    // Equal angle steps do not look equally spaced on an ellipse. Walk a
    // sampled ellipse by distance instead, starting in the lower-right so the
    // current forecast remains the visual anchor.
    function equalArcAngle(index, count, radiusX, radiusY) {
        if (count <= 1)
            return 38 * Math.PI / 180;

        const segments = 720;
        const start = 38 * Math.PI / 180;
        const step = Math.PI * 2 / segments;
        let previousX = Math.cos(start) * radiusX;
        let previousY = Math.sin(start) * radiusY;
        let total = 0;
        const lengths = [0];

        for (let sample = 1; sample <= segments; sample++) {
            const angle = start + sample * step;
            const nextX = Math.cos(angle) * radiusX;
            const nextY = Math.sin(angle) * radiusY;
            total += Math.hypot(nextX - previousX, nextY - previousY);
            lengths.push(total);
            previousX = nextX;
            previousY = nextY;
        }

        const target = total * index / count;
        for (let sample = 1; sample < lengths.length; sample++) {
            if (lengths[sample] < target)
                continue;
            const segmentLength = lengths[sample] - lengths[sample - 1];
            const fraction = segmentLength > 0
                ? (target - lengths[sample - 1]) / segmentLength : 0;
            return start + (sample - 1 + fraction) * step;
        }
        return start;
    }

    NumberAnimation on globalOrbitAngle {
        from: 0
        to: Math.PI * 2
        duration: 90000
        loops: Animation.Infinite
        running: Settings.motion && root.visible
    }

    ParallelAnimation {
        running: true
        NumberAnimation {
            target: root
            property: "introClock"
            from: 0
            to: 1
            duration: Settings.motion ? 900 : 0
            easing.type: Easing.OutBack
            easing.overshoot: 1.15
        }
        NumberAnimation {
            target: root
            property: "introAmbient"
            from: 0
            to: 1
            duration: Settings.motion ? 1000 : 0
            easing.type: Easing.OutSine
        }
    }

    Rectangle {
        width: parent.width * 0.5
        height: width
        radius: width / 2
        x: parent.width * 0.75 - width / 2
            + Math.cos(root.globalOrbitAngle * 1.5) * 350 * root.sf
        y: parent.height * 0.3 - height / 2
            + Math.sin(root.globalOrbitAngle * 1.5) * 200 * root.sf
        opacity: 0.025 * root.introAmbient
        color: Theme.accent
    }

    Rectangle {
        width: parent.width * 0.6
        height: width
        radius: width / 2
        x: parent.width * 0.25 - width / 2
            + Math.sin(root.globalOrbitAngle * 1.2) * -300 * root.sf
        y: parent.height * 0.7 - height / 2
            + Math.cos(root.globalOrbitAngle * 1.2) * -250 * root.sf
        opacity: 0.02 * root.introAmbient
        color: Theme.cyan
    }

    Rectangle {
        width: parent.width * 0.45
        height: width
        radius: width / 2
        x: parent.width * 0.5 - width / 2
            + Math.cos(root.globalOrbitAngle * -1.8) * 400 * root.sf
        y: parent.height * 0.5 - height / 2
            + Math.sin(root.globalOrbitAngle * -1.8) * -350 * root.sf
        opacity: 0.015 * root.introAmbient
        color: Theme.rose
    }

    Text {
        id: backgroundGlyph
        anchors.centerIn: parent
        text: root.current.icon || ""
        font.family: Theme.fontDisplay
        font.pixelSize: 650 * root.sf
        color: Theme.accent
        opacity: (0.03 + 0.01 * Math.sin(root.globalOrbitAngle * 4)) * root.introAmbient
        property real drift: 0

        SequentialAnimation on drift {
            loops: Animation.Infinite
            running: Settings.motion
            NumberAnimation { to: -20 * root.sf; duration: 6000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 6000; easing.type: Easing.InOutSine }
        }
        transform: Translate { y: backgroundGlyph.drift }
    }

    Item {
        id: centralHub
        anchors.centerIn: parent
        width: 1
        height: 1
        z: 5
        opacity: root.introClock
        scale: 0.85 + 0.15 * root.introClock

        property real levitation: 0
        property real orbitBreath: 1
        property real rollBreath: 0

        SequentialAnimation on levitation {
            loops: Animation.Infinite
            running: Settings.motion
            NumberAnimation { to: -15 * root.sf; duration: 4000; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: 4000; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on orbitBreath {
            loops: Animation.Infinite
            running: Settings.motion
            NumberAnimation { to: 1.035; duration: 3500; easing.type: Easing.InOutSine }
            NumberAnimation { to: 1; duration: 3500; easing.type: Easing.InOutSine }
        }
        SequentialAnimation on rollBreath {
            loops: Animation.Infinite
            running: Settings.motion
            NumberAnimation { to: 0.55; duration: 5800; easing.type: Easing.InOutSine }
            NumberAnimation { to: -0.55; duration: 5800; easing.type: Easing.InOutSine }
        }

        transform: [
            Translate { y: 25 * root.sf * (1 - root.introClock) },
            Translate { y: centralHub.levitation },
            Rotation { axis { x: 0; y: 0; z: 1 } angle: centralHub.rollBreath }
        ]

        Canvas {
            id: orbitCanvas
            z: -10
            readonly property real paintPadding: Math.max(8, 10 * root.sf)
            x: -width / 2
            y: -height / 2
            width: (root.orbitRadiusX + paintPadding) * 2
            height: (root.orbitRadiusY + paintPadding) * 2
            opacity: 0.25
            scale: centralHub.orbitBreath
            property color orbitColor: Theme.accent

            onOrbitColorChanged: requestPaint()
            onPaintPaddingChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPaint: {
                const ctx = getContext("2d");
                ctx.clearRect(0, 0, width, height);
                ctx.beginPath();
                for (let angle = 0; angle <= Math.PI * 2 + 0.01; angle += 0.035) {
                    const xx = width / 2 + Math.cos(angle) * root.orbitRadiusX;
                    const yy = height / 2 + Math.sin(angle) * root.orbitRadiusY;
                    if (angle === 0) ctx.moveTo(xx, yy); else ctx.lineTo(xx, yy);
                }
                ctx.strokeStyle = orbitColor;
                ctx.lineWidth = Math.max(1, 1.5 * root.sf);
                ctx.setLineDash([4 * root.sf, 10 * root.sf]);
                ctx.stroke();
            }
        }

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 0
            z: 0
            scale: 0.95 + 0.05 * root.secondPulse

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 2 * root.sf
                Text {
                    text: Qt.formatDateTime(clock.date, "HH:mm")
                    font.family: Theme.fontMono
                    font.weight: Font.Black
                    font.pixelSize: 58 * root.sf
                    color: Theme.moon
                }
                Text {
                    text: Qt.formatDateTime(clock.date, ":ss")
                    font.family: Theme.fontMono
                    font.weight: Font.Bold
                    font.pixelSize: 22 * root.sf
                    color: Theme.accent
                    Layout.alignment: Qt.AlignBottom
                    Layout.bottomMargin: 10 * root.sf
                    opacity: root.secondPulse > 1.02 ? 1 : 0.6
                }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(clock.date, "dddd, MMMM dd")
                font.family: Theme.fontMono
                font.weight: Font.Bold
                font.pixelSize: 11 * root.sf
                color: Theme.muted
            }
        }

        Repeater {
            id: hourRepeater
            model: root.hours.slice ? root.hours.slice(0, 8) : []

            delegate: Item {
                id: satellite
                required property var modelData
                required property int index
                readonly property bool highlighted: index === 0
                readonly property int satelliteCount: Math.max(1, hourRepeater.count)
                readonly property real radiusX: root.orbitRadiusX * centralHub.orbitBreath
                readonly property real radiusY: root.orbitRadiusY * centralHub.orbitBreath
                readonly property real baseRadians: root.equalArcAngle(index,
                    satelliteCount, radiusX, radiusY)
                readonly property real commonDrift: Math.sin(root.globalOrbitAngle * 4)
                    * 0.55 * Math.PI / 180
                readonly property real radians: baseRadians + commonDrift

                x: Math.cos(radians) * radiusX - width / 2
                y: Math.sin(radians) * radiusY - height / 2
                z: Math.sin(radians) * 100 * root.sf
                scale: highlighted ? 1.16 : 1
                opacity: highlighted ? 1 : 0.84
                width: 56 * root.sf
                height: 95 * root.sf

                Rectangle {
                    anchors.fill: parent
                    radius: 28 * root.sf
                    color: satellite.highlighted ? Theme.accent
                        : hourPointer.containsMouse ? Theme.controlHover : Theme.controlRest
                    border.width: 0

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 4 * root.sf
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: satellite.modelData.time
                            font.family: Theme.fontMono
                            font.weight: Font.Bold
                            font.pixelSize: 11 * root.sf
                            color: satellite.highlighted ? Theme.void_ : Theme.muted
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: satellite.modelData.icon || "·"
                            font.family: Theme.fontDisplay
                            font.pixelSize: 15 * root.sf
                            color: satellite.highlighted ? Theme.void_ : Theme.accent
                            transform: Translate { y: hourPointer.containsMouse ? -3 * root.sf : 0 }
                        }
                        Text {
                            Layout.alignment: Qt.AlignHCenter
                            text: Math.round(Number(satellite.modelData.temp)) + root.unitSymbol
                            font.family: Theme.fontMono
                            font.weight: Font.Black
                            font.pixelSize: 10 * root.sf
                            color: satellite.highlighted ? Theme.void_ : Theme.moon
                        }
                    }
                }
                MouseArea {
                    id: hourPointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                }
            }
        }
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: {
            root.secondPulse = 1.06;
            pulseReset.restart();
        }
    }
    NumberAnimation {
        id: pulseReset
        target: root
        property: "secondPulse"
        to: 1
        duration: 600
        easing.type: Easing.OutQuint
    }
    SystemClock { id: clock; precision: SystemClock.Seconds }
}
