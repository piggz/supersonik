import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import QtQml.XmlListModel
import QtMultimedia as QTMM

import uk.co.piggz 1.0

Rectangle {
    id: mediaplayer
    height: childrenRect.height * 2
    color: "#000000"
    opacity: 0.75

    QTMM.MediaPlayer {
        id: player
        audioOutput: QTMM.AudioOutput {}
    }

    RowLayout {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 10
        x: 10
        width: parent.width - 20

        Controls.Button {
            id: btnPrev
            icon.name: "media-skip-backward"
        }

        Controls.Button {
            id: btnPlayePause
            icon.name: "media-playback-start"
        }

        Controls.Button {
            id: btnNext
            icon.name: "media-skip-forward"
        }

        Controls.Slider {
            id: sldPosition
            Layout.fillWidth: true
            enabled: false
        }
    }

    XmlListModel {
        id: xmlPlaylistModel
        query: "/subsonic-response/album/song"

        onStatusChanged: {
            if (status === XmlListModel.Ready) {
                playFile(xmlPlaylistModel.get(0).songid);
            }
        }

        XmlListModelRole { name: "title"; attributeName: "title" }
        XmlListModelRole { name: "artist"; attributeName: "artist" }
        XmlListModelRole { name: "year"; attributeName: "year" }
        XmlListModelRole { name: "duration"; attributeName: "duration" }
        XmlListModelRole { name: "songid"; attributeName: "id" }
        XmlListModelRole { name: "albumid"; attributeName: "albumId" }

    }

    ListModel {
        id: playlist
    }

    function loadAlbum(albumId) {
        //xmlPlaylistModel.source = buildSubsonicUrl("getAlbum?id=" + albumId)
        //xmlPlaylistModel.reload();
        doRequest(buildSubsonicUrl("getAlbum?id=" + albumId), "GET", parseAlbum );
    }

    function playFile(url) {
        console.log(url);
        player.source = url;
        player.play()
    }

    function parseAlbum(xhr) {
        console.log(xhr.response);
        var res = xhr.responseXML;
        console.log(xhr.responseType, xhr.responseText);
        playlist.clear();

        if (attributeValue(res.documentElement, "status") === "ok") {
            console.log("Get album list Ok");

            var doc = res.documentElement;
            console.log("xhr length: " + doc.childNodes.length );

            for (var i = 0; i < doc.childNodes.length; ++i) {
                var album = doc.childNodes[i];
                console.log("album length: " + album.nodeName, album.childNodes.length);

                for (var j = 0; j < album.childNodes.length; ++j) {
                    var song = album.childNodes[j];

                    console.log(song.nodeName);
                    if ( song.nodeName ===  "song") {
                        playlist.append({"title": attributeValue(song, "title"), "artist": attributeValue(song, "artist"),
                                            "year": attributeValue(song, "year"), "duration": attributeValue(song, "duration"),
                                            "songid": attributeValue(song, "id"), "albumid": attributeValue(song, "albumId")})
                    }

                }
            }

            console.log("Parsed album....", playlist.get(0).songid);
            playFile(buildSubsonicUrl("stream?id=" + playlist.get(0).songid))
        } else {
            console.log("Get album list failed");
        }
    }
}
