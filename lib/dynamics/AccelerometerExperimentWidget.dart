import 'dart:async';
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

  Widget _buildAxisColumn(String label, double value) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
          const SizedBox(height: 8),
          Text(value.toStringAsFixed(2), style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // 画面全体の背景を白に
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
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildAxisColumn('X軸', x),
                    _buildAxisColumn('Y軸', y),
                    _buildAxisColumn('Z軸', z),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
