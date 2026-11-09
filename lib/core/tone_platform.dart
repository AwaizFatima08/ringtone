import 'dart:async';

import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What happened when the app tried to change a phone setting.
enum ChangeOutcome {
  ok,

  /// "Modify system settings" is not switched on for this app yet.
  needsPermission,

  /// Do Not Disturb blocks the change until the user allows "Do Not Disturb access".
  needsDndAccess,

  /// This phone keeps the setting for its own Settings app.
  notAllowed
  ;

  static ChangeOutcome parse(String? wire) =>
      values.firstWhere((v) => v.name == wire, orElse: () => ChangeOutcome.notAllowed);
}

enum RingerMode {
  normal,
  vibrate,
  silent
  ;

  static RingerMode parse(String? wire) =>
      values.firstWhere((v) => v.name == wire, orElse: () => RingerMode.normal);
}

/// The five volumes the app shows, in screen order.
enum VolumeStream { ring, message, alarm, media, call }

class VolumeLevel {
  const VolumeLevel({required this.level, required this.min, required this.max});

  final int level;
  final int min;
  final int max;

  VolumeLevel copyWith({int? level}) => VolumeLevel(level: level ?? this.level, min: min, max: max);
}

class InstalledApp {
  const InstalledApp({required this.packageName, required this.label, required this.icon});

  final String packageName;
  final String label;
  final Uint8List icon;
}

/// Pages that belong to Android's own Settings app.
enum SettingsPage { writeSettings, dndAccess, accessibility, sound }

/// Everything the app asks of Android. Throws [PlatformException] on a native error.
abstract interface class TonePlatform {
  Future<Tone?> currentTone(ToneKind kind);

  Future<List<Tone>> phoneTones(ToneKind kind);

  Future<bool> canWriteSettings();

  Future<ChangeOutcome> setDefault(ToneKind kind, String uri);

  /// Copies [source] into the phone's tone folder for [kind]; returns its new uri.
  Future<String> saveTone({required String source, required String title, required ToneKind kind});

  /// Android's file picker for sounds. Null when the user backed out.
  Future<Tone?> pickAudio();

  /// Plays on the volume the real tone uses. Returns the sound mode so the UI can warn about silent.
  Future<RingerMode> play(String source, ToneKind kind);

  Future<void> stop();

  /// Fires when a sound finishes or is stopped.
  Stream<void> get playbackStopped;

  Future<Map<VolumeStream, VolumeLevel>> volumes();

  Future<ChangeOutcome> setVolume(VolumeStream stream, int level);

  Future<RingerMode> ringerMode();

  Future<ChangeOutcome> setRingerMode(RingerMode mode);

  /// Null when the phone has no "vibrate when ringing" setting.
  Future<bool?> vibrateWhenRinging();

  Future<ChangeOutcome> setVibrateWhenRinging({required bool on});

  Future<void> testVibration();

  Future<List<InstalledApp>> installedApps(List<String> packageNames);

  /// Each `open…` returns false when Android had no page to show.
  Future<bool> openAppSounds(String packageName);

  Future<bool> openApp(String packageName);

  Future<bool> openSettings(SettingsPage page);
}

