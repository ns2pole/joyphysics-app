import 'dart:math' as math;
import 'package:flutter/material.dart';


class WaveComponent {
  final String id;
  final String label;
  final Color color;
  final double value;

  WaveComponent({
    required this.id,
    required this.label,
    required this.color,
    required this.value,
  });
}

class WaveMarker {
  final math.Point<double> point;
  final Color color;

  const WaveMarker({
    required this.point,
    this.color = Colors.yellow,
  });
}

/// A wave field defines the phase of the wave at (x,y,t).
/// Units are arbitrary, but consistent with the painter's world coordinates.
abstract class WaveField {
  const WaveField();

  double phase(double x, double y, double t);

  double z(double x, double y, double t) => math.sin(phase(x, y, t));

  /// Returns a list of individual wave components at (x,y,t).
  /// [activeIds] is a set of component IDs that should be included.
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    return [
      WaveComponent(
        id: 'total',
        label: '合成波',
        color: Colors.blue,
        value: z(x, y, t),
      ),
    ];
  }
}

class PlaneWaveField extends WaveField {
  const PlaneWaveField({
    required this.theta,
    required this.lambda,
    required this.periodT,
    this.amplitude = 0.4,
  });

  final double theta;

  final double lambda;

  final double periodT;

  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final dir = x * math.cos(theta) + y * math.sin(theta);
    return 2 * math.pi * ((dir / lambda) - (t / periodT));
  }

  @override
  double z(double x, double y, double t) {
    final k1 = 2 * math.pi / lambda;
    const dOffset = 7.5;
    // phase(x,y,t) is (k*path - omega*t)
    final p = -(phase(x, y, t) + k1 * dOffset);
    return (p > 0) ? amplitude * math.sin(p) : 0.0;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    if (activeIds.contains('total')) {
      return [
        WaveComponent(
          id: 'total',
          label: '平面波',
          color: Colors.blueAccent,
          value: z(x, y, t),
        ),
      ];
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    return other is PlaneWaveField &&
        other.theta == theta &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(theta, lambda, periodT, amplitude);
}

/// Refraction through a slab medium occupying 0 < x < slabWidth (on z=0 plane),
/// with n1 fixed to 1 and n2 = n inside the slab.
///
/// The wave is constructed by keeping ky continuous across boundaries and using
/// piecewise kx. Phase offsets ensure continuity at x=0 and x=slabWidth.
class SlabRefractionWaveField extends WaveField {
  const SlabRefractionWaveField({
    required this.theta,
    required this.lambda,
    required this.periodT,
    required this.n,
    this.slabWidth = 1.0,
    this.amplitude = 0.4,
  });

  final double theta;

  final double lambda;
  final double periodT;

  /// Refractive index inside slab (n2). Outside is n1 = 1.
  final double n;

  final double slabWidth;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final k1 = 2 * math.pi / lambda;
    final k2 = (n <= 0) ? k1 : (n * k1);
    final omega = 2 * math.pi / periodT;

    final ky = k1 * math.sin(theta);
    final kx1 = k1 * math.cos(theta);
    final kx2 = math.sqrt(math.max(k2 * k2 - ky * ky, 0.0));

    if (x < 0) {
      return kx1 * x + ky * y - omega * t;
    }
    if (x <= slabWidth) {
      return kx2 * x + ky * y - omega * t;
    }

    // Offset to keep phase continuous at x=slabWidth.
    final offset = (kx2 - kx1) * slabWidth;
    return kx1 * x + ky * y + offset - omega * t;
  }

  @override
  double z(double x, double y, double t) {
    final k1 = 2 * math.pi / lambda;
    const dOffset = 7.5;

    // phase(x,y,t) is (k*path - omega*t)
    // we want omega*t - (k*path + k*dOffset)
    // which is - (phase(x,y,t) + k*dOffset)
    final p = -(phase(x, y, t) + k1 * dOffset);
    return (p > 0) ? amplitude * math.sin(p) : 0.0;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    if (activeIds.contains('total')) {
      return [
        WaveComponent(
          id: 'total',
          label: '屈折波',
          color: Colors.blueAccent,
          value: z(x, y, t),
        ),
      ];
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    return other is SlabRefractionWaveField &&
        other.theta == theta &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.n == n &&
        other.slabWidth == slabWidth &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(theta, lambda, periodT, n, slabWidth, amplitude);
}

enum ReflectionMode { incident, reflected, combined }

class ReflectionWaveField extends WaveField {
  const ReflectionWaveField({
    required this.theta,
    required this.lambda,
    required this.periodT,
    required this.mode,
    this.isFixedEnd = false,
    this.amplitude = 0.4,
  });

  final double theta;
  final double lambda;
  final double periodT;
  final ReflectionMode mode;
  final bool isFixedEnd;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final k = 2 * math.pi / lambda;
    final omega = 2 * math.pi / periodT;
    const dOffset = 7.5;
    final di = x * math.cos(theta) + y * math.sin(theta) + dOffset;
    return omega * t - k * di;
  }

  @override
  double z(double x, double y, double t) {
    if (x > 0) return 0.0; // Medium boundary at x=0

    final k = 2 * math.pi / lambda;
    final omega = 2 * math.pi / periodT;

    // We want the wave to start outside the view (range is ~5).
    // Let's add an offset so at t=0, even at (-5, -5), phase is negative.
    // d = x*cos + y*sin. Max d for x,y in [-5,5] is ~7.
    const dOffset = 7.5;

    final di = x * math.cos(theta) + y * math.sin(theta) + dOffset;
    final dr = -x * math.cos(theta) + y * math.sin(theta) + dOffset;

    final phaseI = omega * t - k * di;
    final phaseR = omega * t - k * dr;

    final zi = (phaseI > 0) ? amplitude * math.sin(phaseI) : 0.0;
    double zr = (phaseR > 0) ? amplitude * math.sin(phaseR) : 0.0;

    if (isFixedEnd) {
      zr = -zr;
    }

    switch (mode) {
      case ReflectionMode.incident:
        return zi;
      case ReflectionMode.reflected:
        return zr;
      case ReflectionMode.combined:
        return zi + zr;
    }
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    final k = 2 * math.pi / lambda;
    final omega = 2 * math.pi / periodT;
    const dOffset = 7.5;

    final di = x * math.cos(theta) + y * math.sin(theta) + dOffset;
    final dr = -x * math.cos(theta) + y * math.sin(theta) + dOffset;

    final phaseI = omega * t - k * di;
    final phaseR = omega * t - k * dr;

    final zi = (x <= 0 && phaseI > 0) ? amplitude * math.sin(phaseI) : 0.0;
    double zr = (x <= 0 && phaseR > 0) ? amplitude * math.sin(phaseR) : 0.0;

    if (isFixedEnd) {
      zr = -zr;
    }

    final List<WaveComponent> res = [];
    if (activeIds.contains('incident')) {
      res.add(WaveComponent(
          id: 'incident', label: '入射波', color: Colors.purpleAccent, value: zi));
    }
    if (activeIds.contains('reflected')) {
      res.add(WaveComponent(
          id: 'reflected', label: '反射波', color: Colors.greenAccent, value: zr));
    }
    if (activeIds.contains('combined')) {
      res.add(WaveComponent(
          id: 'combined',
          label: '合成波',
          color: Colors.blueAccent,
          value: zi + zr));
    }
    return res;
  }

  @override
  bool operator ==(Object other) {
    return other is ReflectionWaveField &&
        other.theta == theta &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.mode == mode &&
        other.isFixedEnd == isFixedEnd &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(theta, lambda, periodT, mode, isFixedEnd, amplitude);
}

class OneDimensionReflectionField extends WaveField {
  const OneDimensionReflectionField({
    required this.lambda,
    required this.periodT,
    required this.mode,
    required this.isFixedEnd,
    this.boundaryX = 5.0,
    this.amplitude = 0.4,
  });

  final double lambda;
  final double periodT;
  final ReflectionMode mode;
  final bool isFixedEnd;
  final double boundaryX;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    const xStart = -7.5;
    final distI = x - xStart;
    return 2 * math.pi * (t / periodT - distI / lambda);
  }

  @override
  double z(double x, double y, double t) {
    if (x > boundaryX) return 0.0;

    // Start position for the wave (outside the visible range)
    const xStart = -7.5;

    final distI = x - xStart;
    final distR = (boundaryX - xStart) + (boundaryX - x);

    final phaseI = 2 * math.pi * (t / periodT - distI / lambda);
    final phaseR = 2 * math.pi * (t / periodT - distR / lambda);

    final zi = (phaseI > 0) ? amplitude * math.sin(phaseI) : 0.0;
    
    double zr = 0.0;
    if (phaseR > 0) {
      if (isFixedEnd) {
        // Fixed end reflection: pi phase shift (negative amplitude)
        zr = -amplitude * math.sin(phaseR);
      } else {
        // Free end reflection: no phase shift
        zr = amplitude * math.sin(phaseR);
      }
    }

    switch (mode) {
      case ReflectionMode.incident:
        return zi;
      case ReflectionMode.reflected:
        return zr;
      case ReflectionMode.combined:
        return zi + zr;
    }
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    const xStart = -7.5;
    final distI = x - xStart;
    final distR = (boundaryX - xStart) + (boundaryX - x);
    final omega = 2 * math.pi / periodT;
    final k = 2 * math.pi / lambda;

    final phaseI = omega * t - k * distI;
    final phaseR = omega * t - k * distR;

    final zi = (x <= boundaryX && phaseI > 0) ? amplitude * math.sin(phaseI) : 0.0;
    final zr = (x <= boundaryX && phaseR > 0)
        ? (isFixedEnd
            ? -amplitude * math.sin(phaseR)
            : amplitude * math.sin(phaseR))
        : 0.0;

    final List<WaveComponent> res = [];
    if (activeIds.contains('incident')) {
      res.add(WaveComponent(
          id: 'incident', label: '入射波', color: Colors.purpleAccent, value: zi));
    }
    if (activeIds.contains('reflected')) {
      res.add(WaveComponent(
          id: 'reflected', label: '反射波', color: Colors.greenAccent, value: zr));
    }
    if (activeIds.contains('combined')) {
      res.add(WaveComponent(
          id: 'combined',
          label: '合成波',
          color: Colors.blueAccent,
          value: zi + zr));
    }
    return res;
  }

  @override
  bool operator ==(Object other) {
    return other is OneDimensionReflectionField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.mode == mode &&
        other.isFixedEnd == isFixedEnd &&
        other.boundaryX == boundaryX &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode =>
      Object.hash(lambda, periodT, mode, isFixedEnd, boundaryX, amplitude);
}

class OneDimensionSlabRefractionField extends WaveField {
  const OneDimensionSlabRefractionField({
    required this.lambda,
    required this.periodT,
    required this.n,
    this.slabStart = 0.0,
    this.slabEnd = 1.0,
    this.amplitude = 0.4,
  });

  final double lambda;
  final double periodT;
  final double n;
  final double slabStart;
  final double slabEnd;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    const xSource = -7.5;
    final omega = 2 * math.pi / periodT;
    final k1 = 2 * math.pi / lambda;
    final k2 = k1 * n;

    if (x < slabStart) {
      return omega * t - k1 * (x - xSource);
    } else if (x <= slabEnd) {
      return omega * t - k1 * (slabStart - xSource) - k2 * (x - slabStart);
    } else {
      return omega * t - k1 * (slabStart - xSource) - k2 * (slabEnd - slabStart) - k1 * (x - slabEnd);
    }
  }

  @override
  double z(double x, double y, double t) {
    final v1 = lambda / periodT;
    final v2 = v1 / n;

    // Time taken to reach position x
    double tReach = 0.0;
    const xSource = -7.5; // Start left

    if (x < slabStart) {
      tReach = (x - xSource) / v1;
    } else if (x <= slabEnd) {
      tReach = (slabStart - xSource) / v1 + (x - slabStart) / v2;
    } else {
      tReach = (slabStart - xSource) / v1 + (slabEnd - slabStart) / v2 + (x - slabEnd) / v1;
    }

    if (t < tReach) return 0.0;

    // Calculate phase continuously
    double localPhase = 0.0;
    final omega = 2 * math.pi / periodT;
    final k1 = 2 * math.pi / lambda;
    final k2 = k1 * n;

    if (x < slabStart) {
      localPhase = omega * t - k1 * (x - xSource);
    } else if (x <= slabEnd) {
      localPhase = omega * t - k1 * (slabStart - xSource) - k2 * (x - slabStart);
    } else {
      localPhase = omega * t - k1 * (slabStart - xSource) - k2 * (slabEnd - slabStart) - k1 * (x - slabEnd);
    }

    return amplitude * math.sin(localPhase);
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    const xSource = -7.5;
    final v1 = lambda / periodT;
    final v2 = v1 / n;
    final k1 = 2 * math.pi / lambda;
    final k2 = k1 * n;
    final omega = 2 * math.pi / periodT;

    double tReach = 0.0;
    if (x < slabStart) {
      tReach = (x - xSource) / v1;
    } else if (x <= slabEnd) {
      tReach = (slabStart - xSource) / v1 + (x - slabStart) / v2;
    } else {
      tReach = (slabStart - xSource) / v1 + (slabEnd - slabStart) / v2 + (x - slabEnd) / v1;
    }

    if (t < tReach) return [];

    double localPhase = 0.0;
    if (x < slabStart) {
      localPhase = omega * t - k1 * (x - xSource);
    } else if (x <= slabEnd) {
      localPhase = omega * t - k1 * (slabStart - xSource) - k2 * (x - slabStart);
    } else {
      localPhase = omega * t - k1 * (slabStart - xSource) - k2 * (slabEnd - slabStart) - k1 * (x - slabEnd);
    }

    if (activeIds.contains('total')) {
      return [
        WaveComponent(
          id: 'total',
          label: '合成波',
          color: Colors.blueAccent,
          value: amplitude * math.sin(localPhase),
        ),
      ];
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    return other is OneDimensionSlabRefractionField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.n == n &&
        other.slabStart == slabStart &&
        other.slabEnd == slabEnd &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode =>
      Object.hash(lambda, periodT, n, slabStart, slabEnd, amplitude);
}

enum ThinFilmMode { incident, reflected1, reflected2, combinedReflected }

class ThinFilmInterferenceField extends WaveField {
  const ThinFilmInterferenceField({
    required this.lambda,
    required this.periodT,
    required this.n,
    required this.thicknessL,
    required this.mode,
    this.amplitude = 0.4,
  });

  final double lambda;
  final double periodT;
  final double n;
  final double thicknessL;
  final ThinFilmMode mode;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final k1 = 2 * math.pi / lambda;
    final omega = 2 * math.pi / periodT;
    const xSource = -7.5;
    return omega * t - k1 * (x - xSource);
  }

  @override
  double z(double x, double y, double t) {
    final v1 = lambda / periodT;
    final v2 = v1 / n;
    final k1 = 2 * math.pi / lambda;
    final k2 = k1 * n;
    final omega = 2 * math.pi / periodT;
    const xSource = -7.5;

    // 1. Incident Wave (traveling right)
    double zi = 0.0;
    double tReachI = 0.0;
    if (x < 0) {
      tReachI = (x - xSource) / v1;
    } else if (x <= thicknessL) {
      tReachI = (0 - xSource) / v1 + (x - 0) / v2;
    } else {
      tReachI =
          (0 - xSource) / v1 + (thicknessL - 0) / v2 + (x - thicknessL) / v1;
    }

    if (t >= tReachI) {
      double phaseI = 0.0;
      if (x < 0) {
        phaseI = omega * t - k1 * (x - xSource);
      } else if (x <= thicknessL) {
        phaseI = omega * t - k1 * (0 - xSource) - k2 * (x - 0);
      } else {
        phaseI = omega * t - k1 * (0 - xSource) - k2 * thicknessL -
            k1 * (x - thicknessL);
      }
      zi = amplitude * math.sin(phaseI);
    }

    if (mode == ThinFilmMode.incident) return zi;

    // 2. Reflected Wave 1 (from x=0, fixed end)
    double zr1 = 0.0;
    if (x <= 0) {
      final distR1 = (0 - xSource) + (0 - x);
      final tReachR1 = distR1 / v1;
      if (t >= tReachR1) {
        zr1 = -amplitude * math.sin(omega * t - k1 * distR1);
      }
    }
    if (mode == ThinFilmMode.reflected1) return zr1;

    // 3. Reflected Wave 2 (from x=L, free end)
    double zr2 = 0.0;
    if (x <= thicknessL) {
      double tReachR2 = 0.0;
      double phaseR2 = 0.0;
      if (x > 0) {
        // Path: xSource -> 0(v1) -> L(v2) -> x(v2)
        tReachR2 = (0 - xSource) / v1 + (thicknessL - 0) / v2 + (thicknessL - x) / v2;
        phaseR2 = omega * t - k1 * (0 - xSource) - k2 * (2 * thicknessL - x);
      } else {
        // Path: xSource -> 0(v1) -> L(v2) -> 0(v2) -> x(v1)
        tReachR2 = (0 - xSource) / v1 + (2 * thicknessL) / v2 + (0 - x) / v1;
        phaseR2 = omega * t - k1 * (0 - xSource) - k2 * (2 * thicknessL) - k1 * (0 - x);
      }
      if (t >= tReachR2) {
        zr2 = amplitude * math.sin(phaseR2);
      }
    }
    if (mode == ThinFilmMode.reflected2) return zr2;

    return zr1 + zr2;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    final v1 = lambda / periodT;
    final v2 = v1 / n;
    final k1 = 2 * math.pi / lambda;
    final k2 = k1 * n;
    final omega = 2 * math.pi / periodT;
    const xSource = -7.5;

    // 1. Incident Wave
    double zi = 0.0;
    double tReachI = 0.0;
    if (x < 0) {
      tReachI = (x - xSource) / v1;
    } else if (x <= thicknessL) {
      tReachI = (0 - xSource) / v1 + (x - 0) / v2;
    } else {
      tReachI =
          (0 - xSource) / v1 + (thicknessL - 0) / v2 + (x - thicknessL) / v1;
    }
    if (t >= tReachI) {
      double phaseI = 0.0;
      if (x < 0) {
        phaseI = omega * t - k1 * (x - xSource);
      } else if (x <= thicknessL) {
        phaseI = omega * t - k1 * (0 - xSource) - k2 * (x - 0);
      } else {
        phaseI = omega * t - k1 * (0 - xSource) - k2 * thicknessL -
            k1 * (x - thicknessL);
      }
      zi = amplitude * math.sin(phaseI);
    }

    // 2. Reflected Wave 1
    double zr1 = 0.0;
    if (x <= 0) {
      final distR1 = (0 - xSource) + (0 - x);
      final tReachR1 = distR1 / v1;
      if (t >= tReachR1) {
        zr1 = -amplitude * math.sin(omega * t - k1 * distR1);
      }
    }

    // 3. Reflected Wave 2 (from x=L, free end)
    double zr2 = 0.0;
    if (x <= thicknessL) {
      double tReachR2 = 0.0;
      double phaseR2 = 0.0;
      if (x > 0) {
        tReachR2 =
            (0 - xSource) / v1 + (thicknessL - 0) / v2 + (thicknessL - x) / v2;
        phaseR2 = omega * t - k1 * (0 - xSource) - k2 * (2 * thicknessL - x);
      } else {
        tReachR2 = (0 - xSource) / v1 + (2 * thicknessL) / v2 + (0 - x) / v1;
        phaseR2 =
            omega * t - k1 * (0 - xSource) - k2 * (2 * thicknessL) - k1 * (0 - x);
      }
      if (t >= tReachR2) {
        zr2 = amplitude * math.sin(phaseR2);
      }
    }

    final List<WaveComponent> res = [];
    if (activeIds.contains('incident')) {
      res.add(WaveComponent(
          id: 'incident', label: '入射波', color: Colors.purpleAccent, value: zi));
    }
    if (activeIds.contains('reflected1')) {
      res.add(WaveComponent(
          id: 'reflected1',
          label: '反射波1',
          color: Colors.greenAccent,
          value: zr1));
    }
    if (activeIds.contains('reflected2')) {
      res.add(WaveComponent(
          id: 'reflected2',
          label: '反射波2',
          color: Colors.orangeAccent,
          value: zr2));
    }
    if (activeIds.contains('combinedReflected')) {
      res.add(WaveComponent(
          id: 'combinedReflected',
          label: '合成反射波',
          color: Colors.blueAccent,
          value: zr1 + zr2));
    }
    return res;
  }


  @override
  bool operator ==(Object other) {
    return other is ThinFilmInterferenceField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.n == n &&
        other.thicknessL == thicknessL &&
        other.mode == mode &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode =>
      Object.hash(lambda, periodT, n, thicknessL, mode, amplitude);
}

class CircularInterferenceField extends WaveField {
  const CircularInterferenceField({
    required this.lambda,
    required this.periodT,
    required this.a,
    required this.phi,
    this.amplitude = 0.3,
  });

  final double lambda;
  final double periodT;
  final double a; // distance of source from origin on y-axis
  final double phi; // phase difference
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    // Return phase of the first source for rough visualization
    final v = lambda / periodT;
    final r1 = math.sqrt(x * x + (y - a) * (y - a));
    return 2 * math.pi * (t / periodT - r1 / lambda);
  }

  @override
  double z(double x, double y, double t) {
    final v = lambda / periodT;

    // Source 1: (0, a)
    final r1 = math.sqrt(x * x + (y - a) * (y - a));
    final tReach1 = r1 / v;
    final z1 = (t >= tReach1)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r1 / lambda))
        : 0.0;

    // Source 2: (0, -a)
    final r2 = math.sqrt(x * x + (y + a) * (y + a));
    final tReach2 = r2 / v;
    final z2 = (t >= tReach2)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r2 / lambda) + phi)
        : 0.0;

    return z1 + z2;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    final v = lambda / periodT;

    // Source 1
    final r1 = math.sqrt(x * x + (y - a) * (y - a));
    final tReach1 = r1 / v;
    final z1 = (t >= tReach1)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r1 / lambda))
        : 0.0;

    // Source 2
    final r2 = math.sqrt(x * x + (y + a) * (y + a));
    final tReach2 = r2 / v;
    final z2 = (t >= tReach2)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r2 / lambda) + phi)
        : 0.0;

    final List<WaveComponent> res = [];
    if (activeIds.contains('wave1')) {
      res.add(WaveComponent(
          id: 'wave1', label: '波1', color: Colors.purpleAccent, value: z1));
    }
    if (activeIds.contains('wave2')) {
      res.add(WaveComponent(
          id: 'wave2', label: '波2', color: Colors.greenAccent, value: z2));
    }
    if (activeIds.contains('combined')) {
      res.add(WaveComponent(
          id: 'combined',
          label: '合成波',
          color: Colors.blueAccent,
          value: z1 + z2));
    }
    return res;
  }

  @override
  bool operator ==(Object other) {
    return other is CircularInterferenceField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.a == a &&
        other.phi == phi &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(lambda, periodT, a, phi, amplitude);
}

