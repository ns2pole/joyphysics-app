import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:flutter/material.dart';

class BeatExperimentWidget extends StatefulWidget {
  @override
  _BeatExperimentWidgetState createState() => _BeatExperimentWidgetState();
}

class _BeatExperimentWidgetState extends State<BeatExperimentWidget> {
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  double freq1 = 350;
  double freq2 = 351;
  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  Future<Uint8List> generateBeats(double f1, double f2, {int durationMs = 1000}) async {
    const sampleRate = 44100;
    final length = sampleRate * durationMs ~/ 1000;
    final buffer = Int16List(length);

    for (int i = 0; i < length; i++) {
      final t = i / sampleRate;
      final val = 0.5 * (sin(2 * pi * f1 * t) + sin(2 * pi * f2 * t));
      buffer[i] = (val * 32767).toInt();
    }

    return Uint8List.view(buffer.buffer);
  }

  Future<void> playSound() async {
    final data = await generateBeats(freq1, freq2, durationMs: 3000);
    await _player.startPlayer(
      fromDataBuffer: data,
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
      whenFinished: () => setState(() => isPlaying = false),
    );
    setState(() => isPlaying = true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("うなりの実験", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 12),
        Row(
          children: [
            Text("f₁: ${freq1.toStringAsFixed(1)} Hz"),
            Expanded(
              child: Slider(
                min: 300, max: 400, value: freq1,
                onChanged: (v) => setState(() => freq1 = v),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Text("f₂: ${freq2.toStringAsFixed(1)} Hz"),
            Expanded(
              child: Slider(
                min: 300, max: 400, value: freq2,
                onChanged: (v) => setState(() => freq2 = v),
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        ElevatedButton.icon(
          icon: Icon(isPlaying ? Icons.stop : Icons.play_arrow),
          label: Text(isPlaying ? "再生中…" : "再生する"),
          onPressed: isPlaying ? null : playSound,
        ),
      ],
    );
  }
}
