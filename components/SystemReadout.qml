import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

Rectangle {
    id: root
    implicitWidth: row.implicitWidth + 14
    implicitHeight: Settings.compact ? 28 : 32
    radius: 9
    color: hover.hovered ? Theme.barNeutralHover : "transparent"
    border.width: 0

    HoverHandler { id: hover }

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 9

        Repeater {
            model: Settings.showSystemStats ? [
                { "code": "CPU", "value": SysStats.cpuPercent + "%" },
                { "code": "MEM", "value": SysStats.memoryPercent + "%" }
            ] : []

            Item {
                id: statHitbox
                required property var modelData
                Layout.preferredWidth: stat.implicitWidth
                Layout.preferredHeight: root.implicitHeight

                RowLayout {
                    id: stat
                    anchors.centerIn: parent
                    spacing: 4
                    Text {
                        text: statHitbox.modelData.code
                        color: Theme.muted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                        font.letterSpacing: 0.8
                    }
                    Text {
                        text: statHitbox.modelData.value
                        color: Theme.moon
                        font.family: Theme.fontMono
                        font.pixelSize: 9
                    }
                }
                TapHandler { onTapped: ShellState.toggleEphemeris("system") }
            }
        }

        Rectangle {
            id: audioDivider
            visible: Settings.showAudio && Settings.showSystemStats
            Layout.preferredWidth: 1
            Layout.preferredHeight: 13
            color: Theme.barHairlineHover
        }

        Item {
            id: audioHitbox
            visible: Settings.showAudio
            Layout.preferredWidth: audioReadout.implicitWidth
            Layout.preferredHeight: root.implicitHeight

            RowLayout {
                id: audioReadout
                anchors.centerIn: parent
                spacing: 4
                Text {
                    text: Audio.muted ? "MUT" : "VOL"
                    color: Audio.muted ? Theme.warning : Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: 8
                    font.letterSpacing: 0.8
                }
                Text {
                    text: Audio.percent + "%"
                    color: Theme.moon
                    font.family: Theme.fontMono
                    font.pixelSize: 9
                }
            }
            TapHandler { onTapped: ShellState.toggleEphemeris("audio") }
        }
    }

    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
        onWheel: function(event) {
            Audio.change(event.angleDelta.y > 0 ? 5 : -5);
            event.accepted = true;
        }
    }

    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
}
