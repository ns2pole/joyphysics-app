import 'package:flutter/widgets.dart';

/// UI 言語: `ja` のみ日本語、それ以外は英語。
Locale normalizeAppLocale(Locale? locale) {
  final lang = locale?.languageCode.toLowerCase();
  return lang == 'ja' ? const Locale('ja') : const Locale('en');
}

/// [MaterialApp.localeResolutionCallback] 用。
Locale? resolveAppLocale(
  Locale? deviceLocale,
  Iterable<Locale> supportedLocales,
) {
  final candidates = <Locale>[
    if (deviceLocale != null) deviceLocale,
    ...WidgetsBinding.instance.platformDispatcher.locales,
  ];

  for (final loc in candidates) {
    final resolved = normalizeAppLocale(loc);
    for (final s in supportedLocales) {
      if (s.languageCode == resolved.languageCode) {
        return resolved;
      }
    }
  }
  return const Locale('en');
}

/// Effective app language code (`ja` or `en`) from [context].
String appLanguageCode(BuildContext context) {
  final locale = Localizations.maybeLocaleOf(context);
  return normalizeAppLocale(locale).languageCode;
}

bool isEnglishAppLocale(BuildContext context) =>
    appLanguageCode(context) == 'en';
