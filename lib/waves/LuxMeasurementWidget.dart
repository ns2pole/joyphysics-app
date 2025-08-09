import 'package:flutter/material.dart';
import 'package:light/light.dart';
import 'dart:async';

class LuxMeasurementWidget extends StatefulWidget {
  @override
  _LuxMeasurementWidgetState createState() => _LuxMeasurementWidgetState();
}

class _LuxMeasurementWidgetState extends State<LuxMeasurementWidget> {
  Light _light = Light();
  StreamSubscription? _subscription;
  double? lux;

  @override
  void initState() {
    super.initState();
    _subscription = _light.lightSensorStream.listen((luxValue) {
      setState(() {
        lux = luxValue.toDouble();
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 画面全体の背景白
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: lux == null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        "照度測定中...",
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "現在の照度",
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        "${lux!.toStringAsFixed(1)} lx",
                        style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
