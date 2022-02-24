import Flutter
import MediaPlayer

private struct PlayedSong : Encodable {
    let title: String
    let artist: String
    let album: String?
    let lastPlayedDate: Date
}

private struct Song : Encodable {
    let title: String
    let artist: String
    let album: String?
    let playbackDuration: Double
    let artwork: String?
}

private struct Album : Encodable {
    let id: String
    let title: String
    let artist: String
    let artwork: String?
}

private struct FullAlbum : Encodable {
    let id: String
    let title: String
    let artist: String
    let artwork: String?
    let tracks: [Song]
}

private struct Artist : Encodable {
    let id: String
    let name: String
    let artwork: String?
}

private struct Playlist : Encodable {
    let id: String
    let title: String
}

private struct SearchRequest {
    let query: String?
    let artistId: MPMediaEntityPersistentID?
    let limit: Int
    let page: Int
    
    init?(_ arguments: Any?) {
        guard let args = arguments as? [String: Any], let query = args["query"] as? String?, let artistId = args["artistId"] as? String?, let limit = args["limit"] as? Int, let page = args["page"] as? Int else {
            return nil
        }
        
        self.query = query
        self.limit = limit
        self.page = page
        
        if let artistId = artistId {
            self.artistId = MPMediaEntityPersistentID(artistId)
        } else {
            self.artistId = nil
        }
    }
}

extension Array {
    func getPage(_ limit: Int, _ page: Int) -> ArraySlice<Element> {
        return self[(page - 1) * limit..<Swift.min(page * limit, count)]
    }
}

extension MPMediaItem {
    var artworkData: String? {
        get {
            return artwork?.image(at: CGSize(width: 300, height: 300))?.pngData()?.base64EncodedString()
        }
    }
}

