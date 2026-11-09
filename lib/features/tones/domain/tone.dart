/// Which of the phone's three sounds a tone is for.
enum ToneKind { call, message, alarm }

/// A sound the user can listen to and use.
///
/// [source] is what the native side plays and copies: a content uri, `asset:<key>` or `file:<path>`.
/// [origin] identifies the sound across copies, so the same recording is not saved twice for one kind.
class Tone {
  const Tone._({
    required this.title,
    required this.source,
    required this.origin,
    required this.inPhoneList,
  });

  /// A tone Android already lists (its own tones, or one this app saved before).
  const Tone.inPhone({required String uri, required String title, String? origin})
    : this._(title: title, source: uri, origin: origin ?? uri, inPhoneList: true);

  /// A song or sound the user picked from the phone's files.
  const Tone.picked({required String uri, required String title})
    : this._(title: title, source: uri, origin: uri, inPhoneList: false);

  /// One of the app's own loud tones.
  const Tone.asset({required String key, required String title})
    : this._(title: title, source: 'asset:$key', origin: 'asset:$key', inPhoneList: false);

  /// A voice recording in the app's own folder.
  const Tone.recording({required String path, required String title})
    : this._(title: title, source: 'file:$path', origin: 'file:$path', inPhoneList: false);

  final String title;
  final String source;
  final String origin;
  final bool inPhoneList;
}

/// A tone this app copied into the phone's tone list (a recording, a picked song or a loud tone).
class MyTone {
  const MyTone({required this.title, required this.uri, required this.kind, required this.origin});

  factory MyTone.fromJson(Map<String, Object?> json) => MyTone(
    title: json['title']! as String,
    uri: json['uri']! as String,
    kind: ToneKind.values.byName(json['kind']! as String),
    origin: json['origin']! as String,
  );

  final String title;
  final String uri;
  final ToneKind kind;
  final String origin;

  Map<String, Object?> toJson() => {
    'title': title,
    'uri': uri,
    'kind': kind.name,
    'origin': origin,
  };

  Tone get tone => Tone.inPhone(uri: uri, title: title, origin: origin);
}

/// The app's loud tones (made by tool/make_tones.py). Low pitched and repeated, for weak hearing.
enum LoudTone {
  bell('loud_bell', ToneKind.call),
  deepBeep('loud_deep_beep', ToneKind.call),
  warmChime('loud_warm_chime', ToneKind.call),
  strongPulse('loud_strong_pulse', ToneKind.alarm),
  doubleTone('loud_double_tone', ToneKind.message),
  knock('loud_knock', ToneKind.message)
  ;

  const LoudTone(this.file, this.bestFor);

  final String file;
  final ToneKind bestFor;

  String get assetKey => 'assets/tones/$file.ogg';
}
