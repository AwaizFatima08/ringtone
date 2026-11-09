# Easy Ringtone — design v1.0 (9 Nov 2026)

Android app (Flutter, package `com.homilabs.easyringtone`, minSdk 26) for elderly people and anyone with little
phone experience. One job: make the phone ring, beep and buzz the way the user wants, from one simple window.

## Decisions
| # | Decision | Why |
|---|---|---|
| E1 | **One app, not several.** Six big buttons on the home screen, each opening one simple page. | Several apps = several icons to find; one front door is easier for elderly users. Each page does only one thing. |
| E2 | Big type (body 22, buttons 72 dp tall), icon + short label on every button, high contrast, no gestures, no hidden menus. | Elderly users, low vision, shaky hands. |
| E3 | **Urdu and English**, chosen with one button on the home screen (starts in the phone's language). | Main audience is Pakistan. Urdu text needs Homi's review. |
| E4 | Every tone can be **heard before it is used** ("Listen") and is played on the ring volume, so it sounds like the real thing. | Users choose by ear. |
| E5 | Sources: phone's own tones, a song or sound from the phone (Android file picker), **own voice recording** (max 30 s), and the app's **loud tones**. | As asked. |
| E6 | Changing the phone's call / message / alarm tone needs Android's "Modify system settings" switch, granted once. The app explains it in one sentence and opens the page. | Android rule (`WRITE_SETTINGS`). |
| E7 | **WhatsApp, Messenger and other apps:** Android does not let one app change another app's sounds. The app (a) saves the chosen tone into the phone's own tone list, so it shows up in WhatsApp's picker under "Easy Ringtone", and (b) opens that app's sound page with numbered big-text steps. | Honest about what Android allows; still one window for all apps. |
| E8 | Volume page: Ring, Messages, Alarm, Media, Call voice — each with big **−** and **+** buttons (no small sliders) and a test sound. Sound / Vibrate / Silent as three big buttons. "Vibrate when ringing" switch where Android allows, otherwise opens Sound settings. Test-vibration button. | As asked; buttons are easier than sliders. |
| E9 | **Loud tones** section (separate button, its own colour): original tones made in code (`tool/make_tones.py`), low pitch (500–1200 Hz, easier to hear with age-related high-frequency loss), loud and repeated. One-tap **"Make my phone loud"**: ring + message + alarm volume to max, sound mode on, vibrate on. Link to Android's flash-alert setting. | People with decreased hearing. |
| E10 | Ads: one banner at the bottom of the home screen only, with space above it. **No full-screen ads.** Consent (UMP) before the SDK starts. | Full-screen ads confuse low-tech users and invite accidental taps. |
| E11 | No account, no internet use apart from ads, no data leaves the phone. Recordings stay on the phone in `Ringtones/Easy Ringtone`. | Privacy, simple Play data-safety form. |

## Not in v1 (ideas)
- A special tone for one person (contact ringtone; needs the contacts permission).
- Flash light when ringing (Android 14+ has its own setting; the app links to it).

## Pages
Home → Call tone · Message tone · Alarm tone · WhatsApp & other apps · Volume & vibration · Loud tones (for weak hearing).
Tone page (call/message/alarm): current tone + Listen; four big sources; each tone row: Listen · Use this.

## Android pieces (`android/app/src/main/kotlin/com/homilabs/easyringtone/ToneChannel.kt`, channel `com.homilabs.easyringtone/tones`)
`RingtoneManager` (list, get/set defaults), `MediaStore.Audio` (save tones as ringtone/notification/alarm),
`AudioManager` (volumes, ringer mode), `Vibrator`, `Settings.System` (vibrate when ringing), settings intents.

## Web
Pages on tools.homilabs.org (slug `easyringtone`): hub card, privacy section, terms section (source:
`/mnt/storage/projects/homilabs_tools/site`).