/// [TonePlatform] over the `com.homilabs.easyringtone/tones` channel (see ToneChannel.kt).
class MethodChannelTonePlatform implements TonePlatform {
  MethodChannelTonePlatform() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'playbackStopped') _stopped.add(null);
    });
  }

  static const _channel = MethodChannel('com.homilabs.easyringtone/tones');
  final _stopped = StreamController<void>.broadcast();

  static Map<String, Object> _kind(ToneKind kind) => {'kind': kind.name};

  @override
  Future<Tone?> currentTone(ToneKind kind) async {
    final m = await _channel.invokeMapMethod<String, String>('getDefault', _kind(kind));
    if (m == null) return null;
    return Tone.inPhone(uri: m['uri']!, title: m['title'] ?? '');
  }

  @override
  Future<List<Tone>> phoneTones(ToneKind kind) async {
    final raw =
        await _channel.invokeListMethod<Map<Object?, Object?>>('listTones', _kind(kind)) ?? [];
    return [
      for (final m in raw) Tone.inPhone(uri: m['uri']! as String, title: m['title']! as String),
    ];
  }

  @override
  Future<bool> canWriteSettings() async =>
      await _channel.invokeMethod<bool>('canWriteSettings') ?? false;

  @override
  Future<ChangeOutcome> setDefault(ToneKind kind, String uri) async => ChangeOutcome.parse(
    await _channel.invokeMethod<String>('setDefault', {..._kind(kind), 'uri': uri}),
  );

  @override
  Future<String> saveTone({
    required String source,
    required String title,
    required ToneKind kind,
  }) async => (await _channel.invokeMethod<String>('saveTone', {
    ..._kind(kind),
    'source': source,
    'title': title,
  }))!;

  @override
  Future<Tone?> pickAudio() async {
    final m = await _channel.invokeMapMethod<String, String>('pickAudio');
    if (m == null) return null;
    return Tone.picked(uri: m['uri']!, title: m['title']!);
  }

  @override
  Future<RingerMode> play(String source, ToneKind kind) async => RingerMode.parse(
    await _channel.invokeMethod<String>('play', {..._kind(kind), 'source': source}),
  );

  @override
  Future<void> stop() => _channel.invokeMethod<void>('stop');

  @override
  Stream<void> get playbackStopped => _stopped.stream;

  @override
  Future<Map<VolumeStream, VolumeLevel>> volumes() async {
    final raw = await _channel.invokeMapMethod<String, Map<Object?, Object?>>('getVolumes') ?? {};
    return {
      for (final stream in VolumeStream.values)
        if (raw[stream.name] case final m?)
          stream: VolumeLevel(
            level: m['level']! as int,
            min: m['min']! as int,
            max: m['max']! as int,
          ),
    };
  }

  @override
  Future<ChangeOutcome> setVolume(VolumeStream stream, int level) async => ChangeOutcome.parse(
    await _channel.invokeMethod<String>('setVolume', {'stream': stream.name, 'level': level}),
  );

  @override
  Future<RingerMode> ringerMode() async =>
      RingerMode.parse(await _channel.invokeMethod<String>('getRingerMode'));

  @override
  Future<ChangeOutcome> setRingerMode(RingerMode mode) async => ChangeOutcome.parse(
    await _channel.invokeMethod<String>('setRingerMode', {'mode': mode.name}),
  );

  @override
  Future<bool?> vibrateWhenRinging() => _channel.invokeMethod<bool>('getVibrateWhenRinging');

  @override
  Future<ChangeOutcome> setVibrateWhenRinging({required bool on}) async => ChangeOutcome.parse(
    await _channel.invokeMethod<String>('setVibrateWhenRinging', {'on': on}),
  );

  @override
  Future<void> testVibration() => _channel.invokeMethod<void>('testVibration');

  @override
  Future<List<InstalledApp>> installedApps(List<String> packageNames) async {
    final raw =
        await _channel.invokeListMethod<Map<Object?, Object?>>('installedApps', {
          'packages': packageNames,
        }) ??
        [];
    return [
      for (final m in raw)
        InstalledApp(
          packageName: m['packageName']! as String,
          label: m['label']! as String,
          icon: m['icon']! as Uint8List,
        ),
    ];
  }

  @override
  Future<bool> openAppSounds(String packageName) async =>
      await _channel.invokeMethod<bool>('openAppSounds', {'packageName': packageName}) ?? false;

  @override
  Future<bool> openApp(String packageName) async =>
      await _channel.invokeMethod<bool>('openApp', {'packageName': packageName}) ?? false;

  @override
  Future<bool> openSettings(SettingsPage page) async =>
      await _channel.invokeMethod<bool>('openSettings', {'page': page.name}) ?? false;
}

final Provider<TonePlatform> tonePlatformProvider = Provider<TonePlatform>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);
