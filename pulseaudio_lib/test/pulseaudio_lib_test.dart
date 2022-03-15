import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pulseaudio_lib/pulseaudio_lib.dart';

void main() {
  const MethodChannel channel = MethodChannel('pulseaudio_lib');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await PulseaudioLib.platformVersion, '42');
  });
}
