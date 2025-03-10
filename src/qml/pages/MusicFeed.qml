// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-FileCopyrightText: 2023 Adam Pigg <adam@piggz.co.uk>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

import uk.co.piggz 1.0

Kirigami.ScrollablePage {
    id: musicpage
    title: pageTitle()

    property string uid: "musicpage"
    property int _columns: musicpage.width > musicpage.height ? 4 : 2
    property int _albumWidth: ((musicpage.width - _columns * 2)) / _columns
    property int _albumHeight: 0
    property int itemsPerPage: 100
    property int totalItems: 0
    property int currentPage: 1
    property string listType: "alphabeticalByName"
    property bool _canPageBackward: currentPage > 1
    property bool _canPageForward: albums.count == itemsPerPage
    property bool _displaySearch: false
    property bool _displayArtist: false

    GridView {
        id: grdAlbums
        model: {
            console.log(_offlineMode);
            if (_offlineMode) {
                return offlineFiles.albumModel
            } else if (_displayArtist) {
                return artists;
            } else {
                return albums;
            }
        }

        delegate: _displayArtist ? artistDelegate : albumDelegate
        anchors.fill: parent
        anchors.bottomMargin: 50
        cellWidth: _albumWidth + 2;
        cellHeight: _albumHeight + 2;

        header: Component {
            Item {
                height: _displaySearch ? txtSearch.height + 20: 0
                width: parent.width - 20

                RowLayout {
                    spacing: 10
                    anchors.fill: parent
                    anchors.margins: 10
                    visible: _displaySearch

                    Controls.TextField {
                        id: txtSearch
                        Layout.fillWidth: true
                        placeholderText: listType === "alphabeticalByArtist" ? "Artist Search..." : "Album Search..."
                    }
                    Controls.ToolButton {
                        id: btnSearch
                        icon.name: "search"
                        onClicked: {
                            if (listType === "alphabeticalByArtist") {
                                searchArtists(txtSearch.text);
                            } else {
                                searchAlbums(txtSearch.text);
                            }
                        }
                    }
                }
            }
        }
        footer: Component {
            Item {
                width: parent.width
                height: mpHeight
            }
        }
    }


    actions: [
        Kirigami.Action {
            icon.name: "search"
            onTriggered: {
                console.log("search");
                if (grdAlbums.atYBeginning) {
                    _displaySearch = !_displaySearch;
                }
                if (_displaySearch) {
                    grdAlbums.positionViewAtBeginning()
                }
            }
        },
        Kirigami.Action {
            icon.name: "go-previous"
            enabled: _canPageBackward
            onTriggered: {
                if (currentPage > 1) {
                    currentPage--;
                    refresh();
                }
            }
        },
        Kirigami.Action {
            displayComponent: Controls.Label { text: currentPage }
        },
        Kirigami.Action {
            icon.name: "go-next"
            enabled: _canPageForward
            onTriggered: {
                currentPage++;
                refresh();
            }
        }
    ]

    Component {
        id: albumDelegate

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
    }

    Component {
        id: artistDelegate

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
    }

    ListModel {
        id: albums;
    }

    ListModel {
        id: artists;
    }

    Component.onCompleted: {
        refresh();
    }

    function setCellHeight(h) {
        if (Math.floor(h) != _albumHeight) {
            _albumHeight = Math.floor(h);
            grdAlbums.forceLayout();
        }
    }

    function pageTitle() {
        if (listType == "alphabeticalByName") {
            if (_offlineMode) {
                return i18n("Albums by Name (offline)")
            } else {
                return i18n("Albums by Name")
            }
        }
        if (listType == "alphabeticalByArtist") {
            return i18n("Albums by Artist")
        }
        if (listType == "random") {
            return i18n("Random Albums")
        }
        if (listType == "starred") {
            return i18n("Favorite Albums")
        }
        if (listType == "newest") {
            return i18n("Latest Albums")
        }
        if (listType == "highest") {
            return i18n("Top Rated Albums")
        }
        if (listType == "frequent") {
            return i18n("Frequently Played Albums")
        }
    }

    function switchViewType(viewType) {
        if (viewType !== listType) {
            currentPage = 1;
            listType = viewType;
            refresh();
        }
    }

    function searchArtists(text) {
        console.log("searchArtists");
        doRequest(buildSubsonicUrl("search3?query=" + text + "&albumCount=0" + "&artistCount=" + itemsPerPage + "&songCount=0" + "&artistOffset=" + (currentPage - 1) * itemsPerPage ), "GET", parseArtists );
    }

    function searchAlbums(text) {
        console.log("searchAlbums");
        doRequest(buildSubsonicUrl("search3?query=" + text + "&artistCount=0" + "&albumCount=" + itemsPerPage + "&songCount=0" + "&albumOffset=" + (currentPage - 1) * itemsPerPage ), "GET", parseAlbumList );
    }

    function loadArtistAlbums(artistId) {
        console.log("loadArtistAlbums");
        doRequest(buildSubsonicUrl("getArtist?id=" + artistId), "GET", parseAlbumList );
    }

    function refresh() {
        console.log("refresh");
        doRequest(buildSubsonicUrl("getAlbumList2?type=" + listType + "&size=" + itemsPerPage + "&offset=" + (currentPage - 1) * itemsPerPage ), "GET", parseAlbumList );
    }

    function starAlbum(albumId) {
        console.log("starAlbum", albumId);
        doRequest(buildSubsonicUrl("star?albumId=" + albumId),  "GET", parseStar, albumId );
    }

    function unStarAlbum(albumId) {
        console.log("starAlbum", albumId);
        doRequest(buildSubsonicUrl("unstar?albumId=" + albumId),  "GET", parseUnStar, albumId );
    }

    function parseAlbumList(xhr) {
        console.log(xhr.response);
        var res = xhr.responseXML;
        console.log(xhr.responseType, xhr.responseText);
        _displayArtist = false;

        if (attributeValue(res.documentElement, "status") === "ok") {
            console.log("Get album list Ok");
            albums.clear();
            artists.clear();

            var doc = res.documentElement;
            console.log("xhr length: " + doc.childNodes.length );

            for (var i = 0; i < doc.childNodes.length; ++i) {
                var album = doc.childNodes[i];
                console.log("album length: " + album.nodeName, album.childNodes.length);

                for (var j = 0; j < album.childNodes.length; ++j) {
                    var song = album.childNodes[j];

                    console.log(song.nodeName);
                    if ( song.nodeName ===  "album") {
                        var title = attributeValue(song, "title")
                        if(!title) {
                            title = attributeValue(song, "name")
                        }
                        var coverArt = attributeValue(song, "coverArt")
                        var artist = attributeValue(song, "artist")
                        var albumid = attributeValue(song, "id")
                        albums.append({"title": title, "artist": artist,
                                          "year": attributeValue(song, "year"),"albumid": albumid,
                                          "coverArt": attributeValue(song, "coverArt"), "starred": attributeValue(song, "starred"),
                                          "artUrl": albumArt.getAlbumArtUrl(coverArt, artist, title, albumid, updateAlbumArt)})
                    }

                }
            }
        } else {
            console.log("Get album failed");
        }
    }

    function parseArtists(xhr) {
        console.log(xhr.response);
        var res = xhr.responseXML;
        console.log(xhr.responseType, xhr.responseText);
        _displayArtist = true;

        if (attributeValue(res.documentElement, "status") === "ok") {
            console.log("Get artist list Ok");
            artists.clear();
            albums.clear();

            var doc = res.documentElement;
            console.log("xhr length: " + doc.childNodes.length );

            for (var i = 0; i < doc.childNodes.length; ++i) {
                var results = doc.childNodes[i];
                console.log("result length: " + results.nodeName, results.childNodes.length);

                for (var j = 0; j < results.childNodes.length; ++j) {
                    var artist = results.childNodes[j];

                    console.log(artist.nodeName);
                    if ( artist.nodeName ===  "artist") {
                        artists.append({"name": attributeValue(artist, "name"),
                                           "artistImage": attributeValue(artist, "artistImageUrl"),"artistId": attributeValue(artist, "id"),
                                           "coverArt": attributeValue(artist, "coverArt")})
                    }
                }
            }
        } else {
            console.log("Get album failed");
        }
    }

    function parseStar(xhr) {
        console.log(xhr.response, xhr.param);

        var res = xhr.responseXML;
        var albumId = xhr.param;

        if (!albumId) {
            console.log("No albumId in repsonse");
            return;
        }

        if (attributeValue(res.documentElement, "status") !== "ok") {
            console.log("Album", xhr.param, "star failed");

            for( var i = 0; i < albums.rowCount(); i++ ) {
                console.log( albums.get(i).albumid,  albums.get(i).starred);
                if (albums.get(i).albumid === albumId) {
                    albums.setProperty(i, "starred", false);
                }
            }
        }
    }


    function parseUnStar(xhr) {
        console.log(xhr.response, xhr.param);

        var res = xhr.responseXML;
        var albumId = xhr.param;

        if (!albumId) {
            console.log("No albumId in repsonse");
            return;
        }

        if (attributeValue(res.documentElement, "status") !== "ok") {
            console.log("Album", xhr.param, "unstar failed");

            for( var i = 0; i < albums.rowCount(); i++ ) {
                console.log( albums.get(i).albumid,  albums.get(i).starred);
                if (albums.get(i).albumid === albumId) {
                    albums.setProperty(i, "starred", "true");
                }
            }
        }
    }

    function updateAlbumArt(albumId, newArtUrl) {
        for( var i = 0; i < albums.rowCount(); i++ ) {
            if (albums.get(i).albumid === albumId) {
                albums.setProperty(i, "artUrl", newArtUrl);
            }
        }
    }
}
