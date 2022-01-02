import Flutter
import MediaPlayer

private struct PlayedSong : Encodable {
    let title: String
    let artist: String
    let album: String?
    let lastPlayedDate: Date
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
