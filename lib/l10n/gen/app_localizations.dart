import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en'), Locale('ur')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Easy Ringtone'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @pleaseWait.
  ///
  /// In en, this message translates to:
  /// **'Please wait…'**
  String get pleaseWait;

  /// No description provided for @somethingWrong.
  ///
  /// In en, this message translates to:
  /// **'Sorry, that did not work. Please try again.'**
  String get somethingWrong;

  /// No description provided for @tryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get tryAgain;

  /// No description provided for @inUseNow.
  ///
  /// In en, this message translates to:
  /// **'In use now'**
  String get inUseNow;

  /// No description provided for @listen.
  ///
  /// In en, this message translates to:
  /// **'Listen'**
  String get listen;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @phoneIsSilent.
  ///
  /// In en, this message translates to:
  /// **'Your phone is on Silent, so you may hear nothing. Turn the sound on in “Volume & vibration”.'**
  String get phoneIsSilent;

  /// No description provided for @phoneIsVibrate.
  ///
  /// In en, this message translates to:
  /// **'Your phone is on Vibrate, so you may hear nothing. Turn the sound on in “Volume & vibration”.'**
  String get phoneIsVibrate;

  /// No description provided for @cannotPlay.
  ///
  /// In en, this message translates to:
  /// **'This sound cannot be played.'**
  String get cannotPlay;

  /// No description provided for @doneCall.
  ///
  /// In en, this message translates to:
  /// **'Done! When someone calls, your phone will ring with “{title}”.'**
  String doneCall(String title);

  /// No description provided for @doneMessage.
  ///
  /// In en, this message translates to:
  /// **'Done! New messages will now sound with “{title}”.'**
  String doneMessage(String title);

  /// No description provided for @doneAlarm.
  ///
  /// In en, this message translates to:
  /// **'Done! Your alarm will now ring with “{title}”.'**
  String doneAlarm(String title);

  /// No description provided for @permissionTitle.
  ///
  /// In en, this message translates to:
  /// **'One-time step'**
  String get permissionTitle;

  /// No description provided for @permissionBody.
  ///
  /// In en, this message translates to:
  /// **'To change your phone\'s tone, Android needs your OK once.\n\nOn the next page, turn ON the switch next to “Easy Ringtone”, then press Back.'**
  String get permissionBody;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openSettings;

  /// No description provided for @notNow.
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// No description provided for @permissionStillOff.
  ///
  /// In en, this message translates to:
  /// **'The switch is still off, so the tone was not changed.'**
  String get permissionStillOff;

  /// No description provided for @dndTitle.
  ///
  /// In en, this message translates to:
  /// **'Do Not Disturb is on'**
  String get dndTitle;

  /// No description provided for @dndBody.
  ///
  /// In en, this message translates to:
  /// **'Android needs your OK before this app can change the sound while Do Not Disturb is on.\n\nOn the next page, tap “Easy Ringtone” and turn it ON, then press Back.'**
  String get dndBody;

  /// No description provided for @useThis.
  ///
  /// In en, this message translates to:
  /// **'Use this'**
  String get useThis;

  /// No description provided for @chooseFrom.
  ///
  /// In en, this message translates to:
  /// **'Choose a new tone from:'**
  String get chooseFrom;

  /// No description provided for @sourcePhone.
  ///
  /// In en, this message translates to:
  /// **'Phone\'s tones'**
  String get sourcePhone;

  /// No description provided for @sourcePhoneHint.
  ///
  /// In en, this message translates to:
  /// **'Tones already on your phone'**
  String get sourcePhoneHint;

  /// No description provided for @sourceFile.
  ///
  /// In en, this message translates to:
  /// **'Song or sound from my phone'**
  String get sourceFile;

  /// No description provided for @sourceFileHint.
  ///
  /// In en, this message translates to:
  /// **'Music, WhatsApp audio, downloads'**
  String get sourceFileHint;

  /// No description provided for @sourceVoice.
  ///
  /// In en, this message translates to:
  /// **'Record my voice'**
  String get sourceVoice;

  /// No description provided for @sourceVoiceHint.
  ///
  /// In en, this message translates to:
  /// **'Say a name or a few words'**
  String get sourceVoiceHint;

  /// No description provided for @sourceLoud.
  ///
  /// In en, this message translates to:
  /// **'Loud tones'**
  String get sourceLoud;

  /// No description provided for @sourceLoudHint.
  ///
  /// In en, this message translates to:
  /// **'Easy to hear, for weak hearing'**
  String get sourceLoudHint;

  /// No description provided for @homeCall.
  ///
  /// In en, this message translates to:
  /// **'Call ringtone'**
  String get homeCall;

  /// No description provided for @homeCallHint.
  ///
  /// In en, this message translates to:
  /// **'When someone phones you'**
  String get homeCallHint;

  /// No description provided for @homeMessage.
  ///
  /// In en, this message translates to:
  /// **'Message tone'**
  String get homeMessage;

  /// No description provided for @homeMessageHint.
  ///
  /// In en, this message translates to:
  /// **'SMS and notifications'**
  String get homeMessageHint;

  /// No description provided for @homeAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm tone'**
  String get homeAlarm;

  /// No description provided for @homeAlarmHint.
  ///
  /// In en, this message translates to:
  /// **'Your wake-up alarm'**
  String get homeAlarmHint;

  /// No description provided for @homeApps.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp & other apps'**
  String get homeApps;

  /// No description provided for @homeAppsHint.
  ///
  /// In en, this message translates to:
  /// **'Messenger, Facebook, imo and more'**
  String get homeAppsHint;

  /// No description provided for @homeVolume.
  ///
  /// In en, this message translates to:
  /// **'Volume & vibration'**
  String get homeVolume;

  /// No description provided for @homeVolumeHint.
  ///
  /// In en, this message translates to:
  /// **'Louder, softer, silent, vibrate'**
  String get homeVolumeHint;

  /// No description provided for @homeLoud.
  ///
  /// In en, this message translates to:
  /// **'Loud tones (weak hearing)'**
  String get homeLoud;

  /// No description provided for @homeLoudHint.
  ///
  /// In en, this message translates to:
  /// **'Make the phone as loud as it goes'**
  String get homeLoudHint;

  /// No description provided for @nowUsing.
  ///
  /// In en, this message translates to:
  /// **'Your phone uses now:'**
  String get nowUsing;

  /// No description provided for @unknownTone.
  ///
  /// In en, this message translates to:
  /// **'A tone'**
  String get unknownTone;

  /// No description provided for @noTone.
  ///
  /// In en, this message translates to:
  /// **'No sound (silent)'**
  String get noTone;

  /// No description provided for @myTones.
  ///
  /// In en, this message translates to:
  /// **'My tones'**
  String get myTones;

  /// No description provided for @phoneTones.
  ///
  /// In en, this message translates to:
  /// **'Phone\'s own tones'**
  String get phoneTones;

  /// No description provided for @noPhoneTones.
  ///
  /// In en, this message translates to:
  /// **'No tones found on this phone.'**
  String get noPhoneTones;

  /// No description provided for @songTip.
  ///
  /// In en, this message translates to:
  /// **'Press Listen first. A ringtone plays from the start of the song.'**
  String get songTip;

  /// No description provided for @loudBell.
  ///
  /// In en, this message translates to:
  /// **'Old phone bell'**
  String get loudBell;

  /// No description provided for @loudDeepBeep.
  ///
  /// In en, this message translates to:
  /// **'Deep beep'**
  String get loudDeepBeep;

  /// No description provided for @loudWarmChime.
  ///
  /// In en, this message translates to:
  /// **'Warm chime'**
  String get loudWarmChime;

  /// No description provided for @loudStrongPulse.
  ///
  /// In en, this message translates to:
  /// **'Strong pulse'**
  String get loudStrongPulse;

  /// No description provided for @loudDoubleTone.
  ///
  /// In en, this message translates to:
  /// **'Double tone'**
  String get loudDoubleTone;

  /// No description provided for @loudKnock.
  ///
  /// In en, this message translates to:
  /// **'Knock knock'**
  String get loudKnock;

  /// No description provided for @micDenied.
  ///
  /// In en, this message translates to:
  /// **'To record your voice, allow the microphone when the phone asks.'**
  String get micDenied;

  /// No description provided for @myVoice.
  ///
  /// In en, this message translates to:
  /// **'My voice {number}'**
  String myVoice(int number);

  /// No description provided for @recordingTooShort.
  ///
  /// In en, this message translates to:
  /// **'That was too short. Please record again.'**
  String get recordingTooShort;

  /// No description provided for @recordingNow.
  ///
  /// In en, this message translates to:
  /// **'Recording… speak now. Press Stop when you finish.'**
  String get recordingNow;

  /// No description provided for @recordTip.
  ///
  /// In en, this message translates to:
  /// **'Press the red button and speak, for example: “Phone for you!”'**
  String get recordTip;

  /// No description provided for @startRecording.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get startRecording;

  /// No description provided for @stopRecording.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stopRecording;

  /// No description provided for @secondsOf.
  ///
  /// In en, this message translates to:
  /// **'{seconds} of {max} seconds'**
  String secondsOf(int seconds, int max);

  /// No description provided for @appsIntro.
  ///
  /// In en, this message translates to:
  /// **'Android lets only you change another app\'s sound. Tap an app and follow the steps.'**
  String get appsIntro;

  /// No description provided for @noChatApps.
  ///
  /// In en, this message translates to:
  /// **'No chat apps found on this phone.'**
  String get noChatApps;

  /// No description provided for @otherAppSettings.
  ///
  /// In en, this message translates to:
  /// **'Another app: phone\'s sound settings'**
  String get otherAppSettings;

  /// No description provided for @appGuideIntro.
  ///
  /// In en, this message translates to:
  /// **'Three easy steps to change the sound of {app}.'**
  String appGuideIntro(String app);

  /// No description provided for @appStep1.
  ///
  /// In en, this message translates to:
  /// **'Choose the tone you want. We add it to your phone\'s list.'**
  String get appStep1;

  /// No description provided for @chooseATone.
  ///
  /// In en, this message translates to:
  /// **'Choose a tone'**
  String get chooseATone;

  /// No description provided for @appStep2.
  ///
  /// In en, this message translates to:
  /// **'Open the sound page of {app}.'**
  String appStep2(String app);

  /// No description provided for @openAppSounds.
  ///
  /// In en, this message translates to:
  /// **'Open {app} sounds'**
  String openAppSounds(String app);

  /// No description provided for @appStep3.
  ///
  /// In en, this message translates to:
  /// **'There, tap “Sound” (or “Notification tone”) and pick your tone from the list. Then press Back.'**
  String get appStep3;

  /// No description provided for @whatsappTip.
  ///
  /// In en, this message translates to:
  /// **'{app} also has its own sound settings: open {app}, tap ⋮ (top corner) → Settings → Notifications → Notification tone or Ringtone.'**
  String whatsappTip(String app);

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open {app}'**
  String openApp(String app);

  /// No description provided for @addToneIntro.
  ///
  /// In en, this message translates to:
  /// **'The tone you save here can be picked inside {app}.'**
  String addToneIntro(String app);

  /// No description provided for @saveTone.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get saveTone;

  /// No description provided for @toneSavedFor.
  ///
  /// In en, this message translates to:
  /// **'Saved! Now open {app}\'s sounds and look for “{title}”.'**
  String toneSavedFor(String app, String title);

  /// No description provided for @soundMode.
  ///
  /// In en, this message translates to:
  /// **'Sound mode'**
  String get soundMode;

  /// No description provided for @modeSound.
  ///
  /// In en, this message translates to:
  /// **'Sound on'**
  String get modeSound;

  /// No description provided for @modeVibrate.
  ///
  /// In en, this message translates to:
  /// **'Vibrate only'**
  String get modeVibrate;

  /// No description provided for @modeSilent.
  ///
  /// In en, this message translates to:
  /// **'Silent'**
  String get modeSilent;

  /// No description provided for @volumes.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volumes;

  /// No description provided for @volumeRing.
  ///
  /// In en, this message translates to:
  /// **'Ringtone'**
  String get volumeRing;

  /// No description provided for @volumeMessage.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get volumeMessage;

  /// No description provided for @volumeAlarm.
  ///
  /// In en, this message translates to:
  /// **'Alarm'**
  String get volumeAlarm;

  /// No description provided for @volumeMedia.
  ///
  /// In en, this message translates to:
  /// **'Music and videos'**
  String get volumeMedia;

  /// No description provided for @volumeCall.
  ///
  /// In en, this message translates to:
  /// **'Voice during a call'**
  String get volumeCall;

  /// No description provided for @levelOf.
  ///
  /// In en, this message translates to:
  /// **'{level} of {max}'**
  String levelOf(int level, int max);

  /// No description provided for @quieter.
  ///
  /// In en, this message translates to:
  /// **'Quieter'**
  String get quieter;

  /// No description provided for @louder.
  ///
  /// In en, this message translates to:
  /// **'Louder'**
  String get louder;

  /// No description provided for @vibration.
  ///
  /// In en, this message translates to:
  /// **'Vibration'**
  String get vibration;

  /// No description provided for @vibrateWhenRinging.
  ///
  /// In en, this message translates to:
  /// **'Vibrate when ringing'**
  String get vibrateWhenRinging;

  /// No description provided for @vibrateNotAllowed.
  ///
  /// In en, this message translates to:
  /// **'This phone keeps this switch in its own Settings. Open Sound settings and look for “Vibrate for calls”.'**
  String get vibrateNotAllowed;

  /// No description provided for @testVibration.
  ///
  /// In en, this message translates to:
  /// **'Test vibration'**
  String get testVibration;

  /// No description provided for @moreSoundSettings.
  ///
  /// In en, this message translates to:
  /// **'More sound settings'**
  String get moreSoundSettings;

  /// No description provided for @loudIntro.
  ///
  /// In en, this message translates to:
  /// **'For people who hear less. Press the big red button to make your phone as loud as it can be, and pick a loud tone below.'**
  String get loudIntro;

  /// No description provided for @makeLoud.
  ///
  /// In en, this message translates to:
  /// **'Make my phone loud'**
  String get makeLoud;

  /// No description provided for @madeLoud.
  ///
  /// In en, this message translates to:
  /// **'Done! Sound is on, ringtone, messages and alarm are at full volume, and the phone vibrates when it rings (where allowed).'**
  String get madeLoud;

  /// No description provided for @loudTones.
  ///
  /// In en, this message translates to:
  /// **'Loud tones'**
  String get loudTones;

  /// No description provided for @useFor.
  ///
  /// In en, this message translates to:
  /// **'Use this tone for:'**
  String get useFor;

  /// No description provided for @flashTitle.
  ///
  /// In en, this message translates to:
  /// **'Flash light when a call comes'**
  String get flashTitle;

  /// No description provided for @flashBody.
  ///
  /// In en, this message translates to:
  /// **'Many phones can flash the light for calls and messages. Open Accessibility and look for “Flash notification”.'**
  String get flashBody;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About and privacy'**
  String get about;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String version(String version);

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'Change your call, message and alarm tones, record your own voice, set WhatsApp and other app sounds, and control volume and vibration, all from one simple screen.'**
  String get aboutBody;

  /// No description provided for @privacyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get privacyTitle;

  /// No description provided for @privacyBody.
  ///
  /// In en, this message translates to:
  /// **'Your recordings and tones stay on your phone. The app has no account and sends none of your sounds anywhere. Ads are shown by Google AdMob.'**
  String get privacyBody;

  /// No description provided for @copyLink.
  ///
  /// In en, this message translates to:
  /// **'Copy privacy link'**
  String get copyLink;

  /// No description provided for @copied.
  ///
  /// In en, this message translates to:
  /// **'Copied'**
  String get copied;

  /// No description provided for @privacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Ad privacy choices'**
  String get privacyChoices;

  /// No description provided for @madeBy.
  ///
  /// In en, this message translates to:
  /// **'Made by HomiLabs'**
  String get madeBy;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ur':
      return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
