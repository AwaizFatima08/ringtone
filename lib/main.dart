import 'dart:async';

import 'package:easyringtone/ads/ad_service.dart';
import 'package:easyringtone/ads/google_ad_service.dart';
import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/prefs.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kReleaseMode) debugPrint('Unhandled Flutter error: ${details.exception}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('Unhandled error: $error\n$stack');
    return true;
  };
  final prefs = await SharedPreferences.getInstance();
  final ads = GoogleAdService();
  runApp(
    ProviderScope(
      // A failed read is shown with a "Try again" button; no silent automatic retries.
      retry: (_, _) => null,
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        tonePlatformProvider.overrideWithValue(MethodChannelTonePlatform()),
        adServiceProvider.overrideWithValue(ads),
      ],
      child: const EasyRingtoneApp(),
    ),
  );
  unawaited(ads.start());
}
