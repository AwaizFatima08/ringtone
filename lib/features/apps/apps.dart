import 'package:easyringtone/core/tone_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Chat and social apps the "WhatsApp and other apps" page knows. Keep in step with the
/// `<queries>` list in AndroidManifest.xml, or Android hides them from this app.
const knownApps = [
  'com.whatsapp',
  'com.whatsapp.w4b',
  'com.facebook.orca',
  'com.facebook.mlite',
  'com.facebook.katana',
  'com.facebook.lite',
  'com.instagram.android',
  'org.telegram.messenger',
  'org.thoughtcrime.securesms',
  'com.imo.android.imoim',
  'com.viber.voip',
  'com.snapchat.android',
  'com.zhiliaoapp.musically',
  'com.google.android.apps.messaging',
  'com.samsung.android.messaging',
  'com.android.mms',
  'com.google.android.gm',
  'com.google.android.apps.tachyon',
  'com.skype.raider',
];

/// Apps whose own settings hold their tones (in addition to Android's notification page).
const appsWithOwnToneSettings = {'com.whatsapp', 'com.whatsapp.w4b'};

final FutureProvider<List<InstalledApp>> installedChatAppsProvider =
    FutureProvider<List<InstalledApp>>(
      (ref) => ref.watch(tonePlatformProvider).installedApps(knownApps),
    );
