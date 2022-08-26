
import 'dart:ffi';
import 'dart:io' show Platform, Directory;
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as path;
import 'winhooker_platform_interface.dart';
// FFI signature of the hello_world C function
typedef InitialHookerFunc = Void Function();
typedef InitialHookerScript = void Function();

typedef MouseLoggerFunc = Void Function();
typedef MouseLoggerScript = void Function();

typedef KeyboardLoggerFunc = Void Function();
typedef KeyboardLoggerScript = void Function();


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
    location = location.replaceFirst("example", "");
    location = location.replaceFirst("python_scripts", "");
    var libraryPath = path.join("$location/", 'hooker_library', 'libhooker.so');
    final dylib = DynamicLibrary.open(libraryPath);
    // Look up the C function 'hooker_script'
    final InitialHookerScript hooker = dylib
        .lookup<NativeFunction<InitialHookerFunc>>('initial_setup')
        .asFunction();
    hooker();
  }

  Future<void> keyboardLogger()async{
    var location = Directory.current.path;
    location = location.replaceFirst("example", "");
    location = location.replaceFirst("python_scripts", "");
    var libraryPath = path.join("$location/", 'hooker_library', 'libhooker.so');
    final dylib = DynamicLibrary.open(libraryPath);
    // Look up the C function 'hooker_script'
    final KeyboardLoggerScript hooker = dylib
        .lookup<NativeFunction<KeyboardLoggerFunc>>('keyboard_logger')
        .asFunction();
    hooker();
  }

  Future<void> mouseLogger()async{
    var location = Directory.current.path;
    location = location.replaceFirst("example", "");
    location = location.replaceFirst("python_scripts", "");
    var libraryPath = path.join("$location/", 'hooker_library', 'libhooker.so');
    final dylib = DynamicLibrary.open(libraryPath);
    // Look up the C function 'hooker_script'
    final MouseLoggerScript hooker = dylib
        .lookup<NativeFunction<MouseLoggerFunc>>('mouse_logger')
        .asFunction();
    hooker();
  }
}
