import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class BarometerExperimentWidget extends StatefulWidget {
  @override
  State<BarometerExperimentWidget> createState() => _BarometerExperimentWidgetState();
}

class _BarometerExperimentWidgetState extends State<BarometerExperimentWidget> {
  double? _pressure;
  StreamSubscription<BarometerEvent>? _pressureSub;

  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid || Platform.isIOS) {
      _pressureSub = barometerEventStream().listen((BarometerEvent event) {
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
    return Scaffold(
      backgroundColor: Colors.white, // 画面全体の背景白
      body: Center(
        child: Card(
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: _pressure == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "気圧データを取得中...",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "現在の大気圧",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "${_pressure!.toStringAsFixed(2)} hPa",
                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                      // 推定標高差が必要なら復活してください
                      // const SizedBox(height: 8),
                      // Text(
                      //   _estimateAltitude(_pressure!),
                      //   style: const TextStyle(fontSize: 16, color: Colors.grey),
                      // ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  String _estimateAltitude(double p) {
    final h = (1013.25 - p) * 8.3;
    return "推定標高差: 約 ${h.toStringAsFixed(1)} m";
  }
}
