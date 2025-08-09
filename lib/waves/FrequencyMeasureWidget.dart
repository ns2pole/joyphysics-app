// import 'package:flutter/material.dart';
// import 'package:flutter_fft/flutter_fft.dart';

// class FrequencyMeasureWidget extends StatefulWidget {
//   @override
//   State<FrequencyMeasureWidget> createState() => _FrequencyMeasureWidgetState();
// }

// class _FrequencyMeasureWidgetState extends State<FrequencyMeasureWidget> {
//   final FlutterFft _flutterFft = FlutterFft();
//   double? frequency;

//   @override
//   void initState() {
//     super.initState();
//     initRecorder();
//   }

//   Future<void> initRecorder() async {
//     await _flutterFft.startRecorder();
//     _flutterFft.onRecorderStateChanged.listen((event) {
//       setState(() {
//         frequency = (event[1] is num) ? (event[1] as num).toDouble() : null;
//       });
//     });
//   }

//   @override
//   void dispose() {
//     _flutterFft.stopRecorder();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text(
//         frequency == null ? '周波数測定中...' : '周波数: ${frequency!.toStringAsFixed(2)} Hz',
//         style: TextStyle(fontSize: 24),
//       ),
//     );
//   }
// }