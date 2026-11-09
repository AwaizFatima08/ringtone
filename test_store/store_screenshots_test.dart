// Renders the Play Store phone screenshots from the real screens with the fake platform.
// Not part of `flutter test`. Run:
//   python3 tool/make_store_fonts.py <dir>
//   STORE_FONTS=<dir> flutter test test_store --update-goldens   → then move test_store/out/*.png to store/screenshots/
import 'dart:io';

import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/prefs.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../test/support/fake_platform.dart';

Future<void> _loadFont(String family, List<String> paths) async {
  final loader = FontLoader(family);
  for (final p in paths) {
    loader.addFont(Future.value(ByteData.sublistView(File(p).readAsBytesSync())));
  }
  await loader.load();
}

Future<void> _pumpApp(WidgetTester tester, {String locale = 'en'}) async {
  // ignore: invalid_use_of_visible_for_testing_member (test_store/ is a test, outside test/)
  SharedPreferences.setMockInitialValues({'locale': locale});
  final sharedPrefs = await SharedPreferences.getInstance();
  final platform = FakeTonePlatform()
    ..mode = RingerMode.normal
    ..defaults[ToneKind.call] = const Tone.inPhone(uri: 'content://x/1', title: 'Classic');
  // 1080×2340 phone.
  tester.view.physicalSize = const Size(1080, 2340);
  tester.view.devicePixelRatio = 2.625;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        prefsProvider.overrideWithValue(sharedPrefs),
        tonePlatformProvider.overrideWithValue(platform),
      ],
      child: const EasyRingtoneApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 150, scrollable: find.byType(Scrollable).last);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _shot(String name) =>
    expectLater(find.byType(MaterialApp), matchesGoldenFile('out/$name.png'));

void main() {
  final flutterRoot = Platform.environment['FLUTTER_ROOT']!;
  final fonts = '$flutterRoot/bin/cache/artifacts/material_fonts';

  setUpAll(() async {
    // Roboto merged with Noto Naskh Arabic and a ✓, made by tool/make_store_fonts.py: the test
    // engine has no font fallback, so Urdu needs to be inside the one family the theme uses.
    final merged = Platform.environment['STORE_FONTS']!;
    await _loadFont('Roboto', [
      '$merged/Roboto-Regular.ttf',
      '$merged/Roboto-Medium.ttf',
      '$merged/Roboto-Bold.ttf',
    ]);
    await _loadFont('MaterialIcons', ['$fonts/MaterialIcons-Regular.otf']);
  });

  testWidgets('1 home', (tester) async {
    await _pumpApp(tester);
    await _shot('1_home_en');
  });

  testWidgets('2 call', (tester) async {
    await _pumpApp(tester);
    await _open(tester, 'Call ringtone');
    await _shot('2_call_en');
  });

  testWidgets('3 loud', (tester) async {
    await _pumpApp(tester);
    await _open(tester, 'Loud tones (weak hearing)');
    await _shot('3_loud_en');
  });

  testWidgets('4 volume', (tester) async {
    await _pumpApp(tester);
    await _open(tester, 'Volume & vibration');
    await _shot('4_volume_en');
  });

  testWidgets('5 home urdu', (tester) async {
    await _pumpApp(tester, locale: 'ur');
    await _shot('5_home_ur');
  });
}
