import 'dart:async';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/application/tone_providers.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/features/tones/view/record_screen.dart';
import 'package:easyringtone/features/tones/view/tone_flows.dart';
import 'package:easyringtone/l10n/gen/app_localizations.dart';
import 'package:easyringtone/ui/feedback.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:easyringtone/ui/widgets/big_tile.dart';
import 'package:easyringtone/ui/widgets/stop_playback_on_exit.dart';
import 'package:easyringtone/ui/widgets/tone_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four places a tone can come from. Used for the call, message and alarm pages and
/// (with a different action) for adding a tone for WhatsApp and other apps.
class ToneSourcesScreen extends ConsumerWidget {
  const ToneSourcesScreen({
    required this.title,
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    this.intro,
    this.showCurrent = true,
    super.key,
  });

  /// The call / message / alarm page.
  factory ToneSourcesScreen.forKind(AppLocalizations l10n, ToneKind kind) => ToneSourcesScreen(
    title: kindTitle(l10n, kind),
    kind: kind,
    actionLabel: l10n.useThis,
    onAction: (context, ref, tone) => useToneFlow(context, ref, kind, tone),
  );

  final String title;
  final String? intro;
  final ToneKind kind;
  final String actionLabel;
  final ToneAction onAction;
  final bool showCurrent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final intro = this.intro;
    void open(Widget page) =>
        unawaited(Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page)));
    return StopPlaybackOnExit(
      child: Scaffold(
        appBar: AppBar(title: Text(title)),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            if (intro != null) ...[
              Text(intro, style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.md),
            ],
            if (showCurrent) _CurrentToneCard(kind: kind),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Text(l10n.chooseFrom, style: theme.textTheme.titleMedium),
            ),
            BigTile(
              icon: Icons.library_music,
              color: AppColors.message,
              label: l10n.sourcePhone,
              subtitle: l10n.sourcePhoneHint,
              onTap: () => open(
                PhoneTonesScreen(kind: kind, actionLabel: actionLabel, onAction: onAction),
              ),
            ),
            BigTile(
              icon: Icons.audio_file,
              color: AppColors.apps,
              label: l10n.sourceFile,
              subtitle: l10n.sourceFileHint,
              onTap: () => unawaited(_pickFile(context, ref)),
            ),
            BigTile(
              icon: Icons.mic,
              color: AppColors.call,
              label: l10n.sourceVoice,
              subtitle: l10n.sourceVoiceHint,
              onTap: () => open(
                RecordScreen(kind: kind, actionLabel: actionLabel, onAction: onAction),
              ),
            ),
            BigTile(
              icon: Icons.volume_up,
              color: AppColors.loud,
              label: l10n.sourceLoud,
              subtitle: l10n.sourceLoudHint,
              onTap: () => open(
                LoudTonesListScreen(kind: kind, actionLabel: actionLabel, onAction: onAction),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickFile(BuildContext context, WidgetRef ref) async {
    final Tone? tone;
    try {
      tone = await ref.read(tonePlatformProvider).pickAudio();
    } on PlatformException {
      if (context.mounted) await showProblem(context, context.l10n.somethingWrong);
      return;
    }
    if (tone == null || !context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ConfirmToneScreen(
          tone: tone!,
          kind: kind,
          actionLabel: actionLabel,
          onAction: onAction,
        ),
      ),
    );
  }
}

String kindTitle(AppLocalizations l10n, ToneKind kind) => switch (kind) {
  ToneKind.call => l10n.homeCall,
  ToneKind.message => l10n.homeMessage,
  ToneKind.alarm => l10n.homeAlarm,
};

class _CurrentToneCard extends ConsumerWidget {
  const _CurrentToneCard({required this.kind});

  final ToneKind kind;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final current = ref.watch(currentToneProvider(kind));
    return Card(
      color: theme.colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.nowUsing, style: theme.textTheme.bodyLarge),
            switch (current) {
              AsyncData(value: final tone?) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    tone.title.isEmpty ? l10n.unknownTone : tone.title,
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ListenButton(tone: tone, kind: kind),
                ],
              ),
              AsyncData() => Text(l10n.noTone, style: theme.textTheme.titleLarge),
              AsyncError() => Text(l10n.unknownTone, style: theme.textTheme.titleLarge),
              _ => const LinearProgressIndicator(),
            },
          ],
        ),
      ),
    );
  }
}

