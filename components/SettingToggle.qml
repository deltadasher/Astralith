import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root
    implicitHeight: 54
    radius: Theme.radiusMedium
    color: root.checked ? Theme.controlActive
        : pointer.containsMouse ? Theme.controlHover : Theme.controlRest
    border.width: 0

    property string label: "Setting"
    property string detail: ""
    property bool checked: false
    signal toggled

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 12
        spacing: 12

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            Text {
                text: root.label
                color: Theme.moon
                font.family: Theme.fontText
                font.pixelSize: 12
                font.weight: Font.Medium
            }
            Text {
                text: root.detail
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: 10
                elide: Text.ElideRight
                Layout.fillWidth: true
            }
        }

        Rectangle {
            Layout.preferredWidth: 34
            Layout.preferredHeight: 18
            radius: 9
            color: root.checked ? Theme.accent : Theme.elevated
            border.width: 0

            Rectangle {
                y: 3
                x: root.checked ? 19 : 3
                width: 12
                height: 12
                radius: 6
                color: root.checked ? Theme.void_ : Theme.muted
                Behavior on x {
                    NumberAnimation {
                        duration: Settings.motion ? Theme.motionNormal : 0
                        easing.type: Easing.OutBack
                    }
                }
            }
        }
    }

    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled()
    }

    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
}
