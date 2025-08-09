import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class MagnetometerExperimentWidget extends StatefulWidget {
  @override
  State<MagnetometerExperimentWidget> createState() => _MagnetometerExperimentWidgetState();
}

class _MagnetometerExperimentWidgetState extends State<MagnetometerExperimentWidget> {
  StreamSubscription<MagnetometerEvent>? _subscription;
  double _x = 0, _y = 0, _z = 0;

  @override
  void initState() {
    super.initState();
    _subscription = magnetometerEventStream().listen((MagnetometerEvent event) {
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

    return Scaffold(
      backgroundColor: Colors.white,  // 画面全体白背景
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "現在の磁場強度",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                ),
                const SizedBox(height: 24),
                Text("X: ${_x.toStringAsFixed(1)} μT",
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                Text("Y: ${_y.toStringAsFixed(1)} μT",
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                Text("Z: ${_z.toStringAsFixed(1)} μT",
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                const SizedBox(height: 24),
                Text(
                  "合成磁場: ${magnitude.toStringAsFixed(1)} μT",
                  style: const TextStyle(
                      fontSize: 20,
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