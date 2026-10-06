import 'package:flutter/widgets.dart';
import 'package:joyphysics/l10n/catalog_names_en.dart';
import 'package:joyphysics/utils/locale_utils.dart';

/// Localize a catalog / subcategory / overview label.
///
/// Internal keys stay Japanese (mind-map matching). Display follows device locale.
String localizeCatalogName(BuildContext context, String japaneseName) {
  if (!isEnglishAppLocale(context)) return japaneseName;
  return kCatalogNamesEn[japaneseName] ?? japaneseName;
}

String localizeCatalogNameForLang(String languageCode, String japaneseName) {
  if (languageCode != 'en') return japaneseName;
  return kCatalogNamesEn[japaneseName] ?? japaneseName;
}
