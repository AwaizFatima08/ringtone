import 'dart:async';

import 'package:easyringtone/ads/ad_service.dart';
import 'package:easyringtone/app.dart';
import 'package:easyringtone/config.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final privacyChoices = ref.watch(privacyChoicesRequiredProvider).value ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.about)),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(l10n.appTitle, style: theme.textTheme.headlineSmall),
          Text(l10n.version(kAppVersion), style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          Text(l10n.aboutBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.privacyTitle, style: theme.textTheme.titleMedium),
          Text(l10n.privacyBody, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          SelectableText(kPrivacyUrl, style: theme.textTheme.bodyLarge),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            icon: const Icon(Icons.copy),
            onPressed: () async {
              await Clipboard.setData(const ClipboardData(text: kPrivacyUrl));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.copied)));
              }
            },
            label: Text(l10n.copyLink),
          ),
          if (privacyChoices) ...[
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              icon: const Icon(Icons.privacy_tip),
              onPressed: () => unawaited(ref.read(adServiceProvider).showPrivacyChoices()),
              label: Text(l10n.privacyChoices),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          Text(l10n.madeBy, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
