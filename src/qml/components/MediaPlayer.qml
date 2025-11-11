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
    property int minHeight:(lblTitle.height + lblArtist.height + sldPosition.height + rowButtons.height + 50 )
    color: "#000000"
    opacity: 0.85

    property int currentIndex: -1;
    property bool maximised: false;
    property string currentArtist: ""
    property string currentTitle: ""
    property string currentAlbum: ""
    property string currentYear: ""
    property string currentAlbumArtUrl: ""

    property bool canGoNext: currentIndex < (playlist.count - 1)
    property bool canGoPrevious: currentIndex > 0
    property alias playbackState: player.playbackState
    property alias url: player.source

    //property int minHeight: (btnPrev.height * 4) - 30

    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    QTMM.MediaPlayer {
        id: player
        audioOutput: QTMM.AudioOutput {}

        onPositionChanged: {
            sldPosition.value = player.position / 1000;
        }

        onMediaStatusChanged: {
            if (mediaStatus == QTMM.MediaPlayer.EndOfMedia) {
                nextTrack();
            }
        }

        onDurationChanged: (duration) => {
            sldPosition.to = duration / 1000;
        }
    }

    ColumnLayout {
        id: controlLayout
        anchors.top: parent.top
        anchors.topMargin: 10
        width: parent.width - 20
        height: parent.height
        x: 10
        spacing: 10

        Controls.Label {
            id: lblTitle
            text: currentTitle
            color: "white"
            font.bold: true
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: root.width - 20
            elide: "ElideRight"
        }

        RowLayout {
            Layout.fillWidth: true

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2

                Controls.Label {
                    id: lblArtist
                    text: currentArtist
                    color: "white"
                    font.pointSize: 10
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                }

                Controls.Label {
                    id: lblAlbum
                    text: currentAlbum + (currentYear ? " (" + currentYear + ")" : "")
                    color: "#cccccc"
                    font.pointSize: 9
                    elide: Text.ElideRight
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
                }
            }

            Item { Layout.fillWidth: false; Layout.preferredWidth: 10 }

            Controls.Label {
                id: lblTime
                text: "%1 / %2".arg(formatTime(player.position / 1000)).arg(formatTime(player.duration / 1000))
                color: "white"
                font.bold: true
                horizontalAlignment: Text.AlignRight
                Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                Layout.preferredWidth: parent.width * 0.3
            }
        }

        Controls.Slider {
            id: sldPosition
            Layout.fillWidth: true
            enabled: false
            Layout.alignment: Qt.AlignVCenter
            from: 0
            to: 0
            //Layout.preferredHeight: minHeight / 3

            onMoved: {
                player.position = value * 1000;
            }
        }

        //Controls
        RowLayout {
            id: rowButtons
            Layout.alignment: Qt.AlignVCenter
            //Layout.fillHeight: true
            spacing: 10
            //Layout.rowSpan: 3

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

            Item {
                Layout.fillWidth: true
            }

            Controls.Button {
                id: btnToggleSize
                icon.name: maximised ? "go-down" : "go-up"

                onClicked: {
                    maximised = !maximised
                }
            }
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
            clip: true

            delegate: Controls.ItemDelegate {
                width: parent ? parent.width : 0
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
                        Layout.maximumWidth: parent.width * 0.5
                        elide: "ElideRight"
                        Layout.alignment: Qt.AlignVCenter
                    }
                    Controls.Label {
                        id: txtArtist
                        text: artist
                        color: "white"
                        font.bold: highlighted
                        Layout.preferredWidth: parent.width * 0.3
                        Layout.maximumWidth: parent.width * 0.5
                        elide: "ElideRight"
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }



    ListModel {
        id: playlist
    }

    function play() {
        console.log("MediaPlayer::play");
        player.play();
    }

    function stop() {
        console.log("MediaPlayer::stop");
        player.stop();
    }

    function pause() {
        console.log("MediaPlayer::pause");
        player.pause();
    }

    function playPause() {
        console.log("MediaPlayer::playPause", player.playing);
        if (player.playing) {
            player.pause();
        } else {
            player.play();
        }
    }

    function nextTrack() {
        console.log("MediaPlayer::nextTrack", currentIndex, playlist.count);
        if (currentIndex < (playlist.count - 1)) {
            currentIndex++;
            playFile(currentIndex);
        }
    }

    function previousTrack() {
        console.log("MediaPlayer::previousTrack", currentIndex, playlist.count);

        if (currentIndex > 0) {
            currentIndex--;
            playFile(currentIndex);
        }
    }

    function replaceAlbumOffline(albumId) {
        playlist.clear();
        var songs = offlineFiles.songs(albumId);

        songs.forEach(s => {
                          console.log(s.name, s.artistName, s.id, s.albumId, s.albumName);
                          playlist.append({"title": s.name, "artist": s.artistName,
                                              "songid": s.id, "albumid": s.albumId,
                                              "albumtitle": s.albumName,
                                              "duration": s.duration,
                                              "year": s.year,
                                              "url": "file://" + FileIO.filePath(s.id + "." + s.suffix)})
                      });


        playFile(0)
    }

    function addAlbumOffline(albumId) {
        var songs = offlineFiles.songs(albumId);

        songs.forEach(s => {
                          console.log(s.name, s.artistName, s.id, s.albumId, s.albumName);
                          playlist.append({"title": s.name, "artist": s.artistName,
                                              "songid": s.id, "albumid": s.albumId,
                                              "albumtitle": s.albumName,
                                              "duration": s.duration,
                                              "year": s.year,
                                              "url": "file://" + FileIO.filePath(s.id + "." + s.suffix)})
                      });
    }

    function replaceAlbum(albumId) {
        doRequest(buildSubsonicUrl("getAlbum?id=" + albumId), "GET", postReplaceAlbum );
    }

    function addAlbum(albumId) {
        doRequest(buildSubsonicUrl("getAlbum?id=" + albumId), "GET", postAddAlbum );
    }

    function playRadioUrl(url) {
        console.log(url);
        doRequest(url, "GET", parseRadioPlaylist)
    }

    function parseRadioPlaylist(xhr) {
        console.log(xhr.responseType, xhr.responseText);
        playlist.clear();
        player.stop();

        var lines = xhr.responseText.split('\n');

        var start = false;
        var count = 0;

        var lastFile = "";
        var lastTitle = "";
        var lastDuration = 0;

        for (const line of lines) {
            var tline = line.trim();
            if (tline === '[playlist]') {
                start = true;
            }
            if (start) {
                if (tline.indexOf("=") > 0) {
                    var key = tline.split("=")[0];
                    var value = tline.split("=")[1];
                    console.log(key, value);

                    if (key === "NumberOfEntries") {
                        count = value;
                    }
                    if (key.startsWith("File")) {
                        lastFile = value;
                    }
                    if (key.startsWith("Title")) {
                        lastTitle = value;
                    }
                    if (key.startsWith("Length")) {
                        lastDuration = parseInt(value);
                        console.log("Appending playlist item:", lastTitle, lastFile, lastDuration);
                        playlist.append({"title": lastTitle, "artist": "",
                                            "year": "", "duration": lastDuration,
                                            "songid": 0, "albumid": 0,
                                            "albumtitle": "", "url": lastFile})
                    }
                }
            }
        }

        playFile(0);
    }

    function playFile(index) {
        console.log(index);
        player.stop();
        if (playlist.count === 0 || index >= playlist.count) {
            console.log("Index out of range");
            return;
        }

        currentIndex = index;

        var song = playlist.get(index);
        currentArtist = song.artist;
        currentTitle = song.title;
        currentAlbum = song.albumtitle;
        currentYear = song.year;
        currentAlbumArtUrl = albumArt.getAlbumArtUrl(false, song.albumArtist, currentAlbum, 0, null)

        var url = song.url
        console.log(url);

        sldPosition.to = song.duration
        player.source = url;
        player.play();
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

                if(album.nodeName == "album") {
                    var albumArtist = attributeValue(album, "artist")

                    for (var j = 0; j < album.childNodes.length; ++j) {
                        var song = album.childNodes[j];

                        console.log(song.nodeName);
                        if ( song.nodeName ===  "song") {
                            playlist.append({"title": attributeValue(song, "title"), "artist": attributeValue(song, "artist"),
                                                "albumArtist": albumArtist, "year": attributeValue(song, "year"),
                                                "duration": attributeValue(song, "duration"), "songid": attributeValue(song, "id"),
                                                "albumid": attributeValue(song, "albumId"), "albumtitle": attributeValue(song, "album"),
                                                "url": buildSubsonicUrl("stream?id=" + attributeValue(song, "id"))})
                        }
                    }
                }
            }

            console.log("Parsed album....", playlist.get(0).songid);
        } else {
            console.log("Get album failed");
        }
    }

    function formatTime(seconds) {
        if (isNaN(seconds) || seconds < 0)
            return "0:00";
        var m = Math.floor(seconds / 60);
        var s = Math.floor(seconds % 60);
        return m + ":" + (s < 10 ? "0" + s : s);
    }
}
