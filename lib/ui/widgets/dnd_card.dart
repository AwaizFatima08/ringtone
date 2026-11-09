import 'dart:async';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/volume/volume_providers.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Shown only while Do Not Disturb is on: the most common reason an elderly user misses calls.
class DoNotDisturbCard extends ConsumerStatefulWidget {
  const DoNotDisturbCard({super.key});

  @override
  ConsumerState<DoNotDisturbCard> createState() => _DoNotDisturbCardState();
}

class _DoNotDisturbCardState extends ConsumerState<DoNotDisturbCard> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onResume: () => unawaited(ref.read(soundProvider.notifier).refresh()),
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<void> _turnOff() async {
    final outcome = await ref.read(soundProvider.notifier).turnOffDoNotDisturb();
    // Without Do Not Disturb access, send the user straight to the switch: one step, no permission page.
    if (outcome != ChangeOutcome.ok) {
      await ref.read(tonePlatformProvider).openSettings(SettingsPage.doNotDisturb);
    }
  }

  @override
  Widget build(BuildContext context) {
    final on = ref.watch(soundProvider).value?.doNotDisturb ?? false;
    if (!on) return const SizedBox.shrink();
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.do_not_disturb_on, size: 36, color: theme.colorScheme.error),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: Text(l10n.dndOnTitle, style: theme.textTheme.titleMedium)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.dndOnBody, style: theme.textTheme.bodyLarge),
            const SizedBox(height: AppSpacing.md),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: theme.colorScheme.error),
              icon: const Icon(Icons.notifications_active),
              onPressed: () => unawaited(_turnOff()),
              label: Text(l10n.turnOffDnd),
            ),
          ],
        ),
      ),
    );
  }
}
