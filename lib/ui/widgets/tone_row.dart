import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/application/tone_providers.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/ui/feedback.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One tone: its name, a Listen / Stop button and the page's action button ("Use this", "Save").
class ToneRow extends ConsumerWidget {
  const ToneRow({
    required this.tone,
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    this.isCurrent = false,
    super.key,
  });

  final Tone tone;
  final ToneKind kind;
  final String actionLabel;
  final VoidCallback onAction;
  final bool isCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      color: isCurrent ? theme.colorScheme.primaryContainer : null,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(tone.title, style: theme.textTheme.titleMedium),
            if (isCurrent)
              Text(
                l10n.inUseNow,
                style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.call),
              ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: ListenButton(tone: tone, kind: kind),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton(onPressed: onAction, child: Text(actionLabel)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Plays a tone on the volume it will really ring with; warns when the phone is on silent.
class ListenButton extends ConsumerWidget {
  const ListenButton({required this.tone, required this.kind, super.key});

  final Tone tone;
  final ToneKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final playing = ref.watch(playbackProvider) == tone.source;
    return OutlinedButton.icon(
      onPressed: () async {
        try {
          final note = await ref.read(playbackProvider.notifier).toggle(tone, kind);
          if (!context.mounted) return;
          switch (note) {
            case PlayNote.silent:
              showNote(context, l10n.phoneIsSilent);
            case PlayNote.vibrate:
              showNote(context, l10n.phoneIsVibrate);
            case PlayNote.doNotDisturb:
              showNote(context, l10n.phoneIsDnd);
            case PlayNote.none || null:
              break;
          }
        } on PlatformException {
          await ref.read(playbackProvider.notifier).stop();
          if (context.mounted) showNote(context, l10n.cannotPlay);
        }
      },
      icon: Icon(playing ? Icons.stop_circle : Icons.play_circle),
      label: Text(playing ? l10n.stop : l10n.listen),
    );
  }
}
