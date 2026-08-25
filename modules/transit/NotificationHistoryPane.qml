import QtQuick
import QtQuick.Layouts
import "../.."
import "../../components"
import "../../services"

pragma ComponentBehavior: Bound

Item {
    id: root

    onVisibleChanged: {
        if (visible)
            Notifications.markRead();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    text: "TRANSIT SIGNALS"
                    color: Theme.moon
                    font.family: Theme.fontDisplay
                    font.pixelSize: 20
                    font.weight: Font.DemiBold
                }
                Text {
                    text: Notifications.history.count + " SIGNALS RETAINED"
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: 8
                    font.letterSpacing: 1
                }
            }

            Rectangle {
                implicitWidth: dndRow.implicitWidth + 18
                implicitHeight: 32
                radius: 16
                color: Settings.doNotDisturb ? Theme.accentVeil : Theme.mantle
                border.width: 1
                border.color: Settings.doNotDisturb ? Theme.accentLine : Theme.line
                RowLayout {
                    id: dndRow
                    anchors.centerIn: parent
                    spacing: 6
                    Rectangle {
                        Layout.preferredWidth: 6
                        Layout.preferredHeight: 6
                        radius: 3
                        color: Settings.doNotDisturb ? Theme.warning : Theme.success
                    }
                    Text {
                        text: Settings.doNotDisturb ? "DND ACTIVE" : "SIGNALS LIVE"
                        color: Settings.doNotDisturb ? Theme.warning : Theme.moon
                        font.family: Theme.fontMono
                        font.pixelSize: 7
                        font.weight: Font.Bold
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Settings.doNotDisturb = !Settings.doNotDisturb
                }
            }

            Rectangle {
                implicitWidth: clearText.implicitWidth + 18
                implicitHeight: 32
                radius: Theme.radiusSmall
                color: clearPointer.containsMouse ? Theme.elevated : Theme.mantle
                border.width: 1
                border.color: Theme.line
                Text {
                    id: clearText
                    anchors.centerIn: parent
                    text: "CLEAR"
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: 7
                }
                MouseArea {
                    id: clearPointer
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Notifications.clearHistory()
                }
            }
        }

        ListView {
            id: historyList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 8
            model: Notifications.history

            delegate: NotificationCard {
                required property var model
                uid: model.uid
                appName: model.appName
                summary: model.summary
                body: model.body
                icon: model.icon
                time: model.time
                critical: model.critical
                actions: model.actions || []
                width: historyList.width
                onActivated: Notifications.invokeDefault(uid)
                onActionInvoked: function(identifier) { Notifications.invokeAction(uid, identifier); }
                onDismissed: Notifications.removeHistory(uid)
            }

            Text {
                anchors.centerIn: parent
                visible: historyList.count === 0
                text: Settings.doNotDisturb ? "SILENCE ACROSS THE ARRAY" : "NO SIGNALS RECEIVED"
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: 10
                font.letterSpacing: 1
            }
        }
    }
}
