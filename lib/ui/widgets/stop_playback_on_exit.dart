import 'dart:async';

import 'package:easyringtone/features/tones/application/tone_providers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Stops any tone that is still playing when the user leaves the page.
class StopPlaybackOnExit extends ConsumerStatefulWidget {
  const StopPlaybackOnExit({required this.child, super.key});

  final Widget child;

  @override
  ConsumerState<StopPlaybackOnExit> createState() => _StopPlaybackOnExitState();
}

class _StopPlaybackOnExitState extends ConsumerState<StopPlaybackOnExit> {
  late final Playback _playback;

  @override
  void initState() {
    super.initState();
    _playback = ref.read(playbackProvider.notifier);
  }

  @override
  void dispose() {
    // Providers may not change while the tree is being torn down.
    final playback = _playback;
    unawaited(Future.microtask(playback.stop));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
