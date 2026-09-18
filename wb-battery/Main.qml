import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 128
    minHeight: 139

    function pct(v) {
        if (v === undefined || v === null || isNaN(v))
            return 0;
        return Math.round(v > 1 ? v : v * 100);
    }

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            Item {
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                OrganicBlobHourBulges {
                    anchors.fill: parent
                    fillColor: Theme.primary
                    lobes: 12
                    rotationDeg: -90
                    lobeAmount: 0.075
                    hillPower: 0.92
                    roundness: 0.22
                    paddingFrac: 0.02
                    segments: 144
                }
                DankIcon {
                    anchors.centerIn: parent
                    name: "battery_full"
                    size: 24
                    color: "white"
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Text {
                text: BatteryService.batteryAvailable ? root.pct(BatteryService.batteryLevel) + "%" : "--"
                color: Theme.primary
                font.pixelSize: 38
                font.weight: Font.Bold
            }
            Text {
                text: "Battery"
                color: Theme.surfaceText
                opacity: 0.6
                font.pixelSize: Theme.fontSizeMedium
            }
        }
    }
}
