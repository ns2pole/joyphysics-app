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

  final int sampleRate = 22050;
  final int durationSec = 600;

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
    final cycles = max(1, (freq * durationSec).round());
    final sampleCount = max(sampleRate, (cycles * sampleRate / freq).round());
    final buffer = Int16List(sampleCount);
    final step = 2 * pi * freq / sampleRate;
    var phase = 0.0;
    for (int i = 0; i < sampleCount; i++) {
      buffer[i] = (sin(phase) * 32767).toInt();
      phase += step;
    }
    return Uint8List.view(buffer.buffer);
  }

  Future<void> playSound(double freq) async {
    if (isPlaying) return;
    setState(() => isPlaying = true);
    await _start(freq);
  }

  Future<void> _start(double playFreq) async {
    try {
      final data = generateSineWave(playFreq);
      await _player!.startPlayer(
        fromDataBuffer: data,
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: 1,
        whenFinished: () {
          if (!mounted) return;
          if (isPlaying) {
            _start(freq);
          } else {
            setState(() => isPlaying = false);
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => isPlaying = false);
    }
  }

  Future<void> stopSound() async {
    if (isPlaying) {
      await _player!.stopPlayer();
      setState(() => isPlaying = false);
    }
  }

  void _adjustFreq(int delta) {
    // 中途半端な値は整数に丸めてから ±1Hz
    final next = (freq.round() + delta)
        .clamp(widget.minFreq.round(), widget.maxFreq.round())
        .toDouble();
    setState(() => freq = next);
  }

  String get _freqLabel {
    final showInt = (freq - freq.roundToDouble()).abs() < 1e-9;
    return showInt ? freq.round().toString() : freq.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height, // 👈 高さを適用
      child: Card(
        margin: const EdgeInsets.all(4),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    tooltip: '-1 Hz',
                    onPressed: freq <= widget.minFreq
                        ? null
                        : () => _adjustFreq(-1),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text(
                    "周波数: $_freqLabel Hz",
                    style: const TextStyle(fontSize: 20),
                  ),
                  IconButton(
                    tooltip: '+1 Hz',
                    onPressed: freq >= widget.maxFreq
                        ? null
                        : () => _adjustFreq(1),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              Slider(
                value: freq.clamp(widget.minFreq, widget.maxFreq),
                min: widget.minFreq,
                max: widget.maxFreq,
                divisions: (widget.maxFreq - widget.minFreq).toInt(),
                label: '$_freqLabel Hz',
                onChanged: (v) => setState(() => freq = v),
              ),
              const SizedBox(height: 8),
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
