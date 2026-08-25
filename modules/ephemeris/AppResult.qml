import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import "../.."

Rectangle {
    id: root
    height: 58
    radius: Theme.radiusMedium
    color: root.selected ? Theme.accentVeil
        : pointer.containsMouse ? Theme.elevated : "transparent"
    border.width: 1
    border.color: root.selected ? Theme.accentLine : "transparent"

    required property var modelData
    required property int index
    property bool selected: false
    signal activated
    signal hovered(int index)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 11
        anchors.rightMargin: 12
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 10
            color: Theme.elevated
            border.width: 1
            border.color: root.selected ? Theme.accentLine : Theme.line

            IconImage {
                anchors.centerIn: parent
                implicitSize: 25
                source: Quickshell.iconPath(root.modelData.icon, "application-x-executable")
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                Layout.fillWidth: true
                text: root.modelData.name
                color: Theme.moon
                font.family: Theme.fontText
                font.pixelSize: 12
                font.weight: root.selected ? Font.DemiBold : Font.Normal
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: Settings.showAppDescriptions
                text: root.modelData.genericName || root.modelData.comment || root.modelData.id
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: 8
                elide: Text.ElideRight
            }
        }

        Text {
            visible: root.selected
            text: "LAUNCH  ↵"
            color: Theme.accent
            font.family: Theme.fontMono
            font.pixelSize: 8
            font.letterSpacing: 1
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onEntered: root.hovered(root.index)
        onClicked: root.activated()
    }

    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }
}
