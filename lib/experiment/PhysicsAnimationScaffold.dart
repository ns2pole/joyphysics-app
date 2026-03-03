import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
  final bool enableWideWebSplit;
  final List<WaveMarker> Function(double time)? getMarkers;
  final void Function(int index, math.Point<double> newPoint, double time)? onMarkerDragged;
  final String? rangeLabel;
  final bool showTimeOverlay;
  final bool enableTime;
  final bool compactButtonSpacing;
  final double animationOffsetY;

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
    this.enableWideWebSplit = true,
    this.getMarkers,
    this.onMarkerDragged,
    this.rangeLabel,
    this.showTimeOverlay = true,
    this.enableTime = true,
    this.compactButtonSpacing = false,
    this.animationOffsetY = 0,
  });

  @override
  double get widgetHeight => height;

  @override
  State<PhysicsAnimationScaffold> createState() => _PhysicsAnimationScaffoldState();
}

class _PhysicsAnimationScaffoldState extends State<PhysicsAnimationScaffold>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ValueNotifier<double> _time = ValueNotifier<double>(0.0);
  bool _isPlaying = true;

  // Camera settings for 3D
  // Camerva settings for 3D
  // Camerva settings for 3Ds
  static const double _defaultAzimuth = 0.0;
  static const double _defaultTilt = 35 * math.pi / 180;
  static const double _tiltMax = math.pi / 2;

  double _azimuth = _defaultAzimuth;
  double _tilt = _defaultTilt;
  double _scale = 1.0;
  double _baseScale = 1.0;

  int _draggingMarkerIndex = -1;

  void _zoomBy(double factor) {
    setState(() {
      _scale = (_scale * factor).clamp(0.5, 3.0);
      _baseScale = _scale;
    });
  }

  @override
  void initState() {
    super.initState();
    _isPlaying = widget.enableTime;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    if (widget.enableTime) {
      _controller.repeat();
    }

    _controller.addListener(() {
      if (mounted && widget.enableTime && _isPlaying) {
        // Keep the same time step as before (behavior unchanged),
        // but avoid rebuilding the whole widget tree each tick.
        _time.value = _time.value + 0.02;
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _time.dispose();
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
    _time.value = 0.0;
    // Reset only the clock; keep camera/zoom and simulation parameters.
  }

  Widget _buildPlayPauseResetButtons() {
    const btnSize = 26.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: btnSize,
            color: Colors.white,
            tooltip: _isPlaying ? '停止' : '再生',
            onPressed: _togglePlayPause,
            icon: Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          Container(
            width: 1,
            height: btnSize,
            color: Colors.white.withOpacity(0.25),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: btnSize,
            color: Colors.white,
            tooltip: 'リセット',
            onPressed: _reset,
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimationArea() {
    return ValueListenableBuilder<double>(
      valueListenable: _time,
      builder: (context, rawTime, _) {
        final time = widget.enableTime ? rawTime : 0.0;
        return Center(
          child: AspectRatio(
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
                          final markers = widget.getMarkers!(time);
                          // ヒットテスト: 赤いマーカーのみドラッグ可能にする
                          for (int i = 0; i < markers.length; i++) {
                            final m = markers[i];
                            if (m.color != Colors.red) continue;

                            // 本来は波の高さzを考慮すべきだが、簡略化のためz=0で判定
                            final screenPos = transformer.worldToScreen(
                              m.point.x,
                              m.point.y,
                              0,
                            );
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
                          final newWorldPoint =
                              transformer.screenToWorld(details.localFocalPoint);
                          widget.onMarkerDragged!(
                              _draggingMarkerIndex, newWorldPoint, time);
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
                        child: RepaintBoundary(
                          child: widget.animationBuilder(
                              context, time, _azimuth, _tilt, _scale),
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (kIsWeb)
                        DecoratedBox(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: 26,
                                color: Colors.white,
                                tooltip: 'Zoom out',
                                onPressed: () => _zoomBy(1 / 1.15),
                                icon: const Icon(Icons.remove),
                              ),
                              Container(
                                width: 1,
                                height: 26,
                                color: Colors.white.withOpacity(0.25),
                              ),
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                iconSize: 26,
                                color: Colors.white,
                                tooltip: 'Zoom in',
                                onPressed: () => _zoomBy(1.15),
                                icon: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      if (kIsWeb) const SizedBox(width: 8),
                      if (widget.enableTime && widget.showTimeOverlay)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            'Time: ${time.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Courier',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                if (widget.rangeLabel != null)
                  Positioned(
                    top: kIsWeb ? 48 : 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
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
        );
      },
    );
  }

  Widget _buildRightPanel({
    required bool scrollable,
    bool includeFormula = true,
    bool showPlayButtons = true,
  }) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (includeFormula && widget.formula != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
            child: widget.formula!,
          ),
        // 再生/停止/リセット（数式の下に中央寄せ）
        if (widget.enableTime && showPlayButtons)
          Padding(
            padding: EdgeInsets.fromLTRB(
              8.0,
              8.0,
              8.0,
              widget.compactButtonSpacing ? 3.0 : 8.0,
            ),
            child: Center(child: _buildPlayPauseResetButtons()),
          ),
        if (widget.extraControls != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: widget.extraControls!,
          ),
        if (widget.sliders != null && widget.sliders!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
            child: Column(
              children: widget.sliders!,
            ),
          ),
      ],
    );

    if (!scrollable) return content;
    return Scrollbar(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 12),
        child: content,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Web横長のときは左右分割（左=アニメ、右=数式→スライダー）
    // 親がスクロールビュー等で高さ無制限になってもレイアウトできるように、
    // wide-web の Row は必ず bounded height にする。
    return LayoutBuilder(
      builder: (context, constraints) {
        final win = MediaQuery.sizeOf(context);
        final availableW = constraints.maxWidth;
        final isWideWeb =
            widget.enableWideWebSplit &&
            kIsWeb &&
            availableW >= 900 &&
            (availableW / win.height) >= 1.2;

        if (isWideWeb) {
          return SizedBox(
            height: widget.height,
            child: Container(
              color: widget.backgroundColor ?? Colors.white,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildAnimationArea(),
                    ),
                  ),
                  const VerticalDivider(width: 1, thickness: 1),
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildRightPanel(
                        scrollable: true,
                        includeFormula: true,
                        showPlayButtons: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Container(
          color: widget.backgroundColor ?? Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min, // コンテンツに合わせて最小限の高さに
            children: [
              // 数式（formula / buildFormulaOverlay）
              if (widget.formula != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: widget.formula!,
                ),
              // 再生/停止/リセット（数式の下に中央寄せ・縦レイアウト用）
              if (widget.enableTime)
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    8.0,
                    8.0,
                    8.0,
                    widget.compactButtonSpacing ? 3.0 : 8.0,
                  ),
                  child: Center(
                    child: _buildPlayPauseResetButtons(),
                  ),
                ),
              Transform.translate(
                offset: Offset(0, widget.animationOffsetY),
                child: _buildAnimationArea(),
              ),
              // 操作パネル部分（縦レイアウトは従来の順序を維持）
              _buildRightPanel(
                scrollable: false,
                includeFormula: false,
                showPlayButtons: false,
              ),
            ],
          ),
        );
      },
    );
  }
}

