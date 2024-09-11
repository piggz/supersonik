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

    GridView {
        model: xmlModel
        delegate: albumDelegate
        anchors.fill: parent
        cellWidth: 258;
        cellHeight: 320
    }

    Component {
        id: albumDelegate

        Kirigami.Card {
            width: 256
            height: 320
            actions: [
                Kirigami.Action {
                    text: qsTr("Play")
                    icon.name: "media-playback-start"
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
