import 'dart:math';

import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

const _tutoringJmtyUrl = 'https://jmty.jp/mie/les-stu/article-x6ccv';
const _calculusGachaIosStoreId = '6753078774';
const _calculusGachaAndroidPackageId = 'com.joymath';
const _calculusGachaIconAsset = 'assets/icon/calculus_gacha_icon.png';
const _unitGachaIosStoreId = '6756411322';
const _unitGachaAndroidPackageId = 'com.joyphysics.unitgacha';
const _unitGachaIconAsset = 'assets/icon/unit_gacha_icon_removebg.png';
const _appStoreBadgeAsset = 'assets/app_badge/app_store_badge_blk.svg';
const _googlePlayBadgeAsset = 'assets/app_badge/google_play_badge.png';

final _calculusGachaIosStoreUri =
    Uri.parse('https://apps.apple.com/app/id$_calculusGachaIosStoreId');
final _calculusGachaAndroidStoreUri = Uri.parse(
  'https://play.google.com/store/apps/details?id=$_calculusGachaAndroidPackageId',
);
final _unitGachaIosStoreUri =
    Uri.parse('https://apps.apple.com/app/id$_unitGachaIosStoreId');
final _unitGachaAndroidStoreUri = Uri.parse(
  'https://play.google.com/store/apps/details?id=$_unitGachaAndroidPackageId',
);

const _unitGachaComments = [
  '単位で検算やってますか？',
  '単位計算は基本です',
];
const _unitGachaCommentCursorKey = 'unit_gacha_comment_cursor';
const _calculusGachaCommentCursorKey = 'calculus_gacha_comment_cursor';
const _calculusGachaCommentCount = 4;
/// 単元対応コメント（開くたびに 1/2 の確率）
const _calculusGachaTopicsCommentIndex = 5;

/// Home へ戻ったときにコメントを切り替えるため
final RouteObserver<ModalRoute<void>> homeRouteObserver =
    RouteObserver<ModalRoute<void>>();

/// joymath と同じデフォルトフォント（KeiFont を継承しない）
Widget _withJoymathTypography(Widget child) {
  return Theme(
    data: ThemeData(primarySwatch: Colors.blue),
    child: DefaultTextStyle.merge(
      style: const TextStyle(fontFamily: 'Roboto'),
      child: child,
    ),
  );
}

bool _isCompact(BuildContext context) =>
    MediaQuery.sizeOf(context).width < 600;

Future<void> _openExternalUrl(String url) async {
  final uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
      webOnlyWindowName: '_blank',
    );
  }
}

/// 端末 OS に応じたストア URL（iOS / macOS → App Store、それ以外 → Google Play）
String _storeUrlForDevice({
  required String iosStoreUrl,
  required String androidStoreUrl,
}) {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.macOS:
      return iosStoreUrl;
    default:
      return androidStoreUrl;
  }
}

/// jimty 数学物理 個別指導へのリンク（Home タイトル直上）
class TutoringPromoLink extends StatelessWidget {
  const TutoringPromoLink({super.key});

  @override
  Widget build(BuildContext context) {
    return _withJoymathTypography(
      const _HomeExternalPromoLink(
        url: _tutoringJmtyUrl,
        line1: '実験を交えて物理を指導しています。',
        line2: 'お気軽にお問い合わせ下さい。初回体験は無料で承ります。',
      ),
    );
  }
}

class _HomeExternalPromoLink extends StatelessWidget {
  const _HomeExternalPromoLink({
    required this.url,
    required this.line1,
    required this.line2,
    this.line2FontSizeScale = 1.0,
  });

  final String url;
  final String line1;
  final String line2;
  final double line2FontSizeScale;

