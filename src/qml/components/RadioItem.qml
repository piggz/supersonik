import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Card {
    width: _albumWidth

    property string streamUrl
    property string homepageUrl
    property string name

    signal openStation(url: string)

    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
    Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    actions: [
        Kirigami.Action {
            icon.name: "media-playback-start"
            onTriggered: {
               openStation(streamUrl)
            }
        },
        Kirigami.Action {
            icon.name: "go-home"
            onTriggered: {
                Qt.openUrlExternally(homepageUrl)
            }
        }
    ]
    banner {
        source: Qt.resolvedUrl("../pics/radio.png")
    }
    contentItem: Controls.Label {
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        text: name
    }

    onHeightChanged: {
        if (GridView.isCurrentItem) {
            setCellHeight(height);
        }
    }
}
