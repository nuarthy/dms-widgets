import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

DesktopPluginComponent {
    id: root

    minWidth: 340
    minHeight: 430

    property bool acceptsKeyboardFocus: true

    property var presets: []
    property string selectedName: ""
    property int screenIdx: 0
    property string renamingName: ""

    function sel() {
        for (let i = 0; i < presets.length; i++)
            if (presets[i].name === root.selectedName)
                return presets[i];
        return null;
    }

    function screensOf(p) {
        if (!p || !p.data || !p.data.desktopWidgetInstancePositions)
            return [];
        return Object.keys(p.data.desktopWidgetInstancePositions);
    }

    function refresh() {
        listProc.running = true;
    }

    function runCmd(args) {
        cmdProc.command = ["dms-preset"].concat(args);
        cmdProc.running = true;
    }

    Component.onCompleted: refresh()

    Process {
        id: listProc
        command: ["dms-preset", "list-json"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    root.presets = JSON.parse(this.text || "[]");
                } catch (e) {
                    root.presets = [];
                }
                if (root.selectedName === "") {
                    const ss = root.screensOf(root.sel());
                    void ss;
                }
                preview.requestPaint();
            }
        }
    }

    Process {
        id: cmdProc
        onExited: root.refresh()
    }

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacingS

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS

                Text {
                    Layout.fillWidth: true
                    text: "Layout presets"
                    color: Theme.surfaceText
                    font.weight: Font.DemiBold
                    font.pixelSize: Theme.fontSizeLarge
                }
                DankButton {
                    iconName: "close"
                    buttonHeight: 30
                    onClicked: hideProc.running = true
                }
            }

            Process {
                id: hideProc
                command: ["dms", "ipc", "call", "desktopWidget", "disable", root.instanceId]
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingS

                DankTextField {
                    id: nameField
                    Layout.fillWidth: true
                    placeholderText: "Preset name"
                    onAccepted: {
                        if (text.trim() !== "") {
                            root.runCmd(["save", text.trim()]);
                            text = "";
                        }
                    }
                }
                DankButton {
                    text: "Save"
                    buttonHeight: 36
                    onClicked: {
                        if (nameField.text.trim() !== "") {
                            root.runCmd(["save", nameField.text.trim()]);
                            nameField.text = "";
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Repeater {
                    model: root.presets
                    delegate: ColumnLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: 2

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Theme.spacingS

                            Text {
                                Layout.fillWidth: true
                                visible: root.renamingName !== modelData.name
                                text: modelData.name + "  (" + modelData.widgets + ")"
                                color: root.selectedName === modelData.name ? Theme.primary : Theme.surfaceText
                                elide: Text.ElideRight

                                MouseArea {
                                    anchors.fill: parent
                                    onClicked: {
                                        if (root.selectedName === modelData.name)
                                            root.selectedName = "";
                                        else {
                                            root.selectedName = modelData.name;
                                            root.screenIdx = 0;
                                        }
                                        preview.requestPaint();
                                    }
                                }
                            }
                            DankTextField {
                                id: renameField
                                Layout.fillWidth: true
                                visible: root.renamingName === modelData.name
                                placeholderText: "New name"
                                onVisibleChanged: {
                                    if (visible)
                                        text = modelData.name;
                                }
                                onAccepted: {
                                    if (text.trim() !== "" && text.trim() !== modelData.name)
                                        root.runCmd(["rename", modelData.name, text.trim()]);
                                    root.renamingName = "";
                                }
                            }
                            DankButton {
                                iconName: root.renamingName === modelData.name ? "check" : "edit"
                                buttonHeight: 30
                                onClicked: {
                                    if (root.renamingName === modelData.name) {
                                        if (renameField.text.trim() !== "" && renameField.text.trim() !== modelData.name)
                                            root.runCmd(["rename", modelData.name, renameField.text.trim()]);
                                        root.renamingName = "";
                                    } else {
                                        root.renamingName = modelData.name;
                                    }
                                }
                            }
                            DankButton {
                                iconName: "wallpaper"
                                buttonHeight: 30
                                onClicked: root.runCmd(["apply", modelData.name, "--wallpaper-only"])
                            }
                            DankButton {
                                iconName: "check"
                                buttonHeight: 30
                                onClicked: root.runCmd(["apply", modelData.name])
                            }
                            DankButton {
                                iconName: "delete"
                                buttonHeight: 30
                                onClicked: root.runCmd(["delete", modelData.name])
                            }
                        }
                    }
                }

                Text {
                    Layout.fillWidth: true
                    visible: root.presets.length === 0
                    text: "No presets yet — arrange your desktop, name it above, hit Save."
                    color: Theme.surfaceText
                    opacity: 0.6
                    font.pixelSize: Theme.fontSizeSmall
                    wrapMode: Text.WordWrap
                }
            }

            RowLayout {
                Layout.fillWidth: true
                visible: root.selectedName !== ""
                spacing: Theme.spacingS

                DankButton {
                    iconName: "chevron_left"
                    buttonHeight: 30
                    onClicked: {
                        const ss = root.screensOf(root.sel());
                        if (ss.length > 0) {
                            root.screenIdx = (root.screenIdx + ss.length - 1) % ss.length;
                            preview.requestPaint();
                        }
                    }
                }
                Text {
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                    text: {
                        const ss = root.screensOf(root.sel());
                        return ss.length > 0 ? ss[root.screenIdx % ss.length] : "";
                    }
                    color: Theme.surfaceText
                    opacity: 0.7
                    font.pixelSize: Theme.fontSizeSmall
                    elide: Text.ElideRight
                }
                DankButton {
                    iconName: "chevron_right"
                    buttonHeight: 30
                    onClicked: {
                        const ss = root.screensOf(root.sel());
                        if (ss.length > 0) {
                            root.screenIdx = (root.screenIdx + 1) % ss.length;
                            preview.requestPaint();
                        }
                    }
                }
            }

            Canvas {
                id: preview
                Layout.fillWidth: true
                Layout.preferredHeight: 170
                visible: root.selectedName !== ""
                renderTarget: Canvas.FramebufferObject
                onPaint: {
                    const ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    const p = root.sel();
                    const ss = root.screensOf(p);
                    if (!p || ss.length === 0)
                        return;
                    const screen = ss[root.screenIdx % ss.length];
                    const rects = p.data.desktopWidgetInstancePositions[screen];
                    const names = {};
                    const insts = p.data.desktopWidgetInstances || [];
                    for (let i = 0; i < insts.length; i++)
                        names[insts[i].id] = insts[i].name || insts[i].widgetType || insts[i].id;

                    let minX = 1e9, minY = 1e9, maxX = -1e9, maxY = -1e9;
                    const keys = Object.keys(rects);
                    for (let i = 0; i < keys.length; i++) {
                        const r = rects[keys[i]];
                        if (r.x === undefined)
                            continue;
                        minX = Math.min(minX, r.x);
                        minY = Math.min(minY, r.y);
                        maxX = Math.max(maxX, r.x + (r.width || 100));
                        maxY = Math.max(maxY, r.y + (r.height || 100));
                    }
                    if (minX > maxX)
                        return;
                    const pad = 20;
                    minX -= pad;
                    minY -= pad;
                    maxX += pad;
                    maxY += pad;
                    const s = Math.min(width / (maxX - minX), height / (maxY - minY));
                    const ox = (width - (maxX - minX) * s) / 2;
                    const oy = (height - (maxY - minY) * s) / 2;

                    const prim = Theme.primary;
                    for (let i = 0; i < keys.length; i++) {
                        const r = rects[keys[i]];
                        if (r.x === undefined)
                            continue;
                        const x = ox + (r.x - minX) * s;
                        const y = oy + (r.y - minY) * s;
                        const w = Math.max(3, (r.width || 100) * s);
                        const h = Math.max(3, (r.height || 100) * s);
                        ctx.fillStyle = Qt.rgba(prim.r, prim.g, prim.b, 0.3);
                        ctx.fillRect(x, y, w, h);
                        ctx.strokeStyle = Qt.rgba(prim.r, prim.g, prim.b, 1);
                        ctx.lineWidth = 1;
                        ctx.strokeRect(x + 0.5, y + 0.5, w, h);
                        const label = String(names[keys[i]] || "").slice(0, 12);
                        if (label !== "" && h > 12) {
                            ctx.fillStyle = Qt.rgba(prim.r, prim.g, prim.b, 1);
                            ctx.font = "9px sans-serif";
                            ctx.fillText(label, x + 3, y + 11);
                        }
                    }
                }
            }

            Item {
                Layout.fillWidth: true
                Layout.fillHeight: true
            }

            Text {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignBottom
                text: "Apply restarts DMS (~10s). Wallpaper icon switches wallpaper instantly."
                color: Theme.surfaceText
                opacity: 0.5
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }
        }
    }
}
