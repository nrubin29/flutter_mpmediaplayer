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
  final double playbackDuration;
  final Uint8List? artwork;

  const Song(
    this.title, {
    required this.artist,
    this.album,
    required this.playbackDuration,
    this.artwork,
  });

  Song.fromJson(dynamic json)
      : title = json['title'] as String,
        artist = json['artist'] as String,
        album = json['album'] as String?,
        playbackDuration = json['playbackDuration'] as double,
        artwork = _decodeData(json['artwork'] as String?);
}

class PlayedSong extends Song {
  final DateTime lastPlayedDate;

  const PlayedSong(
    String title, {
    required String artist,
    String? album,
    required double playbackDuration,
    required this.lastPlayedDate,
  }) : super(title,
            artist: artist, album: album, playbackDuration: playbackDuration);

  PlayedSong.fromJson(dynamic json)
      : lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(
            (json['lastPlayedDate'] as num).truncate()),
        super.fromJson(json);
}

class Album {
  final String id;
  final String title;
  final String artist;
  final Uint8List? artwork;

  const Album(this.title,
      {required this.id, required this.artist, this.artwork});

  Album.fromJson(dynamic json)
      : title = json['title'] as String,
        id = json['id'] as String,
        artist = json['artist'] as String,
        artwork = _decodeData(json['artwork'] as String?);
}

class FullAlbum extends Album {
  final List<Song> tracks;

  const FullAlbum(
    String title, {
    required String id,
    required String artist,
    Uint8List? artwork,
    required this.tracks,
  }) : super(title, id: id, artist: artist, artwork: artwork);

  FullAlbum.fromJson(dynamic json)
      : tracks = (json['tracks'] as List<dynamic>)
            .map(Song.fromJson)
            .toList(growable: false),
        super.fromJson(json);
}

class Artist {
  final String name;
  final Uint8List? artwork;

  const Artist(this.name, {this.artwork});

  Artist.fromJson(dynamic json)
      : name = json['name'] as String,
        artwork = _decodeData(json['artwork'] as String?);
}

class Playlist {
  final String title;

  const Playlist(this.title);

  Playlist.fromJson(dynamic json) : title = json['title'] as String;
}
