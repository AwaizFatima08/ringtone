import 'package:easyringtone/core/tone_platform.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Sound mode, volumes and "vibrate when ringing", read together and re-read when the user comes
/// back from Android's settings.
class SoundState {
  const SoundState({
    required this.mode,
    required this.volumes,
    required this.vibrateWhenRinging,
    required this.doNotDisturb,
  });

  final RingerMode mode;
  final Map<VolumeStream, VolumeLevel> volumes;

  /// Null when the phone has no such setting.
  final bool? vibrateWhenRinging;

  /// Do Not Disturb silences calls and messages even at full volume.
  final bool doNotDisturb;
}

class SoundController extends AsyncNotifier<SoundState> {
  TonePlatform get _platform => ref.read(tonePlatformProvider);

  @override
  Future<SoundState> build() async {
    final platform = ref.watch(tonePlatformProvider);
    return SoundState(
      mode: await platform.ringerMode(),
      volumes: await platform.volumes(),
      vibrateWhenRinging: await platform.vibrateWhenRinging(),
      doNotDisturb: await platform.doNotDisturbOn(),
    );
  }

  Future<void> refresh() async => state = AsyncData(await build());

  /// Moves one volume a step up or down.
  Future<ChangeOutcome> step(VolumeStream stream, int by) async {
    final current = state.value?.volumes[stream];
    if (current == null) return ChangeOutcome.ok;
    final level = (current.level + by).clamp(current.min, current.max);
    if (level == current.level) return ChangeOutcome.ok;
    final outcome = await _platform.setVolume(stream, level);
    await refresh();
    return outcome;
  }

  Future<ChangeOutcome> setMode(RingerMode mode) async {
    final outcome = await _platform.setRingerMode(mode);
    await refresh();
    return outcome;
  }

  Future<ChangeOutcome> setVibrateWhenRinging({required bool on}) async {
    final outcome = await _platform.setVibrateWhenRinging(on: on);
    await refresh();
    return outcome;
  }

  Future<ChangeOutcome> turnOffDoNotDisturb() async {
    final outcome = await _platform.turnOffDoNotDisturb();
    await refresh();
    return outcome;
  }

  /// "Make my phone loud": Do Not Disturb off, sound on, ring / message / alarm at the top,
  /// vibrate when ringing.
  /// Returns the first problem, or ok.
  Future<ChangeOutcome> makeLoud() async {
    final platform = _platform;
    final outcomes = <ChangeOutcome>[
      await platform.turnOffDoNotDisturb(),
      await platform.setRingerMode(RingerMode.normal),
    ];
    final volumes = await platform.volumes();
    for (final stream in [VolumeStream.ring, VolumeStream.message, VolumeStream.alarm]) {
      if (volumes[stream] case final v?) outcomes.add(await platform.setVolume(stream, v.max));
    }
    if (await platform.vibrateWhenRinging() == false) {
      // Not every phone lets an app flip this switch; the volumes matter more.
      await platform.setVibrateWhenRinging(on: true);
    }
    await refresh();
    return outcomes.firstWhere((o) => o != ChangeOutcome.ok, orElse: () => ChangeOutcome.ok);
  }
}

final AsyncNotifierProvider<SoundController, SoundState> soundProvider =
    AsyncNotifierProvider<SoundController, SoundState>(SoundController.new);
