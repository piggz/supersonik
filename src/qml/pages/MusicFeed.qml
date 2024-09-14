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
    title: i18n("Album List")

    property int _columns: Math.floor(musicpage.width / 256)
    property int _albumWidth: ((musicpage.width - _columns * 2) - 32) / _columns
    property int _albumHeight: _albumWidth * 1.2

    GridView {
        model: xmlModel
        delegate: albumDelegate
        anchors.fill: parent
        cellWidth: _albumWidth + 2;
        cellHeight: _albumHeight + 2
    }

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

    XmlListModel {
        id: xmlModel
        query: "/subsonic-response/albumList/album"

        XmlListModelRole { name: "title"; attributeName: "title" }
        XmlListModelRole { name: "artist"; attributeName: "artist" }
        XmlListModelRole { name: "year"; attributeName: "year" }
        XmlListModelRole { name: "coverArt"; attributeName: "coverArt" }
        XmlListModelRole { name: "albumid"; attributeName: "id" }

    }


    Component.onCompleted: {
        console.log("Get albun list");
        xmlModel.source = buildSubsonicUrl("getAlbumList?type=alphabeticalByName&size=100");
        xmlModel.reload();
    }

    function parseAlbumList(xhr) {
        console.log(xhr.response);
        var doc = xhr.responseXML;
        console.log(xhr.responseType, xhr.responseText, doc.documentElement.tagName, doc.documentElement.attributes.length);

        if (attributeValue(doc.documentElement, "status") === "ok") {
            console.log("Get album list Ok");

        } else {
            console.log("Get album list failed");
        }
    }
}
