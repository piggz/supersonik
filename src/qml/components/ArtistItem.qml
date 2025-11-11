import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Card {

    property string _artistName
    property string _artistId
    property string _coverArt

    signal openArtist(artisId: string)

    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
    Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    actions: [
        Kirigami.Action {
            icon.name: "library-music-symbolic"
            onTriggered: {
                openArtist(_artistId);
            }
        }
    ]
    banner {
        source: _coverArt ? buildSubsonicUrl("getCoverArt?id=" + _coverArt) : Qt.resolvedUrl("../pics/artist.png")
        onToggled: {
            console.log("toggle");
        }
    }
    contentItem: Controls.Label {
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        text: _artistName
    }

    onHeightChanged: {
        if (GridView.isCurrentItem) {
            setCellHeight(height);
        }
    }
}
