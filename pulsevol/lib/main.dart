import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:pulseaudio_lib/models/pulseaudio_device.dart';
import 'package:pulseaudio_lib/pulseaudio_lib.dart';
import 'package:vs_scrollbar/vs_scrollbar.dart';

void main() {
  runApp(const MyApp());

  doWhenWindowReady(() {
    final initialSize = Size(600, 450);
    appWindow.minSize = initialSize;
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pulse Audio Volume Control',
      theme: ThemeData(primarySwatch: Colors.blue, brightness: Brightness.dark),
      home: const MyHomePage(title: 'Pulse Audio Volume Control'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final ScrollController _scrollController = ScrollController();
  final ScrollController _scrollController2 = ScrollController();

  @override
  void initState() {
    PulseaudioLib.updateStream.listen((event) {
      setState(() {});
    });
    PulseaudioLib.runPaLoop();
    PulseaudioLib.getSinkList();
    PulseaudioLib.getSourceList();
    super.initState();
  }

  @override
  void dispose() {
    PulseaudioLib.stopPaLoop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Future testWindowFunctions() async {
    //   Size size = await DesktopWindow.getWindowSize();
    //   print(size);
    // }

    // testWindowFunctions();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: VsScrollbar(
                controller: _scrollController,
                showTrackOnHover: true, // default false
                isAlwaysShown: true, // default false
                scrollbarFadeDuration: const Duration(milliseconds: 500), // default : Duration(milliseconds: 300)
                scrollbarTimeToFade: const Duration(milliseconds: 800), // default : Duration(milliseconds: 600)
                style: const VsScrollbarStyle(
                  hoverThickness: 10.0, // default 12.0
                  radius: Radius.circular(10), // default Radius.circular(8.0)
                  thickness: 10.0, // [ default 8.0 ]
                  //color: Colors.purple.shade900, // default ColorScheme Theme
                ),

                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  children: PulseaudioLib.sourceDevices
                      .where((element) => element.monitorSink == null)
                      .map((e) => VolumeControl(device: e))
                      .toList(),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: VsScrollbar(
                controller: _scrollController2,
                showTrackOnHover: true, // default false
                isAlwaysShown: true, // default false
                scrollbarFadeDuration: const Duration(milliseconds: 500), // default : Duration(milliseconds: 300)
                scrollbarTimeToFade: const Duration(milliseconds: 800), // default : Duration(milliseconds: 600)
                style: const VsScrollbarStyle(
                  hoverThickness: 10.0, // default 12.0
                  radius: Radius.circular(10), // default Radius.circular(8.0)
                  thickness: 10.0, // [ default 8.0 ]
                  //color: Colors.purple.shade900, // default ColorScheme Theme
                ),

                child: ListView(
                  controller: _scrollController2,
                  scrollDirection: Axis.horizontal,
                  children: PulseaudioLib.sinkDevices.map((e) => VolumeControl(device: e)).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class VolumeControl extends StatefulWidget {
  const VolumeControl({Key? key, required this.device}) : super(key: key);

  final PulseAudioDevice device;

  @override
  _VolumeControlState createState() => _VolumeControlState();
}

class _VolumeControlState extends State<VolumeControl> {
  double sliderval = 0;
  DateTime _lastUpdate = DateTime.now();
  final int _updateInterval = 5;

  @override
  void initState() {
    sliderval = widget.device.currentVolume;
    super.initState();
  }

  _setVol(double v) async {
    setState(() {
      sliderval = v;
    });
    var _diff = DateTime.now().difference(_lastUpdate).inMilliseconds;
    if (_diff > _updateInterval) {
      _lastUpdate = DateTime.now();

      widget.device.setVolume(sliderval);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.fromLTRB(5, 5, 5, 25),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                  flex: 2,
                  child: Text(
                    widget.device.description,
                    textAlign: TextAlign.center,
                  )),
              Expanded(
                flex: 6,
                child: RotatedBox(
                  quarterTurns: 3,
                  child: Slider(
                    value: sliderval,
                    min: 0,
                    max: 100,
                    onChanged: _setVol,
                  ),
                ),
              ),
              Expanded(flex: 1, child: Text("${widget.device.currentVolume.toInt()}%")),
            ],
          ),
        ),
      ),
    );
  }
}
