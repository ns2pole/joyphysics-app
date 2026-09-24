import 'dart:math' as math;

import 'package:flutter/material.dart';

/// 運動エネルギー。速度や力の矢印の青・オレンジとは被せない。
const Color kEnergyKinetic = Color(0xFF7B1FA2);

/// 位置エネルギー。
const Color kEnergyPotential = Color(0xFF2E7D32);

/// 熱になった分。
const Color kEnergyHeat = Color(0xFFBCAAA4);

const double kEnergyGaugeWidth = 128;
const double kEnergyGaugeBarHeight = 10;

const String kLabelKinetic = '運動エネルギー';
const String kLabelKinetic1 = 'm₁の運動エネルギー';
const String kLabelKinetic2 = 'm₂の運動エネルギー';
const String kLabelGravitation = '万有引力位置エネルギー';
const String kLabelGravity = '重力による位置エネルギー';
const String kLabelElastic = '弾性エネルギー';
const String kLabelHeat = '熱エネルギー';

/// ゲージの1区画。2体の運動エネルギーを物体ごとに描くときに使う。
class EnergyPortion {
  const EnergyPortion({
    required this.value,
    required this.label,
    required this.color,
  });

  final double value;
  final String label;
  final Color color;

  EnergyPortion cleaned() => EnergyPortion(
        value: value.isNaN || value.isInfinite || value < 0 ? 0 : value,
        label: label,
        color: color,
      );

  EnergyPortion scaled(double factor) => EnergyPortion(
        value: value * factor,
        label: label,
        color: color,
      );
}

/// 力学的エネルギーの内訳。単位は J。枠の長さは [scale]。
class EnergyLedger {
  const EnergyLedger({
    required this.kinetic,
    required this.potential,
    required this.dissipated,
    required this.scale,
    this.kineticPortions = const [],
    this.legendKinetic = true,
    this.legendPotential = true,
    this.legendHeat = false,
    this.potentialLabel = '位置エネルギー',
  });

  final double kinetic;
  final double potential;
  final double dissipated;
  final double scale;

  /// 空なら [kinetic] を1本で描く。あるときはこの合計を運動エネルギーとして描く。
  final List<EnergyPortion> kineticPortions;
  final bool legendKinetic;
  final bool legendPotential;
  final bool legendHeat;

  /// 緑の帯の名前。ばねは弾性、万有引力は万有引力、など。
  final String potentialLabel;

  static double _clean(double value) {
    if (value.isNaN || value.isInfinite || value < 0) return 0;
    return value;
  }

  /// 負と非数を 0 にし、合計が枠を超えるときは枠内に比例して収める。
  /// 枠が 0 のときは空。
  EnergyLedger normalize() {
    final portions = kineticPortions.map((p) => p.cleaned()).toList();
    final k = portions.isEmpty
        ? _clean(kinetic)
        : portions.fold<double>(0, (sum, p) => sum + p.value);
    final u = _clean(potential);
    final q = _clean(dissipated);
    final s = _clean(scale);
    if (s <= 1e-12) {
      return EnergyLedger(
        kinetic: 0,
        potential: 0,
        dissipated: 0,
        scale: 0,
        kineticPortions:
            portions.map((p) => p.scaled(0)).toList(growable: false),
        legendKinetic: legendKinetic,
        legendPotential: legendPotential,
        legendHeat: legendHeat,
        potentialLabel: potentialLabel,
      );
    }
    final sum = k + u + q;
    if (sum <= s + 1e-9) {
      return EnergyLedger(
        kinetic: k,
        potential: u,
        dissipated: q,
        scale: s,
        kineticPortions: portions,
        legendKinetic: legendKinetic,
        legendPotential: legendPotential,
        legendHeat: legendHeat,
        potentialLabel: potentialLabel,
      );
    }
    final factor = s / sum;
    return EnergyLedger(
      kinetic: k * factor,
      potential: u * factor,
      dissipated: q * factor,
      scale: s,
      kineticPortions:
          portions.map((p) => p.scaled(factor)).toList(growable: false),
      legendKinetic: legendKinetic,
      legendPotential: legendPotential,
      legendHeat: legendHeat,
      potentialLabel: potentialLabel,
    );
  }
}

class _ReadoutLayout {
  const _ReadoutLayout({
    required this.card,
    required this.text,
    required this.legend,
    required this.column,
    required this.gauge,
    required this.contentHeight,
    required this.gaugeBlock,
  });

  final Rect card;
  final TextPainter text;
  final TextPainter legend;
  final double column;
  final double gauge;
  final double contentHeight;
  final double gaugeBlock;
}

