//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <winhooker/winhooker_plugin_c_api.h>
#include <winhooker_mouse/winhooker_mouse_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  WinhookerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WinhookerPluginCApi"));
  WinhookerMousePluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WinhookerMousePluginCApi"));
}
