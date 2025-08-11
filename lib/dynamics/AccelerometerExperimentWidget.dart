import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerExperimentWidget extends StatefulWidget {
  const AccelerometerExperimentWidget({Key? key}) : super(key: key);

  @override
  State<AccelerometerExperimentWidget> createState() => _AccelerometerExperimentWidgetState();
}

class _AccelerometerExperimentWidgetState extends State<AccelerometerExperimentWidget> {
  double x = 0.0;
  double y = 0.0;
  double z = 0.0;
  StreamSubscription<UserAccelerometerEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = userAccelerometerEvents.listen((event) {
      setState(() {
        x = event.x;
        y = event.y;
        z = event.z;
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
    final magnitude = sqrt(x * x + y * y + z * z);

    return Scaffold(
      backgroundColor: Colors.white, // 全体背景白
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
                  'ユーザー加速度センサーの値 (m/s²)',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 24),
                Text("X: ${x.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                Text("Y: ${y.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                Text("Z: ${z.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 18, color: Colors.black)),
                const SizedBox(height: 24),
                Text(
                  "合成加速度: ${magnitude.toStringAsFixed(2)} m/s²",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
