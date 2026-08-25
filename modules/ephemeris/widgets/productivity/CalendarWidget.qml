import QtQuick
import QtQuick.Layouts
import Quickshell
import "../shared" as Shared
import "../../../.."
import "../../../../services"

Item {
    id: root
    clip: true

    readonly property date today: new Date()
    property int viewYear: today.getFullYear()
    property int viewMonth: today.getMonth()
    readonly property var monthNames: ["JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE",
        "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"]
    readonly property var dayNames: ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    readonly property var calendarDays: buildCalendar(viewYear, viewMonth)

    function buildCalendar(year, month) {
        const first = new Date(year, month, 1);
        const mondayOffset = (first.getDay() + 6) % 7;
        const start = new Date(year, month, 1 - mondayOffset);
        const result = [];
        for (let index = 0; index < 42; index++) {
            const date = new Date(start.getFullYear(), start.getMonth(), start.getDate() + index);
            result.push({
                "day": date.getDate(),
                "month": date.getMonth(),
                "year": date.getFullYear(),
                "inMonth": date.getMonth() === month,
                "today": date.getFullYear() === today.getFullYear()
                    && date.getMonth() === today.getMonth() && date.getDate() === today.getDate()
            });
        }
        return result;
    }

    function moveMonth(delta) {
        const next = new Date(viewYear, viewMonth + delta, 1);
        viewYear = next.getFullYear();
        viewMonth = next.getMonth();
    }

    function temperature(value) {
        return value === undefined ? "--" : Math.round(Number(value)) + Weather.unitSymbol;
    }

    Shared.OrbitalForecast {
        anchors.fill: parent
        z: 0
        hours: Weather.hourly
        current: Weather.current
        unitSymbol: Weather.unitSymbol
    }

    RowLayout {
        anchors.fill: parent
        z: 10
        spacing: 12

        ColumnLayout {
            Layout.preferredWidth: 320
            Layout.minimumWidth: 320
            Layout.maximumWidth: 320
            Layout.fillHeight: true
            spacing: 10

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: root.monthNames[root.viewMonth] + "  " + root.viewYear
                    color: Theme.moon
                    font.family: Theme.fontDisplay
                    font.pixelSize: 17
                    fontSizeMode: Text.Fit
                    minimumPixelSize: 11
                    font.weight: Font.DemiBold
                    font.letterSpacing: 1.1
                }
                Repeater {
                    model: [
                        { "glyph": "‹", "delta": -1 },
                        { "glyph": "TODAY", "delta": 0 },
                        { "glyph": "›", "delta": 1 }
                    ]
                    Rectangle {
                        id: monthButton
                        required property var modelData
                        implicitWidth: modelData.delta === 0 ? 62 : 34
                        implicitHeight: 32
                        radius: 10
                        color: monthPointer.containsMouse ? Theme.accentVeil : Theme.mantle
                        border.width: 0
                        border.color: monthPointer.containsMouse ? Theme.accentLine : Theme.line
                        Text {
                            anchors.centerIn: parent
                            text: monthButton.modelData.glyph
                            color: monthPointer.containsMouse ? Theme.accent : Theme.moon
                            font.family: Theme.fontMono
                            font.pixelSize: monthButton.modelData.delta === 0 ? 7 : 15
                            font.weight: Font.Bold
                        }
                        MouseArea {
                            id: monthPointer
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (monthButton.modelData.delta === 0) {
                                    root.viewYear = root.today.getFullYear();
                                    root.viewMonth = root.today.getMonth();
                                } else root.moveMonth(monthButton.modelData.delta);
                            }
                        }
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                columns: 7
                columnSpacing: 6
                Repeater {
                    model: root.dayNames
                    Text {
                        required property string modelData
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                        text: modelData
                        color: Theme.lineBright
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.weight: Font.Bold
                        font.letterSpacing: 1
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                columnSpacing: 6
                rowSpacing: 6

                Repeater {
                    model: root.calendarDays
                    Rectangle {
                        id: dayCell
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        radius: 11
                        color: modelData.today ? Theme.accent
                            : dayPointer.containsMouse ? Theme.accentVeil : Theme.mantle
                        border.width: 0
                        border.color: modelData.today ? Theme.accent
                            : dayPointer.containsMouse ? Theme.accentLine : Theme.line
                        opacity: modelData.inMonth ? 1 : 0.42

                        Text {
                            anchors.top: parent.top
                            anchors.left: parent.left
                            anchors.margins: 9
                            text: dayCell.modelData.day
                            color: dayCell.modelData.today ? Theme.void_ : Theme.moon
                            font.family: Theme.fontMono
                            font.pixelSize: 11
                            font.weight: dayCell.modelData.today ? Font.Black : Font.Medium
                        }
                        Rectangle {
                            visible: dayCell.modelData.today
                            anchors.right: parent.right
                            anchors.bottom: parent.bottom
                            anchors.margins: 8
                            width: 6
                            height: 6
                            radius: 3
                            color: Theme.void_
                        }
                        MouseArea { id: dayPointer; anchors.fill: parent; hoverEnabled: true }
                    }
                }
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true
        }

        ColumnLayout {
            Layout.preferredWidth: 320
            Layout.minimumWidth: 320
            Layout.maximumWidth: 320
            Layout.fillHeight: true
            spacing: 9

            RowLayout {
                Layout.fillWidth: true
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        Layout.fillWidth: true
                        text: (Weather.location || Settings.weatherLocation).toUpperCase()
                        color: Theme.moon
                        font.family: Theme.fontMono
                        font.pixelSize: 10
                        font.weight: Font.DemiBold
                        elide: Text.ElideRight
                    }
                }
                Rectangle {
                    implicitWidth: 34
                    implicitHeight: 34
                    radius: 10
                    color: refreshPointer.containsMouse ? Theme.accentVeil : Theme.mantle
                    border.width: 0
                    border.color: Weather.loading ? Theme.accent : Theme.line
                    Text {
                        anchors.centerIn: parent
                        text: Weather.loading ? "···" : "↻"
                        color: Weather.loading ? Theme.accent : Theme.moon
                        font.family: Theme.fontMono
                        font.pixelSize: 14
                    }
                    MouseArea {
                        id: refreshPointer
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Weather.refresh()
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: Weather.available ? 126 : 112
                radius: Theme.radiusMedium
                color: Theme.accentVeil
                border.width: 0
                border.color: Theme.accentLine

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    spacing: 5

                    RowLayout {
                        Layout.fillWidth: true
                        visible: Weather.available
                        Text {
                            text: Weather.current.icon || "·"
                            color: Theme.accent
                            font.family: Theme.fontDisplay
                            font.pixelSize: 38
                        }
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0
                            Text {
                                text: root.temperature(Weather.current.temp)
                                color: Theme.moon
                                font.family: Theme.fontDisplay
                            font.pixelSize: 32
                                font.weight: Font.DemiBold
                            }
                            Text {
                                Layout.fillWidth: true
                                text: (Weather.current.condition || "ACQUIRING SKY").toUpperCase()
                                color: Theme.accent
                                font.family: Theme.fontMono
                                font.pixelSize: 10
                                font.letterSpacing: 0.8
                                elide: Text.ElideRight
                            }
                        }
                        ColumnLayout {
                            spacing: 1
                            Text { text: "FEELS " + root.temperature(Weather.current.feels); color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 11 }
                            Text { text: "HUM " + (Weather.current.humidity || 0) + "%"; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 11 }
                            Text { text: "WIND " + (Weather.current.wind || 0) + " " + Weather.windUnit; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 11 }
                        }
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        visible: !Weather.available
                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: 5
                            Text { Layout.alignment: Qt.AlignHCenter; text: Settings.weatherEnabled ? "SKY LINK UNAVAILABLE" : "SKY LINK DISABLED"; color: Theme.warning; font.family: Theme.fontMono; font.pixelSize: 11; font.weight: Font.Bold }
                            Text { Layout.alignment: Qt.AlignHCenter; text: Weather.status; color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 10; elide: Text.ElideRight; Layout.maximumWidth: 285 }
                        }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        visible: Weather.available
                        Text { Layout.fillWidth: true; text: (Weather.location + (Weather.country ? " · " + Weather.country : "")).toUpperCase(); color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 10; font.weight: Font.Bold; elide: Text.ElideRight }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 5
                visible: Weather.available
                Repeater {
                    model: Weather.daily
                    Rectangle {
                        id: dailyCell
                        required property var modelData
                        Layout.fillWidth: true
                        Layout.preferredHeight: 43
                        radius: 10
                        color: Theme.mantle
                        border.width: 0
                        border.color: Theme.line
                        RowLayout {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            spacing: 8
                            Text { Layout.preferredWidth: 38; text: dailyCell.modelData.day; color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 10; font.weight: Font.Bold }
                            Text { text: dailyCell.modelData.icon; color: Theme.accent; font.family: Theme.fontDisplay; font.pixelSize: 16 }
                            Text { Layout.fillWidth: true; text: dailyCell.modelData.condition.toUpperCase(); color: Theme.muted; font.family: Theme.fontMono; font.pixelSize: 11; elide: Text.ElideRight }
                            Text { text: dailyCell.modelData.precipitation + "%"; color: Theme.cyan; font.family: Theme.fontMono; font.pixelSize: 11 }
                            Text { text: root.temperature(dailyCell.modelData.max) + " / " + root.temperature(dailyCell.modelData.min); color: Theme.moon; font.family: Theme.fontMono; font.pixelSize: 10; font.weight: Font.Bold }
                        }
                    }
                }
            }

            Item { Layout.fillHeight: true }
        }
    }

    SystemClock { id: clock; precision: SystemClock.Seconds }
}
