import 'package:flutter_test/flutter_test.dart';
import 'package:winhooker/winhooker.dart';
import 'package:winhooker/winhooker_platform_interface.dart';
import 'package:winhooker/winhooker_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockWinhookerPlatform 
    with MockPlatformInterfaceMixin
    implements WinhookerPlatform {

  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final WinhookerPlatform initialPlatform = WinhookerPlatform.instance;

  test('$MethodChannelWinhooker is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelWinhooker>());
  });

  test('getPlatformVersion', () async {
    Winhooker winhookerPlugin = Winhooker();
    MockWinhookerPlatform fakePlatform = MockWinhookerPlatform();
    WinhookerPlatform.instance = fakePlatform;
  
    expect(await winhookerPlugin.getPlatformVersion(), '42');
  });
}
