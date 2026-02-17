import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/HasHeight.dart';
import 'waves/animations/fields/wave_fields.dart';
import 'waves/animations/utils/coordinate_transformer.dart';

class PhysicsAnimationScaffold extends StatefulWidget with HasHeight {
  final String title;
  final Widget? formula;
  final List<Widget>? sliders;
  final Widget? extraControls;
  final Widget Function(BuildContext context, double time, double azimuth, double tilt, double scale) animationBuilder;
  final VoidCallback? onReset;
  final double height;
  final bool is3D;
  final double aspectRatio;
  final Color? backgroundColor;
  final List<WaveMarker> Function(double time)? getMarkers;
  final void Function(int index, math.Point<double> newPoint, double time)? onMarkerDragged;
  final String? rangeLabel;

  const PhysicsAnimationScaffold({
    super.key,
    required this.title,
    this.formula,
    this.sliders,
    this.extraControls,
    required this.animationBuilder,
    this.onReset,
    this.height = 650,
    this.is3D = false,
    this.aspectRatio = 1.0,
    this.backgroundColor,
    this.getMarkers,
    this.onMarkerDragged,
    this.rangeLabel,
  });

  @override
  double get widgetHeight => height;

  @override
  State<PhysicsAnimationScaffold> createState() => _PhysicsAnimationScaffoldState();
}

class _PhysicsAnimationScaffoldState extends State<PhysicsAnimationScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _time = 0.0;
  bool _isPlaying = true;

  // Camera settings for 3D
  static const double _defaultAzimuth = 0.0;
  static const double _defaultTilt = 35 * math.pi / 180;
  static const double _tiltMax = math.pi / 2;

  double _azimuth = _defaultAzimuth;
  double _tilt = _defaultTilt;
  double _scale = 1.0;
  double _baseScale = 1.0;

  int _draggingMarkerIndex = -1;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _controller.addListener(() {
      if (mounted && _isPlaying) {
        setState(() {
          _time += 0.02;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _togglePlayPause() {
    setState(() {
      _isPlaying = !_isPlaying;
      if (_isPlaying) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    });
  }

  void _reset() {
    setState(() {
      _time = 0.0;
      _azimuth = _defaultAzimuth;
      _tilt = _defaultTilt;
      _scale = 1.0;
      _baseScale = 1.0;
      if (widget.onReset != null) {
        widget.onReset!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: widget.backgroundColor ?? Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min, // コンテンツに合わせて最小限の高さに
        children: [
          if (widget.formula != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: widget.formula!,
            ),
          AspectRatio(
            aspectRatio: widget.aspectRatio, // 正方形以外も許可するように変更
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final transformer = WaveCoordinateTransformer(
                      size: Size(constraints.maxWidth, constraints.maxHeight),
                      scale: _scale,
                      is3D: widget.is3D,
                      azimuth: _azimuth,
                      tilt: _tilt,
                    );

                    return GestureDetector(
                      onScaleStart: (details) {
                        _baseScale = _scale;
                        _draggingMarkerIndex = -1;

                        if (widget.onMarkerDragged != null &&
                            widget.getMarkers != null) {
                          final markers = widget.getMarkers!(_time);
                          // ヒットテスト: 赤いマーカーのみドラッグ可能にする
                          for (int i = 0; i < markers.length; i++) {
                            final m = markers[i];
                            if (m.color != Colors.red) continue;

                            // 本来は波の高さzを考慮すべきだが、簡略化のためz=0で判定、
                            // または近傍判定を広めにとる
                            final screenPos =
                                transformer.worldToScreen(m.point.x, m.point.y, 0);
                            final dist =
                                (screenPos - details.localFocalPoint).distance;
                            if (dist < 30.0) {
                              _draggingMarkerIndex = i;
                              break;
                            }
                          }
                        }
                      },
                      onScaleUpdate: (details) {
                        if (_draggingMarkerIndex != -1) {
                          final newWorldPoint = transformer
                              .screenToWorld(details.localFocalPoint);
                          widget.onMarkerDragged!(
                              _draggingMarkerIndex, newWorldPoint, _time);
                          return;
                        }

                        setState(() {
                          // Handle Scaling (Pinch)
                          _scale = (_baseScale * details.scale).clamp(0.5, 3.0);

                          // Handle Rotation (Pan) - only for 3D
                          if (widget.is3D) {
                            _azimuth =
                                (_azimuth + details.focalPointDelta.dx * 0.01) %
                                    (2 * math.pi);
                            _tilt = (_tilt + details.focalPointDelta.dy * 0.005)
                                .clamp(0.0, _tiltMax);
                          }
                        });
                      },
                      onScaleEnd: (details) {
                        _draggingMarkerIndex = -1;
                      },
                      child: ClipRect(
                        child: widget.animationBuilder(
                            context, _time, _azimuth, _tilt, _scale),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      'Time: ${_time.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ),
                if (widget.rangeLabel != null)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Text(
                        widget.rangeLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          // 操作パネル部分
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.extraControls != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: widget.extraControls!,
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _togglePlayPause,
                      icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                      label: Text(_isPlaying ? '停止' : '再生'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isPlaying ? Colors.red[400] : Colors.green[400],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: _reset,
                      icon: const Icon(Icons.restore),
                      label: const Text('リセット'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (widget.sliders != null && widget.sliders!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Column(
                children: widget.sliders!,
              ),
            ),
        ],
      ),
    );
  }
}

