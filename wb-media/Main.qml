import QtQuick
import QtQuick.Effects
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins
import qs.Services
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 360
    minHeight: 135

    property var player: MprisController.activePlayer
    property string trackTitle: player ? (player.trackTitle || "Unknown title") : "Nothing playing"
    property string trackArtist: player ? (player.trackArtist || "") : ""
    property bool playing: player ? !!player.isPlaying : false
    property string artUrl: player ? (player.trackArtUrl || "") : ""

    CardBase {
        anchors.fill: parent

        RowLayout {
            anchors.fill: parent
            spacing: Theme.spacingM

            Item {
                Layout.fillHeight: true
                Layout.preferredWidth: height

                Image {
                    id: artImg
                    anchors.fill: parent
                    source: root.artUrl
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    visible: false
                }

                Rectangle {
                    id: artMask
                    anchors.fill: parent
                    radius: Theme.cornerRadius
                    visible: false
                    layer.enabled: true
                }

                MultiEffect {
                    anchors.fill: parent
                    source: artImg
                    maskEnabled: true
                    maskSource: artMask
                    maskThresholdMin: 0.5
                    maskSpreadAtMin: 1.0
                    visible: root.artUrl !== ""
                }

                Rectangle {
                    anchors.fill: parent
                    radius: Theme.cornerRadius
                    color: Theme.withAlpha(Theme.surfaceContainerHigh, 0.5)
                    visible: root.artUrl === ""
                    border.width: 1
                    border.color: Theme.withAlpha(Theme.outline, 0.25)

                    DankIcon {
                        anchors.centerIn: parent
                        name: "music_note"
                        size: 38
                        color: Theme.surfaceText
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 2

                Text {
                    Layout.fillWidth: true
                    text: root.trackTitle
                    color: Theme.surfaceText
                    font.pixelSize: Theme.fontSizeLarge
                    font.weight: Font.DemiBold
                    elide: Text.ElideRight
                }
                Text {
                    Layout.fillWidth: true
                    visible: root.trackArtist !== ""
                    text: root.trackArtist
                    color: Theme.surfaceText
                    opacity: 0.7
                    elide: Text.ElideRight
                }

                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                }

                RowLayout {
                    Layout.alignment: Qt.AlignRight
                    spacing: 4

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: height / 2
                        color: Theme.withAlpha(Theme.primary, 0.25)
                        DankIcon {
                            anchors.centerIn: parent
                            name: "skip_previous"
                            size: Theme.fontSizeLarge
                            color: Theme.surfaceText
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: root.player && root.player.canGoPrevious
                            onClicked: root.player.previous()
                        }
                    }

                    Item {
                        Layout.preferredWidth: 54
                        Layout.preferredHeight: 54
                        OrganicBlobHourBulges {
                            anchors.fill: parent
                            fillColor: Theme.primary
                            lobes: 12
                            rotationDeg: -90
                            lobeAmount: 0.075
                            hillPower: 0.92
                            roundness: 0.22
                            paddingFrac: 0.02
                            segments: 144
                        }
                        DankIcon {
                            anchors.centerIn: parent
                            name: root.playing ? "pause" : "play_arrow"
                            size: 26
                            color: "white"
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: !!root.player
                            onClicked: root.player.playPause()
                        }
                    }

                    Rectangle {
                        Layout.preferredWidth: 32
                        Layout.preferredHeight: 32
                        radius: height / 2
                        color: Theme.withAlpha(Theme.primary, 0.25)
                        DankIcon {
                            anchors.centerIn: parent
                            name: "skip_next"
                            size: Theme.fontSizeLarge
                            color: Theme.surfaceText
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: root.player && root.player.canGoNext
                            onClicked: root.player.next()
                        }
                    }
                }
            }
        }
    }
}
