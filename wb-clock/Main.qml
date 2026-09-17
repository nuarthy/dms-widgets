import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    minWidth: 150
    minHeight: 180

    property var now: new Date()

    Timer {
        interval: 1000
        repeat: true
        running: true
        onTriggered: root.now = new Date()
    }

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDateTime(root.now, "hh")
                color: Theme.primary
                font.pixelSize: 48
                font.weight: Font.Bold
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDateTime(root.now, "mm")
                color: Theme.primary
                font.pixelSize: 48
                font.weight: Font.Bold
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: Qt.formatDateTime(root.now, "ddd, dd/MM")
                color: Theme.surfaceText
                opacity: 0.7
                font.pixelSize: Theme.fontSizeMedium
            }
        }
    }
}
