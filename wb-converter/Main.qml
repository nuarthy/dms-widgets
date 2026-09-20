import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 200
    minHeight: 225

    property var formats: ["WEBP", "PNG", "JPG", "AVIF"]
    property int formatIndex: 0
    property string status: "idle"
    property string statusMessage: ""
    property var queue: []

    function ext() {
        return root.formats[root.formatIndex].toLowerCase();
    }

    function localPath(url) {
        const s = url.toString();
        if (s.startsWith("file://"))
            return s.slice(7);
        return s;
    }

    function enqueue(urls) {
        for (let i = 0; i < urls.length; i++)
            root.queue.push(urls[i]);
        if (root.status !== "converting")
            next();
    }

    function next() {
        if (root.queue.length === 0) {
            root.status = "idle";
            return;
        }
        const input = localPath(root.queue.shift());
        const dot = input.lastIndexOf(".");
        const output = (dot > 0 ? input.slice(0, dot) : input) + "." + root.ext();
        root.status = "converting";
        root.statusMessage = "Converting...";
        convProc.targetOutput = output;
        convProc.triedFfmpeg = false;
        convProc.command = ["magick", input, output];
        convProc.running = true;
    }

    Process {
        id: convProc
        property string targetOutput: ""
        property bool triedFfmpeg: false
        property string lastInput: ""
        onStarted: lastInput = command.length > 1 ? command[1] : ""
        onExited: exitCode => {
            if (exitCode === 0) {
                root.statusMessage = "Saved " + targetOutput.split("/").pop();
                root.next();
            } else if (!triedFfmpeg) {
                triedFfmpeg = true;
                command = ["ffmpeg", "-y", "-i", lastInput, targetOutput];
                running = true;
            } else {
                root.status = "idle";
                root.statusMessage = "Failed (need magick/ffmpeg)";
            }
        }
    }

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacingS

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: Theme.cornerRadius
                color: "transparent"
                border.width: 1
                border.color: root.status === "hover" ? Theme.primary : Theme.withAlpha(Theme.outline, 0.5)

                Column {
                    anchors.centerIn: parent
                    width: parent.width - Theme.spacingM * 2
                    spacing: Theme.spacingS

                    DankIcon {
                        name: "image"
                        size: 32
                        color: Theme.surfaceText
                        anchors.horizontalCenter: parent.horizontalCenter
                    }

                    Text {
                        width: parent.width
                        horizontalAlignment: Text.AlignHCenter
                        wrapMode: Text.WordWrap
                        text: {
                            if (root.status === "hover")
                                return "Release to convert to ." + root.ext().toUpperCase();
                            if (root.status === "converting" || root.statusMessage !== "")
                                return root.statusMessage;
                            return "Drop image(s) here\nto convert to ." + root.ext().toUpperCase();
                        }
                        color: Theme.surfaceText
                        opacity: 0.75
                    }
                }

                DropArea {
                    anchors.fill: parent
                    onEntered: root.status = "hover"
                    onExited: {
                        if (root.status === "hover")
                            root.status = root.queue.length > 0 ? "converting" : "idle";
                    }
                    onDropped: drop => {
                        if (drop.hasUrls)
                            root.enqueue(drop.urls);
                        else
                            root.status = "idle";
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS

                Text {
                    Layout.fillWidth: true
                    text: "Convert to: " + root.formats[root.formatIndex]
                    color: Theme.surfaceText
                    opacity: 0.7
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
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
                        onClicked: root.formatIndex = (root.formatIndex + root.formats.length - 1) % root.formats.length
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
                        onClicked: root.formatIndex = (root.formatIndex + 1) % root.formats.length
                    }
                }
            }
        }
    }
}
