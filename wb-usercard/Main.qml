import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 220
    minHeight: root.narrow ? 400 : 172

    readonly property bool narrow: root.width < 300

    property string displayName: UserInfoService.fullName !== "" ? UserInfoService.fullName : (UserInfoService.username !== "" ? UserInfoService.username : "user")
    property string uptimeText: (typeof DgopService !== "undefined" && DgopService.uptime) ? DgopService.uptime : ""
    property string avatarPath: UserInfoService.username !== "" ? ("file:///var/lib/AccountsService/icons/" + UserInfoService.username) : ""
    property var wx: WeatherService.weather

    Component.onCompleted: {
        if (typeof DgopService !== "undefined" && DgopService.addRef)
            DgopService.addRef(["system"]);
        if (typeof WeatherService !== "undefined" && WeatherService.addRef)
            WeatherService.addRef();
    }

    Process {
        id: ipcProc
    }

    CardBase {
        anchors.fill: parent

        GridLayout {
            anchors.fill: parent
            columns: root.narrow ? 1 : 2
            rowSpacing: Theme.spacingS
            columnSpacing: Theme.spacingM

            Item {
                Layout.fillWidth: root.narrow
                Layout.fillHeight: !root.narrow
                Layout.preferredWidth: root.narrow ? 0 : height
                Layout.preferredHeight: root.narrow ? 150 : 0

                Image {
                    id: avatarImg
                    anchors.fill: parent
                    source: root.avatarPath
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                }

                Rectangle {
                    id: avatarMask
                    anchors.fill: parent
                    radius: Theme.cornerRadius
                    visible: false
                    layer.enabled: true
                }

                MultiEffect {
                    anchors.fill: parent
                    source: avatarImg
                    maskEnabled: true
                    maskSource: avatarMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                    visible: root.avatarPath !== ""
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.cornerRadius
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    visible: root.avatarPath === ""
                    border.width: 1
                    border.color: Theme.withAlpha(Theme.outline, 0.25)

                    Text {
                        anchors.centerIn: parent
                        text: root.displayName.charAt(0).toUpperCase()
                        color: Theme.surfaceText
                        font.pixelSize: 48
                        font.weight: Font.Bold
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.spacingS

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                Text {
                    Layout.fillWidth: true
                    text: root.displayName
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Row {
                    spacing: Theme.spacingS
                    visible: root.uptimeText !== ""
                    DankIcon {
                        name: "schedule"
                        size: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: root.uptimeText
                        color: Theme.surfaceText
                        opacity: 0.6
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                Row {
                    spacing: Theme.spacingS
                    visible: root.wx && root.wx.available
                    DankIcon {
                        name: WeatherService.getWeatherIcon(root.wx.wCode)
                        size: Theme.fontSizeMedium
                        color: Theme.surfaceText
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Text {
                        text: Math.round(root.wx.temp) + "°  " + WeatherService.getWeatherCondition(root.wx.wCode)
                        color: Theme.surfaceText
                        opacity: 0.6
                        font.pixelSize: Theme.fontSizeSmall
                        elide: Text.ElideRight
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingM
                    visible: root.wx && root.wx.available

                    Row {
                        spacing: 2
                        DankIcon {
                            name: "water_drop"
                            size: Theme.fontSizeSmall + 2
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (root.wx.humidity ?? "--") + "%"
                            color: Theme.surfaceText
                            opacity: 0.6
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Row {
                        spacing: 2
                        DankIcon {
                            name: "air"
                            size: Theme.fontSizeSmall + 2
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: root.wx.wind || "--"
                            color: Theme.surfaceText
                            opacity: 0.6
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                    Row {
                        spacing: 2
                        DankIcon {
                            name: "umbrella"
                            size: Theme.fontSizeSmall + 2
                            color: Theme.surfaceText
                            anchors.verticalCenter: parent.verticalCenter
                        }
                        Text {
                            text: (root.wx.precipitationProbability ?? "--") + "%"
                            color: Theme.surfaceText
                            opacity: 0.6
                            font.pixelSize: Theme.fontSizeSmall
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingS

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 30
                        radius: height / 2
                        color: Theme.primary
                        Row {
                            anchors.centerIn: parent
                            spacing: Theme.spacingS
                            DankIcon {
                                name: "lock"
                                size: Theme.fontSizeMedium
                                color: Theme.surfaceContainer
                                anchors.verticalCenter: parent.verticalCenter
                            }
                            Text {
                                text: "Lock"
                                color: Theme.surfaceContainer
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                ipcProc.command = ["loginctl", "lock-session"];
                                ipcProc.running = true;
                            }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: height / 2
                        color: Theme.withAlpha(Theme.primary, 0.25)
                        DankIcon {
                            name: "settings"
                            size: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                ipcProc.command = ["dms", "ipc", "call", "settings", "toggle"];
                                ipcProc.running = true;
                            }
                        }
                    }
                    Rectangle {
                        Layout.preferredWidth: 30
                        Layout.preferredHeight: 30
                        radius: height / 2
                        color: Theme.withAlpha(Theme.primary, 0.25)
                        DankIcon {
                            name: "power_settings_new"
                            size: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            anchors.centerIn: parent
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                ipcProc.command = ["dms", "ipc", "call", "powermenu", "toggle"];
                                ipcProc.running = true;
                            }
                        }
                    }
                }
            }
        }
    }
}
