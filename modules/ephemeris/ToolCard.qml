import QtQuick
import QtQuick.Layouts
import "../.."

Rectangle {
    id: root
    implicitHeight: 108
    radius: Theme.radiusMedium
    color: pointer.containsMouse && root.available ? Theme.elevated : Theme.mantle
    border.width: 1
    border.color: pointer.containsMouse && root.available
        ? Theme.accentLine : Theme.line
    opacity: root.available ? 1 : 0.52

    property string code: "SYS/00"
    property string title: "Tool"
    property string detail: "Tool description"
    property string status: "READY"
    property bool available: true
    signal activated

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 6

        RowLayout {
            Layout.fillWidth: true
            Text {
                Layout.fillWidth: true
                text: root.code
                color: Theme.accent
                font.family: Theme.fontMono
                font.pixelSize: 8
                font.letterSpacing: 1.1
            }
            Text {
                text: root.status
                color: root.available ? Theme.success : Theme.warning
                font.family: Theme.fontMono
                font.pixelSize: 8
                font.letterSpacing: 0.8
            }
        }

        Text {
            Layout.fillWidth: true
            text: root.title
            color: Theme.moon
            font.family: Theme.fontDisplay
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }

        Text {
            Layout.fillWidth: true
            text: root.detail
            color: Theme.muted
            font.family: Theme.fontText
            font.pixelSize: 10
            elide: Text.ElideRight
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        enabled: root.available
        hoverEnabled: true
        cursorShape: root.available ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: root.activated()
    }

    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
    Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }
}
