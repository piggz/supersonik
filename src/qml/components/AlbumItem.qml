import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Card {
    id: card

    property bool _offline
    property string _albumId
    property bool _starred
    property string _albumArtist
    property string _albumTitle
    property string _albumYear
    property string _artUrl

    signal replaceAlbum(id: string, offlineMode: bool)
    signal appendAlbum(id: string, offlineMode: bool)
    signal starAlbum(id: string)
    signal unstarAlbum(id: string)
    signal downloadAlbum(id: string)

    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
    Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    actions: [
        Kirigami.Action {
            icon.name: "media-playback-start"
            onTriggered: {
                replaceAlbum(_albumId, _offline);
            }
        },
        Kirigami.Action {
            icon.name: "media-playlist-append"
            onTriggered: {
                appendAlbum(_albumId, _offline);
            }
        },
        Kirigami.Action {
            icon.source: starred ? Qt.resolvedUrl("../pics/star-filled.png") : Qt.resolvedUrl("../pics/star-outline.png")
            visible: !_offline
            onTriggered: {
                if (starred) {
                    unStarAlbum(_albumid)
                    starred = "";
                } else {
                    starAlbum(_albumid)
                    starred =  "true"
                }
            }
        },
        Kirigami.Action {
            icon.name: "download"
            visible: !_offline
            onTriggered: {
                downloadAlbum(_albumId);
            }
        }

    ]
    banner {
        source: _artUrl
        title: _albumTitle
        implicitHeight: width
        titleAlignment: Qt.AlignLeft | Qt.AlignBottom
    }
    contentItem: Controls.Label {
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        text: _albumArtist + " - " + _albumYear
    }

    onHeightChanged: {
        if (GridView.isCurrentItem) {
            setCellHeight(height);
        }
    }
}
