import 'dart:async';
import 'dart:collection';
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

import 'package:pulseaudio_lib/generated_bindings.dart';
import 'package:pulseaudio_lib/models/pulse_audio_task.dart';
import 'package:pulseaudio_lib/models/pulseaudio_device.dart';
import 'package:pulseaudio_lib/utils/array_utils.dart';

class PulseaudioLib {
  static const MethodChannel _channel = MethodChannel('pulseaudio_lib');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  // Public
  static final StreamController<bool> _updateStreamController = StreamController<bool>.broadcast();
  static Stream<bool> get updateStream => _updateStreamController.stream;

  static List<PulseAudioSinkDevice> sinkDevices = [];
  static List<PulseAudioSourceDevice> sourceDevices = [];

  static runPaLoop() async {
    _paReady = 0;

    _paMl = _nv.pa_mainloop_new();
    _paMlapi = _nv.pa_mainloop_get_api(_paMl);
    _paCtx = _nv.pa_context_new(_paMlapi, name);

    _nv.pa_context_connect(_paCtx, ffi.nullptr, 0, ffi.nullptr);

    _nv.pa_context_set_state_callback(_paCtx, ffi.Pointer.fromFunction(stateCallback), ffi.nullptr);

    _paMainLoop();
  }

  static stopPaLoop() {
    _stopFlag = true;
  }

  static getSinkList() {
    _paTasks.add(PulseAudioTask((nv, context) {
      ffi.Pointer<pa_operation> paOp = ffi.nullptr;
      paOp = nv.pa_context_get_sink_info_list(context, ffi.Pointer.fromFunction(_getSinkList), ffi.nullptr);
      _nv.pa_operation_unref(paOp);
    }));
  }

  static getSourceList() {
    _paTasks.add(PulseAudioTask((nv, context) {
      ffi.Pointer<pa_operation> paOp = ffi.nullptr;
      paOp = nv.pa_context_get_source_info_list(context, ffi.Pointer.fromFunction(_getSourceList), ffi.nullptr);
      _nv.pa_operation_unref(paOp);
    }));
  }

  static queueTask(PulseAudioTask task) {
    _paTasks.add(task);
  }

  // Private

  static final ffi.DynamicLibrary _lib = ffi.DynamicLibrary.process();
  static final NativeLibrary _nv = NativeLibrary(_lib);
  static final Queue<PulseAudioTask> _paTasks = Queue();
  static bool _stopFlag = false;
  static int _paReady = 0;
  static ffi.Pointer<ffi.Int8> name = "pulsevol".toPointerInt8();
  static ffi.Pointer<pa_context> _paCtx = ffi.nullptr;
  static ffi.Pointer<pa_mainloop> _paMl = ffi.nullptr;
  static ffi.Pointer<pa_mainloop_api> _paMlapi = ffi.nullptr;

  static Future<void> _paMainLoop() async {
    if (_paReady == 2) {
      _nv.pa_context_disconnect(_paCtx);
      _nv.pa_context_unref(_paCtx);
      _nv.pa_mainloop_free(_paMl);
      malloc.free(name);
      return;
    }

    if (_stopFlag) {
      _nv.pa_context_disconnect(_paCtx);
      _nv.pa_context_unref(_paCtx);
      _nv.pa_mainloop_free(_paMl);
      malloc.free(name);
      return;
    }

    if (_paReady == 0) {
      _nv.pa_mainloop_iterate(_paMl, 1, ffi.nullptr);
      Future.delayed(const Duration(milliseconds: 5)).then((value) => _paMainLoop());
      return;
    }

    for (var i = 0; i < _paTasks.length; i++) {
      var _task = _paTasks.removeFirst();
      _task.task(_nv, _paCtx);
    }

    _nv.pa_mainloop_iterate(_paMl, 1, ffi.nullptr);
    Future.delayed(const Duration(milliseconds: 5)).then((value) => _paMainLoop());
  }

  static void stateCallback(ffi.Pointer<pa_context> c, ffi.Pointer<ffi.Void> userdata) {
    int state;

    state = _nv.pa_context_get_state(c);

    switch (state) {
      case PA_CONTEXT_FAILED:
      case PA_CONTEXT_TERMINATED:
        _paReady = 2;
        break;
      case PA_CONTEXT_READY:
        _paReady = 1;
        break;
      case PA_CONTEXT_UNCONNECTED:
      case PA_CONTEXT_CONNECTING:
      case PA_CONTEXT_AUTHORIZING:
      case PA_CONTEXT_SETTING_NAME:
      default:
        break;
    }
  }

  static void _getSinkList(ffi.Pointer<pa_context> c, ffi.Pointer<pa_sink_info> l, int eol, ffi.Pointer<ffi.Void> userdata) {
    if (eol > 0) return;

    var pad = PulseAudioSinkDevice(l);
    sinkDevices.add(pad);
    _updateStreamController.add(true);
  }

  static void _getSourceList(ffi.Pointer<pa_context> c, ffi.Pointer<pa_source_info> l, int eol, ffi.Pointer<ffi.Void> userdata) {
    if (eol > 0) return;

    var pad = PulseAudioSourceDevice(l);
    sourceDevices.add(pad);
    _updateStreamController.add(true);
  }
}
