import 'package:easyringtone/core/prefs.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/application/tone_providers.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:easyringtone/features/volume/volume_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../support/fake_platform.dart';

Future<(ProviderContainer, FakeTonePlatform)> _setUp() async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final platform = FakeTonePlatform();
  final container = ProviderContainer(
    overrides: [
      prefsProvider.overrideWithValue(prefs),
      tonePlatformProvider.overrideWithValue(platform),
    ],
  );
  addTearDown(container.dispose);
  return (container, platform);
}

void main() {
  const loud = Tone.asset(key: 'assets/tones/loud_bell.ogg', title: 'Old phone bell');

  test('a phone tone is used as it is, without copying', () async {
    final (c, platform) = await _setUp();
    const tone = Tone.inPhone(uri: 'content://media/internal/audio/1', title: 'Classic');

    expect(await c.read(toneActionsProvider).use(ToneKind.call, tone), ChangeOutcome.ok);

    expect(platform.saved, isEmpty);
    expect(platform.defaults[ToneKind.call]!.source, tone.source);
  });

  test('a loud tone is copied into the phone once per kind, then reused', () async {
    final (c, platform) = await _setUp();
    final actions = c.read(toneActionsProvider);

    await actions.use(ToneKind.call, loud);
    await actions.use(ToneKind.call, loud);
    await actions.use(ToneKind.alarm, loud);

    expect(platform.saved.map((s) => s.kind), [ToneKind.call, ToneKind.alarm]);
    expect(c.read(myTonesProvider), hasLength(2));
    expect(c.read(myTonesProvider.notifier).distinct(), hasLength(1));
  });

  test('without "Modify system settings" nothing is copied or changed', () async {
    final (c, platform) = await _setUp();
    platform.canWrite = false;

    expect(
      await c.read(toneActionsProvider).use(ToneKind.message, loud),
      ChangeOutcome.needsPermission,
    );

    expect(platform.saved, isEmpty);
    expect(platform.defaults, isEmpty);
  });

  test('a tone for other apps goes into both the message and the call list', () async {
    final (c, platform) = await _setUp();

    await c.read(toneActionsProvider).addForOtherApps(loud);

    expect(platform.saved.map((s) => s.kind), [ToneKind.message, ToneKind.call]);
  });

  test("the phone's own tones are not copied for other apps", () async {
    final (c, platform) = await _setUp();

    await c
        .read(toneActionsProvider)
        .addForOtherApps(
          const Tone.inPhone(uri: 'content://media/internal/audio/1', title: 'Classic'),
        );

    expect(platform.saved, isEmpty);
  });

  test('my tones survive a restart', () async {
    final (c, _) = await _setUp();
    await c.read(toneActionsProvider).use(ToneKind.call, loud);
    final prefs = c.read(prefsProvider);

    final again = ProviderContainer(overrides: [prefsProvider.overrideWithValue(prefs)]);
    addTearDown(again.dispose);

    expect(again.read(myTonesProvider).single.origin, loud.origin);
  });

  test('"Make my phone loud" turns sound on and ring, message and alarm to the top', () async {
    final (c, platform) = await _setUp();
    await c.read(soundProvider.future);

    expect(await c.read(soundProvider.notifier).makeLoud(), ChangeOutcome.ok);

    expect(platform.mode, RingerMode.normal);
    expect(platform.volumeLevels[VolumeStream.ring]!.level, 7);
    expect(platform.volumeLevels[VolumeStream.message]!.level, 7);
    expect(platform.volumeLevels[VolumeStream.alarm]!.level, 7);
    expect(platform.volumeLevels[VolumeStream.media]!.level, 8, reason: 'media left alone');
    expect(platform.vibrate, isTrue);
  });

  test('"Make my phone loud" reports Do Not Disturb it may not turn off', () async {
    final (c, platform) = await _setUp();
    platform.doNotDisturb = true;
    await c.read(soundProvider.future);

    expect(await c.read(soundProvider.notifier).makeLoud(), ChangeOutcome.needsDndAccess);

    platform.dndAccess = true;
    expect(await c.read(soundProvider.notifier).makeLoud(), ChangeOutcome.ok);
    expect(platform.doNotDisturb, isFalse);
  });

  test('volume steps stop at the ends', () async {
    final (c, platform) = await _setUp();
    await c.read(soundProvider.future);
    final sound = c.read(soundProvider.notifier);

    await sound.step(VolumeStream.alarm, -1);
    await sound.step(VolumeStream.alarm, -1);
    await sound.step(VolumeStream.alarm, -1);
    await sound.step(VolumeStream.alarm, -1);
    await sound.step(VolumeStream.alarm, -1);

    expect(platform.volumeLevels[VolumeStream.alarm]!.level, 1);
  });

  test('Do Not Disturb blocking the sound mode is reported, not hidden', () async {
    final (c, platform) = await _setUp();
    platform.ringerOutcome = ChangeOutcome.needsDndAccess;
    await c.read(soundProvider.future);

    expect(
      await c.read(soundProvider.notifier).setMode(RingerMode.silent),
      ChangeOutcome.needsDndAccess,
    );
  });
}
