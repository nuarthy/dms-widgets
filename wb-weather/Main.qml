import QtQuick
import QtQuick.Layouts
import qs.Common
import qs.Modules.Plugins
import qs.Services

DesktopPluginComponent {
    id: root

    minWidth: 315
    minHeight: 165

    property var wx: WeatherService.weather

    Component.onCompleted: {
        if (typeof WeatherService !== "undefined" && WeatherService.addRef)
            WeatherService.addRef();
    }

    CardBase {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            spacing: Theme.spacingS
            visible: root.wx && root.wx.available

            Text {
                Layout.fillWidth: true
                text: Math.round(root.wx.temp) + "°C  " + (root.wx.city || "")
                color: Theme.surfaceText
                font.pixelSize: Theme.fontSizeLarge * 1.1
                font.weight: Font.DemiBold
            }
            Text {
                Layout.fillWidth: true
                text: "Humidity " + (root.wx.humidity ?? "--") + "%   Wind " + (root.wx.wind || "--")
                color: Theme.surfaceText
                opacity: 0.7
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !(root.wx && root.wx.available)
            text: "Weather unavailable"
            color: Theme.surfaceText
            opacity: 0.6
        }
    }
}
