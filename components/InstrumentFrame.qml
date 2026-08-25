import QtQuick
import ".."

Item {
    id: root

    property string module: "apps"
    property real presentation: 1
    readonly property color tone: Theme.moduleAccent(module)
    readonly property bool cinematic: Settings.atmosphereStyle === "cinematic"

    opacity: presentation

    component Corner: Item {
        required property bool rightSide
        required property bool bottomSide
        property color tone: root.tone
        width: 34
        height: 34

        Rectangle {
            width: 25
            height: 1
            x: parent.rightSide ? 9 : 0
            y: parent.bottomSide ? 33 : 0
            color: parent.tone
            opacity: 0.45
        }
        Rectangle {
            width: 1
            height: 25
            x: parent.rightSide ? 33 : 0
            y: parent.bottomSide ? 9 : 0
            color: parent.tone
            opacity: 0.45
        }
        Rectangle {
            width: 4
            height: 4
            radius: 2
            x: parent.rightSide ? 30 : 0
            y: parent.bottomSide ? 30 : 0
            color: parent.tone
            opacity: 0.8
        }
    }

    Corner { anchors.left: parent.left; anchors.top: parent.top; rightSide: false; bottomSide: false }
    Corner { anchors.right: parent.right; anchors.top: parent.top; rightSide: true; bottomSide: false }
    Corner { anchors.left: parent.left; anchors.bottom: parent.bottom; rightSide: false; bottomSide: true }
    Corner { anchors.right: parent.right; anchors.bottom: parent.bottom; rightSide: true; bottomSide: true }

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        spacing: 11
        Repeater {
            model: 7
            Rectangle {
                required property int index
                width: index === 3 ? 14 : 5
                height: 1
                color: index === 3 ? root.tone : Theme.lineBright
                opacity: index === 3 ? 0.62 : 0.3
            }
        }
    }

    Rectangle {
        visible: root.cinematic && Settings.motion
        y: 1
        width: 80
        height: 1
        color: root.tone
        opacity: 0.45
        x: -width
        NumberAnimation on x {
            from: -80
            to: root.width
            duration: 5200
            loops: Animation.Infinite
            easing.type: Easing.InOutSine
            running: root.visible && root.cinematic && Settings.motion
        }
    }
}
