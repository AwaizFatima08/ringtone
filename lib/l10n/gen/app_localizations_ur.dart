// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appTitle => 'آسان رنگ ٹون';

  @override
  String get ok => 'ٹھیک ہے';

  @override
  String get pleaseWait => 'براہِ کرم انتظار کریں…';

  @override
  String get somethingWrong => 'معذرت، یہ کام نہیں ہوا۔ دوبارہ کوشش کریں۔';

  @override
  String get tryAgain => 'دوبارہ کوشش کریں';

  @override
  String get inUseNow => 'ابھی یہی لگی ہے';

  @override
  String get listen => 'سنیں';

  @override
  String get stop => 'روکیں';

  @override
  String get phoneIsSilent =>
      'آپ کا فون خاموش (Silent) پر ہے، اس لیے آواز نہیں آئے گی۔ “آواز اور تھرتھراہٹ” میں آواز آن کریں۔';

  @override
  String get phoneIsVibrate =>
      'آپ کا فون صرف تھرتھراہٹ (Vibrate) پر ہے، اس لیے آواز نہیں آئے گی۔ “آواز اور تھرتھراہٹ” میں آواز آن کریں۔';

  @override
  String get phoneIsDnd =>
      '“ڈسٹرب نہ کریں” آن ہے، اس لیے آواز نہیں آئے گی۔ “آواز اور تھرتھراہٹ” میں اسے بند کریں۔';

  @override
  String get dndOnTitle => '“ڈسٹرب نہ کریں” آن ہے';

  @override
  String get dndOnBody => 'یہ آن ہو تو کال اور پیغام پر آواز نہیں آتی، چاہے آواز پوری اونچی ہو۔';

  @override
  String get turnOffDnd => 'اسے بند کریں';

  @override
  String get cannotPlay => 'یہ آواز چل نہیں سکتی۔';

  @override
  String doneCall(String title) {
    return 'ہو گیا! اب کال آنے پر فون میں “$title” بجے گی۔';
  }

  @override
  String doneMessage(String title) {
    return 'ہو گیا! اب نئے پیغام پر “$title” بجے گی۔';
  }

  @override
  String doneAlarm(String title) {
    return 'ہو گیا! اب الارم میں “$title” بجے گی۔';
  }

  @override
  String get permissionTitle => 'صرف ایک بار';

  @override
  String get permissionBody =>
      'فون کی ٹون بدلنے کے لیے اینڈرائیڈ کو ایک بار آپ کی اجازت چاہیے۔\n\nاگلے صفحے پر “Easy Ringtone” کے سامنے والا بٹن آن کریں، پھر واپس (Back) آ جائیں۔';

  @override
  String get openSettings => 'کھولیں';

  @override
  String get notNow => 'ابھی نہیں';

  @override
  String get permissionStillOff => 'بٹن ابھی بھی بند ہے، اس لیے ٹون نہیں بدلی۔';

  @override
  String get dndTitle => '“ڈسٹرب نہ کریں” آن ہے';

  @override
  String get dndBody =>
      '“ڈسٹرب نہ کریں” آن ہونے پر آواز بدلنے کے لیے اینڈرائیڈ کو آپ کی اجازت چاہیے۔\n\nاگلے صفحے پر “Easy Ringtone” پر دبائیں اور آن کریں، پھر واپس آ جائیں۔';

  @override
  String get useThis => 'یہ لگائیں';

  @override
  String get chooseFrom => 'نئی ٹون یہاں سے چنیں:';

  @override
  String get sourcePhone => 'فون کی ٹونز';

  @override
  String get sourcePhoneHint => 'جو ٹونز پہلے سے فون میں ہیں';

  @override
  String get sourceFile => 'فون میں سے گانا یا آواز';

  @override
  String get sourceFileHint => 'گانے، واٹس ایپ کی آڈیو، ڈاؤن لوڈ';

  @override
  String get sourceVoice => 'اپنی آواز ریکارڈ کریں';

  @override
  String get sourceVoiceHint => 'کوئی نام یا چند الفاظ بولیں';

  @override
  String get sourceLoud => 'اونچی ٹونز';

  @override
  String get sourceLoudHint => 'سننے میں آسان، کم سننے والوں کے لیے';

  @override
  String get homeCall => 'کال کی ٹون';

  @override
  String get homeCallHint => 'جب کوئی فون کرے';

  @override
  String get homeMessage => 'پیغام کی ٹون';

  @override
  String get homeMessageHint => 'ایس ایم ایس اور اطلاعات';

  @override
  String get homeAlarm => 'الارم کی ٹون';

  @override
  String get homeAlarmHint => 'جاگنے کا الارم';

  @override
  String get homeApps => 'واٹس ایپ اور دوسری ایپس';

  @override
  String get homeAppsHint => 'میسنجر، فیس بک، imo وغیرہ';

  @override
  String get homeVolume => 'آواز اور تھرتھراہٹ';

  @override
  String get homeVolumeHint => 'اونچی، دھیمی، خاموش، تھرتھراہٹ';

  @override
  String get homeLoud => 'اونچی ٹونز (کم سننے والوں کے لیے)';

  @override
  String get homeLoudHint => 'فون کی آواز پوری اونچی کریں';

  @override
  String get nowUsing => 'ابھی فون میں لگی ہے:';

  @override
  String get unknownTone => 'ایک ٹون';

  @override
  String get noTone => 'کوئی آواز نہیں (خاموش)';

  @override
  String get myTones => 'میری ٹونز';

  @override
  String get phoneTones => 'فون کی اپنی ٹونز';

  @override
  String get noPhoneTones => 'اس فون میں کوئی ٹون نہیں ملی۔';

  @override
  String get songTip => 'پہلے “سنیں” دبائیں۔ رنگ ٹون گانے کے شروع سے بجے گی۔';

  @override
  String get loudBell => 'پرانے فون کی گھنٹی';

  @override
  String get loudDeepBeep => 'بھاری بیپ';

  @override
  String get loudWarmChime => 'نرم گھنٹی';

  @override
  String get loudStrongPulse => 'تیز دھڑکن';

  @override
  String get loudDoubleTone => 'دوہری ٹون';

  @override
  String get loudKnock => 'دستک';

  @override
  String get micDenied => 'آواز ریکارڈ کرنے کے لیے فون پوچھے تو مائیک کی اجازت دیں۔';

  @override
  String myVoice(int number) {
    return 'میری آواز $number';
  }

  @override
  String get recordingTooShort => 'یہ بہت چھوٹی تھی۔ دوبارہ ریکارڈ کریں۔';

  @override
  String get recordingNow => 'ریکارڈنگ ہو رہی ہے… اب بولیں۔ ختم ہو تو “روکیں” دبائیں۔';

  @override
  String get recordTip => 'سرخ بٹن دبائیں اور بولیں، مثلاً: “آپ کا فون آیا ہے!”';

  @override
  String get startRecording => 'ریکارڈ';

  @override
  String get stopRecording => 'روکیں';

  @override
  String secondsOf(int seconds, int max) {
    return '$max میں سے $seconds سیکنڈ';
  }

  @override
  String get appsIntro =>
      'اینڈرائیڈ میں کسی دوسری ایپ کی آواز صرف آپ خود بدل سکتے ہیں۔ ایپ پر دبائیں اور مرحلے دیکھیں۔';

  @override
  String get noChatApps => 'اس فون میں کوئی چیٹ ایپ نہیں ملی۔';

  @override
  String get otherAppSettings => 'کوئی اور ایپ: فون کی آواز کی سیٹنگز';

  @override
  String appGuideIntro(String app) {
    return '$app کی آواز بدلنے کے تین آسان مرحلے۔';
  }

  @override
  String get appStep1 => 'اپنی پسند کی ٹون چنیں۔ ہم اسے فون کی فہرست میں ڈال دیں گے۔';

  @override
  String get chooseATone => 'ٹون چنیں';

  @override
  String appStep2(String app) {
    return '$app کا آواز والا صفحہ کھولیں۔';
  }

  @override
  String openAppSounds(String app) {
    return '$app کی آوازیں کھولیں';
  }

  @override
  String get appStep3 =>
      'وہاں “Sound” (یا “Notification tone”) پر دبائیں اور فہرست میں سے اپنی ٹون چنیں۔ پھر واپس آ جائیں۔';

  @override
  String whatsappTip(String app) {
    return '$app کی اپنی سیٹنگز بھی ہیں: $app کھولیں، اوپر کونے میں ⋮ دبائیں ← Settings ← Notifications ← Notification tone یا Ringtone۔';
  }

  @override
  String openApp(String app) {
    return '$app کھولیں';
  }

  @override
  String addToneIntro(String app) {
    return 'یہاں محفوظ کی گئی ٹون $app میں چنی جا سکتی ہے۔';
  }

  @override
  String get saveTone => 'محفوظ کریں';

  @override
  String toneSavedFor(String app, String title) {
    return 'محفوظ ہو گئی! اب $app کی آوازیں کھولیں اور “$title” تلاش کریں۔';
  }

  @override
  String get soundMode => 'آواز کا طریقہ';

  @override
  String get modeSound => 'آواز آن';

  @override
  String get modeVibrate => 'صرف تھرتھراہٹ';

  @override
  String get modeSilent => 'خاموش';

  @override
  String get volumes => 'آواز کتنی اونچی ہو';

  @override
  String get volumeRing => 'رنگ ٹون';

  @override
  String get volumeMessage => 'پیغامات';

  @override
  String get volumeAlarm => 'الارم';

  @override
  String get volumeMedia => 'گانے اور ویڈیوز';

  @override
  String get volumeCall => 'کال کے دوران آواز';

  @override
  String levelOf(int level, int max) {
    return '$max میں سے $level';
  }

  @override
  String get quieter => 'دھیمی';

  @override
  String get louder => 'اونچی';

  @override
  String get vibration => 'تھرتھراہٹ';

  @override
  String get vibrateWhenRinging => 'بجتے وقت تھرتھراہٹ بھی';

  @override
  String get vibrateNotAllowed =>
      'اس فون میں یہ بٹن اس کی اپنی سیٹنگز میں ہے۔ ساؤنڈ سیٹنگز کھولیں اور “Vibrate for calls” تلاش کریں۔';

  @override
  String get testVibration => 'تھرتھراہٹ آزمائیں';

  @override
  String get moreSoundSettings => 'مزید ساؤنڈ سیٹنگز';

  @override
  String get loudIntro =>
      'کم سننے والوں کے لیے۔ بڑا سرخ بٹن دبائیں تاکہ فون کی آواز پوری اونچی ہو جائے، پھر نیچے سے کوئی اونچی ٹون چنیں۔';

  @override
  String get makeLoud => 'میرا فون اونچا کریں';

  @override
  String get madeLoud =>
      'ہو گیا! آواز آن ہے، رنگ ٹون، پیغامات اور الارم پوری آواز پر ہیں، اور فون بجتے وقت تھرتھرائے گا (جہاں ممکن ہو)۔';

  @override
  String get loudTones => 'اونچی ٹونز';

  @override
  String get useFor => 'یہ ٹون کس کے لیے؟';

  @override
  String get flashTitle => 'کال آنے پر روشنی جلے';

  @override
  String get flashBody =>
      'بہت سے فونز کال اور پیغام پر روشنی جلا سکتے ہیں۔ Accessibility کھولیں اور “Flash notification” تلاش کریں۔';

  @override
  String get about => 'ایپ کے بارے میں اور رازداری';

  @override
  String version(String version) {
    return 'ورژن $version';
  }

  @override
  String get aboutBody =>
      'کال، پیغام اور الارم کی ٹون بدلیں، اپنی آواز ریکارڈ کریں، واٹس ایپ اور دوسری ایپس کی آواز سیٹ کریں، اور آواز اور تھرتھراہٹ کنٹرول کریں — سب ایک آسان اسکرین سے۔';

  @override
  String get privacyTitle => 'رازداری';

  @override
  String get privacyBody =>
      'آپ کی ریکارڈنگز اور ٹونز آپ کے فون میں ہی رہتی ہیں۔ ایپ میں کوئی اکاؤنٹ نہیں اور آپ کی کوئی آواز کہیں نہیں بھیجی جاتی۔ اشتہارات گوگل ایڈموب دکھاتا ہے۔';

  @override
  String get copyLink => 'رازداری کا لنک کاپی کریں';

  @override
  String get copied => 'کاپی ہو گیا';

  @override
  String get privacyChoices => 'اشتہارات کی رازداری';

  @override
  String get madeBy => 'HomiLabs کی تیار کردہ';
}
