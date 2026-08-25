import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import "../.."
import "../../services"
import "../../components"
import "widgets"
import "../quickactions"
import "EphemerisRegistry.js" as Registry

PanelWindow {
    id: root

    required property var modelData
    screen: modelData
    readonly property string outputName: modelData.name
    readonly property bool targetScreen: Niri.focusedOutput.length > 0
        ? Niri.focusedOutput === outputName
        : Quickshell.screens.length > 0 && modelData === Quickshell.screens[0]
    readonly property int topClearance: (Settings.compact ? 38 : Theme.barHeight)
        + (Settings.barMode === "docked" ? 10 : Settings.barMargin * 2 + 8)
    readonly property var widgetLayout: Registry.getLayout(
        ShellState.ephemerisTab, width, height, topClearance)
    readonly property color moduleTone: Theme.moduleAccent(ShellState.ephemerisTab)

    property bool surfaceVisible: false
    property real presentation: 0
    property real deckScale: 0.94
    property real widgetPresentation: 1

    visible: surfaceVisible && targetScreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    focusable: true
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    WlrLayershell.namespace: "astralith-ephemeris-host"
    anchors { top: true; right: true; bottom: true; left: true }

    function close() {
        ShellState.closeEphemeris();
    }

    function focusWidget() {
        if (widgetLoader.item && widgetLoader.item.focusPrimary)
            widgetLoader.item.focusPrimary();
        else
            keyCatcher.forceActiveFocus();
    }

    function beginOpen() {
        closeAnimation.stop();
        surfaceVisible = true;
        presentation = 0;
        deckScale = 0.92;
        widgetPresentation = 0;
        openDelay.restart();
    }

    function beginClose() {
        openDelay.stop();
        openAnimation.stop();
        closeAnimation.restart();
    }

    Connections {
        target: ShellState
        function onEphemerisVisibleChanged() {
            if (ShellState.ephemerisVisible && root.targetScreen)
                root.beginOpen();
            else if (root.surfaceVisible)
                root.beginClose();
        }
        function onEphemerisTabChanged() {
            if (!root.surfaceVisible)
                return;
            root.widgetPresentation = 0;
            widgetSwitch.restart();
        }
    }

    onTargetScreenChanged: {
        if (targetScreen && ShellState.ephemerisVisible)
            beginOpen();
        else if (!targetScreen && surfaceVisible)
            surfaceVisible = false;
    }

    Timer {
        id: openDelay
        interval: 24
        onTriggered: openAnimation.restart()
    }

    ParallelAnimation {
        id: openAnimation
        NumberAnimation { target: root; property: "presentation"; to: 1; duration: Settings.motion ? 260 : 0; easing.type: Easing.OutQuint }
        NumberAnimation { target: root; property: "deckScale"; to: 1; duration: Settings.motion ? 430 : 0; easing.type: Easing.OutBack }
        SequentialAnimation {
            PauseAnimation { duration: Settings.motion ? 90 : 0 }
            NumberAnimation { target: root; property: "widgetPresentation"; to: 1; duration: Settings.motion ? 250 : 0; easing.type: Easing.OutCubic }
            ScriptAction { script: root.focusWidget() }
        }
    }

    SequentialAnimation {
        id: closeAnimation
        ParallelAnimation {
            NumberAnimation { target: root; property: "widgetPresentation"; to: 0; duration: Settings.motion ? 100 : 0; easing.type: Easing.InCubic }
            NumberAnimation { target: root; property: "presentation"; to: 0; duration: Settings.motion ? 180 : 0; easing.type: Easing.InQuint }
            NumberAnimation { target: root; property: "deckScale"; to: 0.96; duration: Settings.motion ? 180 : 0; easing.type: Easing.InCubic }
        }
        ScriptAction { script: root.surfaceVisible = false }
    }

    SequentialAnimation {
        id: widgetSwitch
        PauseAnimation { duration: Settings.motion ? 55 : 0 }
        NumberAnimation { target: root; property: "widgetPresentation"; to: 1; duration: Settings.motion ? 220 : 0; easing.type: Easing.OutCubic }
        ScriptAction { script: root.focusWidget() }
    }

    Rectangle {
        id: veil
        anchors.fill: parent
        color: Theme.veil
        opacity: root.presentation

        MouseArea {
            anchors.fill: parent
            onClicked: root.close()
        }

        Rectangle {
            id: deck
            x: root.widgetLayout.x
            y: root.widgetLayout.y
            width: root.widgetLayout.width
            height: root.widgetLayout.height
            radius: 0
            color: "transparent"
            border.width: 0
            opacity: root.presentation
            scale: root.deckScale
            transformOrigin: Item.Center
            // The veil is deliberately inert. Every decorative signal belongs
            // to the popup and is clipped at this boundary.
            clip: true

            Behavior on x { NumberAnimation { duration: Settings.motion ? 270 : 0; easing.type: Easing.OutCubic } }
            Behavior on y { NumberAnimation { duration: Settings.motion ? 270 : 0; easing.type: Easing.OutCubic } }
            Behavior on width { NumberAnimation { duration: Settings.motion ? 300 : 0; easing.type: Easing.OutCubic } }
            Behavior on height { NumberAnimation { duration: Settings.motion ? 300 : 0; easing.type: Easing.OutCubic } }

            MouseArea { anchors.fill: parent }

            EccentricPlate {
                anchors.fill: parent
                fillColor: Theme.glass
                lineColor: Theme.barHairlineHover
                tone: root.moduleTone
                cut: Settings.atmosphereStyle === "cinematic" ? 28 : 20
                energy: root.widgetPresentation
            }

            EphemerisAtmosphere {
                anchors.fill: parent
                anchors.topMargin: 54
                module: ShellState.ephemerisTab
                presentation: root.widgetPresentation
            }

            InstrumentFrame {
                anchors.fill: parent
                anchors.topMargin: 54
                anchors.margins: 7
                module: ShellState.ephemerisTab
                presentation: root.widgetPresentation
            }

            // The original field lived underneath an almost opaque deck, so
            // toggling it made no visible difference. This local constellation
            // is deliberately rendered inside the glass surface.
            Repeater {
                model: Settings.animateStars ? 38 : 0
                Rectangle {
                    required property int index
                    x: (index * 179 + 31) % Math.max(1, deck.width)
                    y: 60 + ((index * 97 + 19) % Math.max(1, deck.height - 64))
                    width: index % 8 === 0 ? 2 : 1
                    height: width
                    radius: width
                    color: index % 4 === 0 ? Theme.accent : index % 7 === 0 ? Theme.cyan : Theme.moon
                    opacity: 0.08 + (index % 4) * 0.035
                    transform: Translate {
                        SequentialAnimation on x {
                            loops: Animation.Infinite
                            running: Settings.motion && Settings.animateStars && root.visible
                            NumberAnimation { from: -4; to: 8; duration: 3900 + index * 41; easing.type: Easing.InOutSine }
                            NumberAnimation { from: 8; to: -4; duration: 4300 + index * 37; easing.type: Easing.InOutSine }
                        }
                        SequentialAnimation on y {
                            loops: Animation.Infinite
                            running: Settings.motion && Settings.animateStars && root.visible
                            NumberAnimation { from: 3; to: -8; duration: 4100 + index * 33; easing.type: Easing.InOutSine }
                            NumberAnimation { from: -8; to: 3; duration: 3700 + index * 39; easing.type: Easing.InOutSine }
                        }
                    }
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: 6
                anchors.rightMargin: 6
                height: 54
                color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.54)

                Rectangle {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    height: 1
                    color: Theme.barHairlineHover
                }

                Row {
                    anchors.left: parent.left
                    anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 11

                    Rectangle {
                        width: 36
                        height: 36
                        radius: 12
                        color: Qt.rgba(root.moduleTone.r, root.moduleTone.g, root.moduleTone.b, 0.11)
                        border.width: 1
                        border.color: Qt.rgba(root.moduleTone.r, root.moduleTone.g, root.moduleTone.b, 0.36)

                        Rectangle {
                            anchors.centerIn: parent
                            width: 31
                            height: 14
                            radius: 8
                            rotation: -24
                            color: "transparent"
                            border.width: 1
                            border.color: Qt.rgba(root.moduleTone.r, root.moduleTone.g, root.moduleTone.b, 0.48)
                            NumberAnimation on rotation {
                                from: -24; to: 336; duration: 18000; loops: Animation.Infinite
                                running: Settings.motion && root.visible
                            }
                        }
                        IconImage {
                            anchors.centerIn: parent
                            implicitSize: 17
                            source: Qt.resolvedUrl("../../assets/icons/" + root.widgetLayout.icon)
                        }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: -1
                        Text {
                            text: "ASTRALITH  //  " + root.widgetLayout.code
                            color: root.moduleTone
                            font.family: Theme.fontMono
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            font.letterSpacing: 1.1
                        }
                        Text {
                            text: root.widgetLayout.title
                            color: Theme.moon
                            font.family: Theme.fontDisplay
                            font.pixelSize: 13
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Row {
                    visible: deck.width >= 690
                    anchors.right: parent.right
                    anchors.rightMargin: 52
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 10

                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        width: 1; height: 24
                        color: Theme.barHairlineHover
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0
                        Text {
                            text: "NIRI LINK  //  NOMINAL"
                            color: Theme.success
                            font.family: Theme.fontMono
                            font.pixelSize: 8
                            font.weight: Font.Bold
                            font.letterSpacing: 0.7
                        }
                        Text {
                            text: root.outputName.toUpperCase()
                            color: Theme.muted
                            font.family: Theme.fontMono
                            font.pixelSize: 8
                            font.letterSpacing: 0.8
                        }
                    }
                }

                Rectangle {
                    anchors.right: parent.right
                    anchors.rightMargin: 10
                    anchors.verticalCenter: parent.verticalCenter
                    width: 32
                    height: 32
                    radius: 10
                    color: closePointer.containsMouse ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.14) : "transparent"
                    border.width: 1
                    border.color: closePointer.containsMouse ? Theme.danger : "transparent"
                    Text { anchors.centerIn: parent; text: "×"; color: closePointer.containsMouse ? Theme.danger : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 15 }
                    MouseArea { id: closePointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.close() }
                }
            }

            Item {
                id: keyCatcher
                anchors.fill: parent
                anchors.topMargin: 54
                focus: true
                Keys.onPressed: function(event) {
                    if (event.key === Qt.Key_Escape) {
                        root.close();
                        event.accepted = true;
                    }
                }

                Loader {
                    id: widgetLoader
                    anchors.fill: parent
                    anchors.margins: 18
                    opacity: root.widgetPresentation
                    transform: Translate { y: (1 - root.widgetPresentation) * 14 }
                    sourceComponent: ShellState.ephemerisTab === "tools" ? toolsComponent
                        : ShellState.ephemerisTab === "walls" ? wallpaperComponent
                        : ShellState.ephemerisTab === "clipboard" ? clipboardComponent
                        : ShellState.ephemerisTab === "notifications" ? notificationsComponent
                        : ShellState.ephemerisTab === "settings" ? settingsComponent
                        : ShellState.ephemerisTab === "calendar" ? calendarComponent
                        : ShellState.ephemerisTab === "capture" ? captureComponent
                        : ShellState.ephemerisTab === "media" ? mediaComponent
                        : ShellState.ephemerisTab === "network" ? networkComponent
                        : ShellState.ephemerisTab === "audio" ? audioComponent
                        : ShellState.ephemerisTab === "workspaces" ? workspacesComponent
                        : ShellState.ephemerisTab === "battery" ? batteryComponent
                        : ShellState.ephemerisTab === "focus" ? focusComponent
                        : ShellState.ephemerisTab === "system" ? systemComponent
                        : ShellState.ephemerisTab === "guide" ? guideComponent
                        : ShellState.ephemerisTab === "timer" ? timerComponent
                        : ShellState.ephemerisTab === "quickstats" ? quickStatsComponent
                        : launcherComponent
                    onLoaded: Qt.callLater(root.focusWidget)
                }
            }

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                anchors.leftMargin: Settings.atmosphereStyle === "cinematic" ? 34 : 26
                anchors.rightMargin: Settings.atmosphereStyle === "cinematic" ? 24 : 18
                height: 2
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: "transparent" }
                    GradientStop { position: 0.5; color: root.moduleTone }
                    GradientStop { position: 1; color: "transparent" }
                }
            }
        }
    }

    Component { id: launcherComponent; LauncherWidget {} }
    Component { id: toolsComponent; ToolsWidget {} }
    Component { id: wallpaperComponent; WallpaperWidget {} }
    Component { id: clipboardComponent; ClipboardWidget {} }
    Component { id: notificationsComponent; NotificationsWidget {} }
    Component { id: settingsComponent; SettingsWidget {} }
    Component { id: calendarComponent; CalendarWidget {} }
    Component { id: captureComponent; CaptureWidget {} }
    Component { id: mediaComponent; MediaWidget {} }
    Component { id: networkComponent; NetworkWidget {} }
    Component { id: audioComponent; AudioWidget {} }
    Component { id: workspacesComponent; WorkspaceWidget {} }
    Component { id: batteryComponent; BatteryWidget {} }
    // Dedicated behavioral widgets remain independently loadable and morph in place.
    Component { id: focusComponent; FocusWidget {} }
    // Observatory telemetry and the full mixer share the same morphing host.
    Component { id: systemComponent; SystemWidget {} }
    Component { id: guideComponent; GuideWidget {} }
    Component { id: timerComponent; TimerAction {} }
    Component { id: quickStatsComponent; TelemetryAction {} }
}
