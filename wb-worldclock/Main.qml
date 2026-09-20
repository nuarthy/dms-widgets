import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 180
    minHeight: root.narrow ? 330 : 220

    readonly property bool narrow: root.width < 260

    property var now: new Date()
    property string localCity: (typeof WeatherService !== "undefined" && WeatherService.weather.city) ? WeatherService.weather.city : "Local"
    property var zones: [
        { city: "Tokyo", tz: "Asia/Tokyo" },
        { city: "Shenyang", tz: "Asia/Shanghai" },
        { city: "New York", tz: "America/New_York" },
        { city: "London", tz: "Europe/London" }
    ]
    property var zoneData: ({})

    function timeFmt() {
        return SettingsData.use24HourClock ? "%H:%M" : "%-I:%M %p";
    }

    function tzScript() {
        const f = root.timeFmt();
        let cmds = ['date "+Local|' + f + '|%z"'];
        for (let i = 0; i < root.zones.length; i++)
            cmds.push('TZ=' + root.zones[i].tz + ' date "+' + root.zones[i].city + '|' + f + '|%z"');
        return cmds.join("; ");
    }

    function gmtLabel(off) {
        if (!off || off.length < 5)
            return "";
        const sign = off[0] === "-" ? "-" : "+";
        const h = parseInt(off.slice(1, 3), 10);
        const m = off.slice(3, 5);
        return "GMT" + sign + h + (m !== "00" ? ":" + m : "");
    }

    function parseTz(text) {
        const data = {};
        const lines = text.trim().split("\n");
        for (let i = 0; i < lines.length; i++) {
            const parts = lines[i].split("|");
            if (parts.length === 3)
                data[parts[0]] = { time: parts[1].toUpperCase(), gmt: root.gmtLabel(parts[2]) };
        }
        root.zoneData = data;
    }

    function zoneTime(city) {
        return (root.zoneData[city] && root.zoneData[city].time) || "--:--";
    }

    function zoneGmt(city) {
        return (root.zoneData[city] && root.zoneData[city].gmt) || "";
    }

    Component.onCompleted: {
        if (typeof WeatherService !== "undefined" && WeatherService.addRef)
            WeatherService.addRef();
        tzProc.running = true;
    }

    Timer {
        interval: 10000
        repeat: true
        running: true
        onTriggered: {
            root.now = new Date();
            if (!tzProc.running)
                tzProc.running = true;
        }
    }

    Process {
        id: tzProc
        command: ["sh", "-c", root.tzScript()]
        stdout: StdioCollector {
            onStreamFinished: root.parseTz(this.text)
        }
    }

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            Row {
                spacing: Theme.spacingS
                DankIcon {
                    name: "location_on"
                    size: Theme.fontSizeMedium
                    color: Theme.surfaceText
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: root.localCity
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeSmall
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
                text: root.zoneTime("Local")
                color: Theme.primary
                font.pixelSize: 50
                font.weight: Font.Bold
                lineHeight: 0.8
            }

            Text {
                Layout.fillWidth: true
                Layout.topMargin: -4
                horizontalAlignment: Text.AlignRight
                text: Qt.formatDateTime(root.now, "dddd, d MMM yyyy")
                color: Theme.surfaceText
                opacity: 0.7
                font.pixelSize: Theme.fontSizeSmall
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            GridLayout {
                Layout.fillWidth: true
                columns: root.narrow ? 1 : 2
                rowSpacing: Theme.spacingS
                columnSpacing: Theme.spacingM

                Repeater {
                    model: root.zones
                    delegate: ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        required property var modelData

                        RowLayout {
                            Layout.fillWidth: true
                            Text {
                                Layout.fillWidth: true
                                text: modelData.city
                                color: Theme.surfaceText
                                opacity: 0.7
                                font.pixelSize: Theme.fontSizeSmall
                                elide: Text.ElideRight
                            }
                            Text {
                                text: root.zoneGmt(modelData.city)
                                color: Theme.surfaceText
                                opacity: 0.5
                                font.pixelSize: Theme.fontSizeSmall
                            }
                        }
                        Text {
                            text: root.zoneTime(modelData.city)
                            color: Theme.primary
                            font.pixelSize: 22
                            font.weight: Font.DemiBold
                        }
                    }
                }
            }
        }
    }
}
