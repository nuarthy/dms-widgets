import QtQuick
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 56
    minHeight: 56

    Process {
        id: showProc
        command: ["sh", "-c", 'ID=$(dms ipc call desktopWidget list | grep -o "dw_[a-z0-9_]* \\[wb-presets\\]" | grep -o "dw_[a-z0-9_]*" | head -1); [ -n "$ID" ] && dms ipc call desktopWidget enable "$ID"']
    }

    CardBase {
        anchors.fill: parent

        DankIcon {
            anchors.centerIn: parent
            name: "dashboard_customize"
            size: 26
            color: Theme.surfaceText
        }

        MouseArea {
            anchors.fill: parent
            onClicked: showProc.running = true
        }
    }
}
