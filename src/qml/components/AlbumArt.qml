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

    function downloadComplete(xhr, callback, albumid, extension) {
        if(!extension) {
            var contenttype = xhr.getResponseHeader("content-type")
            if(contenttype == "image/jpeg") {
                extension = "jpg"
            }
        }

        if(extension) {
            var filename = xhr.param + "." + extension
            if (FileIO.write(filename, xhr.response)) {
                callback(albumid, "file:" + FileIO.filePath(filename))
            } else {
                showMessage("Error saving " + filename);
            }
        }
    }

    function getUrlExtension( url ) {
        return url.split(/[#?]/)[0].split('.').pop().trim();
    }

    function onLastFmCoverArtResponse(artist, album, imageSize, response, callback, albumid) {
        var elements = []
        getElementsByTagName(response, "image", elements)
        for(var i = 0; i < elements.length; i++) {
            if(elements[i].attributes[0].name === "size" && elements[i].attributes[0].value === imageSize && elements[i].childNodes[0]) {
                var url = elements[i].childNodes[0].nodeValue
                var extension = getUrlExtension(url)

                var xhr = new XMLHttpRequest()
                xhr.param = FileIO.makeFilename(artist + "_" + album)
                xhr.responseType = "arrayBuffer"
                xhr.onreadystatechange = (function (response) {
                    return function () {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            downloadComplete(xhr, callback, albumid, extension)
                        }
                    }
                })(xhr)
                xhr.open("GET", url, true)
                xhr.send('')
            }
        }
    }
    
    function fetchLastFmCoverArtUrl(artist, album, albumid, callback) {
        var xhr = new XMLHttpRequest()
        const apiKey = "3e7c3f82073cfd0317d71eab70657d7e";
        const imageSize = "mega";
        const method = "album.getinfo";
        const request = "http://ws.audioscrobbler.com/2.0/?method=" + method + "&api_key=" + apiKey + "&artist=" + artist.replace(" ", "%20") + "&album=" + album.replace(" ", "%20");

        xhr.onreadystatechange = (function (response) {
            return function () {
                if (xhr.readyState === XMLHttpRequest.DONE && xhr.responseXML) {
                    onLastFmCoverArtResponse(artist, album, imageSize, xhr.responseXML.documentElement, callback, albumid)
                }
            }
        })(xhr)
        xhr.open("GET", request, true)
        xhr.send('')

        return ""
    }

    function getAlbumArtUrl(coverArt, artist, album, albumid, callback) {
        var url = Qt.resolvedUrl("../pics/cassette.png")
        
        var cached_url = FileIO.findFilePath(FileIO.makeFilename(artist + "_" + album))

        if(cached_url) {
            url = "file:" + cached_url
        }
        else if(coverArt) {
            url = buildSubsonicUrl("getCoverArt?id=" + coverArt)

            var xhr = new XMLHttpRequest()
            xhr.param = FileIO.makeFilename(artist + "_" + album)
            xhr.responseType = "arrayBuffer"
            xhr.onreadystatechange = (function (response) {
                return function () {
                    if (xhr.readyState === XMLHttpRequest.DONE) {
                        downloadComplete(xhr, callback, albumid, null)
                    }
                }
            })(xhr)
            xhr.open("GET", url, true)
            xhr.send('')
        }
        else if(callback) {
            fetchLastFmCoverArtUrl(artist, album, albumid, callback)
        }

        return new URL(url)
    }
}
