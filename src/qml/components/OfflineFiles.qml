import QtQuick 2.15
import QtQuick.LocalStorage

import uk.co.piggz 1.0


Item {
    id: offlineFiles
    property alias albumModel: albumModel

    ListModel {
        id: downloadQueue;
    }

    ListModel {
        id: albumModel
    }

    Component.onCompleted: {
        openDatabase();
        loadOfflineAlbums();
    }

    function downloadAlbum(albumId) {
        console.log("downloadAlbum", albumId);
        doRequest(buildSubsonicUrl("getAlbum?id=" + albumId), "GET", parseAlbum);
    }

    function addDownload(id, suffix, name, albumId, albumName, artistId, artistName, coverArt, duration, year) {
        console.log("addDownload", id);

        let item = {
            id: id,
            suffix: suffix,
            name: name,
            albumId: albumId,
            albumName: albumName,
            artistId: artistId,
            artistName: artistName,
            coverArt: coverArt,
            duration: duration,
            year: year
        }
        downloadQueue.append(item);
        doRequest(root.buildSubsonicUrl("download?id=" + id), "GET", downloadComplete, id + "." + suffix, "arrayBuffer");
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
                        addDownload(attributeValue(song, "id"), attributeValue(song, "suffix"), attributeValue(song, "title"),
                                    attributeValue(song, "albumId"), attributeValue(song, "album"),
                                    attributeValue(song, "artistId"), attributeValue(song, "artist"),
                                    attributeValue(song, "coverArt"), attributeValue(song, "duration"),
                                    attributeValue(song, "year"));
                    }

                }
            }

            console.log("Parsed album....");
        } else {
            console.log("Get album failed");
        }
    }

    function downloadComplete(xhr) {
        console.log("downloadComplete:", xhr.param);

        if (FileIO.write(xhr.param, xhr.response)) {
            var found = false;
            var rec;
            for( var i = 0; i < downloadQueue.rowCount(); i++ ) {
                rec = downloadQueue.get(i);
                if ((rec.id + "." + rec.suffix) == xhr.param) {
                    found = true;
                    break;
                }
            }
            if (!found || !addRecord(rec)) {
                //Unable to add record so remove file
                FileIO.rm(xhr.param);
                showMessage("Error saving details for " + xhr.param);
            } else {
                showMessage("Saved " + rec.name);
            }
        } else {
            showMessage("Error saving " + xhr.param);
        }
    }

    function addRecord(rec) {
        console.log("Adding record:", rec.id);
        var db = openDatabase();
        var success = true;

        try {
            db.transaction(function (tx) {
                tx.executeSql('INSERT INTO tracks(id, suffix, name, albumId, albumName, artistId, artistName, coverArt, duration, year) VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?);',
                              [rec.id, rec.suffix, rec.name, rec.albumId, rec.albumName, rec.artistId, rec.artistName, rec.coverArt, rec.duration, rec.year]);

            })
        } catch (err) {
            console.log("Error adding track in table: " + err)
            success = false;
        };
        return success;
    }

    function songs(albumId) {
        console.log("Loading offline songs", albumId);
        var db = openDatabase();
        var songs = [];

        try {
            db.transaction(function (tx) {
                var rs = tx.executeSql('SELECT id, name, albumId, albumName, artistId, artistName, coverArt, suffix, duration, year from tracks WHERE albumId=?', [albumId]);

                for (var i = 0; i < rs.rows.length; i++) {
                    songs.push(rs.rows.item(i));
                }
            })
        } catch (err) {
            console.log("Error loading offline albums: " + err)
        };
        return songs;
    }

    function loadOfflineAlbums() {
        console.log("Loading offline albums");
        var db = openDatabase();

        try {
            db.transaction(function (tx) {
                var rs = tx.executeSql('SELECT albumId, albumName, min(artistName) as artistName, min(coverArt) as coverArt from tracks GROUP BY albumId, albumName');

                albumModel.clear();

                for (var i = 0; i < rs.rows.length; i++) {
                    albumModel.append({"title": rs.rows.item(i).albumName, "artist": rs.rows.item(i).artistName,
                                                              "year": "","albumid": rs.rows.item(i).albumId,
                                                              "coverArt": rs.rows.item(i).coverArt, "starred": ""});
                }
            })
        } catch (err) {
            console.log("Error loading offline albums: " + err)
        };
    }

    function openDatabase() {
        var db = LocalStorage.openDatabaseSync("supersonik", "1.0", "Supersonik Offline DB", 1000000);

        try {
            db.transaction(function (tx) {
                tx.executeSql('CREATE TABLE IF NOT EXISTS tracks (id text unique, name text, suffix text, albumId text, albumName text, artistId text, artistName text, coverArt text, duration integer, year text);')
            })
        } catch (err) {
            console.log("Error creating table in database: " + err)
        };
        return db;
    }
}
