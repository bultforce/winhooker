import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'winhooker_method_channel.dart';

abstract class WinhookerPlatform extends PlatformInterface {
  /// Constructs a WinhookerPlatform.
  WinhookerPlatform() : super(token: _token);

  static final Object _token = Object();

  static WinhookerPlatform _instance = MethodChannelWinhooker();

  /// The default instance of [WinhookerPlatform] to use.
  ///
  /// Defaults to [MethodChannelWinhooker].
  static WinhookerPlatform get instance => _instance;
  
  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [WinhookerPlatform] when
  /// they register themselves.
  static set instance(WinhookerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }


  Stream<dynamic> streamMouseEventFromNative() {
    throw UnimplementedError('streamMouseEventFromNative() has not been implemented.');
  }
  Stream<dynamic> streamKeyboardEventFromNative() {
    throw UnimplementedError('streamKeyboardEventFromNative() has not been implemented.');
  }



  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
