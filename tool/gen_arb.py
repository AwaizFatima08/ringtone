"""Writes lib/l10n/app_en.arb and app_ur.arb from one table, so both languages keep the same keys.
Run: python3 tool/gen_arb.py   (then flutter gen-l10n runs on the next build)."""
import json, pathlib, re

S = {
 "appTitle": ("Easy Ringtone", "آسان رنگ ٹون"),
 "ok": ("OK", "ٹھیک ہے"),
 "pleaseWait": ("Please wait…", "براہِ کرم انتظار کریں…"),
 "somethingWrong": ("Sorry, that did not work. Please try again.", "معذرت، یہ کام نہیں ہوا۔ دوبارہ کوشش کریں۔"),
 "tryAgain": ("Try again", "دوبارہ کوشش کریں"),
 "inUseNow": ("In use now", "ابھی یہی لگی ہے"),
 "listen": ("Listen", "سنیں"),
 "stop": ("Stop", "روکیں"),
 "phoneIsSilent": ("Your phone is on Silent, so you may hear nothing. Turn the sound on in “Volume & vibration”.", "آپ کا فون خاموش (Silent) پر ہے، اس لیے آواز نہیں آئے گی۔ “آواز اور تھرتھراہٹ” میں آواز آن کریں۔"),
 "phoneIsVibrate": ("Your phone is on Vibrate, so you may hear nothing. Turn the sound on in “Volume & vibration”.", "آپ کا فون صرف تھرتھراہٹ (Vibrate) پر ہے، اس لیے آواز نہیں آئے گی۔ “آواز اور تھرتھراہٹ” میں آواز آن کریں۔"),
 "cannotPlay": ("This sound cannot be played.", "یہ آواز چل نہیں سکتی۔"),
 "doneCall": ("Done! When someone calls, your phone will ring with “{title}”.", "ہو گیا! اب کال آنے پر فون میں “{title}” بجے گی۔"),
 "doneMessage": ("Done! New messages will now sound with “{title}”.", "ہو گیا! اب نئے پیغام پر “{title}” بجے گی۔"),
 "doneAlarm": ("Done! Your alarm will now ring with “{title}”.", "ہو گیا! اب الارم میں “{title}” بجے گی۔"),
 "permissionTitle": ("One-time step", "صرف ایک بار"),
 "permissionBody": ("To change your phone's tone, Android needs your OK once.\n\nOn the next page, turn ON the switch next to “Easy Ringtone”, then press Back.", "فون کی ٹون بدلنے کے لیے اینڈرائیڈ کو ایک بار آپ کی اجازت چاہیے۔\n\nاگلے صفحے پر “Easy Ringtone” کے سامنے والا بٹن آن کریں، پھر واپس (Back) آ جائیں۔"),
 "openSettings": ("Open", "کھولیں"),
 "notNow": ("Not now", "ابھی نہیں"),
 "permissionStillOff": ("The switch is still off, so the tone was not changed.", "بٹن ابھی بھی بند ہے، اس لیے ٹون نہیں بدلی۔"),
 "dndTitle": ("Do Not Disturb is on", "“ڈسٹرب نہ کریں” آن ہے"),
 "dndBody": ("Android needs your OK before this app can change the sound while Do Not Disturb is on.\n\nOn the next page, tap “Easy Ringtone” and turn it ON, then press Back.", "“ڈسٹرب نہ کریں” آن ہونے پر آواز بدلنے کے لیے اینڈرائیڈ کو آپ کی اجازت چاہیے۔\n\nاگلے صفحے پر “Easy Ringtone” پر دبائیں اور آن کریں، پھر واپس آ جائیں۔"),
 "useThis": ("Use this", "یہ لگائیں"),
 "chooseFrom": ("Choose a new tone from:", "نئی ٹون یہاں سے چنیں:"),
 "sourcePhone": ("Phone's tones", "فون کی ٹونز"),
 "sourcePhoneHint": ("Tones already on your phone", "جو ٹونز پہلے سے فون میں ہیں"),
 "sourceFile": ("Song or sound from my phone", "فون میں سے گانا یا آواز"),
 "sourceFileHint": ("Music, WhatsApp audio, downloads", "گانے، واٹس ایپ کی آڈیو، ڈاؤن لوڈ"),
 "sourceVoice": ("Record my voice", "اپنی آواز ریکارڈ کریں"),
 "sourceVoiceHint": ("Say a name or a few words", "کوئی نام یا چند الفاظ بولیں"),
 "sourceLoud": ("Loud tones", "اونچی ٹونز"),
 "sourceLoudHint": ("Easy to hear, for weak hearing", "سننے میں آسان، کم سننے والوں کے لیے"),
 "homeCall": ("Call ringtone", "کال کی ٹون"),
 "homeCallHint": ("When someone phones you", "جب کوئی فون کرے"),
 "homeMessage": ("Message tone", "پیغام کی ٹون"),
 "homeMessageHint": ("SMS and notifications", "ایس ایم ایس اور اطلاعات"),
 "homeAlarm": ("Alarm tone", "الارم کی ٹون"),
 "homeAlarmHint": ("Your wake-up alarm", "جاگنے کا الارم"),
 "homeApps": ("WhatsApp & other apps", "واٹس ایپ اور دوسری ایپس"),
 "homeAppsHint": ("Messenger, Facebook, imo and more", "میسنجر، فیس بک، imo وغیرہ"),
 "homeVolume": ("Volume & vibration", "آواز اور تھرتھراہٹ"),
 "homeVolumeHint": ("Louder, softer, silent, vibrate", "اونچی، دھیمی، خاموش، تھرتھراہٹ"),
 "homeLoud": ("Loud tones (weak hearing)", "اونچی ٹونز (کم سننے والوں کے لیے)"),
 "homeLoudHint": ("Make the phone as loud as it goes", "فون کی آواز پوری اونچی کریں"),
 "nowUsing": ("Your phone uses now:", "ابھی فون میں لگی ہے:"),
 "unknownTone": ("A tone", "ایک ٹون"),
 "noTone": ("No sound (silent)", "کوئی آواز نہیں (خاموش)"),
 "myTones": ("My tones", "میری ٹونز"),
 "phoneTones": ("Phone's own tones", "فون کی اپنی ٹونز"),
 "noPhoneTones": ("No tones found on this phone.", "اس فون میں کوئی ٹون نہیں ملی۔"),
 "songTip": ("Press Listen first. A ringtone plays from the start of the song.", "پہلے “سنیں” دبائیں۔ رنگ ٹون گانے کے شروع سے بجے گی۔"),
 "loudBell": ("Old phone bell", "پرانے فون کی گھنٹی"),
 "loudDeepBeep": ("Deep beep", "بھاری بیپ"),
 "loudWarmChime": ("Warm chime", "نرم گھنٹی"),
 "loudStrongPulse": ("Strong pulse", "تیز دھڑکن"),
 "loudDoubleTone": ("Double tone", "دوہری ٹون"),
 "loudKnock": ("Knock knock", "دستک"),
 "micDenied": ("To record your voice, allow the microphone when the phone asks.", "آواز ریکارڈ کرنے کے لیے فون پوچھے تو مائیک کی اجازت دیں۔"),
 "myVoice": ("My voice {number}", "میری آواز {number}"),
 "recordingTooShort": ("That was too short. Please record again.", "یہ بہت چھوٹی تھی۔ دوبارہ ریکارڈ کریں۔"),
 "recordingNow": ("Recording… speak now. Press Stop when you finish.", "ریکارڈنگ ہو رہی ہے… اب بولیں۔ ختم ہو تو “روکیں” دبائیں۔"),
 "recordTip": ("Press the red button and speak, for example: “Phone for you!”", "سرخ بٹن دبائیں اور بولیں، مثلاً: “آپ کا فون آیا ہے!”"),
 "startRecording": ("Record", "ریکارڈ"),
 "stopRecording": ("Stop", "روکیں"),
 "secondsOf": ("{seconds} of {max} seconds", "{max} میں سے {seconds} سیکنڈ"),
 "appsIntro": ("Android lets only you change another app's sound. Tap an app and follow the steps.", "اینڈرائیڈ میں کسی دوسری ایپ کی آواز صرف آپ خود بدل سکتے ہیں۔ ایپ پر دبائیں اور مرحلے دیکھیں۔"),
 "noChatApps": ("No chat apps found on this phone.", "اس فون میں کوئی چیٹ ایپ نہیں ملی۔"),
 "otherAppSettings": ("Another app: phone's sound settings", "کوئی اور ایپ: فون کی آواز کی سیٹنگز"),
 "appGuideIntro": ("Three easy steps to change the sound of {app}.", "{app} کی آواز بدلنے کے تین آسان مرحلے۔"),
 "appStep1": ("Choose the tone you want. We add it to your phone's list.", "اپنی پسند کی ٹون چنیں۔ ہم اسے فون کی فہرست میں ڈال دیں گے۔"),
 "chooseATone": ("Choose a tone", "ٹون چنیں"),
 "appStep2": ("Open the sound page of {app}.", "{app} کا آواز والا صفحہ کھولیں۔"),
 "openAppSounds": ("Open {app} sounds", "{app} کی آوازیں کھولیں"),
 "appStep3": ("There, tap “Sound” (or “Notification tone”) and pick your tone from the list. Then press Back.", "وہاں “Sound” (یا “Notification tone”) پر دبائیں اور فہرست میں سے اپنی ٹون چنیں۔ پھر واپس آ جائیں۔"),
 "whatsappTip": ("{app} also has its own sound settings: open {app}, tap ⋮ (top corner) → Settings → Notifications → Notification tone or Ringtone.", "{app} کی اپنی سیٹنگز بھی ہیں: {app} کھولیں، اوپر کونے میں ⋮ دبائیں ← Settings ← Notifications ← Notification tone یا Ringtone۔"),
 "openApp": ("Open {app}", "{app} کھولیں"),
 "addToneIntro": ("The tone you save here can be picked inside {app}.", "یہاں محفوظ کی گئی ٹون {app} میں چنی جا سکتی ہے۔"),
 "saveTone": ("Save", "محفوظ کریں"),
 "toneSavedFor": ("Saved! Now open {app}'s sounds and look for “{title}”.", "محفوظ ہو گئی! اب {app} کی آوازیں کھولیں اور “{title}” تلاش کریں۔"),
 "soundMode": ("Sound mode", "آواز کا طریقہ"),
 "modeSound": ("Sound on", "آواز آن"),
 "modeVibrate": ("Vibrate only", "صرف تھرتھراہٹ"),
 "modeSilent": ("Silent", "خاموش"),
 "volumes": ("Volume", "آواز کتنی اونچی ہو"),
 "volumeRing": ("Ringtone", "رنگ ٹون"),
 "volumeMessage": ("Messages", "پیغامات"),
 "volumeAlarm": ("Alarm", "الارم"),
 "volumeMedia": ("Music and videos", "گانے اور ویڈیوز"),
 "volumeCall": ("Voice during a call", "کال کے دوران آواز"),
 "levelOf": ("{level} of {max}", "{max} میں سے {level}"),
 "quieter": ("Quieter", "دھیمی"),
 "louder": ("Louder", "اونچی"),
 "vibration": ("Vibration", "تھرتھراہٹ"),
 "vibrateWhenRinging": ("Vibrate when ringing", "بجتے وقت تھرتھراہٹ بھی"),
 "vibrateNotAllowed": ("This phone keeps this switch in its own Settings. Open Sound settings and look for “Vibrate for calls”.", "اس فون میں یہ بٹن اس کی اپنی سیٹنگز میں ہے۔ ساؤنڈ سیٹنگز کھولیں اور “Vibrate for calls” تلاش کریں۔"),
 "testVibration": ("Test vibration", "تھرتھراہٹ آزمائیں"),
 "moreSoundSettings": ("More sound settings", "مزید ساؤنڈ سیٹنگز"),
 "loudIntro": ("For people who hear less. Press the big red button to make your phone as loud as it can be, and pick a loud tone below.", "کم سننے والوں کے لیے۔ بڑا سرخ بٹن دبائیں تاکہ فون کی آواز پوری اونچی ہو جائے، پھر نیچے سے کوئی اونچی ٹون چنیں۔"),
 "makeLoud": ("Make my phone loud", "میرا فون اونچا کریں"),
 "madeLoud": ("Done! Sound is on, ringtone, messages and alarm are at full volume, and the phone vibrates when it rings (where allowed).", "ہو گیا! آواز آن ہے، رنگ ٹون، پیغامات اور الارم پوری آواز پر ہیں، اور فون بجتے وقت تھرتھرائے گا (جہاں ممکن ہو)۔"),
 "loudTones": ("Loud tones", "اونچی ٹونز"),
 "useFor": ("Use this tone for:", "یہ ٹون کس کے لیے؟"),
 "flashTitle": ("Flash light when a call comes", "کال آنے پر روشنی جلے"),
 "flashBody": ("Many phones can flash the light for calls and messages. Open Accessibility and look for “Flash notification”.", "بہت سے فونز کال اور پیغام پر روشنی جلا سکتے ہیں۔ Accessibility کھولیں اور “Flash notification” تلاش کریں۔"),
 "about": ("About and privacy", "ایپ کے بارے میں اور رازداری"),
 "version": ("Version {version}", "ورژن {version}"),
 "aboutBody": ("Change your call, message and alarm tones, record your own voice, set WhatsApp and other app sounds, and control volume and vibration, all from one simple screen.", "کال، پیغام اور الارم کی ٹون بدلیں، اپنی آواز ریکارڈ کریں، واٹس ایپ اور دوسری ایپس کی آواز سیٹ کریں، اور آواز اور تھرتھراہٹ کنٹرول کریں — سب ایک آسان اسکرین سے۔"),
 "privacyTitle": ("Privacy", "رازداری"),
 "privacyBody": ("Your recordings and tones stay on your phone. The app has no account and sends none of your sounds anywhere. Ads are shown by Google AdMob.", "آپ کی ریکارڈنگز اور ٹونز آپ کے فون میں ہی رہتی ہیں۔ ایپ میں کوئی اکاؤنٹ نہیں اور آپ کی کوئی آواز کہیں نہیں بھیجی جاتی۔ اشتہارات گوگل ایڈموب دکھاتا ہے۔"),
 "copyLink": ("Copy privacy link", "رازداری کا لنک کاپی کریں"),
 "copied": ("Copied", "کاپی ہو گیا"),
 "privacyChoices": ("Ad privacy choices", "اشتہارات کی رازداری"),
 "madeBy": ("Made by HomiLabs", "HomiLabs کی تیار کردہ"),
}

PLACEHOLDERS = {"title": "String", "app": "String", "number": "int", "seconds": "int", "max": "int", "level": "int", "version": "String"}

def arb(lang, idx):
    out = {"@@locale": lang}
    for key, texts in S.items():
        text = texts[idx]
        out[key] = text
        if idx == 0:
            names = re.findall(r"\{(\w+)\}", text)
            if names:
                out[f"@{key}"] = {"placeholders": {n: {"type": PLACEHOLDERS[n]} for n in dict.fromkeys(names)}}
    return out

root = pathlib.Path(__file__).resolve().parent.parent / "lib" / "l10n"
for lang, idx in (("en", 0), ("ur", 1)):
    (root / f"app_{lang}.arb").write_text(json.dumps(arb(lang, idx), ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
# Same placeholders in both languages, or gen-l10n fails later with a less helpful message.
for key, (en, ur) in S.items():
    assert set(re.findall(r"\{(\w+)\}", en)) == set(re.findall(r"\{(\w+)\}", ur)), key
print(f"{len(S)} strings written")
