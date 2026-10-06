import 'package:flutter/widgets.dart';
import 'package:joyphysics/utils/locale_utils.dart';

/// Locale-aware UI string for animations / simulations.
///
/// Keep [ja] as the Japanese source and [en] as the English display string.
/// Article body fields (`Video.title` / `latex`) stay bilingual on the model
/// and are not routed through this helper.
String animUi(
  BuildContext context, {
  required String ja,
  required String en,
}) {
  return isEnglishAppLocale(context) ? en : ja;
}

/// Same policy without a [BuildContext] (e.g. from a known language code).
String animUiForLang(
  String languageCode, {
  required String ja,
  required String en,
}) {
  return languageCode == 'en' ? en : ja;
}

/// Context-free bilingual UI string for painters / field labels.
///
/// Uses the same ja→Japanese / else→English policy as [resolveAppLocale]:
/// only the primary platform locale counts. A Japanese entry later in
/// [PlatformDispatcher.locales] must not override an English primary
/// (no in-app language switcher).
String animL(String ja, String en) {
  final locale = WidgetsBinding.instance.platformDispatcher.locale;
  return normalizeAppLocale(locale).languageCode == 'ja' ? ja : en;
}
