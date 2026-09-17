import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 240
    minHeight: 232

    property int monthOffset: 0
    property var today: new Date()

    Timer {
        interval: 60000
        repeat: true
        running: true
        onTriggered: root.today = new Date()
    }

    function shownMonth() {
        return new Date(root.today.getFullYear(), root.today.getMonth() + root.monthOffset, 1);
    }

    function cellDate(i) {
        const m = root.shownMonth();
        const firstDow = (m.getDay() + 6) % 7;
        return new Date(m.getFullYear(), m.getMonth(), 1 - firstDow + i);
    }

    function isToday(d) {
        const t = root.today;
        return d.getFullYear() === t.getFullYear() && d.getMonth() === t.getMonth() && d.getDate() === t.getDate();
    }

    function inMonth(d) {
        return d.getMonth() === root.shownMonth().getMonth();
    }

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacingS

            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: Qt.formatDateTime(root.shownMonth(), "MMMM yyyy")
                    color: Theme.surfaceText
                    font.weight: Font.DemiBold
                }
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: height / 2
                    color: Theme.withAlpha(Theme.primary, 0.25)
                    DankIcon {
                        name: "chevron_left"
                        size: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.monthOffset--
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 28
                    Layout.preferredHeight: 28
                    radius: height / 2
                    color: Theme.withAlpha(Theme.primary, 0.25)
                    DankIcon {
                        name: "chevron_right"
                        size: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.centerIn: parent
                    }
                    MouseArea {
                        anchors.fill: parent
                        onClicked: root.monthOffset++
                    }
                }
            }

            GridLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                columns: 7
                rowSpacing: 4
                columnSpacing: 4

                Repeater {
                    model: ["M", "T", "W", "T", "F", "S", "S"]
                    delegate: Item {
                        required property string modelData
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Text {
                            width: 28
                            horizontalAlignment: Text.AlignHCenter
                            anchors.centerIn: parent
                            text: modelData
                            color: Theme.surfaceText
                            opacity: 0.5
                            font.pixelSize: Theme.fontSizeSmall
                        }
                    }
                }
                Repeater {
                    model: 42
                    delegate: Item {
                        required property int index
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        Item {
                            width: 28
                            height: 28
                            anchors.centerIn: parent

                            Rectangle {
                                width: 26
                                height: 26
                                radius: 13
                                anchors.centerIn: parent
                                visible: root.isToday(root.cellDate(index))
                                color: Theme.primary
                            }
                            Text {
                                width: 28
                                horizontalAlignment: Text.AlignHCenter
                                anchors.centerIn: parent
                                text: root.cellDate(index).getDate()
                                color: root.isToday(root.cellDate(index)) ? "white" : Theme.surfaceText
                                opacity: root.inMonth(root.cellDate(index)) ? 1 : 0.35
                                font.pixelSize: 11
                            }
                        }
                    }
                }
            }
        }
    }
}
