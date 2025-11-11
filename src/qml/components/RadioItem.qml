import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Card {

    property string _streamUrl
    property string _homepageUrl
    property string _stationName

    signal openStation(url: string)

    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
    Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    actions: [
        Kirigami.Action {
            icon.name: "media-playback-start"
            onTriggered: {
               openStation(_streamUrl)
            }
        },
        Kirigami.Action {
            icon.name: "go-home"
            onTriggered: {
                Qt.openUrlExternally(_homepageUrl)
            }
        }
    ]
    banner {
        source: Qt.resolvedUrl("../pics/radio.png")
    }
    contentItem: Controls.Label {
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        text: _stationName
    }

    onHeightChanged: {
        if (GridView.isCurrentItem) {
            setCellHeight(height);
        }
    }
}