public class SwiftFlutterMPMediaPlayerPlugin: NSObject, FlutterPlugin {
    private static let jsonEncoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .millisecondsSince1970
        return encoder
    }()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_mpmediaplayer", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterMPMediaPlayerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard #available(iOS 9.3, *) else {
            result(FlutterError(code: "UNAVAILABLE", message: "FlutterMPMediaPlayer requires iOS 9.3 or later", details: nil))
            return
        }
        
        if call.method == "authorize" {
            MPMediaLibrary.requestAuthorization { status in
                result(status.rawValue)
            }
            
            return
        }

        else if call.method == "authorizationStatus" {
            result(MPMediaLibrary.authorizationStatus().rawValue)

            return
        }
        
        else if call.method == "getAlbum" {
            guard let args = call.arguments as? [String: Any], let id = args["id"] as? String else {
                result(FlutterError(code: "BAD_CALL", message: "Bad call", details: nil))
                return
            }
            
            let query = MPMediaQuery.albums()
            query.addFilterPredicate(MPMediaPropertyPredicate(value: MPMediaEntityPersistentID(id), forProperty: MPMediaItemPropertyAlbumPersistentID, comparisonType: .equalTo))
            
            let mpAlbum = query.collections!.first!.representativeItem!
            let mpTracks = query.items!
            
            let tracks = mpTracks.map {item in Song(title: item.title!, artist: item.artist!, album: item.albumTitle!, playbackDuration: item.playbackDuration, artwork: item.artworkData)}
            
            let album = FullAlbum(id: String(mpAlbum.albumPersistentID), title: mpAlbum.albumTitle!, artist: mpAlbum.artist!, artwork: mpAlbum.artworkData, tracks: tracks)
            
            let jsonData = try! SwiftFlutterMPMediaPlayerPlugin.jsonEncoder.encode(album)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            result(jsonString)
            
            return
        }
        
        else if call.method == "getPlaylistSongs" {
            guard let request = SearchRequest(call.arguments) else {
                result(FlutterError(code: "BAD_CALL", message: "Bad call", details: nil))
                return
            }
            
            let query = MPMediaQuery.playlists()
            query.addFilterPredicate(MPMediaPropertyPredicate(value: MPMediaEntityPersistentID(request.query!), forProperty: MPMediaPlaylistPropertyPersistentID, comparisonType: .equalTo))
            
            let items = query.items!.getPage(request.limit, request.page).map { item in
                Song(title: item.title!, artist: item.artist!, album: item.albumTitle!, playbackDuration: item.playbackDuration, artwork: item.artworkData)
            }
            
            let jsonData = try! SwiftFlutterMPMediaPlayerPlugin.jsonEncoder.encode(items)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            result(jsonString)
            
            return
        }
        
        else if call.method == "searchSongs" {
            guard let request = SearchRequest(call.arguments) else {
                result(FlutterError(code: "BAD_CALL", message: "Bad call", details: nil))
                return
            }
            
            let query = MPMediaQuery.songs()
            
            if let queryString = request.query {
                query.addFilterPredicate(MPMediaPropertyPredicate(value: queryString, forProperty: MPMediaItemPropertyTitle, comparisonType: .contains))
            }
            
            if let artistId = request.artistId {
                query.addFilterPredicate(MPMediaPropertyPredicate(value: artistId, forProperty: MPMediaItemPropertyArtistPersistentID, comparisonType: .equalTo))
            }
            
            let items = query.items!.getPage(request.limit, request.page).filter { item in
                item.title != nil && item.artist != nil
            }.map { item in
                Song(title: item.title!, artist: item.artist!, album: item.albumTitle, playbackDuration: item.playbackDuration, artwork: item.artworkData)
            }
            
            let jsonData = try! SwiftFlutterMPMediaPlayerPlugin.jsonEncoder.encode(items)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            result(jsonString)
            
            return
        }
        
        else if call.method == "searchAlbums" {
            guard let request = SearchRequest(call.arguments) else {
                result(FlutterError(code: "BAD_CALL", message: "Bad call", details: nil))
                return
            }
            
            let query = MPMediaQuery.albums()
            
            if let queryString = request.query {
                query.addFilterPredicate(MPMediaPropertyPredicate(value: queryString, forProperty: MPMediaItemPropertyAlbumTitle, comparisonType: .contains))
            }
            
            if let artistId = request.artistId {
                query.addFilterPredicate(MPMediaPropertyPredicate(value: artistId, forProperty: MPMediaItemPropertyArtistPersistentID, comparisonType: .equalTo))
            }
            
            let items = query.collections!.getPage(request.limit, request.page).map { item -> Album in
                let repItem = item.representativeItem!
                return Album(id: String(repItem.albumPersistentID), title: repItem.albumTitle!, artist: repItem.artist!, artwork: repItem.artworkData)
            }
            
            let jsonData = try! SwiftFlutterMPMediaPlayerPlugin.jsonEncoder.encode(items)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            result(jsonString)
            
            return
        }
        
        else if call.method == "searchArtists" {
            guard let request = SearchRequest(call.arguments) else {
                result(FlutterError(code: "BAD_CALL", message: "Bad call", details: nil))
                return
            }
            
            let query = MPMediaQuery.artists()
            query.addFilterPredicate(MPMediaPropertyPredicate(value: request.query, forProperty: MPMediaItemPropertyArtist, comparisonType: .contains))
            
            let items = query.collections!.getPage(request.limit, request.page).map { item -> Artist in
                let repItem = item.representativeItem!
                return Artist(id: String(repItem.artistPersistentID), name: repItem.artist!, artwork: repItem.artworkData)
            }
            
            let jsonData = try! SwiftFlutterMPMediaPlayerPlugin.jsonEncoder.encode(items)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            result(jsonString)
            
            return
        }
        
        else if call.method == "searchPlaylists" {
            guard let request = SearchRequest(call.arguments) else {
                result(FlutterError(code: "BAD_CALL", message: "Bad call", details: nil))
                return
            }
            
            let query = MPMediaQuery.playlists()
            query.addFilterPredicate(MPMediaPropertyPredicate(value: request.query, forProperty: MPMediaPlaylistPropertyName, comparisonType: .contains))
            
            let items = query.collections!.getPage(request.limit, request.page).map { item in Playlist(id: String(item.value(forProperty: MPMediaPlaylistPropertyPersistentID) as! MPMediaEntityPersistentID), title: item.value(forProperty: MPMediaPlaylistPropertyName)! as! String) }
            
            let jsonData = try! SwiftFlutterMPMediaPlayerPlugin.jsonEncoder.encode(items)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            result(jsonString)
            
            return
        }
        
        else if call.method == "getRecentTracks" {
            var after: Date?
            
            if let args = call.arguments as? [String: Any], let afterMillis = args["after"] as? Double {
                after = Date(timeIntervalSince1970: afterMillis / 1000)
            }
            
            let query = MPMediaQuery.songs()
            
            let items = query.items!.filter { item in
                item.title != nil && item.artist != nil && item.lastPlayedDate != nil && (after == nil || item.lastPlayedDate! > after!)
            }.sorted { a, b in
                a.lastPlayedDate!.compare(b.lastPlayedDate!) == .orderedDescending
            }.map { item in
                PlayedSong(title: item.title!, artist: item.artist!, album: item.albumTitle, lastPlayedDate: item.lastPlayedDate!)
            }
            
            let jsonData = try! SwiftFlutterMPMediaPlayerPlugin.jsonEncoder.encode(items)
            let jsonString = String(data: jsonData, encoding: .utf8)!
            result(jsonString)
            
            return
        }
    }
}