class CircularWaveField extends WaveField {
  const CircularWaveField({
    required this.lambda,
    required this.periodT,
    this.amplitude = 0.4,
  });

  final double lambda;
  final double periodT;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final v = lambda / periodT;
    final r = math.sqrt(x * x + y * y);
    return 2 * math.pi * (t / periodT - r / lambda);
  }

  @override
  double z(double x, double y, double t) {
    final v = lambda / periodT;
    final r = math.sqrt(x * x + y * y);
    final tReach = r / v;
    final p = 2 * math.pi * (t / periodT - r / lambda);
    // Add small offset to avoid tReach exactly 0 issues
    return (t >= tReach) ? amplitude * math.sin(p) : 0.0;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    if (activeIds.contains('total')) {
      return [
        WaveComponent(
          id: 'total',
          label: '円形波',
          color: Colors.blueAccent,
          value: z(x, y, t),
        ),
      ];
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    return other is CircularWaveField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(lambda, periodT, amplitude);
}

enum ThinFilm2DMode { incident, reflected1, reflected2, combinedReflected }

class ThinFilmInterference2DField extends WaveField {
  const ThinFilmInterference2DField({
    required this.theta,
    required this.lambda,
    required this.periodT,
    required this.n,
    required this.thicknessL,
    this.amplitude = 0.4,
  });

  final double theta;
  final double lambda;
  final double periodT;
  final double n;
  final double thicknessL;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final k1 = 2 * math.pi / lambda;
    final omega = 2 * math.pi / periodT;
    final ky = k1 * math.sin(theta);
    final kx1 = k1 * math.cos(theta);
    const dOffset = 7.5;
    return omega * t - (kx1 * x + ky * y + k1 * dOffset);
  }

  @override
  double z(double x, double y, double t) {
    // This is used for the "total" wave if getComponents is not used.
    // We'll return the sum of all active components in the getComponents logic,
    // but here we just return the sum of reflections in x < 0.
    if (x > 0) return 0.0;
    final components = getComponents(x, y, t, {'reflected1', 'reflected2'});
    double sum = 0;
    for (var c in components) {
      sum += c.value;
    }
    return sum;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    final k1 = 2 * math.pi / lambda;
    final k2 = n * k1;
    final omega = 2 * math.pi / periodT;

    final ky = k1 * math.sin(theta);
    final kx1 = k1 * math.cos(theta);
    final kx2Sq = k2 * k2 - ky * ky;
    final kx2 = kx2Sq > 0 ? math.sqrt(kx2Sq) : 0.0;

    const dOffset = 7.5;

    // 1. Incident Wave
    double zi = 0.0;
    {
      double distI;
      if (x < 0) {
        distI = kx1 * x + ky * y + k1 * dOffset;
      } else if (x <= thicknessL) {
        distI = kx2 * x + ky * y + k1 * dOffset;
      } else {
        distI = kx1 * (x - thicknessL) + kx2 * thicknessL + ky * y + k1 * dOffset;
      }
      final phaseI = omega * t - distI;
      if (phaseI > 0) zi = amplitude * math.sin(phaseI);
    }

    // 2. Reflected Wave 1 (x=0, Fixed End)
    double zr1 = 0.0;
    if (x <= 0) {
      // Path: to x=0 (kx1*0), back to x (kx1*(-x))
      // Total path in x: k1*dOffset + kx1*(-x)
      final phaseR1 = omega * t - (kx1 * (-x) + ky * y + k1 * dOffset);
      if (phaseR1 > 0) {
        zr1 = -amplitude * math.sin(phaseR1);
      }
    }

    // 3. Reflected Wave 2 (x=L, Free End)
    double zr2 = 0.0;
    if (x <= 0) {
      // Path: to x=0 (kx1*0), through film to L (kx2*L), back to 0 (kx2*L), back to x (kx1*(-x))
      final phaseR2 = omega * t - (kx1 * (-x) + ky * y + k1 * dOffset + 2 * kx2 * thicknessL);
      if (phaseR2 > 0) {
        zr2 = amplitude * math.sin(phaseR2);
      }
    } else if (x <= thicknessL) {
      // Inside film, returning from x=L
      final phaseR2 = omega * t - (kx2 * (thicknessL - x) + ky * y + k1 * dOffset + kx2 * thicknessL);
      if (phaseR2 > 0) {
        zr2 = amplitude * math.sin(phaseR2);
      }
    }

    final List<WaveComponent> res = [];
    if (activeIds.contains('incident')) {
      res.add(WaveComponent(
          id: 'incident', label: '入射波', color: Colors.purpleAccent, value: zi));
    }
    if (activeIds.contains('reflected1')) {
      res.add(WaveComponent(
          id: 'reflected1',
          label: '反射波1',
          color: Colors.greenAccent,
          value: zr1));
    }
    if (activeIds.contains('reflected2')) {
      res.add(WaveComponent(
          id: 'reflected2',
          label: '反射波2',
          color: Colors.orangeAccent,
          value: zr2));
    }
    if (activeIds.contains('combined')) {
      res.add(WaveComponent(
          id: 'combined',
          label: '合成反射波',
          color: Colors.blueAccent,
          value: zr1 + zr2));
    }
    return res;
  }

  @override
  bool operator ==(Object other) {
    return other is ThinFilmInterference2DField &&
        other.theta == theta &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.n == n &&
        other.thicknessL == thicknessL &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode =>
      Object.hash(theta, lambda, periodT, n, thicknessL, amplitude);
}

class YoungDoubleSlitField extends WaveField {
  const YoungDoubleSlitField({
    required this.lambda,
    required this.periodT,
    required this.a,
    required this.phi,
    this.amplitude = 0.3,
  });

  final double lambda;
  final double periodT;
  final double a; // distance of source from origin on y-axis
  final double phi; // phase difference
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final v = lambda / periodT;
    final r1 = math.sqrt((x + 4) * (x + 4) + (y - a) * (y - a));
    return 2 * math.pi * (t / periodT - r1 / lambda);
  }

  @override
  double z(double x, double y, double t) {
    if (x < -4) return 0.0;

    final v = lambda / periodT;

    // Source 1: (-4, a)
    final r1 = math.sqrt((x + 4) * (x + 4) + (y - a) * (y - a));
    final tReach1 = r1 / v;
    final z1 = (t >= tReach1)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r1 / lambda))
        : 0.0;

    // Source 2: (-4, -a)
    final r2 = math.sqrt((x + 4) * (x + 4) + (y + a) * (y + a));
    final tReach2 = r2 / v;
    final z2 = (t >= tReach2)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r2 / lambda) + phi)
        : 0.0;

    return z1 + z2;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    final v = lambda / periodT;

    // Source 1
    final r1 = math.sqrt((x + 4) * (x + 4) + (y - a) * (y - a));
    final tReach1 = r1 / v;
    final z1 = (x >= -4 && t >= tReach1)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r1 / lambda))
        : 0.0;

    // Source 2
    final r2 = math.sqrt((x + 4) * (x + 4) + (y + a) * (y + a));
    final tReach2 = r2 / v;
    final z2 = (x >= -4 && t >= tReach2)
        ? amplitude * math.sin(2 * math.pi * (t / periodT - r2 / lambda) + phi)
        : 0.0;

    final List<WaveComponent> res = [];
    if (activeIds.contains('wave1')) {
      res.add(WaveComponent(
          id: 'wave1', label: '波1', color: Colors.purpleAccent, value: z1));
    }
    if (activeIds.contains('wave2')) {
      res.add(WaveComponent(
          id: 'wave2', label: '波2', color: Colors.greenAccent, value: z2));
    }
    if (activeIds.contains('combined')) {
      res.add(WaveComponent(
          id: 'combined',
          label: '合成波',
          color: Colors.yellow,
          value: z1 + z2));
    }
    return res;
  }

  @override
  bool operator ==(Object other) {
    return other is YoungDoubleSlitField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.a == a &&
        other.phi == phi &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(lambda, periodT, a, phi, amplitude);
}

