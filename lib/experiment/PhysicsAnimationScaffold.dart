import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:joyphysics/experiment/HasHeight.dart';

class PhysicsAnimationScaffold extends StatefulWidget with HasHeight {
  final String title;
  final Widget? formula;
  final List<Widget>? sliders;
  final Widget? extraControls;
  final Widget Function(BuildContext context, double time, double azimuth, double tilt) animationBuilder;
  final VoidCallback? onReset;
  final double height;
  final bool is3D;
  final Color? backgroundColor;

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
    this.backgroundColor,
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
            aspectRatio: 1.0, // ここで正確に正方形を維持
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanUpdate: widget.is3D
                          ? (details) {
                              setState(() {
                                _azimuth = (_azimuth + details.delta.dx * 0.01) %
                                    (2 * math.pi);
                                _tilt = (_tilt + details.delta.dy * 0.005)
                                    .clamp(0.0, _tiltMax);
                              });
                            }
                          : null,
                      child: ClipRect(
                        child: widget.animationBuilder(context, _time, _azimuth, _tilt),
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
              ],
            ),
          ),
          // 操作パネル部分は Expanded を使わず、そのまま並べる
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 4,
              children: [
                if (widget.extraControls != null) widget.extraControls!,
                ElevatedButton.icon(
                  onPressed: _togglePlayPause,
                  icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                  label: Text(_isPlaying ? '停止' : '再生'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isPlaying ? Colors.red[400] : Colors.green[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _reset,
                  icon: const Icon(Icons.restore),
                  label: const Text('リセット'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
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

