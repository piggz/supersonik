// SPDX-FileCopyrightText: 2023 Carl Schwan <carl@carlschwan.eu>
// SPDX-FileCopyrightText: 2023 Adam Pigg <adam@piggz.co.uk>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami
import org.kde.kirigamiaddons.formcard as FormCard
import QtQml.XmlListModel

import uk.co.piggz 1.0

Kirigami.ScrollablePage {
    id: musicpage
    title: pageTitle()

    property string uid: "musicpage"
    property int _albumTargetWidth: 192
    property int _columns: Math.floor(musicpage.width / _albumTargetWidth)
    property int _albumWidth: ((musicpage.width - _columns * 2) - 32) / _columns
    property int _albumHeight: _albumWidth * 1.5
    property int itemsPerPage: 100
    property int totalItems: 0
    property int currentPage: 1
    property string listType: "alphabeticalByName"
    property bool _canPageBackward: currentPage > 1
    property bool _canPageForward: albums.count == itemsPerPage
    property bool _displaySearch: false

    GridView {
        id: grdAlbums
        model: albums
        delegate: albumDelegate
        anchors.fill: parent
        cellWidth: _albumWidth + 2;
        cellHeight: _albumHeight + 2

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
                        placeholderText: "Album Search..."
                    }
                    Controls.ToolButton {
                        id: btnSearch
                        icon.source: "search"
                        onClicked: {
                            searchAlbums(txtSearch.text);
                        }
                    }
                }
            }
        }
    }

    actions: [
        Kirigami.Action {
            icon.name: "search"
            onTriggered: {
                console.log("search");
                _displaySearch = !_displaySearch;
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
            width: _albumWidth
            height: _albumHeight
            Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
            Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

            actions: [
                Kirigami.Action {
                    icon.name: "media-playback-start"
                    onTriggered: {
                        mediaPlayer.replaceAlbum(albumid)
                    }
                },
                Kirigami.Action {
                    icon.name: "media-playlist-append"
                    onTriggered: {
                        mediaPlayer.addAlbum(albumid)
                    }
                }
            ]
            banner {
                source: buildSubsonicUrl("getCoverArt?id=" + coverArt)
                title: title
                titleAlignment: Qt.AlignLeft | Qt.AlignBottom
            }
            contentItem: Controls.Label {
                wrapMode: Text.WordWrap
                text: artist + " - " + year
            }
        }
    }

    ListModel {
        id: albums;
    }


    Component.onCompleted: {
        refresh();
    }

    function pageTitle() {
        if (listType == "alphabeticalByName") {
            return i18n("Albums by Name")
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

    function searchAlbums(text) {
        console.log("Get albun list");
        doRequest(buildSubsonicUrl("search2?query=" + text + "&artistCount=0" + "&songCount=" + itemsPerPage + "&songCount=0" + "&albumOffset=" + (currentPage - 1) * itemsPerPage ), "GET", parseAlbumList );
    }

    function refresh() {
        console.log("Get albun list");
        doRequest(buildSubsonicUrl("getAlbumList2?type=" + listType + "&size=" + itemsPerPage + "&offset=" + (currentPage - 1) * itemsPerPage ), "GET", parseAlbumList );
    }

    function parseAlbumList(xhr) {
        console.log(xhr.response);
        var res = xhr.responseXML;
        console.log(xhr.responseType, xhr.responseText);

        if (attributeValue(res.documentElement, "status") === "ok") {
            console.log("Get album list Ok");
            albums.clear();

            var doc = res.documentElement;
            console.log("xhr length: " + doc.childNodes.length );

            for (var i = 0; i < doc.childNodes.length; ++i) {
                var album = doc.childNodes[i];
                console.log("album length: " + album.nodeName, album.childNodes.length);

                for (var j = 0; j < album.childNodes.length; ++j) {
                    var song = album.childNodes[j];

                    console.log(song.nodeName);
                    if ( song.nodeName ===  "album") {
                        albums.append({"title": attributeValue(song, "title"), "artist": attributeValue(song, "artist"),
                                          "year": attributeValue(song, "year"),"albumid": attributeValue(song, "id"),
                                          "coverArt": attributeValue(song, "coverArt")})
                    }

                }
            }
        } else {
            console.log("Get album failed");
        }
    }
}
