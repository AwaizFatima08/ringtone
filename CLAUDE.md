# Easy Ringtone (HomiLabs) — project notes

Flutter Android app for elderly and low-tech users: change call / message / alarm tones (phone tones, a song from the
phone, own voice recording, loud tones), set WhatsApp and other app sounds step by step, volume and vibration, and a
"Loud tones (weak hearing)" section. English + Urdu. App id `com.homilabs.easyringtone` (locked after the first Play
upload), launcher name "Easy Ringtone", minSdk 26. Design and decisions: `docs/design.md`.

## Locations
- Code: `/mnt/storage/projects/ringtone` · GitHub `AwaizFatima08/ringtone` (PUBLIC repo: no secrets)
- Local backup: `/mnt/storage/project_backups/ringtone_backup` — `bash scripts/backup.sh` (local copy + GitHub push; Drive off until `GDRIVE_FOLDER_ID` is set)
- Web: tools.homilabs.org — hub card, `privacy#easyringtone`, `terms#easyringtone` (source `/mnt/storage/projects/homilabs_tools/site`; live files can be newer than that folder: patch the live files, never overwrite them wholesale)

## Code map
- Native: `android/app/src/main/kotlin/com/homilabs/easyringtone/ToneChannel.kt` (channel `com.homilabs.easyringtone/tones`) — RingtoneManager, MediaStore copy into Ringtones/Notifications/Alarms "Easy Ringtone", AudioManager, Vibrator, settings intents. Dart side `lib/core/tone_platform.dart`.
- `lib/features/tones/application/tone_providers.dart` — the only place that changes phone tones (`ToneActions`), saved tones in shared prefs, playback.
- Chat apps: `lib/features/apps/apps.dart` list must match `<queries>` in AndroidManifest.xml.
- Text: edit `tool/gen_arb.py` (both languages side by side), run it, never edit the .arb files by hand. Urdu needs Homi's review.
- Loud tones: `tool/make_tones.py` synthesises `assets/tones/*.ogg` (original, no samples). Homi must listen to them.

## What Android allows
- Default call/message/alarm tone: needs "Modify system settings" (WRITE_SETTINGS), granted once by the user.
- Other apps' sounds (WhatsApp…): only the user can change them. The app saves the tone into the phone's lists and opens the app's notification page.
- "Vibrate when ringing" is not writable on many phones: the app falls back to Sound settings.
- Silent / sound mode changes may need Do Not Disturb access.

## Ads
AdMob account homilabs.smc@gmail.com (pub-2087846699268567). App `ca-app-pub-2087846699268567~9304654610`, banner
`…/1100850638` (`config/admob.json`). Banner at the bottom of home only; no full-screen ads (design E10). UMP consent
before SDK start. Debug builds use Google's test unit. `bash scripts/check-release-ad-ids.sh` must pass before a release.
After the Play listing is live, add the store to the AdMob app.

## Gate before commit
```
python3 tool/gen_arb.py && dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
Heavy jobs follow `~/.claude/heavy-jobs.md`: `jobq run --name easyringtone-apk -- flutter build apk --release`, then `cd android && ./gradlew --stop`.
Release signing: not set up yet (release builds use the debug key). Create an upload keystore in `.secrets/` before the first Play upload.