enum PulseShape { sine, fullSine, triangle }

class PulseSuperpositionField extends WaveField {
  const PulseSuperpositionField({
    required this.lambda,
    required this.periodT,
    this.amplitude = 0.6,
    this.pulseWidth = 2.0,
    this.shape = PulseShape.sine,
  });

  final double lambda;
  final double periodT;
  final double amplitude;
  final double pulseWidth;
  final PulseShape shape;

  double _pulse(double u) {
    if (u < 0 || u > pulseWidth) return 0.0;
    if (shape == PulseShape.sine) {
      // One positive lobe of sine: 0 to pulseWidth
      return amplitude * math.sin(math.pi * u / pulseWidth);
    } else if (shape == PulseShape.fullSine) {
      // One full period of sine: 0 to pulseWidth
      return amplitude * math.sin(2 * math.pi * u / pulseWidth);
    } else {
      // Triangular pulse
      final mid = pulseWidth / 2;
      if (u < mid) return amplitude * (u / mid);
      return amplitude * (1 - (u - mid) / mid);
    }
  }

  @override
  double phase(double x, double y, double t) => 0.0;

  @override
  double z(double x, double y, double t) {
    final v = lambda / periodT;
    // Initial distance between centers is 10 units.
    // Meeting point at x=0.
    // Pulse 1 center at -5.0 + v*t
    // Pulse 2 center at 5.0 - v*t
    final z1 = _pulse(x - (-5.0 + v * t - pulseWidth / 2));
    final z2 = _pulse((5.0 - v * t + pulseWidth / 2) - x);
    return z1 + z2;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    final v = lambda / periodT;
    final z1 = _pulse(x - (-5.0 + v * t - pulseWidth / 2));
    final z2 = _pulse((5.0 - v * t + pulseWidth / 2) - x);

    final List<WaveComponent> res = [];
    if (activeIds.contains('wave1')) {
      res.add(WaveComponent(
          id: 'wave1', label: '波1', color: Colors.purpleAccent, value: z1));
    }
    if (activeIds.contains('wave2')) {
      res.add(WaveComponent(
          id: 'wave2', label: '波2', color: Colors.greenAccent, value: z2));
    }
    if (activeIds.contains('combined')) {
      res.add(WaveComponent(
          id: 'combined',
          label: '合成波',
          color: Colors.blueAccent,
          value: z1 + z2));
    }
    return res;
  }

