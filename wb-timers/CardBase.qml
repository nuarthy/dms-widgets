import QtQuick
import qs.Common

Rectangle {
    id: root

    default property alias content: slot.data

    radius: Theme.cornerRadius + 8
    color: Theme.surfaceContainer
    border.width: 1
    border.color: Theme.withAlpha(Theme.outline, 0.25)

    Item {
        id: slot
        anchors.fill: parent
        anchors.margins: Theme.spacingM
    }
}
