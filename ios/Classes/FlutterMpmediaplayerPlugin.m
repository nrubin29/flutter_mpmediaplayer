#import "FlutterMpmediaplayerPlugin.h"
#if __has_include(<flutter_mpmediaplayer/flutter_mpmediaplayer-Swift.h>)
#import <flutter_mpmediaplayer/flutter_mpmediaplayer-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_mpmediaplayer-Swift.h"
#endif

@implementation FlutterMpmediaplayerPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMpmediaplayerPlugin registerWithRegistrar:registrar];
}
@end