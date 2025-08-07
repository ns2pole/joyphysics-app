import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerExperimentWidget extends StatefulWidget {
  @override
  State<AccelerometerExperimentWidget> createState() => _AccelerometerExperimentWidgetState();
}

class _AccelerometerExperimentWidgetState extends State<AccelerometerExperimentWidget> {
  StreamSubscription<AccelerometerEvent>? _subscription;
  double _x = 0, _y = 0, _z = 0;

  @override
  void initState() {
    super.initState();
    _subscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      setState(() {
        _x = event.x;
        _y = event.y;
        _z = event.z;
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
    final magnitude = sqrt(_x * _x + _y * _y + _z * _z);

    return Card(
      margin: const EdgeInsets.all(12),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("現在の加速度", style: TextStyle(fontSize: 18)),
            const SizedBox(height: 8),
            Text("X: ${_x.toStringAsFixed(2)} m/s²"),
            Text("Y: ${_y.toStringAsFixed(2)} m/s²"),
            Text("Z: ${_z.toStringAsFixed(2)} m/s²"),
            const SizedBox(height: 8),
            Text("加速度の大きさ: ${magnitude.toStringAsFixed(2)} m/s²",
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
