import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class ToneGeneratorWidget extends StatefulWidget {
  final double initialFreq;
  final double minFreq;
  final double maxFreq;
  final double height; // 👈 高さを追加

  const ToneGeneratorWidget({
    Key? key,
    this.initialFreq = 440.0,
    this.minFreq = 100.0,
    this.maxFreq = 3000.0,
    this.height = 400, // デフォルト高さ
  }) : super(key: key);

  @override
  _ToneGeneratorWidgetState createState() => _ToneGeneratorWidgetState();
}

class _ToneGeneratorWidgetState extends State<ToneGeneratorWidget> {
  FlutterSoundPlayer? _player;
  bool isPlaying = false;
  late double freq;

  final int sampleRate = 44100;
  final int durationMs = 60000; // 2秒分だけ生成 (無限ループじゃなく繰り返しで再生すれば十分)

  @override
  void initState() {
    super.initState();
    freq = widget.initialFreq;
    _player = FlutterSoundPlayer();
    _openPlayer();
  }

  Future<void> _openPlayer() async {
    await _player!.openPlayer();
  }

  @override
  void dispose() {
    // _player?.closePlayer();
    _player = null;
    super.dispose();
  }

  Uint8List generateSineWave(double freq) {
    final sampleCount = (sampleRate * durationMs / 1000).toInt();
    final buffer = Int16List(sampleCount);

    for (int i = 0; i < sampleCount; i++) {
      double t = i / sampleRate;
      double val = sin(2 * pi * freq * t);
      buffer[i] = (val * 32767).toInt();
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

  Future<void> stopSound() async {
    if (isPlaying) {
      await _player!.stopPlayer();
      setState(() => isPlaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height, // 👈 高さを適用
      child: Card(
        margin: const EdgeInsets.all(4),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "周波数: ${freq.toStringAsFixed(1)} Hz",
                style: const TextStyle(fontSize: 24),
              ),
              Slider(
                value: freq,
                min: widget.minFreq,
                max: widget.maxFreq,
                divisions: (widget.maxFreq - widget.minFreq).toInt(),
                label: freq.toStringAsFixed(1),
                onChanged: (v) => setState(() => freq = v),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isPlaying ? null : () => playSound(freq),
                    child: Text(isPlaying ? '再生中' : '再生'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isPlaying ? stopSound : null,
                    child: const Text('停止'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
