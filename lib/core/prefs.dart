import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<SharedPreferences> prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('Overridden in main()'),
);

/// The language the user chose with the button on the home screen; null = the phone's language.
class LocaleController extends Notifier<Locale?> {
  static const _key = 'locale';

  @override
  Locale? build() {
    final code = ref.watch(prefsProvider).getString(_key);
    return code == null ? null : Locale(code);
  }

  Future<void> choose(String languageCode) async {
    state = Locale(languageCode);
    await ref.read(prefsProvider).setString(_key, languageCode);
  }
}

final NotifierProvider<LocaleController, Locale?> localeProvider =
    NotifierProvider<LocaleController, Locale?>(LocaleController.new);
