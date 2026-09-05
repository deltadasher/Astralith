import QtQuick
import Quickshell
import "../.."

PanelWindow {
    id: root
    required property var modelData
    screen: modelData
    anchors { top: true; left: true; right: true }
    implicitHeight: contents.implicitHeight
    color: "transparent"
    exclusionMode: ExclusionMode.Auto
    ApertureContents {
        id: contents
        anchors.fill: parent
        outputName: root.modelData.name
    }
}
