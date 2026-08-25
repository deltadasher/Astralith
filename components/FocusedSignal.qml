import QtQuick
import QtQuick.Layouts
import ".."
import "../services"

RowLayout {
    id: root
    spacing: 8

    readonly property var focusedWindow: Niri.windows.find(function(window) {
        return window.id === Niri.focusedWindowId;
    })
    readonly property string appId: focusedWindow && focusedWindow.app_id
        ? focusedWindow.app_id : "DEEP SPACE"
    readonly property string title: focusedWindow && focusedWindow.title
        ? focusedWindow.title : "NO SIGNAL"

    Rectangle {
        Layout.preferredWidth: 4
        Layout.preferredHeight: 4
        radius: 2
        color: root.focusedWindow ? Theme.cyan : Theme.lineBright
    }

    Text {
        text: root.appId.toUpperCase()
        color: Theme.muted
        font.family: Theme.fontMono
        font.pixelSize: 8
        font.letterSpacing: 1.1
        elide: Text.ElideRight
        Layout.maximumWidth: 120
    }

    Text {
        text: "//"
        color: Theme.lineBright
        font.family: Theme.fontMono
        font.pixelSize: 9
    }

    Text {
        text: root.title
        color: Theme.moon
        font.family: Theme.fontText
        font.pixelSize: 11
        elide: Text.ElideRight
        Layout.maximumWidth: 260
    }
}
