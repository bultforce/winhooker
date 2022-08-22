import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'winhooker_platform_interface.dart';

/// An implementation of [WinhookerPlatform] that uses method channels.
class MethodChannelWinhooker extends WinhookerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('winhooker');
  var keyBoardEventChannel = const EventChannel('win_tracker_keyboard');
  var mouseEventChannel = const EventChannel('win_tracker_mouse');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Stream<dynamic> streamKeyboardEventFromNative() {
    return keyBoardEventChannel.receiveBroadcastStream("keyBoard_event").map((event) => event);
  }

  @override
  Stream<dynamic> streamMouseEventFromNative() {
    return mouseEventChannel.receiveBroadcastStream("mouse_event").map((event) {
      return event;
    });
  }
}
