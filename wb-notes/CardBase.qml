import QtQuick
import qs.Common

Rectangle {
    id: root

    default property alias content: slot.data

    radius: Theme.cornerRadius + 8
    color: Theme.surfaceContainer

    Item {
        id: slot
        anchors.fill: parent
        anchors.margins: Theme.spacingM
    }
}
