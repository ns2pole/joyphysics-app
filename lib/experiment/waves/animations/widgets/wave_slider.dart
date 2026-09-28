import 'package:flutter/material.dart';
import 'dart:math' as math;

/// T スライダーが無い記事も含め、波動アニメの既定周期。
const double kDefaultWavePeriodT = 0.7;

/// 波動パラメータ調整用の共通スライダーウィジェット
class WaveParameterSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final int maxLines;
  final TextAlign labelAlign;
  final double labelWidth;
  final bool labelAbove;
  final String Function(double value)? formatValue;
  final double valueWidth;

  const WaveParameterSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.maxLines = 1,
    this.labelAlign = TextAlign.start,
    this.labelWidth = 56,
    this.labelAbove = false,
    this.formatValue,
    this.valueWidth = 44,
  });

  @override
  Widget build(BuildContext context) {
    final labelText = Text(
      label,
      style: const TextStyle(fontWeight: FontWeight.bold),
      maxLines: maxLines,
      textAlign: labelAlign,
      softWrap: maxLines > 1,
      overflow: maxLines > 1 ? TextOverflow.clip : TextOverflow.visible,
    );
    final sliderRow = Row(
      children: [
        if (!labelAbove)
          SizedBox(
            width: labelWidth,
            child: labelText,
          ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: valueWidth,
          child: Text(
            formatValue?.call(value) ??
                value.toStringAsFixed(value < 0.1 ? 3 : 2),
            style: const TextStyle(fontSize: 12, fontFamily: 'Courier'),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
    if (!labelAbove) return sliderRow;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        labelText,
        sliderRow,
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
  }) : super(label: label, min: 0.1, max: 5.0);
}

class PeriodTSlider extends WaveParameterSlider {
  PeriodTSlider({
    super.key,
    required super.value,
    required super.onChanged,
    String label = 'T',
  }) : super(label: label, min: 0.1, max: 1.5);
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
    bool showDegrees = false,
  }) : super(
          label: 'θ',
          min: 0.0,
          max: maxDeg * math.pi / 180,
          valueWidth: showDegrees ? 52 : 44,
          formatValue: showDegrees
              ? (v) => '${(v * 180 / math.pi).toStringAsFixed(1)}°'
              : null,
        );
}

class PhiSlider extends WaveParameterSlider {
  PhiSlider({super.key, required super.value, required super.onChanged})
      : super(label: 'φ', min: 0.0, max: 2 * math.pi);
}

