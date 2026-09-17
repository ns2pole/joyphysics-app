import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:joyphysics/model.dart';

/// 共通の全画面画像表示ページ（公式集と同じ +/- ズーム・画像端までのパン）
class PhysicsFullscreenImagePage extends StatefulWidget {
  final String imageAsset;
  final String? title;

  const PhysicsFullscreenImagePage({
    Key? key,
    required this.imageAsset,
    this.title,
  }) : super(key: key);

  @override
  State<PhysicsFullscreenImagePage> createState() =>
      _PhysicsFullscreenImagePageState();
}

class _PhysicsFullscreenImagePageState
    extends State<PhysicsFullscreenImagePage> {
  final _viewerKey = GlobalKey();
  final _transformController = TransformationController();
  double _scale = 1.0;
  Orientation? _orientation;

  static const _minScale = 1.0;
  static const _maxScale = 6.0;
  static const _zoomStep = 0.5;

  @override
  void initState() {
    super.initState();
    _transformController.addListener(_onTransformChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final orientation = MediaQuery.orientationOf(context);
    if (_orientation != null && _orientation != orientation) {
      _transformController.value = Matrix4.identity();
      _scale = 1.0;
    }
    _orientation = orientation;
  }

  @override
  void dispose() {
    _transformController.removeListener(_onTransformChanged);
    _transformController.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    final next = _transformController.value.getMaxScaleOnAxis();
    if ((next - _scale).abs() > 0.01) {
      setState(() => _scale = next);
    }
  }

  Size _viewerSize() {
    final box = _viewerKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size ?? MediaQuery.sizeOf(context);
  }

  void _applyScale(double nextScale) {
    final current = _transformController.value.getMaxScaleOnAxis();
    final next = nextScale.clamp(_minScale, _maxScale);
    if ((next - current).abs() < 0.001) return;

    // 画面中央を基準に拡大縮小
    final size = _viewerSize();
    final focal = Offset(size.width / 2, size.height / 2);
    final sceneFocal = _transformController.toScene(focal);

    _transformController.value = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(next, next, 1, 1)
      ..translateByDouble(-sceneFocal.dx, -sceneFocal.dy, 0, 1);

    setState(() => _scale = next);
  }

  void _zoomIn() {
    final current = _transformController.value.getMaxScaleOnAxis();
    _applyScale(current + _zoomStep);
  }

  void _zoomOut() {
    final current = _transformController.value.getMaxScaleOnAxis();
    _applyScale(current - _zoomStep);
  }

  @override
  Widget build(BuildContext context) {
    final canZoomOut = _scale > _minScale + 0.01;
    final canZoomIn = _scale < _maxScale - 0.01;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title ?? ''),
      ),
      body: Stack(
        key: _viewerKey,
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              // 画像端までパンできれば十分（外側への余白パンは不要）
              return InteractiveViewer(
                transformationController: _transformController,
                minScale: _minScale,
                maxScale: _maxScale,
                boundaryMargin: EdgeInsets.zero,
                clipBehavior: Clip.hardEdge,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Image.asset(
                    widget.imageAsset,
                    fit: BoxFit.contain,
                  ),
                ),
              );
            },
          ),
          Positioned(
            right: 16,
            bottom: 16 + MediaQuery.of(context).padding.bottom,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FullscreenZoomButton(
                  icon: Icons.add,
                  tooltip: '拡大',
                  enabled: canZoomIn,
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 8),
                _FullscreenZoomButton(
                  icon: Icons.remove,
                  tooltip: '縮小',
                  enabled: canZoomOut,
                  onPressed: _zoomOut,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FullscreenZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  const _FullscreenZoomButton({
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: enabled ? 0.22 : 0.1),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, color: enabled ? Colors.white : Colors.white38),
        tooltip: tooltip,
      ),
    );
  }
}

/// 共通のYouTubeプレイヤー
class PhysicsYouTubePlayer extends StatefulWidget {
  final String? videoURL;
  final double height;
  const PhysicsYouTubePlayer({super.key, required this.videoURL, this.height = 200});

  @override
  State<PhysicsYouTubePlayer> createState() => _PhysicsYouTubePlayerState();
}

class _PhysicsYouTubePlayerState extends State<PhysicsYouTubePlayer> {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(PhysicsYouTubePlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.videoURL != oldWidget.videoURL) {
      _controller?.close();
      _initController();
    }
  }

  void _initController() {
    if (widget.videoURL != null && widget.videoURL!.isNotEmpty) {
      final videoId = extractVideoId(widget.videoURL!);
      if (videoId.isNotEmpty) {
        _controller = YoutubePlayerController.fromVideoId(
          videoId: videoId,
          params: const YoutubePlayerParams(
            showControls: true,
            showFullscreenButton: true,
            origin: 'https://www.youtube-nocookie.com',
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: RepaintBoundary(
        child: YoutubePlayer(
          controller: _controller!,
        ),
      ),
    );
  }
}

/// 共通バッジ（New, 実験, アニメ, スマホ専用）
class PhysicsBadge extends StatelessWidget {
  final bool isNew;
  final bool isSimulation;
  final bool isExperiment;
  final bool isSmartPhoneOnly;
  final double opacity;
  final double? width;
  final double? height;

  const PhysicsBadge({
    Key? key,
    this.isNew = false,
    this.isSimulation = false,
    this.isExperiment = false,
    this.isSmartPhoneOnly = false,
    this.opacity = 1.0,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 10,
      runSpacing: 5,
      children: [
        if (isSmartPhoneOnly)
          _buildImage('assets/icon/smartphone_only.png', width: width ?? 60, height: height ?? 40),
        if (isSimulation)
          _buildImage('assets/icon/anime.png', width: width ?? 60, height: height ?? 40),
        if (isExperiment)
          _buildImage('assets/icon/experiment.png', width: width ?? 60, height: height ?? 40),
        if (isNew)
          _buildImage('assets/others/new.gif', width: width ?? 45, height: height ?? 30),
      ],
    );
  }

  Widget _buildImage(String asset, {double? width, double? height}) {
    return Opacity(
      opacity: opacity,
      child: Image.asset(
        asset,
        width: width,
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}

/// 準備中透かし
class PreparationWatermark extends StatelessWidget {
  final String text;
  final double fontSize;
  final double angle;
  final double opacity;

  const PreparationWatermark({
    Key? key,
    this.text = '準備中',
    this.fontSize = 40,
    this.angle = -math.pi / 12,
    this.opacity = 0.18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: Center(
          child: Transform.rotate(
            angle: angle,
            child: Opacity(
              opacity: opacity,
              child: Text(
                text,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                  letterSpacing: 4,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// リスト内の共通セクション見出し
class SectionHeader extends StatelessWidget {
  final String title;
  final bool disabled;
  final double fontSize;
  final Color? backgroundColor;

  const SectionHeader({
    Key? key,
    required String name,
    this.disabled = false,
    this.fontSize = 18,
    this.backgroundColor,
  }) : title = name, super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: backgroundColor ?? (disabled ? Colors.grey[200] : Colors.grey[300]),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Text(
        disabled ? '$title（準備中）' : title,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: disabled ? Colors.black45 : Colors.black87,
        ),
      ),
    );
  }
}

/// センサー計測結果を表示する共通カードUI
class SensorDisplayCard extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final double? height;

  const SensorDisplayCard({
    Key? key,
    required this.title,
    required this.children,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: double.infinity,
        child: Card(
          margin: const EdgeInsets.all(24),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 24),
                ...children,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
