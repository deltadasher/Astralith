import QtQuick
import QtQuick.Layouts
import "../../../.."
import "../../../../services"

Rectangle {
    id: root

    property string title: ""
    property string detail: ""
    property string glyph: ""
    property string code: ""
    property color tone: Theme.accent
    property bool active: false
    signal activated

    implicitHeight: 76
    radius: 15
    color: pointer.containsMouse
        ? Qt.rgba(root.tone.r, root.tone.g, root.tone.b, 0.075)
        : "transparent"
    border.width: 0
    clip: true

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 15
        anchors.rightMargin: 15
        anchors.topMargin: 10
        anchors.bottomMargin: 12
        spacing: 12

        Text {
            visible: root.glyph.length > 0
            text: root.glyph
            color: pointer.containsMouse || root.active ? root.tone : Theme.muted
            font.family: Theme.fontIcon
            font.pixelSize: 21
            Layout.alignment: Qt.AlignVCenter
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 3

            Text {
                Layout.fillWidth: true
                text: root.title
                color: Theme.moon
                font.family: Theme.fontDisplay
                font.pixelSize: 13
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                text: root.detail
                color: pointer.containsMouse ? Theme.muted : Theme.lineBright
                font.family: Theme.fontText
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        Text {
            visible: root.code.length > 0
            text: root.code
            color: pointer.containsMouse ? root.tone : Theme.lineBright
            font.family: Theme.fontMono
            font.pixelSize: 11
            font.weight: Font.Bold
            font.letterSpacing: 0.8
            opacity: pointer.containsMouse ? 1 : 0.58
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        width: pointer.containsMouse || root.active ? parent.width : 0
        height: 2
        radius: 1
        color: root.tone
        opacity: pointer.containsMouse || root.active ? 0.95 : 0

        Behavior on width {
            NumberAnimation {
                duration: Settings.motion ? 145 : 0
                easing.type: Easing.OutCubic
            }
        }
        Behavior on opacity { NumberAnimation { duration: Settings.motion ? 90 : 0 } }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.activated()
    }

    Behavior on color { ColorAnimation { duration: Settings.motion ? 100 : 0 } }
}
