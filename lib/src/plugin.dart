library flutter_mpmediaplayer;

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

class FlutterMPMediaPlayer {
  static const _channel = MethodChannel('flutter_mpmediaplayer');

  /// Asks for the user's permission to access their music library.
  ///
  /// If the user hasn't granted permission yet, a popup will be displayed. On
  /// subsequent calls, the popup won't be displayed. This method will always
  /// return the latest authorization status and can be called multiple times.
  static Future<AuthorizationStatus> authorize() async {
    final response = await _channel.invokeMethod<int>('authorize');

    if (response == null) {
      throw PlatformException(code: "NULL_RESPONSE");
    }

    return AuthorizationStatus.values[response];
  }

  /// Returns whether the app can access the user's media library.
  ///
  /// Use [authorize] to request access.
  static Future<AuthorizationStatus> get authorizationStatus async {
    final response = await _channel.invokeMethod<int>('authorizationStatus');

    if (response == null) {
      throw PlatformException(code: "NULL_RESPONSE");
    }

    return AuthorizationStatus.values[response];
  }

  static Future<FullAlbum> getAlbum(String albumId) async {
    final jsonString =
        await _channel.invokeMethod<String>('getAlbum', {'id': albumId});

    if (jsonString == null) {
      throw PlatformException(code: 'NULL_RESPONSE');
    }

    final jsonObject = json.decode(jsonString) as Map<dynamic, dynamic>;
    return FullAlbum.fromJson(jsonObject);
  }

  static Future<Artist> getArtist(String artistId) async {
    final jsonString =
    await _channel.invokeMethod<String>('getArtist', {'id': artistId});

    if (jsonString == null) {
      throw PlatformException(code: 'NULL_RESPONSE');
    }

    final jsonObject = json.decode(jsonString) as Map<dynamic, dynamic>;
    return Artist.fromJson(jsonObject);
  }

  static Future<List<Song>> searchSongs({
    String? query,
    String? artistId,
    required int limit,
    required int page,
  }) async {
    final jsonString = await _channel.invokeMethod<String>('searchSongs', {
      if (query != null) 'query': query,
      if (artistId != null) 'artistId': artistId,
      'limit': limit,
      'page': page,
    });

    if (jsonString == null) {
      throw PlatformException(code: 'NULL_RESPONSE');
    }

    final jsonObject = json.decode(jsonString) as List<dynamic>;
    return jsonObject.map(Song.fromJson).toList(growable: false);
  }

  static Future<List<Album>> searchAlbums({
    String? query,
    String? artistId,
    required int limit,
    required int page,
  }) async {
    final jsonString = await _channel.invokeMethod<String>('searchAlbums', {
      if (query != null) 'query': query,
      if (artistId != null) 'artistId': artistId,
      'limit': limit,
      'page': page,
    });

    if (jsonString == null) {
      throw PlatformException(code: 'NULL_RESPONSE');
    }

    final jsonObject = json.decode(jsonString) as List<dynamic>;
    return jsonObject.map(Album.fromJson).toList(growable: false);
  }

  static Future<List<Artist>> searchArtists(
      String query, int limit, int page) async {
    final jsonString = await _channel.invokeMethod<String>(
        'searchArtists', {'query': query, 'limit': limit, 'page': page});

    if (jsonString == null) {
      throw PlatformException(code: 'NULL_RESPONSE');
    }

    final jsonObject = json.decode(jsonString) as List<dynamic>;
    return jsonObject.map(Artist.fromJson).toList(growable: false);
  }

  static Future<List<Playlist>> searchPlaylists(
      String query, int limit, int page) async {
    final jsonString = await _channel.invokeMethod<String>(
        'searchPlaylists', {'query': query, 'limit': limit, 'page': page});

    if (jsonString == null) {
      throw PlatformException(code: 'NULL_RESPONSE');
    }

    final jsonObject = json.decode(jsonString) as List<dynamic>;
    return jsonObject.map(Playlist.fromJson).toList(growable: false);
  }

  static Future<List<Song>> getPlaylistSongs(
      String playlistId, int limit, int page) async {
    final jsonString = await _channel.invokeMethod<String>('getPlaylistSongs',
        {'query': playlistId, 'limit': limit, 'page': page});

    if (jsonString == null) {
      throw PlatformException(code: 'NULL_RESPONSE');
    }

    final jsonObject = json.decode(jsonString) as List<dynamic>;
    return jsonObject.map(Song.fromJson).toList(growable: false);
  }

  /// Fetches a list of [PlayedSong]s.
  ///
  /// This method will only return songs that are stored on the user's device,
  /// and it will only return a song once, even if the user played it multiple
  /// times.
  ///
  /// If [after] is specified, only songs that were last played after [after]
  /// will be returned.
  static Future<List<PlayedSong>> getRecentTracks({DateTime? after}) async {
    final jsonString = await _channel.invokeMethod<String>(
        'getRecentTracks', {'after': after?.millisecondsSinceEpoch});

    if (jsonString == null) {
      throw PlatformException(code: "NULL_RESPONSE");
    }

    final jsonObject = json.decode(jsonString) as List<dynamic>;
    return jsonObject.map(PlayedSong.fromJson).toList(growable: false);
  }
}
