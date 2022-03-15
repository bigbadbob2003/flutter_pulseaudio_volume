import 'package:ffi/ffi.dart';
import 'package:pulseaudio_lib/generated_bindings.dart';
import 'package:pulseaudio_lib/models/pulse_audio_task.dart';
import 'dart:ffi' as ffi;

import 'package:pulseaudio_lib/pulseaudio_lib.dart';
import 'package:pulseaudio_lib/utils/array_utils.dart';

abstract class PulseAudioDevice {
  late String name;
  late String description;
  late double currentVolume;
  late int maxVolume = PA_VOLUME_NORM;

  setVolume(double volumePercent);
}

class PulseAudioSinkDevice extends PulseAudioDevice {
  @override
  String get name => _name ?? "";
  String? _name;

  @override
  String get description => _description ?? "";
  String? _description;

  @override
  double get currentVolume => _currentVolume ?? 0;
  double? _currentVolume;

  int? monitorSource;
  String? monitorSourceName;

  PulseAudioSinkDevice(ffi.Pointer<pa_sink_info> nativeSink) {
    _name = nativeSink.ref.name.cast<Utf8>().toDartString();
    _description = nativeSink.ref.description.cast<Utf8>().toDartString();
    _currentVolume = (nativeSink.ref.volume.values[0] / maxVolume) * 100;
    monitorSource = nativeSink.ref.monitor_source;
    monitorSourceName = nativeSink.ref.monitor_source_name.cast<Utf8>().toDartString();
  }

  @override
  setVolume(double volumePercent) {
    if (_name == null) return;

    _currentVolume = volumePercent;
    var _v = ((maxVolume / 100) * volumePercent).toInt();

    var task = PulseAudioTask((nv, context) {
      ffi.Pointer<pa_cvolume> _vol = malloc.allocate<pa_cvolume>(ffi.sizeOf<ffi.Uint8>() + ffi.sizeOf<ffi.Uint32>());
      _vol.ref.channels = 1;
      _vol.ref.values[0] = _v;

      nv.pa_context_set_sink_volume_by_name(context, _name!.toPointerInt8(), _vol, ffi.nullptr, ffi.nullptr);

      malloc.free(_vol);
    });

    PulseaudioLib.queueTask(task);
  }
}

class PulseAudioSourceDevice extends PulseAudioDevice {
  @override
  String get name => _name ?? " - ";
  String? _name;

  @override
  String get description => _description ?? "";
  String? _description;

  @override
  double get currentVolume => _currentVolume ?? 0;
  double? _currentVolume;

  int? monitorSink;
  String? monitorSinkName;

  PulseAudioSourceDevice(ffi.Pointer<pa_source_info> nativeSource) {
    _name = nativeSource.ref.name.cast<Utf8>().toDartString();
    _description = nativeSource.ref.description.cast<Utf8>().toDartString();
    _currentVolume = (nativeSource.ref.volume.values[0] / maxVolume) * 100;
    monitorSink = nativeSource.ref.monitor_of_sink == 4294967295 ? null : nativeSource.ref.monitor_of_sink;
    try {
      monitorSinkName = nativeSource.ref.monitor_of_sink_name.cast<Utf8>().toDartString();
    } catch (e) {}
  }

  @override
  setVolume(double volumePercent) {
    if (_name == null) return;

    _currentVolume = volumePercent;
    var _v = ((maxVolume / 100) * volumePercent).toInt();

    var task = PulseAudioTask((nv, context) {
      ffi.Pointer<pa_cvolume> _vol = malloc.allocate<pa_cvolume>(ffi.sizeOf<ffi.Uint8>() + ffi.sizeOf<ffi.Uint32>());
      _vol.ref.channels = 1;
      _vol.ref.values[0] = _v;

      nv.pa_context_set_source_volume_by_name(context, _name!.toPointerInt8(), _vol, ffi.nullptr, ffi.nullptr);

      malloc.free(_vol);
    });

    PulseaudioLib.queueTask(task);
  }
}
