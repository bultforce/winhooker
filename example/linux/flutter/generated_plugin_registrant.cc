//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <winhooker/winhooker_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) winhooker_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "WinhookerPlugin");
  winhooker_plugin_register_with_registrar(winhooker_registrar);
}
