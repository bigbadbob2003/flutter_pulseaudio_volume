//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <pulseaudio_lib/pulseaudio_lib_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) pulseaudio_lib_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "PulseaudioLibPlugin");
  pulseaudio_lib_plugin_register_with_registrar(pulseaudio_lib_registrar);
}
