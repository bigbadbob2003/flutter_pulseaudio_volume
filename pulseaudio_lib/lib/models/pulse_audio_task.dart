import 'package:pulseaudio_lib/generated_bindings.dart';
import 'dart:ffi' as ffi;

class PulseAudioTask {
  final Function(
    NativeLibrary nv,
    ffi.Pointer<pa_context> paContext,
  ) task;

  PulseAudioTask(this.task);
}
