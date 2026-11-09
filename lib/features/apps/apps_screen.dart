import 'dart:async';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/apps/apps.dart';
import 'package:easyringtone/features/tones/application/tone_providers.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/features/tones/view/tone_sources_screen.dart';
import 'package:easyringtone/ui/feedback.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Every chat app on the phone in one list; each opens a short step-by-step page.
class AppsScreen extends ConsumerWidget {
  const AppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final apps = ref.watch(installedChatAppsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.homeApps)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(l10n.appsIntro, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          ...switch (apps) {
            AsyncData(value: final list) => [
              if (list.isEmpty) Text(l10n.noChatApps, style: theme.textTheme.bodyLarge),
              for (final app in list) _AppTile(app: app),
            ],
            AsyncError() => [Text(l10n.somethingWrong)],
            _ => [const Center(child: CircularProgressIndicator())],
          },
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            icon: const Icon(Icons.settings),
            onPressed: () =>
                unawaited(ref.read(tonePlatformProvider).openSettings(SettingsPage.sound)),
            label: Text(l10n.otherAppSettings),
          ),
        ],
      ),
    );
  }
}

class _AppTile extends StatelessWidget {
  const _AppTile({required this.app});

  final InstalledApp app;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => unawaited(
        Navigator.push(
          context,
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: AppGuideScreen.routeName),
            builder: (_) => AppGuideScreen(app: app),
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Image.memory(app.icon, width: 56, height: 56, gaplessPlayback: true),
            const SizedBox(width: AppSpacing.md),
            Expanded(child: Text(app.label, style: Theme.of(context).textTheme.titleLarge)),
            Icon(
              Directionality.of(context) == TextDirection.rtl
                  ? Icons.chevron_left
                  : Icons.chevron_right,
              size: 36,
            ),
          ],
        ),
      ),
    ),
  );
}

/// Android lets only the user change another app's sound, so this page walks them through it:
/// 1. put a tone into the phone's list, 2. open the app's sound page, 3. pick the tone there.
class AppGuideScreen extends ConsumerWidget {
  const AppGuideScreen({required this.app, super.key});

  static const routeName = 'app-guide';

  final InstalledApp app;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final platform = ref.read(tonePlatformProvider);
    final hasOwnSettings = appsWithOwnToneSettings.contains(app.packageName);
    Widget step(int n, String text, Widget? button) => Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.apps,
                  child: Text(
                    '$n',
                    style: theme.textTheme.titleLarge?.copyWith(color: Colors.white),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
              ],
            ),
            if (button != null) ...[const SizedBox(height: AppSpacing.md), button],
          ],
        ),
      ),
    );
    return Scaffold(
      appBar: AppBar(title: Text(app.label)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Row(
            children: [
              Image.memory(app.icon, width: 64, height: 64),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(l10n.appGuideIntro(app.label), style: theme.textTheme.bodyLarge),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          step(
            1,
            l10n.appStep1,
            FilledButton.icon(
              icon: const Icon(Icons.library_add),
              onPressed: () => unawaited(_chooseTone(context)),
              label: Text(l10n.chooseATone),
            ),
          ),
          step(
            2,
            l10n.appStep2(app.label),
            FilledButton.icon(
              icon: const Icon(Icons.notifications_active),
              onPressed: () async {
                if (!await platform.openAppSounds(app.packageName) && context.mounted) {
                  await showProblem(context, l10n.somethingWrong);
                }
              },
              label: Text(l10n.openAppSounds(app.label)),
            ),
          ),
          step(3, l10n.appStep3, null),
          if (hasOwnSettings)
            step(
              4,
              l10n.whatsappTip(app.label),
              OutlinedButton.icon(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => unawaited(platform.openApp(app.packageName)),
                label: Text(l10n.openApp(app.label)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _chooseTone(BuildContext context) => Navigator.push(
    context,
    MaterialPageRoute<void>(
      builder: (_) => ToneSourcesScreen(
        title: context.l10n.chooseATone,
        intro: context.l10n.addToneIntro(app.label),
        kind: ToneKind.message,
        actionLabel: context.l10n.saveTone,
        showCurrent: false,
        onAction: (context, ref, tone) async {
          await ref.read(playbackProvider.notifier).stop();
          if (!context.mounted) return false;
          final l10n = context.l10n;
          final saved = await runWithWait(context, () async {
            await ref.read(toneActionsProvider).addForOtherApps(tone);
            return true;
          });
          if (saved != true || !context.mounted) return false;
          await showDone(context, l10n.toneSavedFor(tone.title, app.label));
          // Straight back to the steps, ready for step 2.
          if (context.mounted) Navigator.popUntil(context, ModalRoute.withName(routeName));
          return false;
        },
      ),
    ),
  );
}
