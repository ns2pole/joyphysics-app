import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:joyphysics/experiment/sensor_availability.dart';
import 'package:joyphysics/experiment/sensor_availability_types.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.joyphysics/sensor_check');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() {
    messenger.setMockMethodCallHandler(channel, null);
  });

  test('ネイティブが true ならジャイロは利用可', () async {
    messenger.setMockMethodCallHandler(channel, (call) async {
      expect(call.method, 'isSensorAvailable');
      expect(call.arguments['sensorType'], 'gyroscope');
      return true;
    });

    final status = await checkSensorAvailability(SensorKind.gyroscope);
    expect(status.isAvailable, isTrue);
  });

  test('メソッドチャネル欠落時は非対応のまま', () async {
    final status = await checkSensorAvailability(SensorKind.gyroscope);
    expect(status.state, SensorAvailabilityState.unavailable);
  });
}