  @override
  bool operator ==(Object other) {
    return other is PulseSuperpositionField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.amplitude == amplitude &&
        other.pulseWidth == pulseWidth &&
        other.shape == shape;
  }

  @override
  int get hashCode =>
      Object.hash(lambda, periodT, amplitude, pulseWidth, shape);
}

class PulseReflectionField extends WaveField {
  const PulseReflectionField({
    required this.lambda,
    required this.periodT,
    this.amplitude = 0.6,
    this.pulseWidth = 2.0,
    this.shape = PulseShape.sine,
    this.isFixedEnd = true,
    this.boundaryX = 5.0,
  });

  final double lambda;
  final double periodT;
  final double amplitude;
  final double pulseWidth;
  final PulseShape shape;
  final bool isFixedEnd;
  final double boundaryX;

  double _pulse(double u) {
    if (u < 0 || u > pulseWidth) return 0.0;
    if (shape == PulseShape.sine) {
      return amplitude * math.sin(math.pi * u / pulseWidth);
    } else if (shape == PulseShape.fullSine) {
      return amplitude * math.sin(2 * math.pi * u / pulseWidth);
    } else {
      final mid = pulseWidth / 2;
      if (u < mid) return amplitude * (u / mid);
      return amplitude * (1 - (u - mid) / mid);
    }
  }

