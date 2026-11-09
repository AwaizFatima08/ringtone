import 'dart:async';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/view/tone_flows.dart';
import 'package:easyringtone/features/volume/volume_providers.dart';
import 'package:easyringtone/l10n/gen/app_localizations.dart';
import 'package:easyringtone/ui/feedback.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound / Vibrate / Silent, five volumes with big − and + buttons, and vibration.
class VolumeScreen extends ConsumerStatefulWidget {
  const VolumeScreen({super.key});

  @override
  ConsumerState<VolumeScreen> createState() => _VolumeScreenState();
}

class _VolumeScreenState extends ConsumerState<VolumeScreen> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    // The user may change things with the phone's own buttons or in Settings.
    _listener = AppLifecycleListener(
      onResume: () => unawaited(ref.read(soundProvider.notifier).refresh()),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final sound = ref.watch(soundProvider);
    final platform = ref.read(tonePlatformProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeVolume)),
      body: switch (sound) {
        AsyncData(value: final s) => ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            Text(l10n.soundMode, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _ModeButtons(mode: s.mode, onChoose: (m) => _guard(() => _notifier.setMode(m))),
            const SizedBox(height: AppSpacing.lg),
            Text(l10n.volumes, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            for (final stream in VolumeStream.values)
              if (s.volumes[stream] case final level?)
                _VolumeRow(
                  stream: stream,
                  level: level,
                  onStep: (by) => _guard(() => _notifier.step(stream, by)),
                ),
            const SizedBox(height: AppSpacing.md),
            Text(l10n.vibration, style: theme.textTheme.titleMedium),
            Card(
              child: Column(
                children: [
                  if (s.vibrateWhenRinging != null)
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      title: Text(l10n.vibrateWhenRinging, style: theme.textTheme.titleMedium),
                      value: s.vibrateWhenRinging!,
                      onChanged: (on) => unawaited(_setVibrate(on: on)),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.vibration),
                        onPressed: () => unawaited(platform.testVibration()),
                        label: Text(l10n.testVibration),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.settings),
              onPressed: () => unawaited(platform.openSettings(SettingsPage.sound)),
              label: Text(l10n.moreSoundSettings),
            ),
          ],
        ),
        AsyncError() => Center(
          child: FilledButton(
            onPressed: () => ref.invalidate(soundProvider),
            child: Text(l10n.tryAgain),
          ),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  SoundController get _notifier => ref.read(soundProvider.notifier);

  void _guard(Future<ChangeOutcome> Function() change) => unawaited(() async {
    try {
      final outcome = await change();
      if (outcome == ChangeOutcome.needsDndAccess && mounted) await askDndAccess(context, ref);
    } on PlatformException {
      if (mounted) await showProblem(context, context.l10n.somethingWrong);
    }
  }());

  Future<void> _setVibrate({required bool on}) async {
    final l10n = context.l10n;
    var outcome = await _notifier.setVibrateWhenRinging(on: on);
    if (outcome == ChangeOutcome.needsPermission && mounted) {
      if (!await askWriteSettings(context, ref)) return;
      outcome = await _notifier.setVibrateWhenRinging(on: on);
    }
    if (outcome == ChangeOutcome.notAllowed && mounted) {
      final open = await askYesNo(
        context,
        title: l10n.vibrateWhenRinging,
        message: l10n.vibrateNotAllowed,
        yes: l10n.openSettings,
        no: l10n.notNow,
      );
      if (open) await ref.read(tonePlatformProvider).openSettings(SettingsPage.sound);
    }
  }
}

class _ModeButtons extends StatelessWidget {
  const _ModeButtons({required this.mode, required this.onChoose});

  final RingerMode mode;
  final ValueChanged<RingerMode> onChoose;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    Widget button(RingerMode m, IconData icon, String label) {
      final selected = m == mode;
      return Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: selected
            ? FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.volume),
                onPressed: () => onChoose(m),
                icon: Icon(icon),
                label: Text('$label  ✓'),
              )
            : OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: scheme.onSurface),
                onPressed: () => onChoose(m),
                icon: Icon(icon),
                label: Text(label),
              ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        button(RingerMode.normal, Icons.notifications_active, l10n.modeSound),
        button(RingerMode.vibrate, Icons.vibration, l10n.modeVibrate),
        button(RingerMode.silent, Icons.notifications_off, l10n.modeSilent),
      ],
    );
  }
}

class _VolumeRow extends StatelessWidget {
  const _VolumeRow({required this.stream, required this.level, required this.onStep});

  final VolumeStream stream;
  final VolumeLevel level;
  final ValueChanged<int> onStep;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final (icon, label) = _labelFor(l10n, stream);
    final range = level.max - level.min;
    final fraction = range <= 0 ? 0.0 : (level.level - level.min) / range;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(icon, size: 32, color: AppColors.volume),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(label, style: theme.textTheme.titleMedium)),
                Text(l10n.levelOf(level.level, level.max), style: theme.textTheme.titleMedium),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                _StepButton(
                  icon: Icons.remove,
                  tooltip: l10n.quieter,
                  onPressed: level.level > level.min ? () => onStep(-1) : null,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: fraction,
                      minHeight: 20,
                      color: AppColors.volume,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                _StepButton(
                  icon: Icons.add,
                  tooltip: l10n.louder,
                  onPressed: level.level < level.max ? () => onStep(1) : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static (IconData, String) _labelFor(AppLocalizations l10n, VolumeStream stream) =>
      switch (stream) {
        VolumeStream.ring => (Icons.ring_volume, l10n.volumeRing),
        VolumeStream.message => (Icons.message, l10n.volumeMessage),
        VolumeStream.alarm => (Icons.alarm, l10n.volumeAlarm),
        VolumeStream.media => (Icons.music_note, l10n.volumeMedia),
        VolumeStream.call => (Icons.phone_in_talk, l10n.volumeCall),
      };
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.tooltip, required this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => IconButton.filled(
    tooltip: tooltip,
    iconSize: 36,
    style: IconButton.styleFrom(
      minimumSize: const Size.square(AppSpacing.buttonHeight),
      backgroundColor: AppColors.volume,
    ),
    onPressed: onPressed,
    icon: Icon(icon),
  );
}
