import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:joyphysics/l10n/anim_ui.dart';

class BeatExperimentWidget extends StatefulWidget {
  final bool useScaffold;
  const BeatExperimentWidget({Key? key, this.useScaffold = true}) : super(key: key);

  @override
  _BeatExperimentWidgetState createState() => _BeatExperimentWidgetState();
}

class _BeatExperimentWidgetState extends State<BeatExperimentWidget> {
  FlutterSoundPlayer? _player1;
  FlutterSoundPlayer? _player2;

  bool isPlaying1 = false;
  bool isPlaying2 = false;

  double freq1 = 440;
  double freq2 = 444;

  final int sampleRate = 22050;
  final int durationSec = 600;

  @override
  void initState() {
    super.initState();
    _player1 = FlutterSoundPlayer();
    _player2 = FlutterSoundPlayer();
    _openPlayers();
  }

  Future<void> _openPlayers() async {
    await _player1!.openPlayer();
    await _player2!.openPlayer();
  }

  @override
  void dispose() {
    _player1?.closePlayer();
    _player2?.closePlayer();
    _player1 = null;
    _player2 = null;
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

  Future<void> playSound1(double freq) async {
    if (isPlaying1) return;
    if (mounted) setState(() => isPlaying1 = true);
    await _start1(freq);
  }

  Future<void> _start1(double playFreq) async {
    try {
      final data = generateSineWave(playFreq);
      await _player1!.startPlayer(
        fromDataBuffer: data,
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: 1,
        whenFinished: () {
          if (!mounted) return;
          if (isPlaying1) {
            _start1(freq1);
          } else {
            setState(() => isPlaying1 = false);
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => isPlaying1 = false);
    }
  }

  Future<void> stopSound1() async {
    if (isPlaying1) {
      await _player1!.stopPlayer();
      if (mounted) setState(() => isPlaying1 = false);
    }
  }

  Future<void> playSound2(double freq) async {
    if (isPlaying2) return;
    if (mounted) setState(() => isPlaying2 = true);
    await _start2(freq);
  }

  Future<void> _start2(double playFreq) async {
    try {
      final data = generateSineWave(playFreq);
      await _player2!.startPlayer(
        fromDataBuffer: data,
        codec: Codec.pcm16,
        sampleRate: sampleRate,
        numChannels: 1,
        whenFinished: () {
          if (!mounted) return;
          if (isPlaying2) {
            _start2(freq2);
          } else {
            setState(() => isPlaying2 = false);
          }
        },
      );
    } catch (_) {
      if (mounted) setState(() => isPlaying2 = false);
    }
  }

  Future<void> stopSound2() async {
    if (isPlaying2) {
      await _player2!.stopPlayer();
      if (mounted) setState(() => isPlaying2 = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double beatFreq = (freq1 - freq2).abs();

    final content = SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${animL('ビート周波数', 'Beat frequency')}: ${beatFreq.toStringAsFixed(2)} Hz",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Sound1 Controls
            Text(
              "${animL('Sound1 周波数', 'Sound 1 frequency')}: ${freq1.toStringAsFixed(1)} Hz",
            ),
            Slider(
              value: freq1,
              min: 100,
              max: 3000,
              divisions: 2900,
              label: freq1.toStringAsFixed(1),
              onChanged: (v) {
                if (mounted) setState(() => freq1 = v);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isPlaying1 ? null : () => playSound1(freq1),
                  child: Text(
                    isPlaying1
                        ? animL('Sound1 再生中', 'Sound 1 playing')
                        : animL('Sound1 再生', 'Play sound 1'),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isPlaying1 ? stopSound1 : null,
                  child: Text(animL('Sound1 停止', 'Stop sound 1')),
                ),
              ],
            ),

            SizedBox(height: 30),

            // Sound2 Controls
            Text(
              "${animL('Sound2 周波数', 'Sound 2 frequency')}: ${freq2.toStringAsFixed(1)} Hz",
            ),
            Slider(
              value: freq2,
              min: 100,
              max: 3000,
              divisions: 2900,
              label: freq2.toStringAsFixed(1),
              onChanged: (v) {
                if (mounted) setState(() => freq2 = v);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: isPlaying2 ? null : () => playSound2(freq2),
                  child: Text(
                    isPlaying2
                        ? animL('Sound2 再生中', 'Sound 2 playing')
                        : animL('Sound2 再生', 'Play sound 2'),
                  ),
                ),
                SizedBox(width: 12),
                ElevatedButton(
                  onPressed: isPlaying2 ? stopSound2 : null,
                  child: Text(animL('Sound2 停止', 'Stop sound 2')),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    if (!widget.useScaffold) {
      return content;
    }

    return Scaffold(
      appBar: AppBar(title: Text('Beat Experiment')),
      body: content,
    );
  }
}
