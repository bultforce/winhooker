#include "include/winhooker/winhooker_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "winhooker_plugin.h"

void WinhookerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  winhooker::WinhookerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
