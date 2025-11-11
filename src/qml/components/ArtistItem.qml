import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Card {
    width: _albumWidth
    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
    Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    actions: [
        Kirigami.Action {
            icon.name: "library-music-symbolic"
            onTriggered: {
                loadArtistAlbums(artistId)
            }
        }
    ]
    banner {
        source: coverArt ? buildSubsonicUrl("getCoverArt?id=" + coverArt) : Qt.resolvedUrl("../pics/artist.png")
        onToggled: {
            console.log("toggle");
        }
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