/// Tones already on the phone: the user's own (recordings, songs, loud tones) first, then Android's.
class PhoneTonesScreen extends ConsumerWidget {
  const PhoneTonesScreen({
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final ToneKind kind;
  final String actionLabel;
  final ToneAction onAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    ref.watch(myTonesProvider);
    final mine = ref.read(myTonesProvider.notifier).distinct();
    final phone = ref.watch(phoneTonesProvider(kind));
    final currentUri = ref.watch(currentToneProvider(kind)).value?.source;
    Widget row(Tone tone) => ToneRow(
      tone: tone,
      kind: kind,
      actionLabel: actionLabel,
      isCurrent: tone.source == currentUri,
      onAction: () async {
        if (await onAction(context, ref, tone) && context.mounted) Navigator.pop(context);
      },
    );
    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: AppSpacing.sm),
      child: Text(text, style: theme.textTheme.titleMedium),
    );
    return StopPlaybackOnExit(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.sourcePhone)),
        body: switch (phone) {
          AsyncError() => _Retry(onRetry: () => ref.invalidate(phoneTonesProvider(kind))),
          AsyncData(value: final tones) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              if (mine.isNotEmpty) ...[
                heading(l10n.myTones),
                for (final t in mine) row(t.tone),
                heading(l10n.phoneTones),
              ],
              if (tones.isEmpty) Text(l10n.noPhoneTones, style: theme.textTheme.bodyLarge),
              for (final t in tones) row(t),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

/// A single picked song or sound: listen to it, then use it.
class ConfirmToneScreen extends StatelessWidget {
  const ConfirmToneScreen({
    required this.tone,
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final Tone tone;
  final ToneKind kind;
  final String actionLabel;
  final ToneAction onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return StopPlaybackOnExit(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.sourceFile)),
        body: Consumer(
          builder: (context, ref, _) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const Icon(Icons.music_note, size: 96, color: AppColors.apps),
              Text(tone.title, style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.md),
              Text(l10n.songTip, style: theme.textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.lg),
              ListenButton(tone: tone, kind: kind),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                icon: const Icon(Icons.check),
                onPressed: () async {
                  if (await onAction(context, ref, tone) && context.mounted) Navigator.pop(context);
                },
                label: Text(actionLabel),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The app's own loud tones, the best ones for this kind first.
class LoudTonesListScreen extends StatelessWidget {
  const LoudTonesListScreen({
    required this.kind,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final ToneKind kind;
  final String actionLabel;
  final ToneAction onAction;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tones = [...LoudTone.values]
      ..sort((a, b) {
        final aBest = a.bestFor == kind ? 0 : 1;
        final bBest = b.bestFor == kind ? 0 : 1;
        return aBest.compareTo(bBest);
      });
    return StopPlaybackOnExit(
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.sourceLoud)),
        body: Consumer(
          builder: (context, ref, _) => ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final loud in tones)
                ToneRow(
                  tone: Tone.asset(key: loud.assetKey, title: loudToneTitle(l10n, loud)),
                  kind: kind,
                  actionLabel: actionLabel,
                  onAction: () async {
                    final tone = Tone.asset(key: loud.assetKey, title: loudToneTitle(l10n, loud));
                    if (await onAction(context, ref, tone) && context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

String loudToneTitle(AppLocalizations l10n, LoudTone tone) => switch (tone) {
  LoudTone.bell => l10n.loudBell,
  LoudTone.deepBeep => l10n.loudDeepBeep,
  LoudTone.warmChime => l10n.loudWarmChime,
  LoudTone.strongPulse => l10n.loudStrongPulse,
  LoudTone.doubleTone => l10n.loudDoubleTone,
  LoudTone.knock => l10n.loudKnock,
};

class _Retry extends StatelessWidget {
  const _Retry({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(context.l10n.somethingWrong, textAlign: TextAlign.center),
          const SizedBox(height: AppSpacing.md),
          FilledButton(onPressed: onRetry, child: Text(context.l10n.tryAgain)),
        ],
      ),
    ),
  );
}
