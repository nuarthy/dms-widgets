import QtQuick
import qs.Common
import qs.Modules.Plugins

PluginSettings {
    id: root
    pluginId: "wb-media"

    ToggleSetting {
        settingKey: "showVisualizer"
        label: "Show Visualizer"
        defaultValue: true
    }
}
