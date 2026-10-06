import 'package:flutter/material.dart';
import 'package:joyphysics/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool _beginnerMode = true;

  static const _normalImagesJa = <String>[
    'assets/others/physics_formulas_1.png',
    'assets/others/physics_formulas_2.png',
  ];

  static const _beginnerImagesJa = <String>[
    'assets/others/physics_formulas_beginner_1.png',
    'assets/others/physics_formulas_beginner_2.png',
  ];

  static const _normalImagesEn = <String>[
    'assets/others/physics_formulas_en_1.png',
    'assets/others/physics_formulas_en_2.png',
  ];

  static const _beginnerImagesEn = <String>[
    'assets/others/physics_formulas_beginner_en_1.png',
    'assets/others/physics_formulas_beginner_en_2.png',
  ];

  static const _minScale = 1.0;
  static const _maxScale = 6.0;
  static const _zoomStep = 0.5;

  bool get _isJapanese =>
      Localizations.localeOf(context).languageCode == 'ja';

  List<String> get _images {
    if (_isJapanese) {
      return _beginnerMode ? _beginnerImagesJa : _normalImagesJa;
    }
    return _beginnerMode ? _beginnerImagesEn : _normalImagesEn;
  }

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

  void _setBeginnerMode(bool enabled) {
    if (_beginnerMode == enabled) return;
    setState(() => _beginnerMode = enabled);
  }

  @override
  Widget build(BuildContext context) {
    final canZoomOut = _scale > _minScale + 0.01;
    final canZoomIn = _scale < _maxScale - 0.01;
    final isPortrait =
        MediaQuery.orientationOf(context) == Orientation.portrait;
    final showMercari = _isJapanese && _beginnerMode;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/init/init.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.white.withOpacity(0.82)),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: kToolbarHeight,
                  child: AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    scrolledUnderElevation: 0,
                    surfaceTintColor: Colors.transparent,
                    title: Text(AppLocalizations.of(context)!.formulaCollection),
                  ),
                ),
                Expanded(
                  child: Stack(
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
                                  direction: isPortrait
                                      ? Axis.vertical
                                      : Axis.horizontal,
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
                        top: 8,
                        left: 12,
                        right: 12,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _BeginnerToggle(
                              beginnerMode: _beginnerMode,
                              onChanged: _setBeginnerMode,
                              compact: !isPortrait,
                              onDarkBackground: false,
                            ),
                            if (showMercari) ...[
                              const SizedBox(width: 8),
                              const _MercariSaleLink(),
                            ],
                          ],
                        ),
                      ),
                      Positioned(
                        right: 16,
                        bottom: 16,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _ZoomButton(
                              icon: Icons.add,
                              tooltip: AppLocalizations.of(context)!.zoomIn,
                              enabled: canZoomIn,
                              onPressed: _zoomIn,
                            ),
                            const SizedBox(height: 8),
                            _ZoomButton(
                              icon: Icons.remove,
                              tooltip: AppLocalizations.of(context)!.zoomOut,
                              enabled: canZoomOut,
                              onPressed: _zoomOut,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BeginnerToggle extends StatelessWidget {
  final bool beginnerMode;
  final ValueChanged<bool> onChanged;
  final bool compact;
  final bool onDarkBackground;

  const _BeginnerToggle({
    required this.beginnerMode,
    required this.onChanged,
    this.compact = false,
    this.onDarkBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor =
        onDarkBackground ? Colors.white : Colors.black87;
    final shellColor = onDarkBackground
        ? Colors.white.withValues(alpha: 0.16)
        : Colors.black.withValues(alpha: 0.08);

    return Material(
      color: shellColor,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 8,
          vertical: compact ? 4 : 6,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppLocalizations.of(context)!.beginner,
              style: TextStyle(
                color: labelColor,
                fontSize: compact ? 12 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: compact ? 6 : 8),
            _BeginnerModeButton(
              label: 'OFF',
              selected: !beginnerMode,
              compact: compact,
              onDarkBackground: onDarkBackground,
              onPressed: () => onChanged(false),
            ),
            SizedBox(width: compact ? 4 : 6),
            _BeginnerModeButton(
              label: 'ON',
              selected: beginnerMode,
              compact: compact,
              onDarkBackground: onDarkBackground,
              onPressed: () => onChanged(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeginnerModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final bool compact;
  final bool onDarkBackground;
  final VoidCallback onPressed;

  const _BeginnerModeButton({
    required this.label,
    required this.selected,
    required this.compact,
    required this.onDarkBackground,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg;
    final Color fg;
    if (onDarkBackground) {
      bg = selected
          ? Colors.white.withValues(alpha: 0.92)
          : Colors.white.withValues(alpha: 0.12);
      fg = selected ? Colors.black87 : Colors.white70;
    } else {
      bg = selected
          ? Theme.of(context).colorScheme.primary
          : Colors.black.withValues(alpha: 0.06);
      fg = selected ? Colors.white : Colors.black54;
    }

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 10 : 12,
            vertical: compact ? 4 : 6,
          ),
          child: Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: compact ? 12 : 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

/// ビギナー公式のラミネート版（メルカリ）。日本語端末のみ表示。
class _MercariSaleLink extends StatelessWidget {
  const _MercariSaleLink();

  static final Uri _itemUri = Uri.parse(
    'https://jp.mercari.com/item/m45610927606',
  );

  Future<void> _open() async {
    await launchUrl(
      _itemUri,
      mode: LaunchMode.externalApplication,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _open,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const _MercariMark(),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.onSale,
                style: const TextStyle(
                  color: Color(0xFFFF0211),
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 赤地に白の m と水色の点。メルカリの目印に寄せた印。
class _MercariMark extends StatelessWidget {
  const _MercariMark();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 18,
      height: 18,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: const Color(0xFFFF0211),
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Stack(
          children: [
            Center(
              child: Text(
                'm',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
            Positioned(
              top: 2,
              right: 2,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Color(0xFF35C4F0),
                  shape: BoxShape.circle,
                ),
                child: SizedBox(width: 5, height: 5),
              ),
            ),
          ],
        ),
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
      color: Colors.white.withValues(alpha: enabled ? 0.92 : 0.55),
      elevation: 2,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Icon(icon, color: enabled ? Colors.black87 : Colors.black38),
        tooltip: tooltip,
      ),
    );
  }
}
