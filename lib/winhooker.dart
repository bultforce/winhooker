
import 'winhooker_platform_interface.dart';

class Winhooker {
  Future<String?> getPlatformVersion() {
    return WinhookerPlatform.instance.getPlatformVersion();
  }

  Stream<dynamic> streamKeyboardHook() {
    return WinhookerPlatform.instance.streamKeyboardEventFromNative();
  }

  Stream<dynamic> streamMouseHook() {
    return WinhookerPlatform.instance.streamMouseEventFromNative();
  }

}
