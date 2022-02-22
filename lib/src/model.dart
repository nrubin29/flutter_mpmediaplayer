library flutter_mpmediaplayer;

enum AuthorizationStatus { notDetermined, denied, restricted, authorized }

class Song {
  final String title;
  final String artist;
  final String? album;

  const Song(this.title, {required this.artist, this.album});

  Song.fromJson(dynamic json)
      : title = json['title'] as String,
        artist = json['artist'] as String,
        album = json['album'] as String?;
}

class PlayedSong extends Song {
  final DateTime lastPlayedDate;

  const PlayedSong(String title,
      {required String artist, String? album, required this.lastPlayedDate})
      : super(title, artist: artist, album: album);

  PlayedSong.fromJson(dynamic json)
      : lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(
            (json['lastPlayedDate'] as num).truncate()),
        super.fromJson(json);
}

class Playlist {
  final String title;

  const Playlist(this.title);

  Playlist.fromJson(dynamic json) : title = json['title'] as String;
}
