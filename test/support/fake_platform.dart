import 'dart:async';
import 'dart:typed_data';

import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';

/// In-memory Android: remembers what the app changed so tests can check it.
class FakeTonePlatform implements TonePlatform {
  bool canWrite = true;
  final defaults = <ToneKind, Tone>{};
  final saved = <({String source, String title, ToneKind kind})>[];
  final volumeLevels = {
    VolumeStream.ring: const VolumeLevel(level: 3, min: 0, max: 7),
    VolumeStream.message: const VolumeLevel(level: 3, min: 0, max: 7),
    VolumeStream.alarm: const VolumeLevel(level: 5, min: 1, max: 7),
    VolumeStream.media: const VolumeLevel(level: 8, min: 0, max: 15),
    VolumeStream.call: const VolumeLevel(level: 2, min: 1, max: 5),
  };
  RingerMode mode = RingerMode.vibrate;
  bool doNotDisturb = false;
  bool dndAccess = false;
  bool? vibrate = false;
  ChangeOutcome ringerOutcome = ChangeOutcome.ok;
  final _stopped = StreamController<void>.broadcast();
  final opened = <String>[];

  @override
  Future<Tone?> currentTone(ToneKind kind) async => defaults[kind];

  @override
  Future<List<Tone>> phoneTones(ToneKind kind) async => const [
    Tone.inPhone(uri: 'content://media/internal/audio/1', title: 'Classic'),
    Tone.inPhone(uri: 'content://media/internal/audio/2', title: 'Bells'),
  ];

  @override
  Future<bool> canWriteSettings() async => canWrite;

  @override
  Future<ChangeOutcome> setDefault(ToneKind kind, String uri) async {
    if (!canWrite) return ChangeOutcome.needsPermission;
    defaults[kind] = Tone.inPhone(uri: uri, title: uri);
    return ChangeOutcome.ok;
  }

  @override
  Future<String> saveTone({
    required String source,
    required String title,
    required ToneKind kind,
  }) async {
    saved.add((source: source, title: title, kind: kind));
    return 'content://media/external/audio/${saved.length}';
  }

  @override
  Future<Tone?> pickAudio() async => null;

  @override
  Future<PlayNote> play(String source, ToneKind kind) async => switch (mode) {
    RingerMode.silent => PlayNote.silent,
    RingerMode.vibrate => PlayNote.vibrate,
    RingerMode.normal => doNotDisturb ? PlayNote.doNotDisturb : PlayNote.none,
  };

  @override
  Future<void> stop() async => _stopped.add(null);

  @override
  Stream<void> get playbackStopped => _stopped.stream;

  @override
  Future<Map<VolumeStream, VolumeLevel>> volumes() async => Map.of(volumeLevels);

  @override
  Future<ChangeOutcome> setVolume(VolumeStream stream, int level) async {
    volumeLevels[stream] = volumeLevels[stream]!.copyWith(level: level);
    return ChangeOutcome.ok;
  }

  @override
  Future<RingerMode> ringerMode() async => mode;

  @override
  Future<ChangeOutcome> setRingerMode(RingerMode mode) async {
    if (ringerOutcome == ChangeOutcome.ok) this.mode = mode;
    return ringerOutcome;
  }

  @override
  Future<bool?> vibrateWhenRinging() async => vibrate;

  @override
  Future<ChangeOutcome> setVibrateWhenRinging({required bool on}) async {
    vibrate = on;
    return ChangeOutcome.ok;
  }

  @override
  Future<void> testVibration() async {}

  @override
  Future<bool> doNotDisturbOn() async => doNotDisturb;

  @override
  Future<ChangeOutcome> turnOffDoNotDisturb() async {
    if (!doNotDisturb) return ChangeOutcome.ok;
    if (!dndAccess) return ChangeOutcome.needsDndAccess;
    doNotDisturb = false;
    return ChangeOutcome.ok;
  }

  @override
  Future<List<InstalledApp>> installedApps(List<String> packageNames) async => [
    InstalledApp(packageName: 'com.whatsapp', label: 'WhatsApp', icon: _pixel),
  ];

  @override
  Future<bool> openAppSounds(String packageName) async {
    opened.add('sounds:$packageName');
    return true;
  }

  @override
  Future<bool> openApp(String packageName) async {
    opened.add('app:$packageName');
    return true;
  }

  @override
  Future<bool> openSettings(SettingsPage page) async {
    opened.add('settings:${page.name}');
    return true;
  }
}

/// A 1×1 transparent PNG.
final _pixel = Uint8List.fromList([
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);
