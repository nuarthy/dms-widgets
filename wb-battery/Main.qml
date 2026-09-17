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

            Rectangle {
                Layout.alignment: Qt.AlignRight
                Layout.preferredWidth: 46
                Layout.preferredHeight: 46
                radius: 14
                color: Theme.primary
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
                font.pixelSize: 27
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
