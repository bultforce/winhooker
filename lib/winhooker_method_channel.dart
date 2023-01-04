import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:winhooker_mouse/winhooker_mouse.dart';

import 'winhooker_platform_interface.dart';

/// An implementation of [WinhookerPlatform] that uses method channels.
typedef keyboardEventListener = void Function(KeyEvent keyEvent);
typedef CancelListening = void Function();
KeyEventMsg toKeyEventMsg(int v) {
  KeyEventMsg keyMsg;
  switch (v) {
    case 0:
      keyMsg = KeyEventMsg.WM_KEYDOWN;
      break;
    case 1:
      keyMsg = KeyEventMsg.WM_KEYUP;
      break;
    case 2:
      keyMsg = KeyEventMsg.WM_SYSKEYDOWN;
      break;
    case 3:
      keyMsg = KeyEventMsg.WM_SYSKEYDOWN;
      break;
    default:
      keyMsg = KeyEventMsg.WM_UNKNOW;
      break;
  }
  return keyMsg;
}
class MethodChannelWinhooker extends WinhookerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('winhooker');
  var keyBoardEventChannel = const EventChannel('win_tracker_keyboard');
  var mouseEventChannel = const EventChannel('win_tracker_mouse');
  StreamController onKeyboardEvent =  StreamController();
  StreamController onMouseEvent =  StreamController();
  KeyBoardState keyboardState = KeyBoardState();
  KeyBoardState mouseState = KeyBoardState();
  static Map<String, int>? virtualKeyString2CodeMap;
  static Map<int, List<String>>? virtualKeyCode2StringMap;
  CancelListening? _cancelKeyboardListening;
  CancelListening? _cancelMouseListening;
  static bool? isLeter(int vk) {
    if (MethodChannelWinhooker.virtualKeyCode2StringMap != null) {
      var A = MethodChannelWinhooker.virtualKeyString2CodeMap!['A'];
      var Z = MethodChannelWinhooker.virtualKeyString2CodeMap!['Z'];
      if ((vk >= A!) && (vk <= Z!)) {
        return true;
      } else {
        return false;
      }
    }
    return null;
  }
  cancelKeyboardListening() async {
    if (_cancelKeyboardListening != null) {
      _cancelKeyboardListening!();
      _cancelKeyboardListening = null;
    } else {
      debugPrint("win_tracker/screen_capture/event No Need");
    }
  }
  cancelMouseListening() async {
    if (_cancelMouseListening != null) {
      _cancelMouseListening!();
      _cancelMouseListening = null;
    } else {
      debugPrint("win_tracker/screen_capture/event No Need");
    }
  }

  static bool? isNumber(int vk) {
    if (MethodChannelWinhooker.virtualKeyCode2StringMap != null) {
      var key_0 = MethodChannelWinhooker.virtualKeyString2CodeMap!['0'];
      var key_9 = MethodChannelWinhooker.virtualKeyString2CodeMap!['9'];
      if ((vk >= key_0!) && (vk <= key_9!)) {
        return true;
      } else {
        return false;
      }
    }
    return null;
  }
  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Stream<dynamic> streamKeyboardEventFromNative() {
    if(Platform.isWindows){
      startKeyboardWindowListening();
      onKeyboardEvent.sink.add("event");
      return onKeyboardEvent.stream;
    }else if(Platform.isMacOS){
      return keyBoardEventChannel.receiveBroadcastStream("keyBoard_event").map((event) => event);}
    else{
      return onKeyboardEvent.stream;
    }
  }

  Future<void> startKeyboardWindowListening() async{
     var subscription =
     keyBoardEventChannel.receiveBroadcastStream("keyBoard_event").listen(//listener
              (dynamic msg) {
            var list = List<int>.from(msg);
            var keyEvent = KeyEvent(list);
            if (keyEvent.isKeyDown) {
              if (!keyboardState.state.contains(keyEvent.vkCode)) {
                keyboardState.state.add(keyEvent.vkCode);
              }
            } else {
              if (keyboardState.state.contains(keyEvent.vkCode)) {
                keyboardState.state.remove(keyEvent.vkCode);
              }
            }
            onKeyboardEvent.sink.add(keyEvent);
          }, cancelOnError: true);
      debugPrint("keyboard_event/event startListening");
     _cancelKeyboardListening= () {
        subscription.cancel();
        debugPrint("keyboard_event/event canceled");
      };
    }

  @override
  Stream<dynamic> streamMouseEventFromNative() {
    if(Platform.isWindows){
      return WinhookerMouse().streamMouseHook();
    }else if(Platform.isMacOS){
      return mouseEventChannel.receiveBroadcastStream("mouse_event").map((event) => event);}
    else{
      return onMouseEvent.stream;
    }

  }

}
class KeyEvent {
  late KeyEventMsg keyMsg;
  late int vkCode;
  late int scanCode;
  late int flags;
  late int time;
  late int dwExtraInfo;

  KeyEvent(List<int> list) {
    keyMsg = toKeyEventMsg(list[0]);
    vkCode = list[1];
    scanCode = list[2];
    flags = list[3];
    time = list[4];
    dwExtraInfo = list[5];
  }

  bool get isKeyUP =>
      (keyMsg == KeyEventMsg.WM_KEYUP) || (keyMsg == KeyEventMsg.WM_SYSKEYUP);
  bool get isKeyDown => !isKeyUP;
  bool get isSysKey =>
      (keyMsg == KeyEventMsg.WM_SYSKEYUP) ||
          (keyMsg == KeyEventMsg.WM_SYSKEYDOWN);

  String? get vkName => MethodChannelWinhooker.virtualKeyCode2StringMap?[vkCode]?[0];

  bool? get isLeter => MethodChannelWinhooker.isLeter(vkCode);
  bool? get isNumber => MethodChannelWinhooker.isNumber(vkCode);

  @override
  String toString() {
    var sb = StringBuffer();
    sb.write('${DateTime.now().millisecondsSinceEpoch}-$vkCode');
    return sb.toString();
  }
}
class KeyBoardState {
  Set<int> state = <int>{};
  KeyBoardState();
  @override
  String toString() {
    if (MethodChannelWinhooker.virtualKeyCode2StringMap != null) {
      var sb = StringBuffer();
      bool isFirst = true;
      sb.write('[');
      for (var key in state) {
        if (isFirst) {
          isFirst = false;
        } else {
          sb.write(',');
        }
        var str = MethodChannelWinhooker.virtualKeyCode2StringMap![key]?[0];
        sb.write(str ?? key.toString());
      }
      sb.write(']');
      return sb.toString();
    } else {
      return state.toString();
    }
  }
}
typedef CancelScreenListening = void Function();
enum KeyEventMsg { WM_KEYDOWN, WM_KEYUP, WM_SYSKEYDOWN, WM_SYSKEYUP, WM_UNKNOW }