  @override
  double phase(double x, double y, double t) => 0.0;

  @override
  double z(double x, double y, double t) {
    if (x > boundaryX) return 0.0;
    
    final v = lambda / periodT;
    const xStart = -7.5;
    
    final distI = x - xStart;
    final distR = (boundaryX - xStart) + (boundaryX - x);
    
    final zi = _pulse(v * t - distI);
    double zr = _pulse(v * t - distR);
    
    if (isFixedEnd) zr = -zr;
    
    return zi + zr;
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    if (x > boundaryX) return [];

    final v = lambda / periodT;
    const xStart = -7.5;
    
    final distI = x - xStart;
    final distR = (boundaryX - xStart) + (boundaryX - x);
    
    final zi = _pulse(v * t - distI);
    double zr = _pulse(v * t - distR);
    if (isFixedEnd) zr = -zr;

    final List<WaveComponent> res = [];
    if (activeIds.contains('incident')) {
      res.add(WaveComponent(
          id: 'incident', label: '入射波', color: Colors.purpleAccent, value: zi));
    }
    if (activeIds.contains('reflected')) {
      res.add(WaveComponent(
          id: 'reflected', label: '反射波', color: Colors.greenAccent, value: zr));
    }
    if (activeIds.contains('combined')) {
      res.add(WaveComponent(
          id: 'combined',
          label: '合成波',
          color: Colors.blueAccent,
          value: zi + zr));
    }
    return res;
  }

