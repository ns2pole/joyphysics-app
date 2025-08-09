import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';

class BeatExperimentWidget extends StatefulWidget {
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

  final int sampleRate = 44100;
  final int durationMs = 60000; // 60秒分の音データ

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
    final sampleCount = (sampleRate * durationMs / 1000).toInt();
    final buffer = Int16List(sampleCount);

    for (int i = 0; i < sampleCount; i++) {
      double t = i / sampleRate;
      double val = sin(2 * pi * freq * t);
      buffer[i] = (val * 32767).toInt();
    }
    return Uint8List.view(buffer.buffer);
  }

  Future<void> playSound1(double freq) async {
    if (isPlaying1) return;
    setState(() => isPlaying1 = true);

    final data = generateSineWave(freq);
    await _player1!.startPlayer(
      fromDataBuffer: data,
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: 1,
      whenFinished: () {
        setState(() => isPlaying1 = false);
      },
    );
  }

  Future<void> stopSound1() async {
    if (isPlaying1) {
      await _player1!.stopPlayer();
      setState(() => isPlaying1 = false);
    }
  }

  Future<void> playSound2(double freq) async {
    if (isPlaying2) return;
    setState(() => isPlaying2 = true);

    final data = generateSineWave(freq);
    await _player2!.startPlayer(
      fromDataBuffer: data,
      codec: Codec.pcm16,
      sampleRate: sampleRate,
      numChannels: 1,
      whenFinished: () {
        setState(() => isPlaying2 = false);
      },
    );
  }

  Future<void> stopSound2() async {
    if (isPlaying2) {
      await _player2!.stopPlayer();
      setState(() => isPlaying2 = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double beatFreq = (freq1 - freq2).abs();

    return Scaffold(
      appBar: AppBar(title: Text('Beat Experiment')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "ビート周波数: ${beatFreq.toStringAsFixed(2)} Hz",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Sound1 Controls
              Text("Sound1 周波数: ${freq1.toStringAsFixed(1)} Hz"),
              Slider(
                value: freq1,
                min: 100,
                max: 1000,
                divisions: 900,
                label: freq1.toStringAsFixed(1),
                onChanged: (v) => setState(() => freq1 = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isPlaying1 ? null : () => playSound1(freq1),
                    child: Text(isPlaying1 ? 'Sound1 再生中' : 'Sound1 再生'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isPlaying1 ? stopSound1 : null,
                    child: Text('Sound1 停止'),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // Sound2 Controls
              Text("Sound2 周波数: ${freq2.toStringAsFixed(1)} Hz"),
              Slider(
                value: freq2,
                min: 100,
                max: 1000,
                divisions: 900,
                label: freq2.toStringAsFixed(1),
                onChanged: (v) => setState(() => freq2 = v),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: isPlaying2 ? null : () => playSound2(freq2),
                    child: Text(isPlaying2 ? 'Sound2 再生中' : 'Sound2 再生'),
                  ),
                  SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: isPlaying2 ? stopSound2 : null,
                    child: Text('Sound2 停止'),
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
