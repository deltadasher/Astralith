import QtQuick
import QtQuick.Layouts
import "../../../.."
import "../../../../services"

pragma ComponentBehavior: Bound

Item {
    id: root

    property string query: ""
    property string currentFilter: Environment.onlineWallpapers.length ? "Online" : "All"
    readonly property var filters: [
        { "label": "ALL", "value": "All", "color": "" },
        { "label": "IMAGE", "value": "Image", "color": "" },
        { "label": "VIDEO", "value": "Video", "color": "" },
        { "label": "ASTRA", "value": "Astralith", "color": Theme.accent },
        { "label": "SAVED", "value": "Downloaded", "color": Theme.success },
        { "label": "ONLINE", "value": "Online", "color": Theme.cyan },
        { "label": "", "value": "Blue", "color": "#4f8dff" },
        { "label": "", "value": "Purple", "color": "#a56bff" },
        { "label": "", "value": "Pink", "color": "#ef77ad" },
        { "label": "", "value": "Mono", "color": "#a6a7b2" }
    ]
    readonly property var filteredWallpapers: Environment.wallpapers.filter(function(entry) {
        const needle = root.query.trim().toLowerCase();
        const textMatch = !needle || (entry.name + " " + entry.source).toLowerCase().indexOf(needle) >= 0;
        if (!textMatch && root.currentFilter !== "Online")
            return false;
        if (root.currentFilter === "All") return textMatch;
        if (root.currentFilter === "Image") return entry.kind === "image" && textMatch;
        if (root.currentFilter === "Video") return entry.kind === "video" && textMatch;
        if (root.currentFilter === "Online") return entry.source === "Online";
        if (root.currentFilter === "Astralith" || root.currentFilter === "Downloaded")
            return entry.source === root.currentFilter && textMatch;
        return entry.bucket === root.currentFilter && textMatch;
    })

    function focusPrimary() {
        searchInput.forceActiveFocus();
        searchInput.cursorPosition = searchInput.text.length;
    }

    function runSearch() {
        if (!query.trim().length)
            return;
        currentFilter = "Online";
        Environment.searchOnline(query);
        searchInput.focus = false;
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 9

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 1
                Text { text: "PARALLAX ARCHIVE"; color: Theme.moon; font.family: Theme.fontDisplay; font.pixelSize: 21; font.weight: Font.Black; font.letterSpacing: 0.5 }
                Text {
                    text: Environment.localWallpapers.length + " LOCAL // "
                        + Environment.onlineWallpapers.length + " ONLINE // IMAGE + VIDEO"
                    color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 0.9
                }
            }
            Text {
                text: Environment.wallpaperStatus
                color: Environment.wallpaperBusy ? Theme.warning : Environment.canSetWallpaper ? Theme.success : Theme.danger
                font.family: Theme.fontMono; font.pixelSize: 9; font.weight: Font.Bold; font.letterSpacing: 0.8
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Rectangle {
                Layout.fillWidth: true; Layout.preferredHeight: 42
                radius: Theme.radiusMedium; color: Theme.mantle
                border.width: 1; border.color: searchInput.activeFocus ? Theme.accentLine : Theme.line
                TextInput {
                    id: searchInput
                    anchors.fill: parent; anchors.leftMargin: 14; anchors.rightMargin: 14
                    verticalAlignment: TextInput.AlignVCenter
                    text: root.query; color: Theme.moon; selectionColor: Theme.accent; selectedTextColor: Theme.void_
                    font.family: Theme.fontText; font.pixelSize: 11; clip: true
                    onTextChanged: root.query = text
                    Keys.onReturnPressed: root.runSearch()
                }
                Text { anchors.left: parent.left; anchors.leftMargin: 14; anchors.verticalCenter: parent.verticalCenter; visible: !searchInput.text.length; text: "Search local names or discover 1080p+ worlds online…"; color: Theme.lineBright; font.family: Theme.fontText; font.pixelSize: 10 }
            }
            Rectangle {
                Layout.preferredWidth: 126; Layout.preferredHeight: 42
                radius: Theme.radiusMedium; color: Environment.onlineBusy ? Theme.elevated : searchPointer.containsMouse ? Theme.accent : Theme.accentVeil
                border.width: 1; border.color: Theme.accentLine
                Text { anchors.centerIn: parent; text: Environment.onlineBusy ? "SEARCHING…" : "SEARCH ORBIT"; color: searchPointer.containsMouse && !Environment.onlineBusy ? Theme.void_ : Theme.accent; font.family: Theme.fontMono; font.pixelSize: 9; font.weight: Font.Bold }
                MouseArea { id: searchPointer; anchors.fill: parent; enabled: !Environment.onlineBusy; hoverEnabled: true; cursorShape: enabled ? Qt.PointingHandCursor : Qt.WaitCursor; onClicked: root.runSearch() }
            }
            Rectangle {
                Layout.preferredWidth: 42; Layout.preferredHeight: 42
                radius: Theme.radiusMedium; color: clearPointer.containsMouse ? Theme.elevated : Theme.mantle
                border.width: 1; border.color: Theme.line
                Text { anchors.centerIn: parent; text: "×"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 17 }
                MouseArea { id: clearPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.query = ""; Environment.clearOnline(); root.currentFilter = "All"; } }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Repeater {
                model: root.filters
                Rectangle {
                    id: filterButton
                    required property var modelData
                    readonly property bool active: root.currentFilter === modelData.value
                    Layout.preferredWidth: modelData.label.length ? Math.max(48, filterText.implicitWidth + 20) : 30
                    Layout.preferredHeight: 30
                    radius: 9
                    color: active ? Theme.accentVeil : filterPointer.containsMouse ? Theme.elevated : Theme.mantle
                    border.width: 1; border.color: active ? Theme.accentLine : Theme.line
                    Row { anchors.centerIn: parent; spacing: 6
                        Rectangle { visible: filterButton.modelData.color !== ""; width: 10; height: 10; radius: 5; color: filterButton.modelData.color; anchors.verticalCenter: parent.verticalCenter }
                        Text { id: filterText; visible: filterButton.modelData.label.length > 0; text: filterButton.modelData.label; color: filterButton.active ? Theme.accent : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
                    }
                    MouseArea { id: filterPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.currentFilter = filterButton.modelData.value }
                }
            }
            Item { Layout.fillWidth: true }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 6
            Text { text: "TARGET"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
            Rectangle {
                Layout.preferredWidth: 42; Layout.preferredHeight: 30; radius: 9
                readonly property bool active: Settings.wallpaperOutputs === "all"
                color: active ? Theme.accent : outputAllPointer.containsMouse ? Theme.elevated : Theme.mantle
                border.width: 1; border.color: active ? Theme.accent : Theme.line
                Text { anchors.centerIn: parent; text: "ALL"; color: parent.active ? Theme.void_ : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
                MouseArea { id: outputAllPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Environment.selectAllOutputs() }
            }
            Repeater {
                model: Environment.outputNames
                Rectangle {
                    id: outputButton
                    required property string modelData
                    readonly property bool active: Environment.outputsSelected(modelData)
                    Layout.preferredWidth: Math.max(48, outputLabel.implicitWidth + 16); Layout.preferredHeight: 30; radius: 9
                    color: active ? Theme.accentVeil : outputPointer.containsMouse ? Theme.elevated : Theme.mantle
                    border.width: 1; border.color: active ? Theme.accentLine : Theme.line
                    Text { id: outputLabel; anchors.centerIn: parent; text: outputButton.modelData; color: outputButton.active ? Theme.accent : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
                    MouseArea { id: outputPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: Environment.toggleOutput(outputButton.modelData) }
                }
            }
            Item { Layout.fillWidth: true }
            Text { text: "TRANSITION"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
            Repeater {
                model: ["any", "fade", "grow", "wave"]
                Rectangle {
                    id: transitionButton
                    required property string modelData
                    readonly property bool active: Settings.wallpaperTransition === modelData
                    Layout.preferredWidth: Math.max(48, transitionLabel.implicitWidth + 16)
                    Layout.preferredHeight: 30
                    radius: 9
                    color: active ? Theme.accentVeil : transitionPointer.containsMouse ? Theme.elevated : Theme.mantle
                    border.width: 1
                    border.color: active ? Theme.accentLine : Theme.line
                    Text {
                        id: transitionLabel
                        anchors.centerIn: parent
                        text: transitionButton.modelData.toUpperCase()
                        color: transitionButton.active ? Theme.accent : Theme.muted
                        font.family: Theme.fontMono
                        font.pixelSize: 8
                        font.weight: Font.Bold
                    }
                    MouseArea {
                        id: transitionPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Settings.wallpaperTransition = transitionButton.modelData
                    }
                }
            }
        }

        GridView {
            id: wallpaperGrid
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true
            readonly property int columns: Math.max(2, Math.min(5, Settings.wallpaperColumns))
            cellWidth: width / columns
            cellHeight: 180
            model: root.filteredWallpapers

            delegate: Rectangle {
                id: wallCard
                required property var modelData
                readonly property bool activeWallpaper: modelData.path.length > 0 && Environment.activeWallpaper === modelData.path
                width: wallpaperGrid.cellWidth - 9; height: wallpaperGrid.cellHeight - 9
                radius: Theme.radiusMedium; color: Theme.mantle; clip: true
                border.width: activeWallpaper ? 2 : 1
                border.color: activeWallpaper || wallPointer.containsMouse ? Theme.accentLine : Theme.line
                opacity: Environment.canSetWallpaper ? 1 : 0.55
                scale: wallPointer.containsMouse ? 0.985 : 1

                Image { anchors.fill: parent; source: "file://" + wallCard.modelData.preview; fillMode: Image.PreserveAspectCrop; asynchronous: true; cache: true }
                Rectangle {
                    anchors.fill: parent
                    gradient: Gradient {
                        GradientStop { position: 0; color: "transparent" }
                        GradientStop { position: 0.58; color: "transparent" }
                        GradientStop { position: 1; color: Qt.rgba(Theme.void_.r, Theme.void_.g, Theme.void_.b, 0.92) }
                    }
                }
                RowLayout {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.margins: 8
                    Rectangle {
                        width: kindLabel.implicitWidth + 14; height: 23; radius: 8
                        color: wallCard.modelData.kind === "video" ? Qt.rgba(Theme.rose.r, Theme.rose.g, Theme.rose.b, 0.88) : Qt.rgba(Theme.void_.r, Theme.void_.g, Theme.void_.b, 0.72)
                        Text { id: kindLabel; anchors.centerIn: parent; text: wallCard.modelData.kind === "video" ? "▶ VIDEO" : wallCard.modelData.source.toUpperCase(); color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
                    }
                    Item { Layout.fillWidth: true }
                    Rectangle { visible: wallCard.modelData.color.length > 0; width: 23; height: 23; radius: 8; color: wallCard.modelData.color; border.width: 1; border.color: Theme.moon }
                }
                Column {
                    anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; anchors.margins: 10
                    spacing: 2
                    Text { width: parent.width; text: wallCard.modelData.name; color: Theme.moon; font.family: Theme.fontText; font.pixelSize: 10; font.weight: Font.Bold; elide: Text.ElideMiddle }
                    Text {
                        width: parent.width
                        text: wallCard.modelData.source === "Online"
                            ? (wallCard.modelData.width || "?") + "×" + (wallCard.modelData.height || "?") + " // DOWNLOAD ON APPLY"
                            : wallCard.modelData.bucket.toUpperCase() + " // " + wallCard.modelData.source.toUpperCase()
                        color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; elide: Text.ElideRight
                    }
                }
                Rectangle {
                    visible: wallCard.activeWallpaper
                    anchors.top: parent.top; anchors.right: parent.right; anchors.margins: 8
                    width: activeText.implicitWidth + 14; height: 23; radius: 8; color: Theme.accent
                    Text { id: activeText; anchors.centerIn: parent; text: "ACTIVE"; color: Theme.void_; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
                }
                MouseArea { id: wallPointer; anchors.fill: parent; enabled: Environment.canSetWallpaper && !Environment.wallpaperBusy; hoverEnabled: true; cursorShape: enabled ? Qt.PointingHandCursor : Qt.WaitCursor; onClicked: Environment.setWallpaper(wallCard.modelData) }
                Behavior on scale { NumberAnimation { duration: Settings.motion ? Theme.motionFast : 0; easing.type: Easing.OutCubic } }
                Behavior on border.color { ColorAnimation { duration: Theme.motionFast } }
            }

            Column {
                anchors.centerIn: parent
                visible: wallpaperGrid.count === 0
                spacing: 8
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Environment.onlineBusy ? "⌁" : "✦"; color: Theme.accent; font.family: Theme.fontDisplay; font.pixelSize: 36 }
                Text { anchors.horizontalCenter: parent.horizontalCenter; text: Environment.onlineBusy ? "SEARCHING DEEP SPACE…" : Environment.onlineError.length ? Environment.onlineError : "NO WORLDS MATCH THIS FILTER"; color: Environment.onlineError.length ? Theme.warning : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 10; horizontalAlignment: Text.AlignHCenter }
            }
        }

        Rectangle {
            Layout.fillWidth: true; Layout.preferredHeight: 55
            radius: Theme.radiusMedium; color: Theme.mantle
            border.width: 1; border.color: Settings.adaptivePalette ? Theme.accentLine : Theme.line
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 10; spacing: 10
                Rectangle { width: 31; height: 31; radius: 10; color: Theme.accentVeil; border.width: 1; border.color: Theme.accentLine
                    Text { anchors.centerIn: parent; text: "󰏘"; color: Theme.accent; font.family: Theme.fontIcon; font.pixelSize: 16 }
                }
                ColumnLayout { Layout.fillWidth: true; spacing: 1
                    Text { text: "ADAPTIVE NEBULA // MATUGEN 4"; color: Theme.moon; font.family: Theme.fontDisplay; font.pixelSize: 11; font.weight: Font.Bold }
                    Text { text: AdaptivePalette.error.length ? AdaptivePalette.error : AdaptivePalette.status; color: AdaptivePalette.error.length ? Theme.warning : Settings.adaptivePalette && AdaptivePalette.ready ? Theme.success : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; elide: Text.ElideRight; Layout.fillWidth: true }
                }
                Row { spacing: 4
                    Repeater { model: [Theme.accent, Theme.cyan, Theme.rose, Theme.warning]
                        Rectangle { required property var modelData; width: 17; height: 17; radius: 6; color: modelData; border.width: 1; border.color: Theme.lineBright }
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 76; Layout.preferredHeight: 32; radius: 9
                    color: Settings.adaptivePalette ? Theme.accent : Theme.elevated; border.width: 1; border.color: Settings.adaptivePalette ? Theme.accent : Theme.line
                    Text { anchors.centerIn: parent; text: Settings.adaptivePalette ? "ENABLED" : "ENABLE"; color: Settings.adaptivePalette ? Theme.void_ : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold }
                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: Settings.adaptivePalette = !Settings.adaptivePalette }
                }
                Rectangle {
                    Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 9; color: refreshPointer.containsMouse ? Theme.accentVeil : Theme.elevated; border.width: 1; border.color: Theme.line
                    Text { anchors.centerIn: parent; text: "↻"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 15; font.weight: Font.Bold }
                    MouseArea { id: refreshPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: AdaptivePalette.refresh() }
                }
            }
        }
    }
}
