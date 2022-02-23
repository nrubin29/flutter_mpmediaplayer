library flutter_mpmediaplayer;

import 'dart:convert';
import 'dart:typed_data';

Uint8List? _decodeData(String? data) =>
    data == null ? null : base64Decode(data);

enum AuthorizationStatus { notDetermined, denied, restricted, authorized }

class Song {
  final String title;
  final String artist;
  final String? album;
  final Uint8List? artwork;

  const Song(this.title, {required this.artist, this.album, this.artwork});

  Song.fromJson(dynamic json)
      : title = json['title'] as String,
        artist = json['artist'] as String,
        album = json['album'] as String?,
        artwork = _decodeData(json['artwork'] as String?);
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

class Album {
  final String title;
  final String artist;
  final Uint8List? artwork;

  const Album(this.title, {required this.artist, this.artwork});

  Album.fromJson(dynamic json)
      : title = json['title'] as String,
        artist = json['artist'] as String,
        artwork = _decodeData(json['artwork'] as String?);
}

class Playlist {
  final String title;

  const Playlist(this.title);

  Playlist.fromJson(dynamic json) : title = json['title'] as String;
}
