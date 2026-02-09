import QtQuick 2.15
import QtQuick.Controls 2.15 as Controls
import org.kde.kirigami 2.20 as Kirigami

Kirigami.Card {

    property string _genreName
    property int _songCount
    property int _albumCount

    signal openGenre(url: string)

    Behavior on height { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }
    Behavior on width { NumberAnimation { easing.type: Easing.InOutQuad; duration: 200 } }

    actions: [
        Kirigami.Action {
            icon.name: "library-music-symbolic"
            text: qsTr("Play")
            displayHint: Kirigami.DisplayHint.IconOnly
            onTriggered: {
               openGenre(_genreName)
            }
        }
    ]
    banner {
        source: Qt.resolvedUrl("../pics/genre.png")
    }
    contentItem: Controls.Label {
        wrapMode: Text.NoWrap
        elide: Text.ElideRight
        text: _genreName
    }

    onHeightChanged: {
        if (GridView.isCurrentItem) {
            setCellHeight(height);
        }
    }
}
