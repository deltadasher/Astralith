import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

Rectangle {
    id: root

    implicitWidth: row.implicitWidth + 14
    implicitHeight: Settings.compact ? 28 : 32
    radius: 9
    color: pointer.containsMouse ? Theme.barNeutralHover : "transparent"
    border.width: 0
    scale: pointer.containsMouse ? 1.03 : 1

    RowLayout {
        id: row
        anchors.centerIn: parent
        spacing: 6

        Rectangle {
            Layout.preferredWidth: 5
            Layout.preferredHeight: 5
            radius: 3
            color: NetState.connected ? Theme.success : Theme.danger
        }
        Text {
            text: NetState.kind
            color: Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: 8
            font.letterSpacing: 0.8
        }
        Text {
            visible: Settings.showNetworkLabel
            text: NetState.label
            color: Theme.moon
            font.family: Theme.fontMono
            font.pixelSize: 9
            elide: Text.ElideRight
            Layout.maximumWidth: 90
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: ShellState.toggleEphemeris("network")
    }

    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    Behavior on scale { NumberAnimation { duration: Theme.motionFast; easing.type: Easing.OutBack } }
}