_ReadoutLayout _readoutLayout(
  String text,
  EnergyLedger ledger, {
  required double textColumnWidth,
  required double gaugeWidth,
  Size? bounds,
}) {
  const ink = Color(0xFF37474F);
  const style = TextStyle(
    color: ink,
    fontSize: 11,
    fontFamily: 'Courier',
    height: 1.35,
  );
  final tp = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: TextDirection.ltr,
  )..layout();

  final legend = _legendEntries(ledger);
  final legendPainter = TextPainter(
    text: TextSpan(children: legend),
    textDirection: TextDirection.ltr,
  )..layout();

  var column = math.max(textColumnWidth, tp.width);
  var gauge = math.max(gaugeWidth, legendPainter.width);
  if (bounds != null) {
    final room = bounds.width - 24;
    if (column + 12 + gauge > room) {
      column = math.max(tp.width, math.min(column, room - 12 - gauge));
    }
    if (column + 12 + gauge > room) {
      gauge = math.max(72.0, room - column - 12);
    }
  }
  if (legend.isNotEmpty && legendPainter.width > gauge) {
    legendPainter.layout(maxWidth: gauge);
  }
  final gaugeBlock = kEnergyGaugeBarHeight +
      (legend.isEmpty ? 0 : 4 + legendPainter.height);
  final contentHeight = math.max(tp.height, gaugeBlock);
  return _ReadoutLayout(
    card: Rect.fromLTWH(8, 8, column + 12 + gauge + 16, contentHeight + 12),
    text: tp,
    legend: legendPainter,
    column: column,
    gauge: gauge,
    contentHeight: contentHeight,
    gaugeBlock: gaugeBlock,
  );
}

/// 白の数値箱の矩形。アニメ本体はこの下端より下に置く。
Rect dynamicsReadoutCard(
  String text,
  EnergyLedger ledger, {
  double textColumnWidth = 168,
  double gaugeWidth = kEnergyGaugeWidth,
  Size? bounds,
}) {
  return _readoutLayout(
    text,
    ledger,
    textColumnWidth: textColumnWidth,
    gaugeWidth: gaugeWidth,
    bounds: bounds,
  ).card;
}

/// 白の数値箱の右に、固定幅のエネルギーゲージを描く。
/// [textColumnWidth] を桁が伸びても足りる幅にしておくと、ゲージの左端は動かない。
void paintDynamicsReadout(
  Canvas canvas,
  String text,
  EnergyLedger ledger, {
  double textColumnWidth = 168,
  double gaugeWidth = kEnergyGaugeWidth,
  Size? bounds,
}) {
  final layout = _readoutLayout(
    text,
    ledger,
    textColumnWidth: textColumnWidth,
    gaugeWidth: gaugeWidth,
    bounds: bounds,
  );
  final card = RRect.fromRectAndRadius(layout.card, const Radius.circular(8));
  canvas.drawRRect(
    card,
    Paint()..color = Colors.white.withValues(alpha: 0.92),
  );
  layout.text.paint(canvas, const Offset(16, 14));

  final barTop = 14 + (layout.contentHeight - layout.gaugeBlock) / 2;
  final barLeft = 16 + layout.column + 12;
  _paintBar(
    canvas,
    Rect.fromLTWH(barLeft, barTop, layout.gauge, kEnergyGaugeBarHeight),
    ledger.normalize(),
  );
  if (layout.gaugeBlock > kEnergyGaugeBarHeight) {
    layout.legend.paint(
      canvas,
      Offset(barLeft, barTop + kEnergyGaugeBarHeight + 4),
    );
  }
}

List<InlineSpan> _legendEntries(EnergyLedger ledger) {
  final spans = <InlineSpan>[];
  void add(String label, Color color) {
    if (spans.isNotEmpty) {
      spans.add(const TextSpan(text: '\n'));
    }
    spans.add(TextSpan(
      text: '● ',
      style: TextStyle(fontSize: 11, color: color, height: 1.35),
    ));
    spans.add(TextSpan(
      text: label,
      style: const TextStyle(
        fontSize: 11,
        color: Color(0xFF37474F),
        height: 1.35,
      ),
    ));
  }

  if (ledger.legendKinetic) {
    if (ledger.kineticPortions.isEmpty) {
      add(kLabelKinetic, kEnergyKinetic);
    } else {
      for (final portion in ledger.kineticPortions) {
        add(portion.label, portion.color);
      }
    }
  }
  if (ledger.legendPotential) add(ledger.potentialLabel, kEnergyPotential);
  if (ledger.legendHeat) add(kLabelHeat, kEnergyHeat);
  return spans;
}

void _paintBar(Canvas canvas, Rect rect, EnergyLedger ledger) {
  final track = RRect.fromRectAndRadius(rect, const Radius.circular(3));
  canvas.drawRRect(
    track,
    Paint()..color = const Color(0xFFECEFF1),
  );
  if (ledger.scale <= 1e-12) return;
  final parts = <(double, Color)>[
    if (ledger.kineticPortions.isEmpty)
      (ledger.kinetic, kEnergyKinetic)
    else
      for (final portion in ledger.kineticPortions)
        (portion.value, portion.color),
    (ledger.potential, kEnergyPotential),
    (ledger.dissipated, kEnergyHeat),
  ];
  var x = rect.left;
  for (final part in parts) {
    final width = rect.width * (part.$1 / ledger.scale);
    if (width <= 0) continue;
    final slice = Rect.fromLTWH(x, rect.top, width, rect.height);
    canvas.save();
    canvas.clipRRect(track);
    canvas.drawRect(slice, Paint()..color = part.$2);
    canvas.restore();
    x += width;
  }
}
