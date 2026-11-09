import 'dart:async';
import 'dart:io';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/features/tones/application/tone_providers.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/features/tones/view/tone_flows.dart';
import 'package:easyringtone/ui/feedback.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:easyringtone/ui/widgets/stop_playback_on_exit.dart';
import 'package:easyringtone/ui/widgets/tone_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

/// Record the user's own voice (up to 30 seconds), listen, then use it as a tone.
class RecordScreen extends ConsumerStatefulWidget {
  const RecordScreen({
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  static const maxLength = Duration(seconds: 30);

  final ToneKind kind;
  final String actionLabel;
  final ToneAction onAction;

  @override
  ConsumerState<RecordScreen> createState() => _RecordScreenState();
}

class _RecordScreenState extends ConsumerState<RecordScreen> {
  final _recorder = AudioRecorder();
  Timer? _ticker;
  int _seconds = 0;
  bool _recording = false;
  Tone? _result;

  @override
  void dispose() {
    _ticker?.cancel();
    unawaited(_recorder.dispose());
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = context.l10n;
    if (!await _recorder.hasPermission()) {
      if (mounted) await showProblem(context, l10n.micDenied);
      return;
    }
    await ref.read(playbackProvider.notifier).stop();
    final dir = Directory('${(await getApplicationDocumentsDirectory()).path}/recordings');
    await dir.create(recursive: true);
    final path = '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
    await _recorder.start(const RecordConfig(numChannels: 1), path: path);
    setState(() {
      _recording = true;
      _seconds = 0;
      _result = null;
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _seconds++);
      if (_seconds >= RecordScreen.maxLength.inSeconds) unawaited(_stop());
    });
  }

  Future<void> _stop() async {
    _ticker?.cancel();
    final path = await _recorder.stop();
    if (!mounted) return;
    final number = await ref.read(myTonesProvider.notifier).nextVoiceNumber();
    if (!mounted) return;
    setState(() {
      _recording = false;
      _result = path == null || _seconds < 1
          ? null
          : Tone.recording(path: path, title: context.l10n.myVoice(number));
    });
    if (_result == null) showNote(context, context.l10n.recordingTooShort);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final result = _result;
    return StopPlaybackOnExit(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.sourceVoice)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            Text(
              _recording ? l10n.recordingNow : l10n.recordTip,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: SizedBox.square(
                dimension: 160,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    shape: const CircleBorder(),
                    backgroundColor: _recording ? Colors.black87 : AppColors.loud,
                  ),
                  onPressed: () => unawaited(_recording ? _stop() : _start()),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_recording ? Icons.stop : Icons.mic, size: 64),
                      Text(_recording ? l10n.stopRecording : l10n.startRecording),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            if (_recording)
              Text(
                l10n.secondsOf(_seconds, RecordScreen.maxLength.inSeconds),
                style: theme.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
            if (result != null) ...[
              Text(result.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              ListenButton(tone: result, kind: widget.kind),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  if (await widget.onAction(context, ref, result) && context.mounted) {
                    Navigator.pop(context);
                  }
                },
                label: Text(widget.actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
