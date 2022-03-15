cmake_minimum_required(VERSION 3.10)
set(PROJECT_NAME "pulseaudio_lib")
project(${PROJECT_NAME})
set(CMAKE_CXX_STANDARD 11)

# This value is used when generating builds using this plugin, so it must
# not be changed
set(PLUGIN_NAME "pulseaudio_lib_plugin")

find_path(PULSEAUDIO_INCLUDE_DIR
        NAMES pulse/pulseaudio.h
        DOC "The PulseAudio include directory"
        )
find_library(PULSEAUDIO_LIBRARY
        NAMES pulse
        DOC "The PulseAudio library"
        )
include_directories(${PULSEAUDIO_INCLUDE_DIRS})

add_library(${PLUGIN_NAME} SHARED
  "pulsetest.c"
  "pulseaudio_lib_plugin.cc"
)
apply_standard_settings(${PLUGIN_NAME})
set_target_properties(${PLUGIN_NAME} PROPERTIES
  CXX_VISIBILITY_PRESET hidden)
target_compile_definitions(${PLUGIN_NAME} PRIVATE FLUTTER_PLUGIN_IMPL)
target_include_directories(${PLUGIN_NAME} INTERFACE
  "${CMAKE_CURRENT_SOURCE_DIR}/include")
target_link_libraries(${PLUGIN_NAME} PRIVATE flutter)
target_link_libraries(${PLUGIN_NAME} PRIVATE PkgConfig::GTK)
target_link_libraries(${PLUGIN_NAME} PRIVATE pulse-simple pulse)

# List of absolute paths to libraries that should be bundled with the plugin
set(pulseaudio_lib_bundled_libraries
  ""
  PARENT_SCOPE
)
