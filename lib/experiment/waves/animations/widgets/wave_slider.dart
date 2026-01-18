import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 波動パラメータ調整用の共通スライダーウィジェット
class WaveParameterSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  const WaveParameterSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
            width: 44,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            value.toStringAsFixed(value < 0.1 ? 3 : 2),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

class LambdaSlider extends WaveParameterSlider {
  LambdaSlider({
    super.key,
    required super.value,
    required super.onChanged,
    String label = 'λ',
  }) : super(label: label, min: 0.001, max: 3.0);
}

class PeriodTSlider extends WaveParameterSlider {
  PeriodTSlider({
    super.key,
    required super.value,
    required super.onChanged,
    String label = 'T',
  }) : super(label: label, min: 0.001, max: 2.0);
}

class RefractiveIndexSlider extends WaveParameterSlider {
  RefractiveIndexSlider({super.key, required super.value, required super.onChanged})
      : super(label: 'n', min: 1.0, max: 2.5);
}

class ThicknessLSlider extends WaveParameterSlider {
  ThicknessLSlider({
    super.key,
    required super.value,
    required super.onChanged,
    String label = 'L',
    double min = 0.0,
    double max = 5.0,
  }) : super(label: label, min: min, max: max);
}

class ThetaSlider extends WaveParameterSlider {
  ThetaSlider({
    super.key,
    required super.value,
    required super.onChanged,
    double maxDeg = 90.0,
  }) : super(
          label: 'θ',
          min: 0.0,
          max: maxDeg * math.pi / 180,
        );
}

class PhiSlider extends WaveParameterSlider {
  PhiSlider({super.key, required super.value, required super.onChanged})
      : super(label: 'φ', min: 0.0, max: 2 * math.pi);
}

