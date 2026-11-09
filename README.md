# Easy Ringtone

An Android app by HomiLabs that makes the phone's sounds easy to manage for elderly people and anyone new to
smartphones. Big buttons, plain words, English and Urdu.

- **Call, message and alarm tones**: pick one of the phone's tones, a song or sound from the phone, your own recorded
  voice, or one of the app's loud tones. Listen first, then press "Use this".
- **WhatsApp and other apps**: Messenger, Facebook, imo, Telegram and more in one list, each with three simple steps.
- **Volume and vibration**: Sound / Vibrate / Silent, big − and + buttons for each volume, vibrate when ringing.
- **Loud tones (weak hearing)**: low-pitched loud tones and one button that makes the phone as loud as it goes.

Design: [docs/design.md](docs/design.md). Privacy: https://tools.homilabs.org/privacy#easyringtone

```bash
flutter analyze && flutter test
flutter build apk --release --target-platform android-arm64,android-arm
```
