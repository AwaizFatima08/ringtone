import 'package:easyringtone/app.dart';
import 'package:easyringtone/core/prefs.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_platform.dart';

Future<FakeTonePlatform> _pumpApp(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
  void Function(FakeTonePlatform)? setUp,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final platform = FakeTonePlatform();
  setUp?.call(platform);
  // A small phone held upright, with big text, as many elderly users set it.
  tester.view.physicalSize = const Size(720, 1520);
  tester.view.devicePixelRatio = 2;
  tester.platformDispatcher.textScaleFactorTestValue = 1.3;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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
  return platform;
}

/// Scrolls the page until [text] is fully on screen, then taps it.
Future<void> _tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 150, scrollable: find.byType(Scrollable).last);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('home shows the six jobs and switches to Urdu', (tester) async {
    await _pumpApp(tester);

    for (final label in [
      'Call ringtone',
      'Message tone',
      'Alarm tone',
      'WhatsApp & other apps',
      'Volume & vibration',
      'Loud tones (weak hearing)',
    ]) {
      await tester.scrollUntilVisible(find.text(label), 100);
      expect(find.text(label), findsOneWidget);
    }

    await tester.tap(find.text('اردو'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('کال کی ٹون'), -150);
    expect(find.text('کال کی ٹون'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the call page lists the phone tones', (tester) async {
    await _pumpApp(tester);

    await _tapText(tester, 'Call ringtone');
    await _tapText(tester, "Phone's tones");

    expect(find.text('Classic'), findsOneWidget);
    expect(find.text('Use this'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('volume page: + raises the ring volume and Sound on switches the mode', (
    tester,
  ) async {
    final platform = await _pumpApp(tester);

    await _tapText(tester, 'Volume & vibration');
    expect(find.text('3 of 7'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Louder').first);
    await tester.pumpAndSettle();
    expect(platform.volumeLevels[VolumeStream.ring]!.level, 4);

    await _tapText(tester, 'Sound on');
    expect(platform.mode, RingerMode.normal);
    expect(tester.takeException(), isNull);
  });

  testWidgets('volume page warns about Do Not Disturb and opens its switch', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final platform = await _pumpApp(tester, setUp: (p) => p.doNotDisturb = true);

    await _tapText(tester, 'Volume & vibration');
    expect(find.text('“Do Not Disturb” is on'), findsOneWidget);
    await _tapText(tester, 'Turn it off');

    expect(platform.opened, ['settings:doNotDisturb']);
  });

  testWidgets('WhatsApp guide opens the app sound page', (tester) async {
    final platform = await _pumpApp(tester);

    await _tapText(tester, 'WhatsApp & other apps');
    await _tapText(tester, 'WhatsApp');
    await _tapText(tester, 'Open WhatsApp sounds');

    expect(platform.opened, ['sounds:com.whatsapp']);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a saved language choice is used at start', (tester) async {
    await _pumpApp(tester, prefs: {'locale': 'ur'});

    expect(find.text('آسان رنگ ٹون'), findsOneWidget);
  });
}
