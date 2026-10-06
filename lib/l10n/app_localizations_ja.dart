// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'アニメと実験で学ぶ高校物理';

  @override
  String get homeTitleLine1 => 'アニメと実験で学ぶ';

  @override
  String get homeTitleLine2 => '高校物理';

  @override
  String articleCount(int count) {
    return '$count記事';
  }

  @override
  String get useSensors => 'センサーを使う！';

  @override
  String get useSensorsTitle => 'センサーを使う';

  @override
  String get formulaCollection => '物理公式集';

  @override
  String get unitList => '単元一覧';

  @override
  String get formulaList => '公式一覧';

  @override
  String get sensorArticlesSection => 'センサー実験 解説記事一覧';

  @override
  String get sensorArticlesTitle => 'センサー関係の記事';

  @override
  String get sensorWantToUse => 'センサーを使いたい人はこちらから';

  @override
  String get sensorWebUnavailable => 'Web版ではセンサーが使えません。アプリをダウンロードしてね。';

  @override
  String get sensorPermissionRequiredSuffix => '(許可が必要)';

  @override
  String get sensorPermissionDeniedSuffix => '(許可拒否)';

  @override
  String get sensorCheckingSuffix => '(確認中)';

  @override
  String get sensorUnsupportedSuffix => '(端末非対応)';

  @override
  String get allowSensorAccess => 'センサー利用を許可';

  @override
  String get articleInPreparation => '記事は準備中です。';

  @override
  String get aboutApp => 'アプリについて';

  @override
  String get keywordSearch => 'キーワード検索';

  @override
  String get searchArticles => '記事を検索';

  @override
  String get noMatchingArticles => '該当する記事がありません';

  @override
  String get inPreparation => '準備中';

  @override
  String get inPreparationSuffix => '（準備中）';

  @override
  String get experimentEquipment => '実験道具';

  @override
  String get noVideoOrExperiment => 'このコンテンツには動画/実験がありません。';

  @override
  String get noExplanation => '解説がありません。';

  @override
  String get zoomIn => '拡大';

  @override
  String get zoomOut => '縮小';

  @override
  String get updateDialogTitle => '新しいアップデートがあります';

  @override
  String get updateDialogMessage => '更新してみませんか？';

  @override
  String get updateDialogLater => 'あとで';

  @override
  String get updateDialogUpdate => '更新する';

  @override
  String updateDialogReleaseNotes(String notes) {
    return '更新内容: $notes';
  }

  @override
  String get waveCrest => '山';

  @override
  String get waveTrough => '谷';

  @override
  String get mindMapPositionTitle => '全体像と本内容の位置付け';

  @override
  String get otherAppsPlease => '他アプリもよろしく！';

  @override
  String get tutoringLine1 => '実験を交えて物理を指導しています。';

  @override
  String get tutoringLine2 => 'お気軽にお問い合わせ下さい。初回体験は無料で承ります。';

  @override
  String get unitGachaTagline1 => '単位で検算やってますか？';

  @override
  String get unitGachaTagline2 => '単位計算は基本です';

  @override
  String get joymathTitle => '【極】微積ガチャ！';

  @override
  String get unitGachaTitle => '単位ガチャ !';

  @override
  String get joymathUnitsIntegral => '積分';

  @override
  String get joymathUnitsLimit => '極限';

  @override
  String get joymathUnitsDiffEq => '微分方程式';

  @override
  String get joymathUnitsIndeterminate => '不定方程式';

  @override
  String get joymathUnitsCongruence => '合同式';

  @override
  String get joymathUnitsFactorization => '因数分解';

  @override
  String get joymathUnitsSequence => '漸化式';

  @override
  String get joymathUnitsSuffix => 'の単元に対応しています';

  @override
  String get starRating => '星評価';

  @override
  String get godAppWithRating => '(4.8)の神アプリ';

  @override
  String get joymathReviewFun => '電車を降り忘れるレベルで楽しい！';

  @override
  String get joymathReviewBasic => '数学の計算力は基礎です';

  @override
  String get beginner => 'ビギナー';

  @override
  String get onSale => '販売中';

  @override
  String get sensorCategory => 'センサー';

  @override
  String get aboutBody =>
      'コンテンツはこれからも随時追加していく予定です。\n扱ってほしいテーマがあれば、YouTubeやTikTokのコメント欄、またはアプリの評価欄にぜひご記入ください。できる限り、リクエストにお応えしていきます。\nこのアプリのテーマは、「実験を通して物理を楽しんで学んでもらう」こと。\n「物理がわからない」「楽しくない」「もっとちゃんと学びたい」——そんな悩みや思いを持つ方の力になれたら嬉しいです。\nAIの発展によって、多くの情報が無料で手に入るようになりました。だからこそ今、体験を通じて学ぶことの価値がより大きくなっていると感じています。\n物理を、もっと身近に。もっと楽しく。あなたの学びの一歩になれば幸いです。';

  @override
  String get play => '再生';

  @override
  String get pause => '一時停止';

  @override
  String get reset => 'リセット';

  @override
  String get restartFromStart => '最初から';
}
