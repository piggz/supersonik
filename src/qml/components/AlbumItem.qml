import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Card {
    id: card

    width: _albumWidth
    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
    Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    actions: [
        Kirigami.Action {
            icon.name: "media-playback-start"
            onTriggered: {
                if (_offlineMode) {
                    mediaPlayer.replaceAlbumOffline(albumid)
                } else {
                    mediaPlayer.replaceAlbum(albumid)
                }
            }
        },
        Kirigami.Action {
            icon.name: "media-playlist-append"
            onTriggered: {
                if (_offlineMode) {
                    mediaPlayer.addAlbumOffline(albumid)
                } else {
                    mediaPlayer.addAlbum(albumid)
                }
            }
        },
        Kirigami.Action {
            icon.source: starred ? Qt.resolvedUrl("../pics/star-filled.png") : Qt.resolvedUrl("../pics/star-outline.png")
            visible: !_offlineMode
            onTriggered: {
                if (starred) {
                    unStarAlbum(albumid)
                    starred = "";
                } else {
                    starAlbum(albumid)
                    starred =  "true"
                }
            }
        },
        Kirigami.Action {
            icon.name: "download"
            visible: !_offlineMode
            onTriggered: {
                offlineFiles.downloadAlbum(albumid);
            }
        }

    ]
    banner {
        source: artUrl
        title: title
        implicitHeight: width
        titleAlignment: Qt.AlignLeft | Qt.AlignBottom
    }
    contentItem: Controls.Label {
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        text: artist + " - " + year
    }

    onHeightChanged: {
        if (GridView.isCurrentItem) {
            setCellHeight(height);
        }
    }
}
