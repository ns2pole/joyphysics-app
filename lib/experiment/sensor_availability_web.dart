import 'dart:html' as html;
import 'dart:js_util' as js_util;
import 'sensor_availability_types.dart';

bool _hasWindowProp(String name) => js_util.hasProperty(html.window, name);

Future<SensorAvailability> checkSensorAvailability(SensorKind kind) async {
  switch (kind) {
    case SensorKind.accelerometer:
      if (!_hasWindowProp('DeviceMotionEvent')) return SensorAvailability.unavailable;
      final ctor = js_util.getProperty(html.window, 'DeviceMotionEvent');
      if (js_util.hasProperty(ctor, 'requestPermission')) {
        return SensorAvailability.permissionRequired;
      }
      return const SensorAvailability(SensorAvailabilityState.available);
    case SensorKind.magnetometer:
      if (!_hasWindowProp('DeviceOrientationEvent')) return SensorAvailability.unavailable;
      final ctor = js_util.getProperty(html.window, 'DeviceOrientationEvent');
      if (js_util.hasProperty(ctor, 'requestPermission')) {
        return SensorAvailability.permissionRequired;
      }
      return const SensorAvailability(SensorAvailabilityState.available);
    case SensorKind.microphone:
      final nav = html.window.navigator;
      if (nav.mediaDevices == null) return SensorAvailability.unavailable;
      return SensorAvailability.permissionRequired;
    case SensorKind.barometer:
      return SensorAvailability.unavailable;
    case SensorKind.light:
      return _hasWindowProp('AmbientLightSensor')
          ? const SensorAvailability(SensorAvailabilityState.available)
          : SensorAvailability.unavailable;
  }
}

Future<SensorAvailability> requestSensorPermission(SensorKind kind) async {
  try {
    switch (kind) {
      case SensorKind.accelerometer:
        if (!_hasWindowProp('DeviceMotionEvent')) return SensorAvailability.unavailable;
        final ctor = js_util.getProperty(html.window, 'DeviceMotionEvent');
        if (!js_util.hasProperty(ctor, 'requestPermission')) {
          return const SensorAvailability(SensorAvailabilityState.available);
        }
        final result = await js_util.promiseToFuture(
          js_util.callMethod(ctor, 'requestPermission', []),
        );
        return result == 'granted'
            ? const SensorAvailability(SensorAvailabilityState.available)
            : SensorAvailability.denied;
      case SensorKind.magnetometer:
        if (!_hasWindowProp('DeviceOrientationEvent')) return SensorAvailability.unavailable;
        final ctor = js_util.getProperty(html.window, 'DeviceOrientationEvent');
        if (!js_util.hasProperty(ctor, 'requestPermission')) {
          return const SensorAvailability(SensorAvailabilityState.available);
        }
        final result = await js_util.promiseToFuture(
          js_util.callMethod(ctor, 'requestPermission', []),
        );
        return result == 'granted'
            ? const SensorAvailability(SensorAvailabilityState.available)
            : SensorAvailability.denied;
      case SensorKind.microphone:
        final mediaDevices = html.window.navigator.mediaDevices;
        if (mediaDevices == null) return SensorAvailability.unavailable;
        final dynamic stream =
            await mediaDevices.getUserMedia(<String, dynamic>{'audio': true});
        try {
          final dynamic tracks = js_util.callMethod(stream, 'getTracks', []);
          final int length = js_util.getProperty(tracks, 'length') as int? ?? 0;
          for (int i = 0; i < length; i++) {
            final dynamic track = js_util.getProperty(tracks, i);
            js_util.callMethod(track, 'stop', []);
          }
        } catch (_) {}
        return const SensorAvailability(SensorAvailabilityState.available);
      case SensorKind.barometer:
        return SensorAvailability.unavailable;
      case SensorKind.light:
        return await checkSensorAvailability(kind);
    }
  } catch (_) {
    return SensorAvailability.denied;
  }
}
