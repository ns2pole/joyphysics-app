import 'package:flutter/material.dart';

const highPitchSoundWarningTitle = '高い音が出ます';
const highPitchSoundWarningMessage =
    'YouTube動画の再生時に高い音が出ます。苦手な人は注意してください。';

Future<bool> confirmHighPitchSound(BuildContext context) async {
  final proceed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text(highPitchSoundWarningTitle),
      content: const Text(highPitchSoundWarningMessage),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('戻る'),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('OK'),
        ),
      ],
    ),
  );
  return proceed == true;
}

/// YouTube再生などを、高音注意の確認が取れるまで止める。
class HighPitchPlayGate extends StatefulWidget {
  final Widget child;
  final bool enabled;
  final Future<void> Function()? onConfirmed;

  const HighPitchPlayGate({
    super.key,
    required this.child,
    this.enabled = true,
    this.onConfirmed,
  });

  @override
  State<HighPitchPlayGate> createState() => _HighPitchPlayGateState();
}

class _HighPitchPlayGateState extends State<HighPitchPlayGate> {
  bool _confirmed = false;
  bool _confirming = false;

  Future<void> _onTap() async {
    if (_confirming || _confirmed) return;
    _confirming = true;
    final ok = await confirmHighPitchSound(context);
    _confirming = false;
    if (!ok || !mounted) return;
    setState(() => _confirmed = true);
    await widget.onConfirmed?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled || _confirmed) {
      return widget.child;
    }
    // WebView を半透明オーバーレイの下に置くと、Android で再生後に黒画面になる。
    // 確認が取れるまで child（YouTube）はマウントしない。
    return Material(
      color: Colors.black,
      child: InkWell(
        onTap: _onTap,
        child: const Center(
          child: Icon(
            Icons.play_circle_fill,
            size: 72,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
