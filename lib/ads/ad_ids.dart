import 'package:flutter/foundation.dart';

/// AdMob identifiers. Debug builds always use Google's published test unit
/// so a developer never clicks a live ad.
abstract final class AdIds {
  static const _testBanner = 'ca-app-pub-3940256099942544/6300978111';

  // Real unit from the HomiLabs AdMob account (homilabs.smc@gmail.com); see config/admob.json.
  static const _liveBanner = 'ca-app-pub-2087846699268567/1100850638';

  static String get banner => kReleaseMode ? _liveBanner : _testBanner;
}
