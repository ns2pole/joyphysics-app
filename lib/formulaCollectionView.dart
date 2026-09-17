import 'package:flutter/material.dart';

class FormulaCollectionView extends StatefulWidget {
  const FormulaCollectionView({super.key});

  @override
  State<FormulaCollectionView> createState() => _FormulaCollectionViewState();
}

class _FormulaCollectionViewState extends State<FormulaCollectionView> {
  final _viewerKey = GlobalKey();
  final _transformController = TransformationController();
  double _scale = 1.0;
  Orientation? _orientation;

  static const _images = <String>[
    'assets/others/physics_formulas_1.png',
    'assets/others/physics_formulas_2.png',
  ];

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
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('物理公式集'),
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
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: Flex(
                      direction:
                          isPortrait ? Axis.vertical : Axis.horizontal,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final path in _images)
                          Image.asset(path),
                      ],
                    ),
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
                _ZoomButton(
                  icon: Icons.add,
                  tooltip: '拡大',
                  enabled: canZoomIn,
                  onPressed: _zoomIn,
                ),
                const SizedBox(height: 8),
                _ZoomButton(
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

class _ZoomButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  const _ZoomButton({
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
