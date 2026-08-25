import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../.."
import "../../components"
import "../../services"

FocusScope {
    id: root

    property bool previewMode: false
    property var screenInfo: null
    property real intro: 0
    property real authEnergy: 0
    property real fluidPhase: 0
    property bool revealPassword: false
    property string pendingPowerAction: ""
    readonly property real sf: Math.max(0.72, Math.min(1.35,
        Math.min(width / 1920, height / 1080)))
    readonly property string screenName: screenInfo && screenInfo.name
        ? screenInfo.name : "WAYLAND OUTPUT"
    readonly property string wallpaperPath: Settings.umbraUseWallpaper
        && Settings.wallpaperKind === "image" ? Settings.wallpaperPath : ""
    readonly property url wallpaperSource: wallpaperPath.length > 0
        ? (wallpaperPath.indexOf("file:") === 0 ? wallpaperPath : "file://" + wallpaperPath)
        : Qt.resolvedUrl("../../assets/wallpapers/umbra-array.png")
    readonly property real stateEnergy: Umbra.authenticating ? 1
        : Umbra.failed ? 0.72 : root.authEnergy * 0.42

    signal dismissPreview()

    function focusInput() {
        passwordInput.forceActiveFocus();
    }

    function submitInput() {
        Umbra.submit();
        if (previewMode)
            previewReset.restart();
    }

    Component.onCompleted: {
        introDelay.restart();
        focusDelay.restart();
    }

    Connections {
        target: Umbra
        function onEventSerialChanged() {
            root.authEnergy = 1;
            energyDecay.restart();
            if (Umbra.failed)
                failureShake.restart();
            focusDelay.restart();
        }
        function onPasswordChanged() {
            if (passwordInput.text !== Umbra.password)
                passwordInput.text = Umbra.password;
        }
    }

    Timer {
        id: introDelay
        interval: 30
        onTriggered: introAnimation.restart()
    }
    Timer {
        id: focusDelay
        interval: 90
        onTriggered: root.focusInput()
    }
    Timer {
        id: previewReset
        interval: 1200
        onTriggered: Umbra.clearInput()
    }

    NumberAnimation {
        id: introAnimation
        target: root
        property: "intro"
        to: 1
        duration: Settings.motion && Settings.umbraMotion ? 720 : 0
        easing.type: Easing.OutExpo
    }
    NumberAnimation {
        id: energyDecay
        target: root
        property: "authEnergy"
        to: 0
        duration: Settings.motion && Settings.umbraMotion ? 1100 : 0
        easing.type: Easing.OutCubic
    }
    NumberAnimation on fluidPhase {
        from: 0
        to: 1
        duration: 9200
        loops: Animation.Infinite
        running: Settings.motion && Settings.umbraMotion && root.visible
    }

    Image {
        id: wallpaper
        anchors.fill: parent
        source: root.wallpaperSource
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
        cache: true
        visible: true
    }

    MultiEffect {
        anchors.fill: parent
        source: wallpaper
        visible: Settings.umbraBlurWallpaper
        blurEnabled: true
        blur: 0.62
        blurMax: 54
        saturation: -0.12
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.void_
        opacity: Settings.umbraBlurWallpaper ? 0.55 : 0.68
    }

    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0; color: Qt.rgba(Theme.void_.r, Theme.void_.g, Theme.void_.b, 0.16) }
            GradientStop { position: 0.53; color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.52) }
            GradientStop { position: 1; color: Qt.rgba(Theme.void_.r, Theme.void_.g, Theme.void_.b, 0.88) }
        }
    }

    UmbraField {
        anchors.fill: parent
        energy: root.stateEnergy
        opacity: root.intro
        scale: 1.08 - root.intro * 0.08
        Behavior on opacity { NumberAnimation { duration: 400 } }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: root.focusInput()
    }

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 28 * root.sf
        opacity: root.intro
        transform: Translate { y: (1 - root.intro) * -18 * root.sf }

        ColumnLayout {
            spacing: 1
            Text {
                text: "ASTRALITH  //  UMBRA"
                color: Theme.moon
                font.family: Theme.fontDisplay
                font.pixelSize: 14 * root.sf
                font.weight: Font.DemiBold
                font.letterSpacing: 1.8 * root.sf
            }
            Text {
                text: root.previewMode ? "SESSION VEIL SIMULATION" : "SECURE WAYLAND SESSION VEIL"
                color: Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: 8 * root.sf
                font.letterSpacing: 1.3 * root.sf
            }
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            Layout.preferredWidth: secureRow.implicitWidth + 24 * root.sf
            Layout.preferredHeight: 38 * root.sf
            radius: height / 2
            color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.68)
            border.width: 1
            border.color: root.previewMode ? Theme.warning
                : Umbra.secure ? Theme.success : Theme.accentLine
            RowLayout {
                id: secureRow
                anchors.centerIn: parent
                spacing: 8 * root.sf
                Rectangle {
                    Layout.preferredWidth: 7 * root.sf
                    Layout.preferredHeight: 7 * root.sf
                    radius: width / 2
                    color: root.previewMode ? Theme.warning
                        : Umbra.secure ? Theme.success : Theme.accent
                    SequentialAnimation on opacity {
                        loops: Animation.Infinite
                        running: Settings.motion && Settings.umbraMotion
                        NumberAnimation { to: 0.35; duration: 900 }
                        NumberAnimation { to: 1; duration: 900 }
                    }
                }
                Text {
                    text: Umbra.stateCode + "  //  " + root.screenName.toUpperCase()
                    color: Theme.moon
                    font.family: Theme.fontMono
                    font.pixelSize: 8 * root.sf
                    font.letterSpacing: 0.9 * root.sf
                }
            }
        }
    }

    ColumnLayout {
        id: centerStack
        anchors.centerIn: parent
        width: Math.min(parent.width - 48 * root.sf, 660 * root.sf)
        spacing: 16 * root.sf
        opacity: root.intro
        scale: 0.88 + root.intro * 0.12
        transform: Translate {
            y: (1 - root.intro) * 46 * root.sf
                + Math.sin(root.fluidPhase * Math.PI * 2) * 2.4 * root.sf
                * (Umbra.authenticating ? 0.14 : Umbra.failed ? 0.36 : 1)
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: -2 * root.sf
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: Qt.formatDateTime(clock.date, "HH:mm")
                color: Theme.moon
                font.family: Theme.fontDisplay
                font.pixelSize: 88 * root.sf
                font.weight: Font.Medium
                font.letterSpacing: 3 * root.sf
            }
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 12 * root.sf
                Text {
                    text: Qt.formatDateTime(clock.date, "dddd, MMMM dd")
                    color: Theme.muted
                    font.family: Theme.fontText
                    font.pixelSize: 12 * root.sf
                    font.letterSpacing: 0.5 * root.sf
                }
                Rectangle {
                    visible: Settings.umbraShowWeather && Weather.available
                    Layout.preferredWidth: 3 * root.sf
                    Layout.preferredHeight: 3 * root.sf
                    radius: width / 2
                    color: Theme.accent
                }
                Text {
                    visible: Settings.umbraShowWeather && Weather.available
                    text: Math.round(Number(Weather.current.temp || 0)) + Weather.unitSymbol
                        + "  " + String(Weather.current.condition || "SKY ACQUIRING").toUpperCase()
                    color: Theme.cyan
                    font.family: Theme.fontMono
                    font.pixelSize: 10 * root.sf
                }
            }
        }

        Item { Layout.preferredHeight: 4 * root.sf }

        Rectangle {
            id: authDeck
            Layout.fillWidth: true
            Layout.preferredHeight: 152 * root.sf
            radius: 0
            color: "transparent"
            border.width: 0
            clip: true
            scale: 1 + root.stateEnergy * 0.006
            transform: Translate { id: failureOffset; x: 0 }

            Behavior on scale {
                NumberAnimation {
                    duration: Settings.motion && Settings.umbraMotion ? 280 : 0
                    easing.type: Easing.OutCubic
                }
            }

            EccentricPlate {
                anchors.fill: parent
                fillColor: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.78)
                lineColor: Umbra.failed
                    ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.72)
                    : passwordInput.activeFocus ? Theme.accentLine : Theme.barHairlineHover
                tone: Umbra.failed ? Theme.danger : Theme.accent
                cut: (24 + (Umbra.authenticating ? 4 : 0)) * root.sf
                energy: root.stateEnergy
            }

            Rectangle {
                width: 220 * root.sf
                height: width
                radius: width / 2
                x: -70 * root.sf
                y: -112 * root.sf
                color: Umbra.failed ? Theme.danger : Theme.accent
                opacity: 0.08 + root.authEnergy * 0.05
                scale: 1 + root.authEnergy * 0.16
                Behavior on color { ColorAnimation { duration: 240 } }
                Behavior on scale { NumberAnimation { duration: 420; easing.type: Easing.OutCubic } }
            }

            ColumnLayout {
                anchors.fill: parent
                anchors.leftMargin: 22 * root.sf
                anchors.rightMargin: 22 * root.sf
                anchors.topMargin: 17 * root.sf
                anchors.bottomMargin: 14 * root.sf
                spacing: 8 * root.sf

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12 * root.sf
                    Rectangle {
                        Layout.preferredWidth: 42 * root.sf
                        Layout.preferredHeight: 42 * root.sf
                        radius: 14 * root.sf
                        color: Theme.accentVeil
                        border.width: 1
                        border.color: Theme.accentLine
                        Text {
                            anchors.centerIn: parent
                            text: "◉"
                            color: Theme.accent
                            font.family: Theme.fontDisplay
                            font.pixelSize: 19 * root.sf
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 1
                        Text {
                            text: Umbra.userName.toUpperCase()
                            color: Theme.moon
                            font.family: Theme.fontDisplay
                            font.pixelSize: 13 * root.sf
                            font.weight: Font.DemiBold
                            font.letterSpacing: 1 * root.sf
                        }
                        Text {
                            text: Umbra.statusText
                            color: Umbra.failed ? Theme.danger
                                : Umbra.authenticating ? Theme.cyan : Theme.muted
                            font.family: Theme.fontMono
                            font.pixelSize: 8 * root.sf
                            font.letterSpacing: 0.9 * root.sf
                        }
                    }
                    Text {
                        text: root.previewMode ? "ESC" : Umbra.authenticating ? "…" : "↵"
                        color: Theme.accent
                        font.family: Theme.fontMono
                        font.pixelSize: 12 * root.sf
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45 * root.sf
                    radius: 0
                    color: "transparent"
                    border.width: 0
                    clip: true

                    EccentricPlate {
                        anchors.fill: parent
                        fillColor: Qt.rgba(Theme.void_.r, Theme.void_.g, Theme.void_.b, 0.64)
                        lineColor: passwordInput.activeFocus ? Theme.accentLine : Theme.line
                        tone: Theme.cyan
                        cut: 11 * root.sf
                        energy: Umbra.authenticating ? 1
                            : passwordInput.activeFocus ? 0.16 : 0
                    }

                    Rectangle {
                        id: authenticationSweep
                        visible: Umbra.authenticating
                        width: parent.width * 0.30
                        height: parent.height
                        x: -width
                        opacity: 0.20
                        gradient: Gradient {
                            orientation: Gradient.Horizontal
                            GradientStop { position: 0; color: "transparent" }
                            GradientStop { position: 0.52; color: Theme.cyan }
                            GradientStop { position: 1; color: "transparent" }
                        }
                        NumberAnimation on x {
                            from: -authenticationSweep.width
                            to: authenticationSweep.parent
                                ? authenticationSweep.parent.width : 0
                            duration: Settings.motion && Settings.umbraMotion ? 940 : 0
                            easing.type: Easing.InOutSine
                            loops: Animation.Infinite
                            running: authenticationSweep.visible
                        }
                    }

                    TextInput {
                        id: passwordInput
                        anchors.fill: parent
                        anchors.leftMargin: 18 * root.sf
                        anchors.rightMargin: 52 * root.sf
                        verticalAlignment: TextInput.AlignVCenter
                        color: Theme.moon
                        selectionColor: Theme.accent
                        selectedTextColor: Theme.void_
                        font.family: Theme.fontMono
                        font.pixelSize: 14 * root.sf
                        font.letterSpacing: root.revealPassword ? 0.5 * root.sf : 3 * root.sf
                        echoMode: root.revealPassword ? TextInput.Normal : TextInput.Password
                        passwordCharacter: "●"
                        enabled: !Umbra.authenticating
                        inputMethodHints: Qt.ImhSensitiveData | Qt.ImhNoPredictiveText
                        text: Umbra.password
                        onTextEdited: {
                            Umbra.password = text;
                            Umbra.failed = false;
                        }
                        onAccepted: root.submitInput()
                        Keys.onEscapePressed: function(event) {
                            event.accepted = true;
                            if (root.previewMode)
                                root.dismissPreview();
                            else
                                Umbra.clearInput();
                        }
                        Keys.onPressed: function(event) {
                            if (event.modifiers & Qt.ControlModifier && event.key === Qt.Key_U) {
                                Umbra.clearInput();
                                event.accepted = true;
                            }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        visible: passwordInput.text.length === 0
                        text: root.previewMode ? "PREVIEW INPUT  //  ENTER SUBMITS"
                            : "ENTER SESSION PASSPHRASE"
                        color: Theme.muted
                        font.family: Theme.fontMono
                        font.pixelSize: 8 * root.sf
                        font.letterSpacing: 1 * root.sf
                    }

                    Rectangle {
                        anchors.right: parent.right
                        anchors.rightMargin: 6 * root.sf
                        anchors.verticalCenter: parent.verticalCenter
                        width: 34 * root.sf
                        height: 34 * root.sf
                        radius: width / 2
                        color: revealPointer.containsMouse ? Theme.accentVeil : "transparent"
                        Text {
                            anchors.centerIn: parent
                            text: root.revealPassword ? "◌" : "◉"
                            color: root.revealPassword ? Theme.cyan : Theme.muted
                            font.family: Theme.fontMono
                            font.pixelSize: 11 * root.sf
                        }
                        MouseArea {
                            id: revealPointer
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.revealPassword = !root.revealPassword;
                                root.focusInput();
                            }
                        }
                    }

                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.previewMode ? "PREVIEW DOES NOT LOCK OR AUTHENTICATE"
                : "ENTER TO AUTHENTICATE  //  CTRL+U TO CLEAR"
            color: root.previewMode ? Theme.warning : Theme.muted
            font.family: Theme.fontMono
            font.pixelSize: 8 * root.sf
            font.letterSpacing: 1.2 * root.sf
        }
    }

    Rectangle {
        id: mediaDeck
        visible: Settings.umbraShowMedia && Media.available
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.margins: 28 * root.sf
        width: Math.min(460 * root.sf, parent.width * 0.32)
        height: 72 * root.sf
        radius: 22 * root.sf
        color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.68)
        border.width: 1
        border.color: Theme.barHairlineHover
        opacity: root.intro
        transform: Translate { x: (1 - root.intro) * -28 * root.sf }

        RowLayout {
            anchors.fill: parent
            anchors.margins: 8 * root.sf
            spacing: 10 * root.sf
            Rectangle {
                Layout.preferredWidth: 54 * root.sf
                Layout.preferredHeight: 54 * root.sf
                radius: 16 * root.sf
                color: Theme.elevated
                clip: true
                Image {
                    anchors.fill: parent
                    source: Media.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
                Text {
                    anchors.centerIn: parent
                    visible: Media.artUrl.length === 0
                    text: "♪"
                    color: Theme.rose
                    font.family: Theme.fontDisplay
                    font.pixelSize: 21 * root.sf
                }
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                Text {
                    Layout.fillWidth: true
                    text: Media.title
                    color: Theme.moon
                    font.family: Theme.fontDisplay
                    font.pixelSize: 11 * root.sf
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    text: Media.artist + "  //  " + Media.statusText
                    color: Theme.muted
                    font.family: Theme.fontMono
                    font.pixelSize: 8 * root.sf
                    elide: Text.ElideRight
                }
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 2 * root.sf
                    radius: height / 2
                    color: Theme.line
                    Rectangle {
                        width: parent.width * Media.progress
                        height: parent.height
                        radius: parent.radius
                        color: Theme.rose
                        Behavior on width { NumberAnimation { duration: 700; easing.type: Easing.Linear } }
                    }
                }
            }
            Text {
                text: "‹"
                color: Theme.muted
                font.pixelSize: 20 * root.sf
                MouseArea { anchors.fill: parent; anchors.margins: -10; onClicked: Media.previous() }
            }
            Text {
                text: Media.playing ? "Ⅱ" : "▶"
                color: Theme.moon
                font.family: Theme.fontMono
                font.pixelSize: 13 * root.sf
                MouseArea { anchors.fill: parent; anchors.margins: -10; onClicked: Media.toggle() }
            }
            Text {
                text: "›"
                color: Theme.muted
                font.pixelSize: 20 * root.sf
                MouseArea { anchors.fill: parent; anchors.margins: -10; onClicked: Media.next() }
            }
        }
    }

    RowLayout {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 28 * root.sf
        spacing: 8 * root.sf
        opacity: root.intro
        transform: Translate { x: (1 - root.intro) * 28 * root.sf }

        Rectangle {
            visible: DeviceState.batteryAvailable
            Layout.preferredWidth: batteryText.implicitWidth + 22 * root.sf
            Layout.preferredHeight: 34 * root.sf
            radius: height / 2
            color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.66)
            border.width: 1
            border.color: Theme.barHairlineHover
            Text {
                id: batteryText
                anchors.centerIn: parent
                text: (DeviceState.batteryCharging ? "↯ " : "") + DeviceState.batteryPercent + "%"
                color: DeviceState.batteryLow ? Theme.danger : Theme.moon
                font.family: Theme.fontMono
                font.pixelSize: 8 * root.sf
            }
        }

        Rectangle {
            Layout.preferredWidth: networkText.implicitWidth + 22 * root.sf
            Layout.preferredHeight: 34 * root.sf
            radius: height / 2
            color: Qt.rgba(Theme.mantle.r, Theme.mantle.g, Theme.mantle.b, 0.66)
            border.width: 1
            border.color: Theme.barHairlineHover
            Text {
                id: networkText
                anchors.centerIn: parent
                text: (NetState.connected ? "● " + NetState.label : "○ OFFLINE")
                color: NetState.connected ? Theme.success : Theme.muted
                font.family: Theme.fontMono
                font.pixelSize: 8 * root.sf
            }
        }
    }

    SequentialAnimation {
        id: failureShake
        NumberAnimation { target: failureOffset; property: "x"; to: -10 * root.sf; duration: 45 }
        NumberAnimation { target: failureOffset; property: "x"; to: 9 * root.sf; duration: 70 }
        NumberAnimation { target: failureOffset; property: "x"; to: -6 * root.sf; duration: 65 }
        NumberAnimation { target: failureOffset; property: "x"; to: 4 * root.sf; duration: 60 }
        NumberAnimation { target: failureOffset; property: "x"; to: 0; duration: 90; easing.type: Easing.OutCubic }
    }

    SystemClock {
        id: clock
        precision: SystemClock.Seconds
    }
}
