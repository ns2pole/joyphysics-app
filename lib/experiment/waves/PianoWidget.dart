import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';

/// 単音を鳴らすボタン（PianoKeyに改名）
class PianoKey extends StatefulWidget {
  final double frequency;

  const PianoKey({Key? key, required this.frequency}) : super(key: key);

  @override
  _PianoKeyState createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  FlutterSoundPlayer? _player;
  bool isPlaying = false;

  final int sampleRate = 44100;
  final int durationMs = 800; // 2秒

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _player!.openPlayer();
  }

  @override
  void dispose() {
    _player?.closePlayer();
    super.dispose();
  }

  Uint8List generateSineWave(double freq) {
    final sampleCount = (sampleRate * durationMs / 1000).toInt();
    final buffer = Int16List(sampleCount);
    for (int i = 0; i < sampleCount; i++) {
      double t = i / sampleRate;
      buffer[i] = (sin(2 * pi * freq * t) * 32767).toInt();
    }
    return Uint8List.view(buffer.buffer);
  }

  Future<void> playSound(double freq) async {
    if (isPlaying) return;
    setState(() => isPlaying = true);

    final data = generateSineWave(freq);
    await _player!.startPlayer(
      fromDataBuffer: data,
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: 1,
      whenFinished: () {
        setState(() => isPlaying = false);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => playSound(widget.frequency),
      style: ElevatedButton.styleFrom(
        backgroundColor: isPlaying ? Colors.orangeAccent : Colors.white,
      ),
      child: Text("${widget.frequency.toStringAsFixed(1)} Hz", style: const TextStyle(color: Colors.black)),
    );
  }
}

/// 複数の音階を横に並べるピアノ
class PianoWidget extends StatelessWidget {
  final List<double> frequencies;

  const PianoWidget({
    Key? key,
    this.frequencies = const [261.63, 293.66, 329.63, 349.23, 392.00, 440.00, 493.88, 523.25],
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      children: frequencies
          .map((f) => PianoKey(frequency: f))
          .toList(),
    );
  }
}
