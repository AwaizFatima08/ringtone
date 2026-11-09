// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Easy Ringtone';

  @override
  String get ok => 'OK';

  @override
  String get pleaseWait => 'Please wait…';

  @override
  String get somethingWrong => 'Sorry, that did not work. Please try again.';

  @override
  String get tryAgain => 'Try again';

  @override
  String get inUseNow => 'In use now';

  @override
  String get listen => 'Listen';

  @override
  String get stop => 'Stop';

  @override
  String get phoneIsSilent =>
      'Your phone is on Silent, so you may hear nothing. Turn the sound on in “Volume & vibration”.';

  @override
  String get phoneIsVibrate =>
      'Your phone is on Vibrate, so you may hear nothing. Turn the sound on in “Volume & vibration”.';

  @override
  String get phoneIsDnd =>
      '“Do Not Disturb” is on, so you may hear nothing. Turn it off in “Volume & vibration”.';

  @override
  String get dndOnTitle => '“Do Not Disturb” is on';

  @override
  String get dndOnBody => 'Calls and messages make no sound while it is on, even at full volume.';

  @override
  String get turnOffDnd => 'Turn it off';

  @override
  String get cannotPlay => 'This sound cannot be played.';

  @override
  String doneCall(String title) {
    return 'Done! When someone calls, your phone will ring with “$title”.';
  }

  @override
  String doneMessage(String title) {
    return 'Done! New messages will now sound with “$title”.';
  }

  @override
  String doneAlarm(String title) {
    return 'Done! Your alarm will now ring with “$title”.';
  }

  @override
  String get permissionTitle => 'One-time step';

  @override
  String get permissionBody =>
      'To change your phone\'s tone, Android needs your OK once.\n\nOn the next page, turn ON the switch next to “Easy Ringtone”, then press Back.';

  @override
  String get openSettings => 'Open';

  @override
  String get notNow => 'Not now';

  @override
  String get permissionStillOff => 'The switch is still off, so the tone was not changed.';

  @override
  String get dndTitle => 'Do Not Disturb is on';

  @override
  String get dndBody =>
      'Android needs your OK before this app can change the sound while Do Not Disturb is on.\n\nOn the next page, tap “Easy Ringtone” and turn it ON, then press Back.';

  @override
  String get useThis => 'Use this';

  @override
  String get chooseFrom => 'Choose a new tone from:';

  @override
  String get sourcePhone => 'Phone\'s tones';

  @override
  String get sourcePhoneHint => 'Tones already on your phone';

  @override
  String get sourceFile => 'Song or sound from my phone';

  @override
  String get sourceFileHint => 'Music, WhatsApp audio, downloads';

  @override
  String get sourceVoice => 'Record my voice';

  @override
  String get sourceVoiceHint => 'Say a name or a few words';

  @override
  String get sourceLoud => 'Loud tones';

  @override
  String get sourceLoudHint => 'Easy to hear, for weak hearing';

  @override
  String get homeCall => 'Call ringtone';

  @override
  String get homeCallHint => 'When someone phones you';

  @override
  String get homeMessage => 'Message tone';

  @override
  String get homeMessageHint => 'SMS and notifications';

  @override
  String get homeAlarm => 'Alarm tone';

  @override
  String get homeAlarmHint => 'Your wake-up alarm';

  @override
  String get homeApps => 'WhatsApp & other apps';

  @override
  String get homeAppsHint => 'Messenger, Facebook, imo and more';

  @override
  String get homeVolume => 'Volume & vibration';

  @override
  String get homeVolumeHint => 'Louder, softer, silent, vibrate';

  @override
  String get homeLoud => 'Loud tones (weak hearing)';

  @override
  String get homeLoudHint => 'Make the phone as loud as it goes';

  @override
  String get nowUsing => 'Your phone uses now:';

  @override
  String get unknownTone => 'A tone';

  @override
  String get noTone => 'No sound (silent)';

  @override
  String get myTones => 'My tones';

  @override
  String get phoneTones => 'Phone\'s own tones';

  @override
  String get noPhoneTones => 'No tones found on this phone.';

  @override
  String get songTip => 'Press Listen first. A ringtone plays from the start of the song.';

  @override
  String get loudBell => 'Old phone bell';

  @override
  String get loudDeepBeep => 'Deep beep';

  @override
  String get loudWarmChime => 'Warm chime';

  @override
  String get loudStrongPulse => 'Strong pulse';

  @override
  String get loudDoubleTone => 'Double tone';

  @override
  String get loudKnock => 'Knock knock';

  @override
  String get micDenied => 'To record your voice, allow the microphone when the phone asks.';

  @override
  String myVoice(int number) {
    return 'My voice $number';
  }

  @override
  String get recordingTooShort => 'That was too short. Please record again.';

  @override
  String get recordingNow => 'Recording… speak now. Press Stop when you finish.';

  @override
  String get recordTip => 'Press the red button and speak, for example: “Phone for you!”';

  @override
  String get startRecording => 'Record';

  @override
  String get stopRecording => 'Stop';

  @override
  String secondsOf(int seconds, int max) {
    return '$seconds of $max seconds';
  }

  @override
  String get appsIntro =>
      'Android lets only you change another app\'s sound. Tap an app and follow the steps.';

  @override
  String get noChatApps => 'No chat apps found on this phone.';

  @override
  String get otherAppSettings => 'Another app: phone\'s sound settings';

  @override
  String appGuideIntro(String app) {
    return 'Three easy steps to change the sound of $app.';
  }

  @override
  String get appStep1 => 'Choose the tone you want. We add it to your phone\'s list.';

  @override
  String get chooseATone => 'Choose a tone';

  @override
  String appStep2(String app) {
    return 'Open the sound page of $app.';
  }

  @override
  String openAppSounds(String app) {
    return 'Open $app sounds';
  }

  @override
  String get appStep3 =>
      'There, tap “Sound” (or “Notification tone”) and pick your tone from the list. Then press Back.';

  @override
  String whatsappTip(String app) {
    return '$app also has its own sound settings: open $app, tap ⋮ (top corner) → Settings → Notifications → Notification tone or Ringtone.';
  }

  @override
  String openApp(String app) {
    return 'Open $app';
  }

  @override
  String addToneIntro(String app) {
    return 'The tone you save here can be picked inside $app.';
  }

  @override
  String get saveTone => 'Save';

  @override
  String toneSavedFor(String app, String title) {
    return 'Saved! Now open $app\'s sounds and look for “$title”.';
  }

  @override
  String get soundMode => 'Sound mode';

  @override
  String get modeSound => 'Sound on';

  @override
  String get modeVibrate => 'Vibrate only';

  @override
  String get modeSilent => 'Silent';

  @override
  String get volumes => 'Volume';

  @override
  String get volumeRing => 'Ringtone';

  @override
  String get volumeMessage => 'Messages';

  @override
  String get volumeAlarm => 'Alarm';

  @override
  String get volumeMedia => 'Music and videos';

  @override
  String get volumeCall => 'Voice during a call';

  @override
  String levelOf(int level, int max) {
    return '$level of $max';
  }

  @override
  String get quieter => 'Quieter';

  @override
  String get louder => 'Louder';

  @override
  String get vibration => 'Vibration';

  @override
  String get vibrateWhenRinging => 'Vibrate when ringing';

  @override
  String get vibrateNotAllowed =>
      'This phone keeps this switch in its own Settings. Open Sound settings and look for “Vibrate for calls”.';

  @override
  String get testVibration => 'Test vibration';

  @override
  String get moreSoundSettings => 'More sound settings';

  @override
  String get loudIntro =>
      'For people who hear less. Press the big red button to make your phone as loud as it can be, and pick a loud tone below.';

  @override
  String get makeLoud => 'Make my phone loud';

  @override
  String get madeLoud =>
      'Done! Sound is on, ringtone, messages and alarm are at full volume, and the phone vibrates when it rings (where allowed).';

  @override
  String get loudTones => 'Loud tones';

  @override
  String get useFor => 'Use this tone for:';

  @override
  String get flashTitle => 'Flash light when a call comes';

  @override
  String get flashBody =>
      'Many phones can flash the light for calls and messages. Open Accessibility and look for “Flash notification”.';

  @override
  String get about => 'About and privacy';

  @override
  String version(String version) {
    return 'Version $version';
  }

  @override
  String get aboutBody =>
      'Change your call, message and alarm tones, record your own voice, set WhatsApp and other app sounds, and control volume and vibration, all from one simple screen.';

  @override
  String get privacyTitle => 'Privacy';

  @override
  String get privacyBody =>
      'Your recordings and tones stay on your phone. The app has no account and sends none of your sounds anywhere. Ads are shown by Google AdMob.';

  @override
  String get copyLink => 'Copy privacy link';

  @override
  String get copied => 'Copied';

  @override
  String get privacyChoices => 'Ad privacy choices';

  @override
  String get madeBy => 'Made by HomiLabs';
}
