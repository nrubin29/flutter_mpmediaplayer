library flutter_mpmediaplayer;

import 'package:flutter/services.dart';

class FlutterMPMediaPlayer {
  static const _channel = MethodChannel('flutter_mpmediaplayer');

  static Future<String?> get platformVersion async =>
      await _channel.invokeMethod('getPlatformVersion');
}