  @override
  bool operator ==(Object other) {
    return other is PulseReflectionField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.amplitude == amplitude &&
        other.pulseWidth == pulseWidth &&
        other.shape == shape &&
        other.isFixedEnd == isFixedEnd &&
        other.boundaryX == boundaryX;
  }

  @override
  int get hashCode => Object.hash(
      lambda, periodT, amplitude, pulseWidth, shape, isFixedEnd, boundaryX);
}

class DopplerEffect2DField extends WaveField {
  const DopplerEffect2DField({
    required this.lambda,
    required this.periodT,
    required this.vSource,
    this.amplitude = 0.4,
  });

  final double lambda;
  final double periodT;
  final double vSource;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    final V = lambda / periodT;
    final v = vSource;

    if (v == 0) {
      final r = math.sqrt(x * x + y * y);
      return 2 * math.pi * (t / periodT - r / lambda);
    }

    final a = V * V - v * v;
    if (a.abs() < 1e-10) return 0.0;

    final termInsideSqrt = V * V * math.pow(v * t - x, 2) + a * y * y;
    if (termInsideSqrt < 0) return 0.0;

    // τ = (V^2*t - v*x - sqrt(V^2(v*t - x)^2 + (V^2 - v^2)y^2)) / (V^2 - v^2)
    final tau = (V * V * t - v * x - math.sqrt(termInsideSqrt)) / a;

