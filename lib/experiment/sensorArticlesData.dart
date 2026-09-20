import 'package:joyphysics/dataExporter.dart';
import 'package:joyphysics/model.dart';

const String kSensorCategoryName = 'センサー';

final Map<String, List<Video>> sensorArticlesByCategory = {
  '加速度センサー': [accelerometer],
  'ジャイロセンサー': [gyroscope],
  '気圧センサー': [barometer],
  '磁気センサー': [magnetometer],
  '周波数センサー': [
    frequencyAndDoReMi,
    beat,
    doppler,
    dopplerObserverMoving,
    dopplerMovingWall,
  ],
  '光センサー': [luxMeasurement],
  'その他': [soundGenerate],
};
