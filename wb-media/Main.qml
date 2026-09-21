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

    minWidth: 230
    minHeight: root.narrow ? 380 : 135

    readonly property bool narrow: root.width < 320

    property var player: MprisController.activePlayer
    property string trackTitle: player ? (player.trackTitle || "Unknown title") : "Nothing playing"
    property string trackArtist: player ? (player.trackArtist || "") : ""
    property bool playing: player ? !!player.isPlaying : false
    property string artUrl: player ? (player.trackArtUrl || "") : ""
    property bool showVisualizer: root.pluginData.showVisualizer ?? true

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
                Layout.preferredHeight: root.narrow ? 130 : 0

                Image {
                    id: artImg
                    anchors.fill: parent
                    source: root.artUrl
                    sourceSize.width: 256
                    sourceSize.height: 256
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    cache: false
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

                RowLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: Theme.spacingS

                    Item {
                        id: viz
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.topMargin: 5

                        readonly property bool live: root.showVisualizer && root.playing && CavaService.cavaAvailable
                        property real gain: 1.2
                        property bool holdVisible: false

                        onLiveChanged: {
                            if (live) {
                                holdTimer.stop();
                                holdVisible = false;
                            } else {
                                holdVisible = true;
                                holdTimer.restart();
                            }
                        }

                        property list<int> spectrum: Array(24).fill(0)

                        function level(i) {
                            const x = viz.spectrum[i] ?? 0;
                            if (x <= 0)
                                return 0;
                            return Math.min(1, Math.sqrt(x * 0.01) * viz.gain);
                        }

                        Process {
                            id: vizCava
                            running: viz.live
                            command: ["sh", "-c", `cat <<'CAVACONF' > /tmp/wb-media-cava.conf
[general]
framerate=30
bars=24
autosens=0
sensitivity=30
sleep_timer=3
lower_cutoff_freq=50
higher_cutoff_freq=12000

[output]
method=raw
raw_target=/dev/stdout
data_format=ascii
channels=mono
mono_option=average

[smoothing]
noise_reduction=35
integral=90
gravity=95
ignore=2
monstercat=1.5
CAVACONF
exec cava -p /tmp/wb-media-cava.conf < /dev/null`]

                            onRunningChanged: {
                                if (!running)
                                    viz.spectrum = Array(24).fill(0);
                            }

                            stdout: SplitParser {
                                splitMarker: "\n"
                                onRead: data => {
                                    if (!viz.live || data.length === 0)
                                        return;
                                    const parts = data.split(";");
                                    if (parts.length < 24)
                                        return;
                                    const pts = [];
                                    for (let i = 0; i < 24; i++)
                                        pts.push(parseInt(parts[i], 10) || 0);
                                    viz.spectrum = pts;
                                }
                            }
                        }

                        Timer {
                            id: holdTimer
                            interval: 5000
                            onTriggered: viz.holdVisible = false
                        }

                        Row {
                            id: vizRow
                            anchors.fill: parent
                            spacing: 4
                            opacity: (viz.live || viz.holdVisible) ? 1 : 0

                            Behavior on opacity {
                                enabled: !viz.live
                                NumberAnimation {
                                    duration: 400
                                }
                            }

                            Repeater {
                                model: 24
                                delegate: Item {
                                    required property int index
                                    property int band: index
                                    width: (vizRow.width - vizRow.spacing * 23) / 24
                                    height: vizRow.height

                                    Rectangle {
                                        anchors.horizontalCenter: parent.horizontalCenter
                                        anchors.bottom: parent.bottom
                                        width: parent.width
                                        height: Math.max(2, viz.level(parent.band) * viz.height)
                                        radius: width / 2
                                        color: Theme.primary

                                        Behavior on height {
                                            NumberAnimation {
                                                duration: 120
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignBottom
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
                            onClicked: MprisController.previousOrRewind()
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
                            segments: 48
                        }
                        DankIcon {
                            anchors.centerIn: parent
                            name: root.playing ? "pause" : "play_arrow"
                            size: 26
                            color: Theme.surfaceContainer
                        }
                        MouseArea {
                            anchors.fill: parent
                            enabled: !!root.player
                            onClicked: { if (root.player) root.player.togglePlaying(); }
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
                            onClicked: MprisController.next()
                        }
                    }
                    }
                }
            }
        }
    }
}
