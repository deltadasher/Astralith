import QtQuick
import Quickshell
import "../../../.."

// One legible orbital path, one evenly spaced body per hourly sample, and a
// central chronometer. Bodies deploy radially and drift without losing their
// formation.
Item {
    id: root

    property var hours: []
    property var current: ({})
    property string unitSymbol: "°C"

    readonly property int visibleHours: Math.min(8,
        hours && hours.length ? hours.length : 0)
    readonly property real scaleFactor: Math.max(0.72,
        Math.min(1, width / 720, height / 610))
    readonly property real orbitRadiusX: Math.max(112,
        Math.min(width * 0.43, 315 * scaleFactor))
    readonly property real orbitRadiusY: Math.max(145,
        Math.min(height * 0.34, 205 * scaleFactor))

    property real reveal: 0
    property real orbitPhase: 0
    property real secondPulse: 0

    clip: true

    function angleFor(index) {
        const count = Math.max(1, visibleHours);
        return -Math.PI / 2 + index * Math.PI * 2 / count + orbitPhase;
    }

    NumberAnimation {
        target: root
        property: "reveal"
        running: true
        from: 0
        to: 1
        duration: Settings.motion ? 620 : 0
        easing.type: Easing.OutCubic
    }

    NumberAnimation on orbitPhase {
        from: 0
        to: Math.PI * 2
        duration: 150000
        loops: Animation.Infinite
        running: Settings.motion && root.visible
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(250 * root.scaleFactor, parent.width * 0.38)
        height: width
        radius: width / 2
        color: Theme.accent
        opacity: 0.025 * root.reveal
        scale: 0.92 + root.secondPulse * 0.04
    }

    Column {
        anchors.centerIn: parent
        spacing: 5
        opacity: root.reveal
        scale: 0.9 + root.reveal * 0.1

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 2
            Text {
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: Theme.moon
                font.family: Theme.fontMono
                font.pixelSize: 46 * root.scaleFactor
                font.weight: Font.Black
            }
            Text {
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 7 * root.scaleFactor
                text: Qt.formatDateTime(clock.date, ":ss")
                color: Theme.accent
                opacity: 0.62 + root.secondPulse * 0.18
                font.family: Theme.fontMono
                font.pixelSize: 16 * root.scaleFactor
                font.weight: Font.Bold
            }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: Qt.formatDateTime(clock.date, "dddd, MMMM d")
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: 10 * root.scaleFactor
            font.weight: Font.DemiBold
        }
    }

    Repeater {
        model: root.hours && root.hours.slice ? root.hours.slice(0, 8) : []

        delegate: Item {
            id: forecastBody
            required property var modelData
            required property int index

            readonly property bool active: index === 0
            readonly property real angle: root.angleFor(index)
            readonly property real stagger: Math.max(0, Math.min(1,
                (root.reveal - index * 0.045) / 0.64))
            readonly property real bodyWidth: (active ? 68 : 54) * root.scaleFactor
            readonly property real bodyHeight: (active ? 94 : 70) * root.scaleFactor

            width: bodyWidth
            height: bodyHeight
            x: root.width / 2
                + Math.cos(angle) * root.orbitRadiusX * stagger - width / 2
            y: root.height / 2
                + Math.sin(angle) * root.orbitRadiusY * stagger - height / 2
            z: active ? 4 : 2
            opacity: stagger
            scale: 0.64 + stagger * (active ? 0.38 : 0.34)

            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: forecastBody.active ? Theme.accent
                    : bodyPointer.containsMouse ? Theme.controlHover : Theme.controlRest

                Column {
                    anchors.centerIn: parent
                    spacing: 1
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: forecastBody.modelData.time || "--:--"
                        color: forecastBody.active ? Theme.void_ : Theme.muted
                        font.family: Theme.fontMono
                        font.pixelSize: (forecastBody.active ? 11 : 9) * root.scaleFactor
                        font.weight: Font.Bold
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: forecastBody.modelData.icon || "·"
                        color: forecastBody.active ? Theme.void_ : Theme.accent
                        font.family: Theme.fontDisplay
                        font.pixelSize: (forecastBody.active ? 17 : 14) * root.scaleFactor
                    }
                    Text {
                        anchors.horizontalCenter: parent.horizontalCenter
                        text: Math.round(Number(forecastBody.modelData.temp)) + root.unitSymbol
                        color: forecastBody.active ? Theme.void_ : Theme.moon
                        font.family: Theme.fontMono
                        font.pixelSize: 10 * root.scaleFactor
                        font.weight: Font.Black
                    }
                }

                Behavior on color {
                    ColorAnimation { duration: Theme.motionFast }
                }
            }

            MouseArea {
                id: bodyPointer
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
            }
        }
    }

    SequentialAnimation on secondPulse {
        loops: Animation.Infinite
        running: Settings.motion && root.visible
        NumberAnimation { to: 1; duration: 900; easing.type: Easing.OutSine }
        NumberAnimation { to: 0; duration: 900; easing.type: Easing.InSine }
    }

    SystemClock { id: clock; precision: SystemClock.Seconds }
}
