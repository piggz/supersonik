// Includes relevant modules used by the QML
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import org.kde.kirigami as Kirigami
import uk.co.piggz 1.0
import uk.co.piggz.supersonik

Item {
    id: albumArt

    function getElementsByTagName(rootElement, tagName, elements) {
        var childNodes = rootElement.childNodes;
        for(var i = 0; i < childNodes.length; i++) {
            if(childNodes[i].nodeName === tagName) {
                elements.push(childNodes[i]);
            }
            if(childNodes[i].childNodes.length > 0) {
                getElementsByTagName(childNodes[i], tagName, elements)    
            }
        }
        return elements;
    }

    function downloadComplete(xhr) {
        console.log("downloadComplete:", xhr.param);

        if (FileIO.write(xhr.param, xhr.response)) {

        } else {
            showMessage("Error saving " + xhr.param);
        }
    }

    function onLastFmCoverArtResponse(artist, album, imageSize, response) {
        var elements = []
        getElementsByTagName(response, "image", elements)
        for(var i = 0; i < elements.length; i++) {
            if(elements[i].attributes[0].name === "size" && elements[i].attributes[0].value === imageSize) {
                var url = elements[i].childNodes[0].nodeValue

                doRequest(url, "GET", downloadComplete, artist + "_" + album + ".jpg", "arrayBuffer");
            }
        }
    }
    
    function fetchLastFmCoverArtUrl(artist, album, albumid) {
        var xhr = new XMLHttpRequest()
        const apiKey = "4b724a8d125b0c56965ad3e28a51530c";
        const imageSize = "large";
        const method = "album.getinfo";
        const request = "http://ws.audioscrobbler.com/2.0/?method=" + method + "&api_key=" + apiKey + "&artist=" + artist.replace(" ", "%20") + "&album=" + album.replace(" ", "%20");

        xhr.onreadystatechange = (function (response) {
            return function () {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    onLastFmCoverArtResponse(artist, album, imageSize, xhr.responseXML.documentElement)
                }
            }
        })(xhr)
        xhr.open("GET", request, true)
        xhr.send('')

        return ""
    }

    function getAlbumArtUrl(coverArt, artist, album, albumid) {
        var url = Qt.resolvedUrl("../pics/cassette.png")
        if(coverArt) {
            url = buildSubsonicUrl("getCoverArt?id=" + coverArt)
        }
        else if(FileIO.filePath(artist + "_" + album + ".jpg")) {
            url = "file:" + FileIO.filePath(artist + "_" + album + ".jpg")
        }
        else {
            fetchLastFmCoverArtUrl(artist, album, albumid)
        }

        return url 
    }
}