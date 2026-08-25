import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../../.."
import "../../../../services"

Item {
    id: root

    property string activeTab: "wifi"
    property string pendingSsid: ""
    property string wifiPassword: ""

    function submitPassword() {
        if (pendingSsid.length === 0)
            return;
        NetState.connectWifi(pendingSsid, wifiPassword);
        pendingSsid = "";
        wifiPassword = "";
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 10

        RowLayout {
            Layout.fillWidth: true
            ColumnLayout {
                Layout.fillWidth: true; spacing: 2
                Text { text: "LINK ARRAY"; color: Theme.moon; font.family: Theme.fontDisplay; font.pixelSize: 20; font.weight: Font.DemiBold }
                Text {
                    text: NetState.connected ? NetState.kind + " // " + NetState.label : "NO ACTIVE UPLINK"
                    color: NetState.connected ? Theme.success : Theme.warning
                    font.family: Theme.fontMono; font.pixelSize: 8; font.letterSpacing: 1
                }
            }

            Rectangle {
                implicitWidth: 104; implicitHeight: 34; radius: 11
                color: scanPointer.containsMouse ? Theme.accentVeil : Theme.mantle
                border.width: 1; border.color: scanPointer.containsMouse ? Theme.accentLine : Theme.line
                Text {
                    anchors.centerIn: parent
                    text: NetState.loading ? "SCANNING…" : "REFRESH ARRAY"
                    color: NetState.loading ? Theme.warning : Theme.accent
                    font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold
                }
                MouseArea {
                    id: scanPointer
                    anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                    enabled: !NetState.loading
                    onClicked: {
                        if (root.activeTab === "bluetooth")
                            NetState.scanBluetooth();
                        else if (root.activeTab === "wifi")
                            NetState.scanWifi();
                        else
                            NetState.refresh();
                    }
                }
            }

            Rectangle {
                implicitWidth: radioLabel.implicitWidth + 32; implicitHeight: 34; radius: 11
                readonly property bool radioOn: root.activeTab === "bluetooth"
                    ? DeviceState.bluetoothEnabled : root.activeTab === "wifi" ? NetState.wifiEnabled : NetState.connected
                color: radioOn ? Theme.accentVeil : Theme.mantle
                border.width: 1; border.color: radioOn ? Theme.accentLine : Theme.line
                RowLayout {
                    anchors.centerIn: parent; spacing: 7
                    Rectangle { Layout.preferredWidth: 7; Layout.preferredHeight: 7; radius: 4; color: parent.parent.radioOn ? Theme.success : Theme.danger }
                    Text {
                        id: radioLabel
                        text: root.activeTab === "bluetooth" ? "BLUETOOTH"
                            : root.activeTab === "wifi" ? "WIFI RADIO" : "ETHERNET"
                        color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold
                    }
                }
                MouseArea {
                    anchors.fill: parent; cursorShape: Qt.PointingHandCursor
                    enabled: root.activeTab !== "ethernet"
                    onClicked: {
                        if (root.activeTab === "bluetooth")
                            NetState.toggleBluetooth();
                        else
                            NetState.toggleWifi();
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 7
            Repeater {
                model: [
                    { "id": "wifi", "label": "WI-FI", "count": NetState.wifiNetworks.length },
                    { "id": "bluetooth", "label": "BLUETOOTH", "count": NetState.bluetoothDevices.length },
                    { "id": "ethernet", "label": "ETHERNET", "count": NetState.ethernetDevices.length }
                ]
                Rectangle {
                    required property var modelData
                    Layout.fillWidth: true; Layout.preferredHeight: 38; radius: 12
                    readonly property bool selected: root.activeTab === modelData.id
                    color: selected ? Theme.accentVeil : tabPointer.containsMouse ? Theme.elevated : Theme.mantle
                    border.width: 1; border.color: selected ? Theme.accentLine : Theme.line
                    RowLayout {
                        anchors.centerIn: parent; spacing: 8
                        Text { text: modelData.label; color: parent.parent.selected ? Theme.accent : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold; font.letterSpacing: 0.7 }
                        Rectangle { implicitWidth: 21; implicitHeight: 19; radius: 7; color: Theme.elevated; Text { anchors.centerIn: parent; text: modelData.count; color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 7 } }
                    }
                    MouseArea {
                        id: tabPointer
                        anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.activeTab = modelData.id;
                            root.pendingSsid = "";
                            root.wifiPassword = "";
                        }
                    }
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.pendingSsid.length > 0 ? 64 : 0
            visible: height > 0
            radius: Theme.radiusMedium; color: Theme.mantle
            border.width: 1; border.color: Theme.accentLine
            clip: true
            Behavior on Layout.preferredHeight { NumberAnimation { duration: Theme.motionNormal; easing.type: Easing.OutCubic } }
            RowLayout {
                anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 10; spacing: 9
                ColumnLayout {
                    Layout.preferredWidth: 150; spacing: 1
                    Text { text: "SECURE ORBIT"; color: Theme.accent; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold; font.letterSpacing: 0.8 }
                    Text { Layout.fillWidth: true; text: root.pendingSsid; color: Theme.moon; font.family: Theme.fontText; font.pixelSize: 10; font.weight: Font.DemiBold; elide: Text.ElideRight }
                }
                Rectangle {
                    Layout.fillWidth: true; Layout.preferredHeight: 38; radius: 11
                    color: Theme.elevated; border.width: 1
                    border.color: passwordInput.activeFocus ? Theme.accent : Theme.line
                    TextInput {
                        id: passwordInput
                        anchors.fill: parent; anchors.leftMargin: 12; anchors.rightMargin: 12
                        verticalAlignment: TextInput.AlignVCenter
                        text: root.wifiPassword
                        onTextChanged: root.wifiPassword = text
                        echoMode: TextInput.Password
                        color: Theme.moon; selectionColor: Theme.accent; selectedTextColor: Theme.void_
                        font.family: Theme.fontMono; font.pixelSize: 9
                        Keys.onReturnPressed: root.submitPassword()
                        Keys.onEscapePressed: { root.pendingSsid = ""; root.wifiPassword = ""; }
                    }
                    Text { anchors.left: parent.left; anchors.leftMargin: 12; anchors.verticalCenter: parent.verticalCenter; visible: passwordInput.text.length === 0 && !passwordInput.activeFocus; text: "NETWORK PASSWORD"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 8 }
                }
                Rectangle {
                    Layout.preferredWidth: 78; Layout.preferredHeight: 38; radius: 11
                    color: connectPointer.containsMouse ? Theme.accent : Theme.accentVeil
                    border.width: 1; border.color: Theme.accentLine
                    Text { anchors.centerIn: parent; text: "CONNECT"; color: connectPointer.containsMouse ? Theme.void_ : Theme.accent; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold }
                    MouseArea { id: connectPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: root.submitPassword() }
                }
                Rectangle {
                    Layout.preferredWidth: 32; Layout.preferredHeight: 32; radius: 10; color: cancelPointer.containsMouse ? Theme.elevated : "transparent"
                    Text { anchors.centerIn: parent; text: "×"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 12 }
                    MouseArea { id: cancelPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { root.pendingSsid = ""; root.wifiPassword = ""; } }
                }
            }
        }

        ListView {
            id: wifiList
            visible: root.activeTab === "wifi"
            Layout.fillWidth: true; Layout.fillHeight: true
            model: NetState.wifiNetworks; spacing: 7; clip: true
            delegate: Rectangle {
                id: wifiRow
                required property var modelData
                width: wifiList.width; height: 68; radius: Theme.radiusMedium
                color: modelData.connected ? Theme.accentVeil : wifiHover.hovered ? Theme.elevated : Theme.mantle
                border.width: modelData.connected ? 2 : 1
                border.color: modelData.connected ? Theme.success : Theme.line
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 10; spacing: 11
                    Item {
                        Layout.preferredWidth: 32; Layout.preferredHeight: 32
                        Row {
                            anchors.bottom: parent.bottom; anchors.horizontalCenter: parent.horizontalCenter; spacing: 2
                            Repeater {
                                model: 4
                                Rectangle {
                                    required property int index
                                    width: 4; height: 6 + index * 5; radius: 2
                                    color: wifiRow.modelData.signal >= (index + 1) * 20 ? Theme.cyan : Theme.line
                                }
                            }
                        }
                    }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 2
                        RowLayout {
                            Layout.fillWidth: true
                            Text { Layout.fillWidth: true; text: wifiRow.modelData.ssid; color: Theme.moon; font.family: Theme.fontText; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                            Text { visible: wifiRow.modelData.saved; text: "SAVED"; color: Theme.violet; font.family: Theme.fontMono; font.pixelSize: 6; font.weight: Font.Bold }
                        }
                        Text { text: wifiRow.modelData.security + " // " + wifiRow.modelData.signal + "% // " + wifiRow.modelData.frequency + " MHZ"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 7 }
                    }
                    Rectangle {
                        Layout.preferredWidth: 92; Layout.preferredHeight: 34; radius: 11
                        color: wifiRow.modelData.connected ? Qt.rgba(Theme.danger.r, Theme.danger.g, Theme.danger.b, 0.10) : wifiButton.containsMouse ? Theme.accentVeil : Theme.elevated
                        border.width: 1; border.color: wifiRow.modelData.connected ? Theme.danger : wifiButton.containsMouse ? Theme.accentLine : Theme.line
                        Text { anchors.centerIn: parent; text: wifiRow.modelData.connected ? "DISCONNECT" : "CONNECT"; color: wifiRow.modelData.connected ? Theme.danger : Theme.moon; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold }
                        MouseArea {
                            id: wifiButton
                            anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (wifiRow.modelData.connected) {
                                    NetState.disconnectWifi(wifiRow.modelData.ssid);
                                } else if (wifiRow.modelData.secure && !wifiRow.modelData.saved) {
                                    root.pendingSsid = wifiRow.modelData.ssid;
                                    root.wifiPassword = "";
                                    Qt.callLater(function() { passwordInput.forceActiveFocus(); });
                                } else {
                                    NetState.connectWifi(wifiRow.modelData.ssid, "");
                                }
                            }
                        }
                    }
                }
                HoverHandler { id: wifiHover }
            }
        }

        ListView {
            id: bluetoothList
            visible: root.activeTab === "bluetooth"
            Layout.fillWidth: true; Layout.fillHeight: true
            model: NetState.bluetoothDevices; spacing: 7; clip: true
            delegate: Rectangle {
                id: bluetoothRow
                required property var modelData
                width: bluetoothList.width; height: 68; radius: Theme.radiusMedium
                color: modelData.connected ? Theme.accentVeil : bluetoothHover.hovered ? Theme.elevated : Theme.mantle
                border.width: modelData.connected ? 2 : 1
                border.color: modelData.connected ? Theme.violet : Theme.line
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 10; spacing: 11
                    Rectangle { Layout.preferredWidth: 38; Layout.preferredHeight: 38; radius: 13; color: Qt.rgba(Theme.violet.r, Theme.violet.g, Theme.violet.b, 0.13); Text { anchors.centerIn: parent; text: "BT"; color: Theme.violet; font.family: Theme.fontMono; font.pixelSize: 8; font.weight: Font.Bold } }
                    ColumnLayout {
                        Layout.fillWidth: true; spacing: 2
                        Text { Layout.fillWidth: true; text: bluetoothRow.modelData.name; color: Theme.moon; font.family: Theme.fontText; font.pixelSize: 11; font.weight: Font.DemiBold; elide: Text.ElideRight }
                        Text { text: bluetoothRow.modelData.address + (bluetoothRow.modelData.paired ? " // PAIRED" : " // DISCOVERED"); color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 7 }
                    }
                    Rectangle {
                        Layout.preferredWidth: 92; Layout.preferredHeight: 34; radius: 11
                        color: bluetoothButton.containsMouse ? Theme.accentVeil : Theme.elevated
                        border.width: 1; border.color: bluetoothRow.modelData.connected ? Theme.danger : Theme.line
                        Text { anchors.centerIn: parent; text: bluetoothRow.modelData.connected ? "DISCONNECT" : bluetoothRow.modelData.paired ? "CONNECT" : "PAIR"; color: bluetoothRow.modelData.connected ? Theme.danger : Theme.moon; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold }
                        MouseArea { id: bluetoothButton; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: NetState.bluetoothAction(bluetoothRow.modelData.address, bluetoothRow.modelData.connected, bluetoothRow.modelData.paired) }
                    }
                }
                HoverHandler { id: bluetoothHover }
            }
        }

        ListView {
            id: ethernetList
            visible: root.activeTab === "ethernet"
            Layout.fillWidth: true; Layout.fillHeight: true
            model: NetState.ethernetDevices; spacing: 7; clip: true
            delegate: Rectangle {
                id: ethernetRow
                required property var modelData
                width: ethernetList.width; height: 68; radius: Theme.radiusMedium
                color: modelData.connected ? Theme.accentVeil : Theme.mantle
                border.width: 1; border.color: modelData.connected ? Theme.cyan : Theme.line
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 13; anchors.rightMargin: 10; spacing: 11
                    Rectangle { Layout.preferredWidth: 38; Layout.preferredHeight: 38; radius: 13; color: Theme.elevated; Text { anchors.centerIn: parent; text: "ETH"; color: Theme.cyan; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold } }
                    ColumnLayout { Layout.fillWidth: true; spacing: 2; Text { text: ethernetRow.modelData.device; color: Theme.moon; font.family: Theme.fontText; font.pixelSize: 11; font.weight: Font.DemiBold } Text { text: (ethernetRow.modelData.connection || "NO PROFILE") + " // " + ethernetRow.modelData.state.toUpperCase(); color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 7 } }
                    Rectangle {
                        Layout.preferredWidth: 92; Layout.preferredHeight: 34; radius: 11; color: ethernetButton.containsMouse ? Theme.accentVeil : Theme.elevated; border.width: 1; border.color: Theme.line
                        Text { anchors.centerIn: parent; text: ethernetRow.modelData.connected ? "DISCONNECT" : "CONNECT"; color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold }
                        MouseArea { id: ethernetButton; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: NetState.ethernetAction(ethernetRow.modelData.device, ethernetRow.modelData.connected) }
                    }
                }
            }
        }

        Text {
            visible: (root.activeTab === "wifi" && wifiList.count === 0)
                || (root.activeTab === "bluetooth" && bluetoothList.count === 0)
                || (root.activeTab === "ethernet" && ethernetList.count === 0)
            Layout.fillWidth: true; Layout.fillHeight: true
            text: NetState.loading ? "SCANNING THE LINK ARRAY…"
                : root.activeTab === "wifi" && !NetState.wifiEnabled ? "WIFI RADIO IS OFFLINE"
                : root.activeTab === "bluetooth" && !DeviceState.bluetoothEnabled ? "BLUETOOTH ARRAY IS OFFLINE"
                : "NO DEVICES DETECTED"
            horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
            color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 9; font.letterSpacing: 0.8
        }

        RowLayout {
            Layout.fillWidth: true
            Text { Layout.fillWidth: true; text: NetState.statusMessage; color: NetState.statusMessage.indexOf("FAIL") >= 0 ? Theme.danger : Theme.muted; font.family: Theme.fontMono; font.pixelSize: 7; elide: Text.ElideRight }
            Rectangle {
                implicitWidth: 142; implicitHeight: 34; radius: 11
                color: advancedPointer.containsMouse ? Theme.accentVeil : Theme.mantle
                border.width: 1; border.color: advancedPointer.containsMouse ? Theme.accentLine : Theme.line
                Text { anchors.centerIn: parent; text: "ADVANCED SETTINGS"; color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 7; font.weight: Font.Bold }
                MouseArea { id: advancedPointer; anchors.fill: parent; hoverEnabled: true; cursorShape: Qt.PointingHandCursor; onClicked: { ShellState.closeEphemeris(); Quickshell.execDetached(["nm-connection-editor"]); } }
            }
        }
    }
}
