#ifndef FLUTTER_PLUGIN_WINHOOKER_PLUGIN_H_
#define FLUTTER_PLUGIN_WINHOOKER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace winhooker {

class WinhookerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  WinhookerPlugin();

  virtual ~WinhookerPlugin();

  // Disallow copy and assign.
  WinhookerPlugin(const WinhookerPlugin&) = delete;
  WinhookerPlugin& operator=(const WinhookerPlugin&) = delete;
 static void showText(LPCTSTR text);
 private:
  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
    flutter::PluginRegistrarWindows *registrar_;
    static const char kOnLogCallbackMethod[];
    static const char kGetVirtualKeyMapMethod[];
      #ifdef KEYEVENT_DEBUG
        UINT _codePage;
      #endif
};

}  // namespace winhooker

#endif  // FLUTTER_PLUGIN_WINHOOKER_PLUGIN_H_
