import 'package:flutter/material.dart';
import 'package:joyphysics/l10n/app_localizations.dart';

/// 自前クロックの再生ループ。波動の足場（enableTime）とは別に、
/// Start で進めるシミュレーションが同じ一時停止を使う。
class _PlaybackFlag extends ValueNotifier<bool> {
  _PlaybackFlag() : super(false);

  void touch() => notifyListeners();
}

class PlaybackLoop {
  PlaybackLoop({required this.onTick});

  final void Function(double dt) onTick;

  final _PlaybackFlag running = _PlaybackFlag();

  bool _scheduled = false;
  DateTime? _last;

  void start() {
    if (running.value) return;
    _last = null;
    running.value = true;
    _schedule();
  }

  void pause() {
    running.value = false;
    _last = null;
  }

  void reset() {
    final wasRunning = running.value;
    running.value = false;
    _last = null;
    if (!wasRunning) running.touch();
  }

  void _schedule() {
    if (!running.value || _scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!running.value) return;
      final now = DateTime.now();
      final dt = _last == null
          ? 1 / 60
          : (now.difference(_last!).inMicroseconds / 1e6)
              .clamp(0.0, 0.05)
              .toDouble();
      _last = now;
      onTick(dt);
      if (running.value) _schedule();
    });
  }
}

/// 再生・一時停止・リセット。波動の足場と同じ見た目。
class PlayPauseResetButtons extends StatelessWidget {
  const PlayPauseResetButtons({
    super.key,
    required this.playing,
    required this.onPlayPause,
    required this.onReset,
    this.playTooltip,
    this.pauseTooltip,
  });

  final bool playing;
  final VoidCallback onPlayPause;
  final VoidCallback onReset;
  final String? playTooltip;
  final String? pauseTooltip;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final play = playTooltip ?? l10n?.play ?? '再生';
    final pause = pauseTooltip ?? l10n?.pause ?? '一時停止';
    final reset = l10n?.reset ?? 'リセット';
    const btnSize = 26.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: btnSize,
            color: Colors.white,
            tooltip: playing ? pause : play,
            onPressed: onPlayPause,
            icon: Icon(playing ? Icons.pause : Icons.play_arrow),
          ),
          Container(
            width: 1,
            height: btnSize,
            color: Colors.white.withValues(alpha: 0.25),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: btnSize,
            color: Colors.white,
            tooltip: reset,
            onPressed: onReset,
            icon: const Icon(Icons.restore),
          ),
        ],
      ),
    );
  }
}

/// 転倒・画面外で止まったあとだけ出す。自動では戻さない。
class RestartFromStartButton extends StatelessWidget {
  const RestartFromStartButton({super.key, required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label =
        AppLocalizations.of(context)?.restartFromStart ?? '最初から';
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF37474F),
        foregroundColor: Colors.white,
        visualDensity: VisualDensity.compact,
      ),
      icon: const Icon(Icons.replay, size: 18),
      label: Text(label),
    );
  }
}

/// アニメ終了後だけ出すリセット。見た目は [PlayPauseResetButtons] に合わせる。
class ResetOnlyButton extends StatelessWidget {
  const ResetOnlyButton({
    super.key,
    required this.onReset,
    this.tooltip,
  });

  final VoidCallback onReset;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final tip = tooltip ?? AppLocalizations.of(context)?.reset ?? 'リセット';
    const btnSize = 26.0;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
      child: IconButton(
        visualDensity: VisualDensity.compact,
        iconSize: btnSize,
        color: Colors.white,
        tooltip: tip,
        onPressed: onReset,
        icon: const Icon(Icons.restore),
      ),
    );
  }
}
