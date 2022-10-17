import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mpmediaplayer/flutter_mpmediaplayer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  AuthorizationStatus? _authorizationStatus;
  List<PlayedSong>? _playedSongs;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    AuthorizationStatus? initialStatus;

    try {
      initialStatus = await FlutterMPMediaPlayer.authorizationStatus;
    } on PlatformException {
      _error = 'Failed to get initial authorization status';
    }

    if (initialStatus != null) {
      setState(() {
        _authorizationStatus = initialStatus;
      });
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> _authorize() async {
    AuthorizationStatus? authorizationStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      authorizationStatus = await FlutterMPMediaPlayer.authorize();
    } on PlatformException {
      _error = 'Failed to authorize.';
    }

    if (authorizationStatus != null) {
      setState(() {
        _authorizationStatus = authorizationStatus;
      });
    }

    List<PlayedSong>? playedSongs;

    if (authorizationStatus == AuthorizationStatus.authorized) {
      try {
        playedSongs =
            await FlutterMPMediaPlayer.getRecentTracks(limit: 20, page: 1);
      } on PlatformException {
        _error = 'Failed to get played songs.';
      }
    }

    if (playedSongs != null) {
      setState(() {
        _playedSongs = playedSongs;
      });
    }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        home: Scaffold(
          appBar: AppBar(
            title: const Text('FlutterMPMediaPlayer Example App'),
          ),
          body: ListView(
            children: [
              if (_error != null)
                ListTile(title: Text(_error!))
              else ...[
                ListTile(
                  title: Text(
                      'Authorization status: ${_authorizationStatus?.name}'),
                ),
                TextButton(
                  onPressed: _authorize,
                  child: const Text('Authorize'),
                ),
                if (_playedSongs != null)
                  for (final song in _playedSongs!)
                    ListTile(
                      title: Text(song.title),
                      subtitle: Text([song.artist, song.album]
                          .whereType<String>()
                          .join(' • ')),
                      trailing: Text('${song.lastPlayedDate}'),
                    ),
              ],
            ],
          ),
        ),
      );
}
