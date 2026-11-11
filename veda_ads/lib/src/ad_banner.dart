// The free-tier banner, sat above the tab bar in the app's shell, never inside
// the scrollable body, so it never scrolls out of view and every screen's own
// layout adjusts for it through Scaffold's normal layout.
//
// Renders nothing (not a placeholder box) until an ad actually has something to
// show, and nothing at all for a member. A failed or empty ad collapses back to
// nothing rather than leaving a blank strip. Written to match Véda's own banner
// (flutter_app/lib/widgets/ad_banner.dart).

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ads_service.dart';

class AdBanner extends StatefulWidget {
  const AdBanner({super.key, required this.isMember, this.membershipReady});

  /// True while the person is a Patron member: no ad is shown, and the ad
  /// library is never started for them.
  final ValueListenable<bool> isMember;

  /// Completes once the membership check has run, so a member never sees an ad
  /// flash up while their membership is still being confirmed. Null when the
  /// app has no membership check yet.
  final Future<void> Function()? membershipReady;

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _ad;
  bool _failed = false;

  // A request can come back empty ("no fill") for no fault of ours, which is
  // common for a new app. It asks again a minute later, then 2, 4, 8 and 10
  // minutes apart, and stops after that.
  static const _maxRetries = 5;
  Timer? _retry;
  int _attempts = 0;

  ValueListenable<bool> get _member => widget.isMember;

  void _scheduleRetry() {
    if (_attempts >= _maxRetries) return;
    final minutes = (1 << _attempts).clamp(1, 10);
    _attempts++;
    _retry = Timer(Duration(minutes: minutes), () {
      if (!mounted || _member.value) return;
      setState(() => _failed = false);
      _load();
    });
  }

  @override
  void initState() {
    super.initState();
    _member.addListener(_onMembershipChanged);
    _load();
  }

  /// Someone who becomes a member mid-session stops seeing ads at once.
  void _onMembershipChanged() {
    final old = _ad;
    if (!_member.value || old == null) return;
    setState(() => _ad = null);
    // Disposed after the frame that removes its AdWidget, never under it.
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
  }

  Future<void> _load() async {
    if (!VedaAds.enabled) return;
    await widget.membershipReady?.call();
    if (!mounted || _member.value) return;
    if (!await AdsService.instance.ensureReady()) return;
    // The consent step can take a while; the screen may be gone by now, and an
    // ad made for it would never be disposed.
    if (!mounted || _member.value) return;
    final ad = BannerAd(
      adUnitId: VedaAds.bannerUnit,
      size: AdSize.banner,
      request: const AdRequest(nonPersonalizedAds: true),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted || _member.value) {
            ad.dispose();
            return;
          }
          _attempts = 0;
          setState(() => _ad = ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          // The SDK refreshes a showing banner about once a minute, and a
          // refresh can come back with no ad to give. The banner then keeps the
          // ad it has; only a first load that fails clears.
          if (_ad != null) return;
          ad.dispose();
          if (!mounted) return;
          setState(() => _failed = true);
          _scheduleRetry();
        },
      ),
    );
    await ad.load();
  }

  @override
  void dispose() {
    _retry?.cancel();
    _member.removeListener(_onMembershipChanged);
    _ad?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _ad;
    if (ad == null || _failed) return const SizedBox.shrink();
    // No SafeArea here: the tab bar directly below already pads for the system
    // nav bar. heightFactor: 1 keeps the banner exactly as tall as the ad (a
    // plain Center grows to all the height it is offered).
    return Center(
      heightFactor: 1,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
