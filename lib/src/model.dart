library flutter_mpmediaplayer;

enum AuthorizationStatus { notDetermined, denied, restricted, authorized }

class PlayedSong {
  final String title;
  final String artist;
  final String? album;
  final DateTime lastPlayedDate;

  const PlayedSong(this.title,
      {required this.artist, this.album, required this.lastPlayedDate});

  PlayedSong.fromJson(dynamic json)
      : title = json['title'] as String,
        artist = json['artist'] as String,
        album = json['album'] as String?,
        lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(
            (json['lastPlayedDate'] as num).truncate());
}
