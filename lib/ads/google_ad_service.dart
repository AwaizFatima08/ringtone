import 'dart:async';

import 'package:easyringtone/ads/ad_ids.dart';
import 'package:easyringtone/ads/ad_service.dart';
import 'package:flutter/widgets.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob implementation. Consent (Google's UMP form) comes first; no ad is
/// requested until the SDK says requests are allowed.
class GoogleAdService implements AdService {
  final _ready = ValueNotifier<bool>(false);
  bool _started = false;

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final consent = Completer<void>();
    ConsentInformation.instance.requestConsentInfoUpdate(
      ConsentRequestParameters(),
      () async {
        await ConsentForm.loadAndShowConsentFormIfRequired((error) {
          if (error != null) debugPrint('Consent form: ${error.message}');
        });
        consent.complete();
      },
      (error) {
        debugPrint('Consent info: ${error.message}');
        consent.complete();
      },
    );
    await consent.future;
    if (!await ConsentInformation.instance.canRequestAds()) return;
    await MobileAds.instance.initialize();
    _ready.value = true;
  }

  @override
  Future<bool> privacyChoicesRequired() async {
    final status = await ConsentInformation.instance.getPrivacyOptionsRequirementStatus();
    return status == PrivacyOptionsRequirementStatus.required;
  }

  @override
  Future<void> showPrivacyChoices() => ConsentForm.showPrivacyOptionsForm((error) {
    if (error != null) debugPrint('Privacy choices: ${error.message}');
  });

  @override
  Widget banner() => ValueListenableBuilder<bool>(
    valueListenable: _ready,
    builder: (context, ready, _) => ready ? const _BannerSlot() : const SizedBox.shrink(),
  );
}

class _BannerSlot extends StatefulWidget {
  const _BannerSlot();

  @override
  State<_BannerSlot> createState() => _BannerSlotState();
}

class _BannerSlotState extends State<_BannerSlot> {
  BannerAd? _ad;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ad != null) return;
    final width = MediaQuery.sizeOf(context).width.truncate();
    unawaited(_load(width));
  }

  Future<void> _load(int width) async {
    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width);
    if (size == null || !mounted) return;
    final ad = BannerAd(
      adUnitId: AdIds.banner,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _loaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('Banner: ${error.message}');
          unawaited(ad.dispose());
        },
      ),
    );
    _ad = ad;
    await ad.load();
  }

  @override
  void dispose() {
    unawaited(_ad?.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (!_loaded || ad == null) return const SizedBox.shrink();
    return SizedBox(
      width: ad.size.width.toDouble(),
      height: ad.size.height.toDouble(),
      child: AdWidget(ad: ad),
    );
  }
}
