import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'dart:async';

import './FrequencyMeasureWidget.dart';
import '../../model.dart'; // Videoクラス定義

/// 白鍵（ド〜ド）
class PianoKey extends StatefulWidget {
  final double frequency;
  final String label;

  const PianoKey({
    Key? key,
    required this.frequency,
    required this.label,
  }) : super(key: key);

  @override
  State<PianoKey> createState() => _PianoKeyState();
}

class _PianoKeyState extends State<PianoKey> {
  bool _pressed = false;
  late FlutterSoundPlayer _player;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _player.openPlayer();
      _initialized = true;
    } catch (e) {
      print("Player init failed: $e");
    }
  }

  Uint8List _sine(double freq, {int sampleRate = 44100, int ms = 800}) {
    final n = (sampleRate * ms / 1000).toInt();
    final buf = Int16List(n);
    for (int i = 0; i < n; i++) {
      final t = i / sampleRate;
      buf[i] = (sin(2 * pi * freq * t) * 32767).toInt();
    }
    return Uint8List.view(buf.buffer);
  }

  Future<void> _play() async {
    if (!_initialized) return;
    final data = _sine(widget.frequency);
    await _player.startPlayer(
      fromDataBuffer: data,
      codec: Codec.pcm16,
      sampleRate: 44100,
      numChannels: 1,
      whenFinished: () {},
    );
  }

  Future<void> _stop() async {
    if (_player.isPlaying) {
      await _player.stopPlayer();
    }
  }

  void _press() {
    setState(() => _pressed = true);
    _play();

    // 0.5秒後に色を元に戻す
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _pressed = false);
      _stop();
    });
  }

  @override
  void dispose() {
    _player.closePlayer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _press(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: _pressed ? Colors.orangeAccent.withOpacity(0.5) : Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label,
              style: const TextStyle(fontSize: 12, color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }
}

/// 1オクターブ（ド〜ド）を画面幅の90%で中央に表示
class PianoWidget extends StatelessWidget {
  final double height;
  PianoWidget({Key? key, this.height = 160}) : super(key: key);

  final List<Map<String, dynamic>> _whiteKeys = const [
    {"note": "ド", "freq": 261.63},
    {"note": "レ", "freq": 293.66},
    {"note": "ミ", "freq": 329.63},
    {"note": "ファ", "freq": 349.23},
    {"note": "ソ", "freq": 392.00},
    {"note": "ラ", "freq": 440.00},
    {"note": "シ", "freq": 493.88},
    {"note": "ド", "freq": 523.25},
  ];

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FractionallySizedBox(
        widthFactor: 0.9,
        child: SizedBox(
          height: height,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: _whiteKeys
                .map((k) => Expanded(
                      child: PianoKey(
                        frequency: k["freq"] as double,
                        label: k["note"] as String,
                      ),
                    ))
                .toList(),
          ),
        ),
      ),
    );
  }
}

