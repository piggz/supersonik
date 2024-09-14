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
    height: maximised ? parent.height : (btnPrev.height * 3)
    color: "#000000"
    opacity: 0.8

    property int currentIndex: -1;
    property bool maximised: false;
    property string currentArtist: ""
    property string currentTitle: ""
    property int minHeight: (btnPrev.height * 3) - 30

    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    QTMM.MediaPlayer {
        id: player
        audioOutput: QTMM.AudioOutput {}

        onPositionChanged: {
            sldPosition.value = player.position / 1000;
        }
    }

    GridLayout {
        columns:  2
        anchors.top: parent.top
        anchors.topMargin: 10
        width: parent.width - 20
        height: parent.height
        x: 5
        rowSpacing: 5
        columnSpacing: 10

        Controls.Label {
            text: currentTitle
            color: "white"
            font.bold: true
            Layout.preferredHeight: minHeight / 3
            Layout.alignment: Qt.AlignVCenter
        }

        //Controls
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            Layout.fillHeight: true
            spacing: 10
            Layout.rowSpan: 3

            Controls.Button {
                id: btnPrev
                icon.name: "media-skip-backward"
                Layout.alignment: Qt.AlignVCenter
                onClicked: previousTrack()
            }

            Controls.Button {
                id: btnPlayePause
                icon.name: player.playing ? "media-playback-pause" : "media-playback-start"

                onClicked: {
                    if (player.playing) {
                        player.pause();
                    } else {
                        player.play();
                    }
                }
            }

            Controls.Button {
                id: btnNext
                icon.name: "media-skip-forward"

                onClicked: nextTrack()
            }

            Controls.Button {
                id: btnToggleSize
                icon.name: maximised ? "go-down" : "go-up"

                onClicked: {
                    maximised = !maximised
                }
            }
        }

        Controls.Label {
            text: currentArtist
            color: "white"
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: minHeight / 3
        }
        Controls.Slider {
            id: sldPosition
            Layout.fillWidth: true
            enabled: false
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredHeight: minHeight / 3
        }
        Item {
            Layout.columnSpan: 2
            Layout.rowSpan: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: !maximised
        }

        ListView {
            id: lvPLaylist
            Layout.columnSpan: 2
            Layout.rowSpan: 2
            Layout.fillHeight: true
            Layout.fillWidth: true
            visible: maximised
            model: playlist

            delegate: Controls.ItemDelegate {
                width: parent.width
                height: 40 + txtTitle.height

                highlighted: index === mediaplayer.currentIndex

                onClicked: {
                    playFile(index);
                }

                contentItem:  RowLayout {
                    anchors.margins: 10
                    anchors.fill: parent
                    Controls.Label {
                        id: txtTitle
                        text: title
                        color: "white"
                        font.bold: highlighted
                        Layout.preferredWidth: parent.width * 0.5
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Controls.Label {
                        id: txtArtist
                        text: artist
                        color: "white"
                        font.bold: highlighted
                        Layout.preferredWidth: parent.width * 0.3
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }



    ListModel {
        id: playlist
    }

    function replaceAlbum(albumId) {
        doRequest(buildSubsonicUrl("getAlbum?id=" + albumId), "GET", postReplaceAlbum );
    }
    
    function addAlbum(albumId) {
        doRequest(buildSubsonicUrl("getAlbum?id=" + albumId), "GET", postAddAlbum );
    }

    function playFile(index) {
        console.log(index);
        if (playlist.count === 0 || index >= playlist.count) {
            console.log("Index out of range");
            return;
        }

        currentIndex = index;

        var song = playlist.get(index);
        currentArtist = song.artist;
        currentTitle = song.title;
        var url = buildSubsonicUrl("stream?id=" + song.songid)
        console.log(url);

        sldPosition.to = song.duration
        player.source = url;
        player.play()
    }

    function nextTrack() {
        console.log(currentIndex, playlist.count);
        if (currentIndex < (playlist.count - 1)) {
            currentIndex++;
            playFile(currentIndex);
        }
    }

    function previousTrack() {
        console.log(currentIndex, playlist.count);

        if (currentIndex > 0) {
            currentIndex--;
            playFile(currentIndex);
        }
    }

    function postReplaceAlbum(xhr) {
        playlist.clear();
        parseAlbum(xhr);
        playFile(0)
    }

    function postAddAlbum(xhr) {
        parseAlbum(xhr);
    }

    function parseAlbum(xhr) {
        console.log(xhr.response);
        var res = xhr.responseXML;
        console.log(xhr.responseType, xhr.responseText);


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
        } else {
            console.log("Get album list failed");
        }
    }
}
