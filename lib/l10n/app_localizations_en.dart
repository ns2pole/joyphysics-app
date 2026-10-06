// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'High School Physics with Animations and Experiments';

  @override
  String get homeTitleLine1 => 'Learn with Animations';

  @override
  String get homeTitleLine2 => 'and Experiments';

  @override
  String articleCount(int count) {
    return '$count articles';
  }

  @override
  String get useSensors => 'Use Sensors!';

  @override
  String get useSensorsTitle => 'Use Sensors';

  @override
  String get formulaCollection => 'Physics Formulas';

  @override
  String get unitList => 'Unit list';

  @override
  String get formulaList => 'Formula list';

  @override
  String get sensorArticlesSection => 'Sensor experiment articles';

  @override
  String get sensorArticlesTitle => 'Sensor articles';

  @override
  String get sensorWantToUse => 'Want to use sensors? Start here';

  @override
  String get sensorWebUnavailable =>
      'Sensors are not available in the web version. Please download the app.';

  @override
  String get sensorPermissionRequiredSuffix => ' (permission required)';

  @override
  String get sensorPermissionDeniedSuffix => ' (permission denied)';

  @override
  String get sensorCheckingSuffix => ' (checking…)';

  @override
  String get sensorUnsupportedSuffix => ' (not supported on this device)';

  @override
  String get allowSensorAccess => 'Allow sensor access';

  @override
  String get articleInPreparation => 'Article coming soon.';

  @override
  String get aboutApp => 'About';

  @override
  String get keywordSearch => 'Keyword search';

  @override
  String get searchArticles => 'Search articles';

  @override
  String get noMatchingArticles => 'No matching articles';

  @override
  String get inPreparation => 'Coming soon';

  @override
  String get inPreparationSuffix => ' (coming soon)';

  @override
  String get experimentEquipment => 'Equipment';

  @override
  String get noVideoOrExperiment => 'This content has no video or experiment.';

  @override
  String get noExplanation => 'No explanation available.';

  @override
  String get zoomIn => 'Zoom in';

  @override
  String get zoomOut => 'Zoom out';

  @override
  String get updateDialogTitle => 'A new update is available';

  @override
  String get updateDialogMessage => 'Would you like to update?';

  @override
  String get updateDialogLater => 'Later';

  @override
  String get updateDialogUpdate => 'Update';

  @override
  String updateDialogReleaseNotes(String notes) {
    return 'What\'s new: $notes';
  }

  @override
  String get waveCrest => 'Crest';

  @override
  String get waveTrough => 'Trough';

  @override
  String get mindMapPositionTitle => 'Overview and where this topic fits';

  @override
  String get otherAppsPlease => 'Check out our other apps!';

  @override
  String get tutoringLine1 => 'I teach physics with hands-on experiments.';

  @override
  String get tutoringLine2 => 'Feel free to inquire. Trial lessons are free.';

  @override
  String get unitGachaTagline1 => 'Do you check units?';

  @override
  String get unitGachaTagline2 => 'Unit calculation is fundamental';

  @override
  String get joymathTitle => 'Calculus Gacha!';

  @override
  String get unitGachaTitle => 'Unit Gacha!';

  @override
  String get joymathUnitsIntegral => 'Integrals';

  @override
  String get joymathUnitsLimit => 'Limits';

  @override
  String get joymathUnitsDiffEq => 'Differential equations';

  @override
  String get joymathUnitsIndeterminate => 'Diophantine equations';

  @override
  String get joymathUnitsCongruence => 'Congruences';

  @override
  String get joymathUnitsFactorization => 'Factorization';

  @override
  String get joymathUnitsSequence => 'Recurrence relations';

  @override
  String get joymathUnitsSuffix => ' topics covered';

  @override
  String get starRating => 'Star rating';

  @override
  String get godAppWithRating => '(4.8) must-have app';

  @override
  String get joymathReviewFun => 'So fun you\'ll miss your stop!';

  @override
  String get joymathReviewBasic =>
      'Calculation skill is the foundation of math';

  @override
  String get beginner => 'Beginner';

  @override
  String get onSale => 'On sale';

  @override
  String get sensorCategory => 'Sensors';

  @override
  String get aboutBody =>
      'We will keep adding content over time.\nIf there are topics you would like covered, please leave a comment on YouTube or TikTok, or in the app review. We will do our best to respond.\nThis app is about enjoying and learning physics through experiments.\nIf you feel physics is hard, not fun, or you want to learn it more carefully, we hope this app can help.\nWith AI, much information is free—so learning through experience matters even more.\nPhysics closer to you, and more enjoyable. We hope this becomes one step in your learning.';

  @override
  String get play => 'Play';

  @override
  String get pause => 'Pause';

  @override
  String get reset => 'Reset';

  @override
  String get restartFromStart => 'Start over';
}
