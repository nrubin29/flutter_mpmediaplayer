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
  final String? albumArtist;
  final double playbackDuration;
  final Uint8List? artwork;

  Song.fromJson(dynamic json)
      : title = json['title'] as String,
        artist = json['artist'] as String,
        album = json['album'] as String?,
        albumArtist = json['albumArtist'] as String?,
        playbackDuration = double.parse(json['playbackDuration'] as String),
        artwork = _decodeData(json['artwork'] as String?);
}

class PlayedSong extends Song {
  final DateTime lastPlayedDate;

  PlayedSong.fromJson(dynamic json)
      : lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(
            (json['lastPlayedDate'] as num).truncate()),
        super.fromJson(json);
}

class Album {
  final String id;
  final String title;
  final String artist;
  final String artistId;
  final Uint8List? artwork;

  Album.fromJson(dynamic json)
      : title = json['title'] as String,
        id = json['id'] as String,
        artist = json['artist'] as String,
        artistId = json['artistId'] as String,
        artwork = _decodeData(json['artwork'] as String?);
}

class FullAlbum extends Album {
  final List<Song> tracks;

  FullAlbum.fromJson(dynamic json)
      : tracks = (json['tracks'] as List<dynamic>)
            .map(Song.fromJson)
            .toList(growable: false),
        super.fromJson(json);
}

class Artist {
  final String id;
  final String name;
  final Uint8List? artwork;

  Artist.fromJson(dynamic json)
      : name = json['name'] as String,
        id = json['id'] as String,
        artwork = _decodeData(json['artwork'] as String?);
}

class Playlist {
  final String id;
  final String title;

  Playlist.fromJson(dynamic json)
      : id = json['id'] as String,
        title = json['title'] as String;
}
