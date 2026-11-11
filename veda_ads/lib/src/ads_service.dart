// Starts the ad SDK, but only after Google's consent step has run.
//
// In the European Economic Area and the UK, Google's User Messaging Platform
// (UMP) has to ask for a choice before any ad is requested; elsewhere it
// reports nothing is required and ads may start. The form itself is written in
// AdMob (Privacy & messaging), not in the app. Nothing here runs unless the
// banner asks, and the banner asks only after the membership check, so a
// Patron member's phone never starts the ad SDK at all.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  AdsService._();

  static final instance = AdsService._();

  Future<bool>? _ready;

  /// The plugin's callbacks are meant to fire once; completing twice would
  /// throw, so a repeated callback is simply ignored.
  static void _finish(Completer<void> c) {
    if (!c.isCompleted) c.complete();
  }

  /// Runs the consent step once, then starts the SDK. True when ads may be
  /// requested; false when the person's choice (or an error) says they may not.
  Future<bool> ensureReady() => _ready ??= _start();

  Future<bool> _start() async {
    try {
      final updated = Completer<void>();
      ConsentInformation.instance.requestConsentInfoUpdate(
        ConsentRequestParameters(),
        () => _finish(updated),
        (error) {
          debugPrint('Ad consent info did not load: ${error.message}');
          _finish(updated);
        },
      );
      await updated.future;
      final dismissed = Completer<void>();
      await ConsentForm.loadAndShowConsentFormIfRequired((error) {
        if (error != null) debugPrint('Ad consent form: ${error.message}');
        _finish(dismissed);
      });
      await dismissed.future;
      if (!await ConsentInformation.instance.canRequestAds()) return false;
      await MobileAds.instance.initialize();
      return true;
    } catch (e) {
      debugPrint('Ads did not start: $e');
      return false;
    }
  }

  /// Whether Profile should offer "Ad choices" (the law requires a way to
  /// change the answer where the consent form was shown).
  Future<bool> get privacyOptionsRequired async {
    if (!VedaAds.enabled) return false;
    try {
      return await ConsentInformation.instance
              .getPrivacyOptionsRequirementStatus() ==
          PrivacyOptionsRequirementStatus.required;
    } catch (_) {
      return false;
    }
  }

  Future<void> showPrivacyOptions() async {
    final done = Completer<void>();
    await ConsentForm.showPrivacyOptionsForm((_) => _finish(done));
    await done.future;
  }
}

/// Build-time switches for ads, the same names as Véda's.
class VedaAds {
  VedaAds._();

  /// Ads are off unless a build asks for them (--dart-define=ADS_ENABLED=true,
  /// used for the store build), so test and beta builds never contact the ad
  /// service.
  static const bool enabled = bool.fromEnvironment('ADS_ENABLED');

  /// Google's own published test ad units: safe as defaults, since they only
  /// ever serve clearly-labelled test creatives. A store build passes the app's
  /// real units:
  ///   --dart-define=BANNER_AD_UNIT_ID=ca-app-pub-...
  ///   --dart-define=BANNER_AD_UNIT_ID_IOS=ca-app-pub-...
  static const String androidBannerUnit = String.fromEnvironment(
    'BANNER_AD_UNIT_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const String iosBannerUnit = String.fromEnvironment(
    'BANNER_AD_UNIT_ID_IOS',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  static String get bannerUnit => defaultTargetPlatform == TargetPlatform.iOS
      ? iosBannerUnit
      : androidBannerUnit;
}
