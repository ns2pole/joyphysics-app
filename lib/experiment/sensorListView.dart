import 'package:flutter/material.dart';
import 'package:joyphysics/model.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/dynamics/AccelerometerExperimentWidget.dart';
import 'package:joyphysics/experiment/dynamics/BarometerExperimentWidget.dart';
import 'package:joyphysics/experiment/electroMagnetism/MagnetometerExperimentWidget.dart';
import 'package:joyphysics/experiment/waves/LuxMeasurementWidget.dart';
import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';



class SensorListView extends StatelessWidget {
  SensorListView({super.key});

  final List<Map<String, dynamic>> sensors = [
    {
      'name': '加速度センサー',
      'icon': Icons.speed,
      'widget': AccelerometerExperimentWidget(),
    },
    {
      'name': '気圧センサー',
      'icon': Icons.compress,
      'widget': BarometerExperimentWidget(),
    },
    {
      'name': '磁気センサー',
      'icon': Icons.sensors,
      'widget': MagnetometerExperimentWidget(height: 380),
    },
    {
      'name': '周波数センサー(音波)',
      'icon': Icons.graphic_eq,
      'widget': FrequencyMeasureWidget(),
    },
    if (!(kIsWeb || Platform.isIOS))
      {
        'name': '光センサー',
        'icon': Icons.wb_sunny,
        'widget': LuxMeasurementWidget(),
      },
  ];

  // 既に定義済みの Video オブジェクトをそのまま入れてください（ここは例示）。
  // --- ここはあなたの既存オブジェクト名をそのまま使う想定です ---
  // 例: accelerometer, barometer, magnetometer, frequencyAndDoReMi, doppler, dopplerObserverMoving, luxMeasurement
  final Map<String, List<Video>> articlesByCategory = {
    '加速度センサー': [accelerometer],
    '気圧センサー': [barometer],
    '磁気センサー': [magnetometer],
    '周波数センサー': [frequencyAndDoReMi, beat, doppler, dopplerObserverMoving],
    '光センサー': [luxMeasurement],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('センサーを使う')),
      body: ListView.separated(
        itemCount: sensors.length + 1, // +1 = 解説記事リンク
        separatorBuilder: (_, __) => Divider(),
        itemBuilder: (context, index) {
          if (index < sensors.length) {
            final sensor = sensors[index];
            return ListTile(
              leading: Icon(sensor['icon']),
              title: Text(sensor['name']),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => sensor['widget']),
                );
              },
            );
          } else {
            // 一番下の「解説記事一覧」
            return _buildArticlesAccordion(context);
          }
        },
      ),
    );
  }

  Widget _buildArticlesAccordion(BuildContext context) {
    return ExpansionTile(
      leading: Icon(Icons.menu_book, color: Colors.blue),
      title: Text(
        'センサー実験\ 解説記事一覧',
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: true,
      children: articlesByCategory.entries.map((entry) {
        final categoryName = entry.key;
        final videos = entry.value;
        return _buildCategory(context, categoryName, videos);
      }).toList(),
    );
  }


  Widget _buildCategory(BuildContext context, String categoryName, List<Video> videos) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          color: Colors.grey[300],
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(
            categoryName,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
        ...videos.map((video) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 2),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              leading: Image.asset(
                'assets/others/smartPhoneOnly.gif',
                width: 60,
                height: 40,
                fit: BoxFit.contain,
              ),
              title: Text(video.title, style: TextStyle(fontSize: 15, color: Colors.black87)),
              tileColor: Colors.blue[50]?.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => VideoDetailView(video: video)),
                );
              },
            ),
          );
        }).toList(),
        SizedBox(height: 4),
      ],
    );
  }
}