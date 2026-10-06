import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In ja, this message translates to:
  /// **'アニメと実験で学ぶ高校物理'**
  String get appTitle;

  /// No description provided for @homeTitleLine1.
  ///
  /// In ja, this message translates to:
  /// **'アニメと実験で学ぶ'**
  String get homeTitleLine1;

  /// No description provided for @homeTitleLine2.
  ///
  /// In ja, this message translates to:
  /// **'高校物理'**
  String get homeTitleLine2;

  /// No description provided for @articleCount.
  ///
  /// In ja, this message translates to:
  /// **'{count}記事'**
  String articleCount(int count);

  /// No description provided for @useSensors.
  ///
  /// In ja, this message translates to:
  /// **'センサーを使う！'**
  String get useSensors;

  /// No description provided for @useSensorsTitle.
  ///
  /// In ja, this message translates to:
  /// **'センサーを使う'**
  String get useSensorsTitle;

  /// No description provided for @formulaCollection.
  ///
  /// In ja, this message translates to:
  /// **'物理公式集'**
  String get formulaCollection;

  /// No description provided for @unitList.
  ///
  /// In ja, this message translates to:
  /// **'単元一覧'**
  String get unitList;

  /// No description provided for @formulaList.
  ///
  /// In ja, this message translates to:
  /// **'公式一覧'**
  String get formulaList;

  /// No description provided for @sensorArticlesSection.
  ///
  /// In ja, this message translates to:
  /// **'センサー実験 解説記事一覧'**
  String get sensorArticlesSection;

  /// No description provided for @sensorArticlesTitle.
  ///
  /// In ja, this message translates to:
  /// **'センサー関係の記事'**
  String get sensorArticlesTitle;

  /// No description provided for @sensorWantToUse.
  ///
  /// In ja, this message translates to:
  /// **'センサーを使いたい人はこちらから'**
  String get sensorWantToUse;

  /// No description provided for @sensorWebUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'Web版ではセンサーが使えません。アプリをダウンロードしてね。'**
  String get sensorWebUnavailable;

  /// No description provided for @sensorPermissionRequiredSuffix.
  ///
  /// In ja, this message translates to:
  /// **'(許可が必要)'**
  String get sensorPermissionRequiredSuffix;

  /// No description provided for @sensorPermissionDeniedSuffix.
  ///
  /// In ja, this message translates to:
  /// **'(許可拒否)'**
  String get sensorPermissionDeniedSuffix;

  /// No description provided for @sensorCheckingSuffix.
  ///
  /// In ja, this message translates to:
  /// **'(確認中)'**
  String get sensorCheckingSuffix;

  /// No description provided for @sensorUnsupportedSuffix.
  ///
  /// In ja, this message translates to:
  /// **'(端末非対応)'**
  String get sensorUnsupportedSuffix;

  /// No description provided for @allowSensorAccess.
  ///
  /// In ja, this message translates to:
  /// **'センサー利用を許可'**
  String get allowSensorAccess;

  /// No description provided for @articleInPreparation.
  ///
  /// In ja, this message translates to:
  /// **'記事は準備中です。'**
  String get articleInPreparation;

  /// No description provided for @aboutApp.
  ///
  /// In ja, this message translates to:
  /// **'アプリについて'**
  String get aboutApp;

  /// No description provided for @keywordSearch.
  ///
  /// In ja, this message translates to:
  /// **'キーワード検索'**
  String get keywordSearch;

  /// No description provided for @searchArticles.
  ///
  /// In ja, this message translates to:
  /// **'記事を検索'**
  String get searchArticles;

  /// No description provided for @noMatchingArticles.
  ///
  /// In ja, this message translates to:
  /// **'該当する記事がありません'**
  String get noMatchingArticles;

  /// No description provided for @inPreparation.
  ///
  /// In ja, this message translates to:
  /// **'準備中'**
  String get inPreparation;

  /// No description provided for @inPreparationSuffix.
  ///
  /// In ja, this message translates to:
  /// **'（準備中）'**
  String get inPreparationSuffix;

  /// No description provided for @experimentEquipment.
  ///
  /// In ja, this message translates to:
  /// **'実験道具'**
  String get experimentEquipment;

  /// No description provided for @noVideoOrExperiment.
  ///
  /// In ja, this message translates to:
  /// **'このコンテンツには動画/実験がありません。'**
  String get noVideoOrExperiment;

  /// No description provided for @noExplanation.
  ///
  /// In ja, this message translates to:
  /// **'解説がありません。'**
  String get noExplanation;

  /// No description provided for @zoomIn.
  ///
  /// In ja, this message translates to:
  /// **'拡大'**
  String get zoomIn;

  /// No description provided for @zoomOut.
  ///
  /// In ja, this message translates to:
  /// **'縮小'**
  String get zoomOut;

  /// No description provided for @updateDialogTitle.
  ///
  /// In ja, this message translates to:
  /// **'新しいアップデートがあります'**
  String get updateDialogTitle;

  /// No description provided for @updateDialogMessage.
  ///
  /// In ja, this message translates to:
  /// **'更新してみませんか？'**
  String get updateDialogMessage;

  /// No description provided for @updateDialogLater.
  ///
  /// In ja, this message translates to:
  /// **'あとで'**
  String get updateDialogLater;

  /// No description provided for @updateDialogUpdate.
  ///
  /// In ja, this message translates to:
  /// **'更新する'**
  String get updateDialogUpdate;

  /// No description provided for @updateDialogReleaseNotes.
  ///
  /// In ja, this message translates to:
  /// **'更新内容: {notes}'**
  String updateDialogReleaseNotes(String notes);

  /// No description provided for @waveCrest.
  ///
  /// In ja, this message translates to:
  /// **'山'**
  String get waveCrest;

  /// No description provided for @waveTrough.
  ///
  /// In ja, this message translates to:
  /// **'谷'**
  String get waveTrough;

  /// No description provided for @mindMapPositionTitle.
  ///
  /// In ja, this message translates to:
  /// **'全体像と本内容の位置付け'**
  String get mindMapPositionTitle;

  /// No description provided for @otherAppsPlease.
  ///
  /// In ja, this message translates to:
  /// **'他アプリもよろしく！'**
  String get otherAppsPlease;

  /// No description provided for @tutoringLine1.
  ///
  /// In ja, this message translates to:
  /// **'実験を交えて物理を指導しています。'**
  String get tutoringLine1;

  /// No description provided for @tutoringLine2.
  ///
  /// In ja, this message translates to:
  /// **'お気軽にお問い合わせ下さい。初回体験は無料で承ります。'**
  String get tutoringLine2;

  /// No description provided for @unitGachaTagline1.
  ///
  /// In ja, this message translates to:
  /// **'単位で検算やってますか？'**
  String get unitGachaTagline1;

  /// No description provided for @unitGachaTagline2.
  ///
  /// In ja, this message translates to:
  /// **'単位計算は基本です'**
  String get unitGachaTagline2;

  /// No description provided for @joymathTitle.
  ///
  /// In ja, this message translates to:
  /// **'【極】微積ガチャ！'**
  String get joymathTitle;

  /// No description provided for @unitGachaTitle.
  ///
  /// In ja, this message translates to:
  /// **'単位ガチャ !'**
  String get unitGachaTitle;

  /// No description provided for @joymathUnitsIntegral.
  ///
  /// In ja, this message translates to:
  /// **'積分'**
  String get joymathUnitsIntegral;

  /// No description provided for @joymathUnitsLimit.
  ///
  /// In ja, this message translates to:
  /// **'極限'**
  String get joymathUnitsLimit;

  /// No description provided for @joymathUnitsDiffEq.
  ///
  /// In ja, this message translates to:
  /// **'微分方程式'**
  String get joymathUnitsDiffEq;

  /// No description provided for @joymathUnitsIndeterminate.
  ///
  /// In ja, this message translates to:
  /// **'不定方程式'**
  String get joymathUnitsIndeterminate;

  /// No description provided for @joymathUnitsCongruence.
  ///
  /// In ja, this message translates to:
  /// **'合同式'**
  String get joymathUnitsCongruence;

  /// No description provided for @joymathUnitsFactorization.
  ///
  /// In ja, this message translates to:
  /// **'因数分解'**
  String get joymathUnitsFactorization;

  /// No description provided for @joymathUnitsSequence.
  ///
  /// In ja, this message translates to:
  /// **'漸化式'**
  String get joymathUnitsSequence;

  /// No description provided for @joymathUnitsSuffix.
  ///
  /// In ja, this message translates to:
  /// **'の単元に対応しています'**
  String get joymathUnitsSuffix;

  /// No description provided for @starRating.
  ///
  /// In ja, this message translates to:
  /// **'星評価'**
  String get starRating;

  /// No description provided for @godAppWithRating.
  ///
  /// In ja, this message translates to:
  /// **'(4.8)の神アプリ'**
  String get godAppWithRating;

  /// No description provided for @joymathReviewFun.
  ///
  /// In ja, this message translates to:
  /// **'電車を降り忘れるレベルで楽しい！'**
  String get joymathReviewFun;

  /// No description provided for @joymathReviewBasic.
  ///
  /// In ja, this message translates to:
  /// **'数学の計算力は基礎です'**
  String get joymathReviewBasic;

  /// No description provided for @beginner.
  ///
  /// In ja, this message translates to:
  /// **'ビギナー'**
  String get beginner;

  /// No description provided for @onSale.
  ///
  /// In ja, this message translates to:
  /// **'販売中'**
  String get onSale;

  /// No description provided for @sensorCategory.
  ///
  /// In ja, this message translates to:
  /// **'センサー'**
  String get sensorCategory;

  /// No description provided for @aboutBody.
  ///
  /// In ja, this message translates to:
  /// **'コンテンツはこれからも随時追加していく予定です。\n扱ってほしいテーマがあれば、YouTubeやTikTokのコメント欄、またはアプリの評価欄にぜひご記入ください。できる限り、リクエストにお応えしていきます。\nこのアプリのテーマは、「実験を通して物理を楽しんで学んでもらう」こと。\n「物理がわからない」「楽しくない」「もっとちゃんと学びたい」——そんな悩みや思いを持つ方の力になれたら嬉しいです。\nAIの発展によって、多くの情報が無料で手に入るようになりました。だからこそ今、体験を通じて学ぶことの価値がより大きくなっていると感じています。\n物理を、もっと身近に。もっと楽しく。あなたの学びの一歩になれば幸いです。'**
  String get aboutBody;

  /// No description provided for @play.
  ///
  /// In ja, this message translates to:
  /// **'再生'**
  String get play;

  /// No description provided for @pause.
  ///
  /// In ja, this message translates to:
  /// **'一時停止'**
  String get pause;

  /// No description provided for @reset.
  ///
  /// In ja, this message translates to:
  /// **'リセット'**
  String get reset;

  /// No description provided for @restartFromStart.
  ///
  /// In ja, this message translates to:
  /// **'最初から'**
  String get restartFromStart;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
