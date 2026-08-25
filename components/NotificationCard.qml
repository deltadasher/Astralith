import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import ".."

Rectangle {
    id: root

    property int uid: 0
    property string appName: "System"
    property string summary: "Notification"
    property string body: ""
    property string icon: ""
    property string time: ""
    property bool critical: false
    property bool popup: false
    property var actions: []
    property real orbitAngle: 0
    readonly property string iconSource: {
        const value = String(icon || "");
        if (!value.length)
            return "";
        if (value.indexOf("://") >= 0 || value.indexOf("image:") === 0)
            return value;
        if (value.charAt(0) === "/")
            return "file://" + value;
        return Quickshell.iconPath(value, true);
    }
    property int revealedSummary: popup ? 0 : summary.length
    property int revealedBody: popup ? 0 : body.length
    signal activated()
    signal dismissed()
    signal expired()
    signal actionInvoked(string identifier)

    implicitHeight: Math.max(86, content.implicitHeight + 24)
    radius: Theme.radiusLarge
    color: critical ? Theme.controlDanger
        : hover.hovered ? Theme.controlHover : Theme.mantle
    border.width: 0
    clip: true

    Rectangle {
        width: parent.width * 0.7
        height: width
        radius: width / 2
        x: parent.width * 0.46 + Math.cos(root.orbitAngle) * 18
        y: -height * 0.55 + Math.sin(root.orbitAngle) * 10
        color: root.critical ? Theme.danger : Theme.accent
        opacity: 0.08
    }

    Rectangle {
        width: parent.width * 0.46
        height: width
        radius: width / 2
        x: -width * 0.36 + Math.sin(root.orbitAngle * 0.8) * 14
        y: parent.height - height * 0.48 + Math.cos(root.orbitAngle * 0.8) * 8
        color: root.critical ? Theme.warning : Theme.cyan
        opacity: 0.06
    }

    NumberAnimation on orbitAngle {
        from: 0
        to: Math.PI * 2
        duration: 24000
        loops: Animation.Infinite
        running: root.popup && Settings.motion
    }

    HoverHandler { id: hover }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: root.activated()
    }

    RowLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: root.popup ? -2 : 0
        anchors.leftMargin: 12
        anchors.rightMargin: 54
        spacing: 11

        Rectangle {
            Layout.preferredWidth: 38
            Layout.preferredHeight: 38
            radius: 12
            color: root.critical ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.15) : Theme.accentVeil
            clip: true

            IconImage {
                id: iconImage
                anchors.fill: parent
                anchors.margins: 5
                source: root.iconSource
                asynchronous: true
                visible: root.iconSource.length > 0 && status === Image.Ready
            }
            Text {
                anchors.centerIn: parent
                visible: !iconImage.visible
                text: root.appName.length > 0 ? root.appName.charAt(0).toUpperCase() : "•"
                color: root.critical ? Theme.danger : Theme.accent
                font.family: Theme.fontDisplay
                font.pixelSize: 15
                font.weight: Font.Bold
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: root.appName.toUpperCase()
                    color: root.critical ? Theme.danger : Theme.accent
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    font.letterSpacing: 0.9
                    elide: Text.ElideRight
                }
                Text {
                    text: root.time
                    color: Theme.lineBright
                    font.family: Theme.fontMono
                    font.pixelSize: 11
                }
            }
            Text {
                Layout.fillWidth: true
                text: root.summary.substring(0, root.revealedSummary)
                color: Theme.moon
                font.family: Theme.fontText
                font.pixelSize: 11
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }
            Text {
                Layout.fillWidth: true
                visible: root.body.length > 0
                text: root.body.substring(0, root.revealedBody)
                textFormat: Text.PlainText
                color: Theme.muted
                font.family: Theme.fontText
                font.pixelSize: 11
                maximumLineCount: root.popup ? 2 : 3
                wrapMode: Text.WordWrap
                elide: Text.ElideRight
            }

            RowLayout {
                Layout.fillWidth: true
                Layout.topMargin: 4
                spacing: 6
                visible: root.actions && root.actions.length > 0

                Repeater {
                    model: root.actions || []
                    Rectangle {
                        required property var modelData
                        implicitWidth: actionLabel.implicitWidth + 18
                        implicitHeight: 25
                        radius: 8
                        color: actionPointer.containsMouse ? Theme.accent : Theme.controlRest
                        border.width: 0
                        Text {
                            id: actionLabel
                            anchors.centerIn: parent
                            text: (modelData.text || modelData.identifier || "OPEN").toUpperCase()
                            color: actionPointer.containsMouse ? Theme.void_ : Theme.moon
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            font.weight: Font.Bold
                            font.letterSpacing: 0.7
                        }
                        MouseArea {
                            id: actionPointer
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.actionInvoked(modelData.identifier)
                        }
                    }
                }
                Item { Layout.fillWidth: true }
            }
        }

    }

    Rectangle {
        id: closeRail
        z: 2
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 46
        color: closePointer.containsMouse
            ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.11)
            : "transparent"

        Text {
            anchors.centerIn: parent
            text: "×"
            color: closePointer.containsMouse ? Theme.danger : Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: 21
            font.weight: Font.Medium
        }

        MouseArea {
            id: closePointer
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: root.dismissed()
        }
    }

    Rectangle {
        id: timeoutTrack
        visible: root.popup
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.bottomMargin: 8
        height: 3
        radius: 2
        color: Theme.line
        clip: true

        Rectangle {
            width: Math.max(0, parent.width * (1 - timeout.progress))
            height: parent.height
            radius: parent.radius
            color: root.critical ? Theme.danger : Theme.accent
        }
    }

    Timer {
        id: timeout
        property real progress: 0
        interval: 50
        repeat: true
        running: root.popup && !hover.hovered
        onTriggered: {
            progress = Math.min(1, progress + interval / (root.critical ? 10000 : 6500));
            if (progress >= 1) {
                stop();
                root.expired();
            }
        }
    }

    SequentialAnimation {
        id: typewriter
        running: root.popup && Settings.motion
        NumberAnimation {
            target: root
            property: "revealedSummary"
            from: 0
            to: root.summary.length
            duration: Math.min(520, 70 + root.summary.length * 15)
            easing.type: Easing.Linear
        }
        PauseAnimation { duration: 70 }
        NumberAnimation {
            target: root
            property: "revealedBody"
            from: 0
            to: root.body.length
            duration: Math.min(900, 60 + root.body.length * 10)
            easing.type: Easing.Linear
        }
    }

    Component.onCompleted: {
        if (!root.popup || !Settings.motion) {
            root.revealedSummary = root.summary.length;
            root.revealedBody = root.body.length;
        }
    }

    onSummaryChanged: {
        if (!popup || !Settings.motion)
            revealedSummary = summary.length;
    }
    onBodyChanged: {
        if (!popup || !Settings.motion)
            revealedBody = body.length;
    }

    Behavior on color { ColorAnimation { duration: Theme.motionFast } }
}
