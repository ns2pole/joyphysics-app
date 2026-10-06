import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/sensor_availability_types.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

String sensorAvailabilityMessage(BuildContext context, SensorAvailability a) {
  switch (a.state) {
    case SensorAvailabilityState.available:
      return a.message;
    case SensorAvailabilityState.checking:
      return animUi(context, ja: '確認中', en: 'Checking…');
    case SensorAvailabilityState.unavailable:
      return animUi(context, ja: '端末非対応', en: 'Not supported on this device');
    case SensorAvailabilityState.denied:
      return animUi(context, ja: '許可が拒否されました', en: 'Permission denied');
    case SensorAvailabilityState.permissionRequired:
      return animUi(
        context,
        ja: '利用には許可が必要です',
        en: 'Permission required',
      );
  }
}

String magnetometerWarningText(BuildContext context, double magnitude) {
  if (magnitude < 200) {
    return animUi(
      context,
      ja: '磁場は正常範囲内です。',
      en: 'Magnetic field is within the normal range.',
    );
  }
  if (magnitude < 500) {
    return animUi(
      context,
      ja: 'やや強い磁場を検知しています。',
      en: 'A somewhat strong magnetic field was detected.',
    );
  }
  if (magnitude < 2000) {
    return animUi(
      context,
      ja: '強力な磁場です。',
      en: 'Strong magnetic field.',
    );
  }
  return animUi(
    context,
    ja: '非常に強い磁場です！端末への影響にご注意ください。',
    en: 'Very strong magnetic field! Be careful of effects on the device.',
  );
}

/// Alert color by resultant field strength [μT].
Color magnetometerAlertColor(double magnitude) {
  if (magnitude < 200) return Colors.green;
  if (magnitude < 500) return Colors.yellow.shade700;
  if (magnitude < 2000) return Colors.orange;
  return Colors.red;
}
