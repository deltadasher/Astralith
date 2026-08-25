import QtQuick
import QtQuick.Layouts
import ".."

Rectangle {
    id: root

    implicitHeight: status.length > 0 ? 72 : 58
    radius: Theme.radiusMedium
    color: Theme.mantle
    border.width: 1
    border.color: editor.activeFocus ? Theme.accentLine : Theme.line

    property string label: "Command"
    property string detail: ""
    property string value: ""
    property string status: ""
    property bool statusOk: true
    signal committed(string value)

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 10
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
                Layout.fillWidth: true
                text: root.detail
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: 10
                elide: Text.ElideRight
            }
        }

        ColumnLayout {
            Layout.preferredWidth: 180
            spacing: 3

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 32
                radius: Theme.radiusSmall
                color: Theme.elevated
                border.width: 1
                border.color: editor.activeFocus ? Theme.accentLine : Theme.line

                TextInput {
                    id: editor
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    text: root.value
                    color: Theme.moon
                    selectionColor: Theme.accent
                    selectedTextColor: Theme.void_
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    clip: true
                    onEditingFinished: root.committed(text.trim())
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.status.length > 0
                text: root.status
                horizontalAlignment: Text.AlignRight
                color: root.statusOk ? Theme.success : Theme.warning
                font.family: Theme.fontMono
                font.pixelSize: 8
                font.letterSpacing: 0.5
                elide: Text.ElideLeft
            }
        }
    }
}
