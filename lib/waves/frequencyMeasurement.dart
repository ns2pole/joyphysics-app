import '../model.dart';
import './FrequencyMeasureWidget.dart';

final frequencyMeasurement = Video(
  isSmartPhoneOnly: true,
  isNew: true,
  category: 'waves',
  iconName: "doppler1", // assets にアイコンを追加
  title: "周波数測定",
  videoURL: "",
  equipment: ["スマホ（マイク搭載）"],
  costRating: "★☆☆",
  latex: """
<p>マイクから入力した音声の周波数をリアルタイムで測定します。</p>
""",
  experimentWidget: const FrequencyMeasureWidget(),
);
