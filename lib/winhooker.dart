
import 'dart:ffi';
import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'winhooker_platform_interface.dart';
// FFI signature of the hello_world C function
typedef HookerScriptFunc = Void Function();
// Dart type definition for calling the C foreign function
typedef HookerScript = void Function();
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

  Future<void> initHooker()async{
    var location = Directory.current.path;
    print("location---$location");
    location = location.replaceFirst("example", "");
    location = location.replaceFirst("python_scripts", "");
    var libraryPath = path.join("$location/", 'hooker_library', 'libhooker.so');
    final dylib = DynamicLibrary.open(libraryPath);
    // Look up the C function 'hooker_script'
    final HookerScript hooker = dylib
        .lookup<NativeFunction<HookerScriptFunc>>('hooker_script')
        .asFunction();
    // Call the function
    hooker();

  }
}