    if (tau < 0) return 0.0;

    return 2 * math.pi * (tau / periodT);
  }

  @override
  double z(double x, double y, double t) {
    final V = lambda / periodT;
    
    // 時刻t=0に原点を出発した波の最前線は半径Vtの円
    if (x * x + y * y > V * V * t * t) return 0.0;

    final p = phase(x, y, t);
    return amplitude * math.sin(p);
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    if (activeIds.contains('total')) {
      return [
        WaveComponent(
          id: 'total',
          label: 'ドップラー効果',
          color: Colors.blueAccent,
          value: z(x, y, t),
        ),
      ];
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    return other is DopplerEffect2DField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.vSource == vSource &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(lambda, periodT, vSource, amplitude);
}

class DopplerEffectObserverMovingField extends WaveField {
  const DopplerEffectObserverMovingField({
    required this.lambda,
    required this.periodT,
    this.amplitude = 0.4,
  });

  final double lambda;
  final double periodT;
  final double amplitude;

  @override
  double phase(double x, double y, double t) {
    // 静止した音源（原点）からの円形波
    final r = math.sqrt(x * x + y * y);
    return 2 * math.pi * (t / periodT - r / lambda);
  }

  @override
  double z(double x, double y, double t) {
    final V = lambda / periodT;
    if (x * x + y * y > V * V * t * t) return 0.0;
    return amplitude * math.sin(phase(x, y, t));
  }

  @override
  List<WaveComponent> getComponents(
      double x, double y, double t, Set<String> activeIds) {
    if (activeIds.contains('total')) {
      return [
        WaveComponent(
          id: 'total',
          label: 'ドップラー効果(観測者移動)',
          color: Colors.blueAccent,
          value: z(x, y, t),
        ),
      ];
    }
    return [];
  }

  @override
  bool operator ==(Object other) {
    return other is DopplerEffectObserverMovingField &&
        other.lambda == lambda &&
        other.periodT == periodT &&
        other.amplitude == amplitude;
  }

  @override
  int get hashCode => Object.hash(lambda, periodT, amplitude);
}

