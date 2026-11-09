import 'dart:async';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/features/tones/view/tone_flows.dart';
import 'package:easyringtone/features/tones/view/tone_sources_screen.dart';
import 'package:easyringtone/features/volume/volume_providers.dart';
import 'package:easyringtone/ui/feedback.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:easyringtone/ui/widgets/stop_playback_on_exit.dart';
import 'package:easyringtone/ui/widgets/tone_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// For people who hear less: one button to make the phone loud, low-pitched loud tones, and the
/// way to Android's flash alerts.
class LoudScreen extends ConsumerWidget {
  const LoudScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return StopPlaybackOnExit(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.homeLoud), backgroundColor: AppColors.loud),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(l10n.loudIntro, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.loud,
                minimumSize: const Size.fromHeight(88),
              ),
              icon: const Icon(Icons.campaign, size: 40),
              onPressed: () => unawaited(_makeLoud(context, ref)),
              label: Text(l10n.makeLoud),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.loudTones, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final loud in LoudTone.values)
              Builder(
                builder: (context) {
                  final tone = Tone.asset(key: loud.assetKey, title: loudToneTitle(l10n, loud));
                  return ToneRow(
                    tone: tone,
                    kind: loud.bestFor,
                    actionLabel: l10n.useThis,
                    onAction: () => unawaited(_use(context, ref, tone)),
                  );
                },
              ),
            const SizedBox(height: AppSpacing.md),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.flashlight_on, size: 36, color: AppColors.alarm),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(child: Text(l10n.flashTitle, style: theme.textTheme.titleMedium)),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(l10n.flashBody, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.accessibility_new),
                      onPressed: () => unawaited(
                        ref.read(tonePlatformProvider).openSettings(SettingsPage.accessibility),
                      ),
                      label: Text(l10n.openSettings),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeLoud(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final ChangeOutcome outcome;
    try {
      outcome = await ref.read(soundProvider.notifier).makeLoud();
    } on PlatformException {
      if (context.mounted) await showProblem(context, l10n.somethingWrong);
      return;
    }
    if (!context.mounted) return;
    if (outcome == ChangeOutcome.needsDndAccess) {
      await askDndAccess(context, ref);
      return;
    }
    await showDone(context, l10n.madeLoud);
  }

  /// Asks which sound the tone is for (calls, messages or alarm), then uses it.
  Future<void> _use(BuildContext context, WidgetRef ref, Tone tone) async {
    final l10n = context.l10n;
    final kind = await showModalBottomSheet<ToneKind>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.useFor, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: AppSpacing.md),
              for (final (k, icon, color) in [
                (ToneKind.call, Icons.call, AppColors.call),
                (ToneKind.message, Icons.message, AppColors.message),
                (ToneKind.alarm, Icons.alarm, AppColors.alarm),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: color),
                    onPressed: () => Navigator.pop(context, k),
                    icon: Icon(icon),
                    label: Text(kindTitle(l10n, k)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    if (kind == null || !context.mounted) return;
    await useToneFlow(context, ref, kind, tone);
  }
}