  @override
  Widget build(BuildContext context) {
    final isCompact = _isCompact(context);
    const titleColor = Color(0xFF8B7355);
    final sectionFontSize = isCompact ? 17.0 : 20.0;
    final line2FontSize = (isCompact ? 13.0 : 15.0) * line2FontSizeScale;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openExternalUrl(url),
        borderRadius: BorderRadius.circular(24),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: isCompact ? 18.0 : 22.0,
            vertical: isCompact ? 6.0 : 8.0,
          ),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            border: Border.all(
              color: titleColor.withValues(alpha: 0.55),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                line1,
                style: TextStyle(
                  fontSize: sectionFontSize,
                  fontWeight: FontWeight.w600,
                  color: titleColor.withValues(alpha: 0.9),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                line2,
                style: TextStyle(
                  fontSize: line2FontSize,
                  fontWeight: FontWeight.w600,
                  color: titleColor.withValues(alpha: 0.9),
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 他アプリのストアリンク（Home 末尾）
class UnitGachaPromoLink extends StatefulWidget {
  const UnitGachaPromoLink({super.key});

  @override
  State<UnitGachaPromoLink> createState() => _UnitGachaPromoLinkState();
}

class _UnitGachaPromoLinkState extends State<UnitGachaPromoLink>
    with RouteAware, AutomaticKeepAliveClientMixin {
  String _unitComment = _unitGachaComments.first;
  int _calculusCommentIndex = 0;
  bool _routeSubscribed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _advanceComments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (!_routeSubscribed && route is PageRoute) {
      homeRouteObserver.subscribe(this, route);
      _routeSubscribed = true;
    }
  }

  @override
  void dispose() {
    if (_routeSubscribed) {
      homeRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void didPopNext() {
    // 力学などのページから Home に戻ってきたとき
    _advanceComments();
  }

  Future<void> _advanceComments() async {
    final prefs = await SharedPreferences.getInstance();

    final unitCursor = prefs.getInt(_unitGachaCommentCursorKey) ?? 0;
    final unitComment =
        _unitGachaComments[unitCursor % _unitGachaComments.length];
    await prefs.setInt(_unitGachaCommentCursorKey, unitCursor + 1);

    late final int calculusIndex;
    if (Random().nextBool()) {
      calculusIndex = _calculusGachaTopicsCommentIndex;
    } else {
      final cursor = prefs.getInt(_calculusGachaCommentCursorKey) ?? 0;
      calculusIndex = cursor % _calculusGachaCommentCount;
      await prefs.setInt(_calculusGachaCommentCursorKey, cursor + 1);
    }

    if (!mounted) return;
    setState(() {
      _unitComment = unitComment;
      _calculusCommentIndex = calculusIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final isCompact = _isCompact(context);
    const titleColor = Color(0xFF8B7355);
    final sectionFontSize = isCompact ? 16.0 : 19.0;
    final titleFontSize = isCompact ? 24.0 : 28.0;
    final iconHeight = isCompact ? 30.0 : 36.0;
    final badgeHeight = isCompact ? 34.0 : 40.0;
    final commentFontSize = isCompact ? 13.0 : 15.0;
    final commentStyle = TextStyle(
      fontSize: commentFontSize,
      fontWeight: FontWeight.w600,
      color: titleColor.withValues(alpha: 0.9),
      height: 1.2,
    );

    return _withJoymathTypography(
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 14),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: titleColor.withValues(alpha: 0.28),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isCompact ? 14.0 : 18.0,
                  vertical: isCompact ? 6.0 : 8.0,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  border: Border.all(
                    color: titleColor.withValues(alpha: 0.55),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Text(
                  '他アプリもよろしく！',
                  style: TextStyle(
                    fontSize: sectionFontSize,
                    fontWeight: FontWeight.w600,
                    color: titleColor.withValues(alpha: 0.9),
                    height: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              _AppStorePromoRow(
                title: '【極】微積ガチャ！',
                comment: _CalculusGachaComment(
                  index: _calculusCommentIndex,
                  style: commentStyle,
                ),
                titleColor: titleColor,
                titleFontSize: titleFontSize,
                badgeHeight: badgeHeight,
                icon: Image.asset(
                  _calculusGachaIconAsset,
                  height: iconHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.functions,
                      size: iconHeight,
                      color: titleColor,
                    );
                  },
                ),
                iosStoreUrl: _calculusGachaIosStoreUri.toString(),
                androidStoreUrl: _calculusGachaAndroidStoreUri.toString(),
              ),
              const SizedBox(height: 24),
              _AppStorePromoRow(
                title: '単位ガチャ !',
                comment: Text(
                  _unitComment,
                  style: commentStyle,
                  textAlign: TextAlign.center,
                ),
                titleColor: titleColor,
                titleFontSize: titleFontSize,
                badgeHeight: badgeHeight,
                icon: Image.asset(
                  _unitGachaIconAsset,
                  height: iconHeight,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.science_outlined,
                      size: iconHeight,
                      color: titleColor,
                    );
                  },
                ),
                iosStoreUrl: _unitGachaIosStoreUri.toString(),
                androidStoreUrl: _unitGachaAndroidStoreUri.toString(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppStorePromoRow extends StatelessWidget {
  const _AppStorePromoRow({
    required this.title,
    required this.titleColor,
    required this.titleFontSize,
    required this.badgeHeight,
    required this.icon,
    required this.iosStoreUrl,
    required this.androidStoreUrl,
    this.comment,
  });

  final String title;
  final Widget? comment;
  final Color titleColor;
  final double titleFontSize;
  final double badgeHeight;
  final Widget icon;
  final String iosStoreUrl;
  final String androidStoreUrl;

  @override
  Widget build(BuildContext context) {
    final onTitleTap = () => _openExternalUrl(
          _storeUrlForDevice(
            iosStoreUrl: iosStoreUrl,
            androidStoreUrl: androidStoreUrl,
          ),
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTitleTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        icon,
                        const SizedBox(width: 6),
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                            height: 1.1,
                          ),
                          softWrap: false,
                          maxLines: 1,
                        ),
                      ],
                    ),
                  ),
                  if (comment != null) ...[
                    const SizedBox(height: 6),
                    comment!,
                  ],
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            _StoreBadgeButton(
              onTap: () => _openExternalUrl(iosStoreUrl),
              child: SvgPicture.asset(
                _appStoreBadgeAsset,
                height: badgeHeight,
                fit: BoxFit.contain,
              ),
            ),
            _StoreBadgeButton(
              onTap: () => _openExternalUrl(androidStoreUrl),
              child: Image.asset(
                _googlePlayBadgeAsset,
                height: badgeHeight,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// 4.8 相当: 最後の ★ は灰シルエットの上に塗りを重ねて少し欠けて見える
class _PartialFiveStars extends StatelessWidget {
  const _PartialFiveStars({required this.fontSize});

  final double fontSize;

  // 4.8 / 5.0
  static const _lastStarFactor = 0.8;
  static const _filledColor = Color(0xFFFF9500);
  static const _emptyColor = Color(0xFFD1D1D6);

  @override
  Widget build(BuildContext context) {
    final size = fontSize + 2;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < 4; i++)
          Icon(Icons.star, size: size, color: _filledColor),
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            children: [
              Icon(Icons.star, size: size, color: _emptyColor),
              ClipRect(
                child: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: _lastStarFactor,
                  child: Icon(Icons.star, size: size, color: _filledColor),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CalculusGachaComment extends StatelessWidget {
  const _CalculusGachaComment({
    required this.index,
    required this.style,
  });

  final int index;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final starSize = (style.fontSize ?? 13) + 1;
    if (index == _calculusGachaTopicsCommentIndex) {
      const topics = [
        '積分',
        '極限',
        '微分方程式',
        '不定方程式',
        '合同式',
        '因数分解',
        '漸化式',
      ];
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 2,
            children: [
              for (final topic in topics)
                Text(topic, style: style),
            ],
          ),
          Text(
            'の単元に対応しています',
            style: style,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    switch (index % _calculusGachaCommentCount) {
      case 0:
        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text('星評価', style: style),
            _PartialFiveStars(fontSize: starSize),
            Text('(4.8)の神アプリ', style: style),
          ],
        );
      case 1:
        return Text(
          'まもなく2000ダウンロード',
          style: style,
          textAlign: TextAlign.center,
        );
      case 2:
        return Text(
          '電車を降り忘れるレベルで楽しい！',
          style: style,
          textAlign: TextAlign.center,
        );
      default:
        return Text(
          '数学の計算力は基礎です',
          style: style,
          textAlign: TextAlign.center,
        );
    }
  }
}

class _StoreBadgeButton extends StatelessWidget {
  const _StoreBadgeButton({
    required this.onTap,
    required this.child,
  });

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
