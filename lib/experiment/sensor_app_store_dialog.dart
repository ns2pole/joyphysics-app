import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:joyphysics/joy_physics_store_uris.dart';
import 'package:joyphysics/experiment/user_agent_stores.dart';
import 'package:joyphysics/l10n/anim_ui.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showSensorAppStoreDialog(
  BuildContext context, {
  String? title,
  String? message,
}) async {
  if (!kIsWeb) return;
  final hint = webStoreClientHint();
  if (!context.mounted) return;
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title ??
            animUi(ctx, ja: 'アプリ版で測定できます', en: 'Measure it in the app'),
      ),
      content: Text(
        message ??
            animUi(
              ctx,
              ja: 'Web版のこの画面では、端末のセンサーで本番測定できません。アプリをインストールしてフル体験してください。',
              en: 'This web screen cannot measure with the device sensors. Install the app for the full experience.',
            ),
      ),
      actions: [
        if (hint == WebStoreClientHint.ios || hint == WebStoreClientHint.unknown)
          TextButton.icon(
            onPressed: () {
              launchUrl(
                JoyPhysicsStoreUris.appStore,
                webOnlyWindowName: '_blank',
              );
            },
            icon: const Icon(Icons.apple),
            label: const Text('App Store'),
          ),
        if (hint == WebStoreClientHint.android ||
            hint == WebStoreClientHint.unknown)
          TextButton.icon(
            onPressed: () {
              launchUrl(
                JoyPhysicsStoreUris.googlePlay,
                webOnlyWindowName: '_blank',
              );
            },
            icon: const Icon(Icons.android),
            label: const Text('Google Play'),
          ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(animUi(ctx, ja: '閉じる', en: 'Close')),
        ),
      ],
    ),
  );
}
