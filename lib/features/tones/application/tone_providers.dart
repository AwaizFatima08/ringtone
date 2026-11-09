import 'dart:async';
import 'dart:convert';

import 'package:easyringtone/core/prefs.dart';
import 'package:easyringtone/core/tone_platform.dart';
import 'package:easyringtone/features/tones/domain/tone.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;

/// The tone the phone uses now for each kind; null when it is set to silent.
final FutureProviderFamily<Tone?, ToneKind> currentToneProvider =
    FutureProvider.family<Tone?, ToneKind>(
      (ref, kind) => ref.watch(tonePlatformProvider).currentTone(kind),
    );

/// The phone's own tones for a kind.
final FutureProviderFamily<List<Tone>, ToneKind> phoneTonesProvider =
    FutureProvider.family<List<Tone>, ToneKind>(
      (ref, kind) => ref.watch(tonePlatformProvider).phoneTones(kind),
    );

/// Tones this app put into the phone's list, newest first. Kept in shared preferences.
class MyTones extends Notifier<List<MyTone>> {
  static const _key = 'my_tones';
  static const _voiceCounterKey = 'voice_counter';

  @override
  List<MyTone> build() {
    final raw = ref.watch(prefsProvider).getString(_key);
    if (raw == null) return const [];
    final list = jsonDecode(raw) as List<Object?>;
    return [for (final m in list) MyTone.fromJson(m! as Map<String, Object?>)];
  }

  MyTone? find(String origin, ToneKind kind) {
    for (final t in state) {
      if (t.origin == origin && t.kind == kind) return t;
    }
    return null;
  }

  Future<void> add(MyTone tone) async {
    state = [tone, ...state];
    await _save();
  }

  /// One tone per sound, whichever kind it was saved for, for the "My tones" list.
  List<MyTone> distinct() {
    final seen = <String>{};
    return [
      for (final t in state)
        if (seen.add(t.origin)) t,
    ];
  }

  /// The next number for "My voice N".
  Future<int> nextVoiceNumber() async {
    final prefs = ref.read(prefsProvider);
    final n = (prefs.getInt(_voiceCounterKey) ?? 0) + 1;
    await prefs.setInt(_voiceCounterKey, n);
    return n;
  }

  Future<void> _save() =>
      ref.read(prefsProvider).setString(_key, jsonEncode([for (final t in state) t.toJson()]));
}

final NotifierProvider<MyTones, List<MyTone>> myTonesProvider =
    NotifierProvider<MyTones, List<MyTone>>(MyTones.new);

/// Using and saving tones. The only place that changes the phone's tones.
class ToneActions {
  ToneActions(this._ref);

  final Ref _ref;

  TonePlatform get _platform => _ref.read(tonePlatformProvider);

  /// Makes [tone] the phone's tone for [kind]. Saves it into the phone's list first when needed.
  Future<ChangeOutcome> use(ToneKind kind, Tone tone) async {
    if (!await _platform.canWriteSettings()) return ChangeOutcome.needsPermission;
    final uri = await ensureInPhoneList(tone, kind);
    final outcome = await _platform.setDefault(kind, uri);
    _ref.invalidate(currentToneProvider(kind));
    return outcome;
  }

  /// The uri of [tone] in the phone's list for [kind], copying it there once.
  Future<String> ensureInPhoneList(Tone tone, ToneKind kind, {bool forceCopy = false}) async {
    if (tone.inPhoneList && !forceCopy) return tone.source;
    final myTones = _ref.read(myTonesProvider.notifier);
    if (myTones.find(tone.origin, kind) case final saved?) return saved.uri;
    final uri = await _platform.saveTone(source: tone.source, title: tone.title, kind: kind);
    await myTones.add(MyTone(title: tone.title, uri: uri, kind: kind, origin: tone.origin));
    _ref.invalidate(phoneTonesProvider(kind));
    return uri;
  }

  /// Puts [tone] into the phone's message and call lists, so other apps (WhatsApp…) can pick it.
  /// The phone's own tones are listed there already.
  Future<void> addForOtherApps(Tone tone) async {
    if (tone.inPhoneList && tone.origin == tone.source) return;
    for (final kind in [ToneKind.message, ToneKind.call]) {
      await ensureInPhoneList(tone, kind, forceCopy: true);
    }
  }
}

final Provider<ToneActions> toneActionsProvider = Provider<ToneActions>(ToneActions.new);

/// The source that is playing now, or null.
class Playback extends Notifier<String?> {
  @override
  String? build() {
    final sub = ref.watch(tonePlatformProvider).playbackStopped.listen((_) => state = null);
    ref.onDispose(sub.cancel);
    return null;
  }

  /// Starts [tone], or stops it when it is already playing. Returns why it may not be heard when it starts.
  Future<PlayNote?> toggle(Tone tone, ToneKind kind) async {
    final platform = ref.read(tonePlatformProvider);
    if (state == tone.source) {
      await platform.stop();
      state = null;
      return null;
    }
    state = tone.source;
    return platform.play(tone.source, kind);
  }

  Future<void> stop() async {
    if (!ref.mounted || state == null) return;
    state = null;
    await ref.read(tonePlatformProvider).stop();
  }
}

final NotifierProvider<Playback, String?> playbackProvider = NotifierProvider<Playback, String?>(
  Playback.new,
);
