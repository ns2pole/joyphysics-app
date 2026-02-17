import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'package:joyphysics/shared_components.dart';

class BarometerExperimentWidget extends StatefulWidget with HasHeight {
  final double height;
  final bool useScaffold;

  const BarometerExperimentWidget({
    Key? key,
    this.height = 320,
    this.useScaffold = true,
  }) : super(key: key);

  @override
  double get widgetHeight => height;

  @override
  State<BarometerExperimentWidget> createState() => _BarometerExperimentWidgetState();
}

class _BarometerExperimentWidgetState extends State<BarometerExperimentWidget> {
  double? _pressure;
  StreamSubscription<BarometerEvent>? _pressureSub;

  @override
  void initState() {
    super.initState();
    final isMobile = !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS);
    if (isMobile) {
      _pressureSub = barometerEventStream().listen((BarometerEvent event) {
        if (!mounted) return;
        setState(() {
          _pressure = event.pressure;
        });
      }, onError: (e) {
        print('Barometer error: $e');
      }, cancelOnError: true);
    } else {
      _pressure = null;
    }
  }

  @override
  void dispose() {
    _pressureSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final content = SensorDisplayCard(
      title: "現在の大気圧",
      height: widget.height,
      children: _pressure == null
          ? [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              const Text(
                "気圧データを取得中...",
                style: TextStyle(fontSize: 18, color: Colors.black),
              ),
            ]
          : [
              Text(
                "${_pressure!.toStringAsFixed(2)} hPa",
                style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
    );

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('気圧センサー'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: content,
    );
  }
}
