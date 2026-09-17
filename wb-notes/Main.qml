import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins

DesktopPluginComponent {
    id: root

    minWidth: 165
    minHeight: 150

    property string cardLabel: "Notes"
    property string upstream: "modules/ii/background/widgets/notes/NotesWidget.qml"

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacingS
            Text {
                Layout.fillWidth: true
                text: root.cardLabel
                color: Theme.surfaceText
                font.weight: Font.DemiBold
            }
            Text {
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: "Phase 2 port of\n" + root.upstream
                color: Theme.surfaceText
                opacity: 0.55
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignVCenter
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }
}
