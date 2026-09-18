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

    Component.onCompleted: {
        if (typeof DgopService !== "undefined" && DgopService.addRef)
            DgopService.addRef(["memory"]);
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
                    lobes: 6
                    rotationDeg: -90
                    lobeAmount: 0.05
                    hillPower: 1.0
                    roundness: 0.08
                    paddingFrac: 0.02
                    segments: 144
                }
                DankIcon {
                    anchors.centerIn: parent
                    name: "developer_board"
                    size: 24
                    color: "white"
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Text {
                text: root.pct(DgopService.memoryUsage) + "%"
                color: Theme.primary
                font.pixelSize: 38
                font.weight: Font.Bold
            }
            Text {
                text: "RAM"
                color: Theme.surfaceText
                opacity: 0.6
                font.pixelSize: Theme.fontSizeMedium
            }
        }
    }
}
