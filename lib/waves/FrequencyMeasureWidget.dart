import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FrequencyMeasureWidget extends StatefulWidget {
  const FrequencyMeasureWidget({Key? key}) : super(key: key);

  @override
  State<FrequencyMeasureWidget> createState() => _FrequencyMeasureWidgetState();
}

class _FrequencyMeasureWidgetState extends State<FrequencyMeasureWidget> {
  static const _frequencyChannel = MethodChannel('com.example.frequency/mic');
  static const _barometerChannel = EventChannel('barometer_channel');

  double? _frequency;
  double? _pressure;
  Timer? _timer;
  StreamSubscription? _barometerSubscription;

  @override
  void initState() {
    super.initState();
    _startMic();
    _startBarometer();
  }

  Future<void> _startMic() async {
    try {
      await _frequencyChannel.invokeMethod('start');
      _timer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
        final freq = await _frequencyChannel.invokeMethod('getFrequency');
        setState(() {
          _frequency = (freq as double?) ?? 0.0;
        });
      });
    } on PlatformException catch (e) {
      print('Failed to start mic: ${e.message}');
    }
  }

  void _startBarometer() {
    _barometerSubscription = _barometerChannel.receiveBroadcastStream().listen((event) {
      setState(() {
        _pressure = event as double;
      });
    }, onError: (error) {
      print('Barometer error: $error');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _frequencyChannel.invokeMethod('stop');
    _barometerSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          _frequency == null ? '周波数計測中...' : '周波数: ${_frequency!.toStringAsFixed(1)} Hz',
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 20),
        Text(
          _pressure == null ? '気圧計測中...' : '気圧: ${_pressure!.toStringAsFixed(1)} hPa',
          style: const TextStyle(fontSize: 24),
        ),
      ],
    );
  }
}
