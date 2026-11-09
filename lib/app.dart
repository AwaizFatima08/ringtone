import 'package:easyringtone/core/prefs.dart';
import 'package:easyringtone/features/home/home_screen.dart';
import 'package:easyringtone/l10n/gen/app_localizations.dart';
import 'package:easyringtone/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class EasyRingtoneApp extends ConsumerWidget {
  const EasyRingtoneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => MaterialApp(
    debugShowCheckedModeBanner: false,
    onGenerateTitle: (context) => context.l10n.appTitle,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    locale: ref.watch(localeProvider),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    // Follow the phone's large-text setting, but stop before the buttons break apart.
    builder: (context, child) =>
        MediaQuery.withClampedTextScaling(maxScaleFactor: 1.5, child: child!),
    home: const HomeScreen(),
  );
}
