import QtQuick
import qs.Common
import qs.Modules.Plugins

// Board container: hosts every WB card in a Flow that reflows
// automatically when the board is resized (e.g. portrait rotation).
// Place this ONE widget instead of the individual wb-* widgets.
DesktopPluginComponent {
    id: root

    minWidth: 300
    minHeight: 400

    Flow {
        id: flow
        anchors.fill: parent
        spacing: Theme.spacingM

        // usercard
        Item {
            width: Math.min(322, flow.width)
            height: 172
            Loader {
                anchors.fill: parent
                source: "../wb-usercard/Main.qml"
            }
        }
        // clock (analog blob)
        Item {
            width: Math.min(200, flow.width)
            height: 210
            Loader {
                anchors.fill: parent
                source: "../wb-clock/Main.qml"
            }
        }
        // cpu / ram / battery
        Item {
            width: Math.min(128, flow.width)
            height: 150
            Loader {
                anchors.fill: parent
                source: "../wb-cpu/Main.qml"
            }
        }
        Item {
            width: Math.min(128, flow.width)
            height: 150
            Loader {
                anchors.fill: parent
                source: "../wb-ram/Main.qml"
            }
        }
        Item {
            width: Math.min(128, flow.width)
            height: 150
            Loader {
                anchors.fill: parent
                source: "../wb-battery/Main.qml"
            }
        }
        // media
        Item {
            width: Math.min(400, flow.width)
            height: 230
            Loader {
                anchors.fill: parent
                source: "../wb-media/Main.qml"
            }
        }
        // worldclock
        Item {
            width: Math.min(320, flow.width)
            height: 230
            Loader {
                anchors.fill: parent
                source: "../wb-worldclock/Main.qml"
            }
        }
        // calendar
        Item {
            width: Math.min(240, flow.width)
            height: 240
            Loader {
                anchors.fill: parent
                source: "../wb-calendar/Main.qml"
            }
        }
        // weather
        Item {
            width: Math.min(315, flow.width)
            height: 165
            Loader {
                anchors.fill: parent
                source: "../wb-weather/Main.qml"
            }
        }
        // converter
        Item {
            width: Math.min(255, flow.width)
            height: 225
            Loader {
                anchors.fill: parent
                source: "../wb-converter/Main.qml"
            }
        }
    }
}
