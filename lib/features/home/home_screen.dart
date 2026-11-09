import 'dart:async';

import 'package:easyringtone/ads/ad_service.dart';
import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/prefs.dart';
import 'package:easyringtone/features/about/about_screen.dart';
import 'package:easyringtone/features/apps/apps_screen.dart';
import 'package:easyringtone/features/loud/loud_screen.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/features/tones/view/tone_sources_screen.dart';
import 'package:easyringtone/features/volume/volume_screen.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:easyringtone/ui/widgets/big_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The one front door: six big buttons, a language button, and the only ad in the app.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isUrdu = Localizations.localeOf(context).languageCode == 'ur';
    void open(Widget page) =>
        unawaited(Navigator.push(context, MaterialPageRoute<void>(builder: (_) => page)));
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.appTitle),
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () =>
                unawaited(ref.read(localeProvider.notifier).choose(isUrdu ? 'en' : 'ur')),
            child: Text(isUrdu ? 'English' : 'اردو'),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  BigTile(
                    icon: Icons.call,
                    color: AppColors.call,
                    label: l10n.homeCall,
                    subtitle: l10n.homeCallHint,
                    onTap: () => open(ToneSourcesScreen.forKind(l10n, ToneKind.call)),
                  ),
                  BigTile(
                    icon: Icons.sms,
                    color: AppColors.message,
                    label: l10n.homeMessage,
                    subtitle: l10n.homeMessageHint,
                    onTap: () => open(ToneSourcesScreen.forKind(l10n, ToneKind.message)),
                  ),
                  BigTile(
                    icon: Icons.alarm,
                    color: AppColors.alarm,
                    label: l10n.homeAlarm,
                    subtitle: l10n.homeAlarmHint,
                    onTap: () => open(ToneSourcesScreen.forKind(l10n, ToneKind.alarm)),
                  ),
                  BigTile(
                    icon: Icons.forum,
                    color: AppColors.apps,
                    label: l10n.homeApps,
                    subtitle: l10n.homeAppsHint,
                    onTap: () => open(const AppsScreen()),
                  ),
                  BigTile(
                    icon: Icons.volume_up,
                    color: AppColors.volume,
                    label: l10n.homeVolume,
                    subtitle: l10n.homeVolumeHint,
                    onTap: () => open(const VolumeScreen()),
                  ),
                  BigTile(
                    icon: Icons.hearing,
                    color: AppColors.loud,
                    label: l10n.homeLoud,
                    subtitle: l10n.homeLoudHint,
                    onTap: () => open(const LoudScreen()),
                  ),
                  Center(
                    child: TextButton.icon(
                      icon: const Icon(Icons.info_outline),
                      onPressed: () => open(const AboutScreen()),
                      label: Text(l10n.about),
                    ),
                  ),
                ],
              ),
            ),
            // Kept apart from the buttons so a shaky tap does not land on the ad.
            const Divider(height: AppSpacing.lg),
            ref.watch(adServiceProvider).banner(),
          ],
        ),
      ),
    );
  }
}
