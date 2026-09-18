import QtQuick
import qs.Common

Rectangle {
    id: root

    default property alias content: slot.data
    property real contentMargins: Theme.spacingL

    radius: Theme.cornerRadius + 8
    color: Theme.surfaceContainer

    Item {
        id: slot
        anchors.fill: parent
        anchors.margins: root.contentMargins
    }
}
