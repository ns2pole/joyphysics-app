import 'package:flutter/material.dart';
import 'package:joyphysics/model.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/experiment/ExperimentView.dart';
import 'package:joyphysics/experiment/dynamics/AccelerometerExperimentWidget.dart';
import 'package:joyphysics/experiment/dynamics/BarometerExperimentWidget.dart';
import 'package:joyphysics/experiment/electroMagnetism/MagnetometerExperimentWidget.dart';
import 'package:joyphysics/experiment/waves/LuxMeasurementWidget.dart';
import 'package:joyphysics/experiment/waves/FrequencyMeasureWidget.dart';
import 'package:joyphysics/shared_components.dart';

import 'package:flutter/services.dart';

class SensorListView extends StatefulWidget {
  const SensorListView({super.key});

  @override
  State<SensorListView> createState() => _SensorListViewState();
}

class _SensorListViewState extends State<SensorListView> {
  static const _sensorCheckChannel = MethodChannel('com.joyphysics/sensor_check');

  final Map<String, bool> _availability = {
    '加速度センサー': true,
    '気圧センサー': true,
    '磁気センサー': true,
    '周波数センサー': true,
    '光センサー': true,
  };

  @override
  void initState() {
    super.initState();
    // Web では MethodChannel が使えないためセンサー判定をスキップ
    if (kIsWeb) {
      for (final k in _availability.keys) {
        _availability[k] = false;
      }
      return;
    }
    _checkAllSensors();
  }

  Future<void> _checkAllSensors() async {
    final Map<String, String> sensorKeys = {
      '加速度センサー': 'accelerometer',
      '気圧センサー': 'barometer',
      '磁気センサー': 'magnetometer',
      '周波数センサー': 'microphone',
      '光センサー': 'light',
    };

    for (var entry in sensorKeys.entries) {
      try {
        final bool available = await _sensorCheckChannel.invokeMethod(
          'isSensorAvailable',
          {'sensorType': entry.value},
        );
        if (mounted) {
          setState(() {
            _availability[entry.key] = available;
          });
        }
      } catch (e) {
        debugPrint('Error checking sensor ${entry.key}: $e');
      }
    }
  }

  final List<Map<String, dynamic>> sensors = [
    {
      'name': '加速度センサー',
      'icon': Icons.speed,
      'widget': AccelerometerExperimentWidget(),
      'key': '加速度センサー',
    },
    {
      'name': '気圧センサー',
      'icon': Icons.compress,
      'widget': BarometerExperimentWidget(),
      'key': '気圧センサー',
    },
    {
      'name': '磁気センサー',
      'icon': Icons.sensors,
      'widget': MagnetometerExperimentWidget(height: 380),
      'key': '磁気センサー',
    },
    {
      'name': '周波数センサー(音波)',
      'icon': Icons.graphic_eq,
      'widget': FrequencyMeasureWidget(),
      'key': '周波数センサー',
    },
    if (!(kIsWeb || defaultTargetPlatform == TargetPlatform.iOS))
      {
        'name': '光センサー',
        'icon': Icons.wb_sunny,
        'widget': LuxMeasurementWidget(),
        'key': '光センサー',
      },
  ];

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
            final availabilityKey = sensor['key'] as String;
            final bool isAvailable = _availability[availabilityKey] ?? true;

            return ListTile(
              leading: Icon(
                sensor['icon'],
                color: isAvailable ? null : Colors.grey,
              ),
              title: Text(
                isAvailable ? sensor['name'] : '${sensor['name']}(端末非対応)',
                style: TextStyle(
                  color: isAvailable ? null : Colors.grey,
                ),
              ),
              enabled: isAvailable,
              onTap: isAvailable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => sensor['widget']),
                      );
                    }
                  : null,
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

  Widget _buildCategory(
      BuildContext context, String categoryName, List<Video> videos) {
    final bool isAvailable = _availability[categoryName] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(name: categoryName, disabled: !isAvailable, fontSize: 16),
        ...videos.map((video) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 2),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 0),
              leading: Opacity(
                opacity: isAvailable ? 1.0 : 0.5,
                child: Image.asset(
                  'assets/icon/smartphone_only.png',
                  width: 60,
                  height: 40,
                  fit: BoxFit.contain,
                ),
              ),
              title: Text(
                video.title,
                style: TextStyle(
                  fontSize: 15,
                  color: isAvailable ? Colors.black87 : Colors.grey,
                ),
              ),
              tileColor: isAvailable
                  ? Colors.blue[50]?.withOpacity(0.1)
                  : Colors.grey[100]?.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              enabled: isAvailable,
              onTap: isAvailable
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => VideoDetailView(video: video)),
                      );
                    }
                  : null,
            ),
          );
        }).toList(),
        SizedBox(height: 4),
      ],
    );
  }
}
