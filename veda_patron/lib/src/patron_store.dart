// The store side of Patron: RevenueCat, behind an interface so screens and
// rules can be tested without billing.
//
// Configured by the same build-time keys as Véda, one per platform:
//   --dart-define=REVENUECAT_ANDROID_KEY=goog_...
//   --dart-define=REVENUECAT_IOS_KEY=appl_...
// With no key, [PatronStore.available] is false: nothing is configured,
// nothing touches the network, and nobody is a Patron (a store build that lost
// its key must not give Patron away).

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:purchases_flutter/purchases_flutter.dart';

const String _androidKey = String.fromEnvironment('REVENUECAT_ANDROID_KEY');
const String _iosKey = String.fromEnvironment('REVENUECAT_IOS_KEY');

/// The RevenueCat entitlement that unlocks Patron, the same in every core app
/// (Véda, Routine, Kitchen, Learn, Today).
const String kPatronEntitlement = 'veda_patron';

/// The entitlement Patron Plus grants: the same in every Plus app.
const String kPlusEntitlement = 'veda_plus';

/// The RevenueCat package identifiers of a Patron Plus app's offering: Plus
/// itself, and this one app's own monthly plan. (Two plain monthly packages
/// cannot share one offering, so both carry their own identifier.)
const String kPlusPackageId = 'plus_monthly';
const String kSinglePackageId = 'single_monthly';

/// What unlocks a Patron Plus app: Patron Plus itself, or that one app's own
/// single-app plan (`veda_<app>`, "veda_allergy"). Patron alone does not.
Set<String> plusEntitlementsFor(String appKey) => {
  kPlusEntitlement,
  'veda_$appKey',
};

/// One purchasable plan, flattened to what the screen draws.
class PatronPackage {
  const PatronPackage({
    required this.id,
    required this.isAnnual,
    required this.priceString,
    required this.price,
    this.trialLabel,
    this.handle,
  });

  final String id;
  final bool isAnnual;

  /// Localized, formatted by the store ("$4.99", "₹199").
  final String priceString;

  /// The same price as a number, for working out the annual saving.
  final double price;

  /// "7-day free trial" when the plan opens with a free period.
  final String? trialLabel;

  /// The store package behind this plan, handed back on purchase. Null in
  /// tests.
  final Object? handle;
}

/// A purchase that did not complete. [cancelled] is the person backing out,
/// which is not an error worth showing.
class PurchaseFailure implements Exception {
  PurchaseFailure(this.message, {this.cancelled = false});
  final String message;
  final bool cancelled;
  @override
  String toString() => message;
}

/// The membership as the store reports it.
class PatronStatus {
  const PatronStatus({required this.active, this.until});
  static const none = PatronStatus(active: false);

  final bool active;

  /// When the current period ends, if known.
  final DateTime? until;
}

abstract class PatronStore {
  bool get available;

  /// Starts billing and reports the membership now and whenever it changes.
  Future<void> start(void Function(PatronStatus status) onChange);

  /// Ties purchases to [appUserId], the coded id of a Google or Apple sign-in,
  /// so the same membership is found from every Véda app.
  Future<PatronStatus> logIn(String appUserId);

  /// Back to an anonymous customer: this phone no longer claims the membership.
  Future<void> logOut();

  Future<List<PatronPackage>> packages();

  Future<PatronStatus> buy(PatronPackage package);

  Future<PatronStatus> restore();
}

class _NoStore implements PatronStore {
  @override
  bool get available => false;
  @override
  Future<void> start(void Function(PatronStatus) onChange) async {}
  @override
  Future<PatronStatus> logIn(String appUserId) async => PatronStatus.none;
  @override
  Future<void> logOut() async {}
  @override
  Future<List<PatronPackage>> packages() async => const [];
  @override
  Future<PatronStatus> buy(PatronPackage package) async => PatronStatus.none;
  @override
  Future<PatronStatus> restore() async => PatronStatus.none;
}

class _RevenueCatStore implements PatronStore {
  _RevenueCatStore(this._key, this._entitlements);
  final String _key;

  /// Any one of these being active unlocks the app.
  final Set<String> _entitlements;

  @override
  bool get available => true;

  PatronStatus _status(CustomerInfo info) {
    final active = [
      for (final id in _entitlements)
        if (info.entitlements.active[id] case final e?) e,
    ];
    if (active.isEmpty) return PatronStatus.none;
    // Several can be active at once (a single-app plan and Plus): the status
    // runs to the latest end, and has no end if any of them has none.
    DateTime? until;
    for (final e in active) {
      if (e.expirationDate == null) return const PatronStatus(active: true);
      final d = DateTime.tryParse(e.expirationDate!);
      if (d != null && (until == null || d.isAfter(until))) until = d;
    }
    return PatronStatus(active: true, until: until);
  }

  @override
  Future<void> start(void Function(PatronStatus) onChange) async {
    await Purchases.configure(PurchasesConfiguration(_key));
    Purchases.addCustomerInfoUpdateListener((info) => onChange(_status(info)));
    onChange(_status(await Purchases.getCustomerInfo()));
  }

  @override
  Future<PatronStatus> logIn(String appUserId) async {
    final result = await Purchases.logIn(appUserId);
    return _status(result.customerInfo);
  }

  @override
  Future<void> logOut() async {
    try {
      await Purchases.logOut();
    } on PlatformException {
      // Already anonymous: nothing to undo.
    }
  }

  @override
  Future<List<PatronPackage>> packages() async {
    final offerings = await Purchases.getOfferings();
    final current = offerings.current;
    if (current == null) return const [];
    final plans = [
      for (final p in current.availablePackages)
        if (p.packageType == PackageType.monthly ||
            p.packageType == PackageType.annual ||
            p.identifier == kPlusPackageId ||
            p.identifier == kSinglePackageId)
          p,
    ];
    // Google only offers a free trial to an account that can still have it.
    // Apple returns the offer to everyone, so on iPhone the trial is promised
    // only when the account is eligible (as in Véda's own paywall).
    Set<String>? eligible;
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      eligible = <String>{};
      try {
        final result = await Purchases.checkTrialOrIntroductoryPriceEligibility(
          [for (final p in plans) p.storeProduct.identifier],
        );
        for (final e in result.entries) {
          if (e.value.status ==
              IntroEligibilityStatus.introEligibilityStatusEligible) {
            eligible.add(e.key);
          }
        }
      } catch (_) {}
    }
    return [
      for (final p in plans)
        PatronPackage(
          id: p.identifier,
          isAnnual: p.packageType == PackageType.annual,
          priceString: p.storeProduct.priceString,
          price: p.storeProduct.price,
          trialLabel:
              eligible != null && !eligible.contains(p.storeProduct.identifier)
              ? null
              : _trialLabel(p.storeProduct.introductoryPrice),
          handle: p,
        ),
    ];
  }

  static String? _trialLabel(IntroductoryPrice? intro) {
    if (intro == null || intro.price != 0) return null;
    final n = intro.periodNumberOfUnits;
    return switch (intro.periodUnit) {
      PeriodUnit.day => '$n-day free trial',
      PeriodUnit.week => '${n * 7}-day free trial',
      PeriodUnit.month => '$n-month free trial',
      PeriodUnit.year => '$n-year free trial',
      _ => null,
    };
  }

  @override
  Future<PatronStatus> buy(PatronPackage package) async {
    try {
      final result = await Purchases.purchase(
        PurchaseParams.package(package.handle! as Package),
      );
      return _status(result.customerInfo);
    } on PlatformException catch (e) {
      final code = PurchasesErrorHelper.getErrorCode(e);
      final cancelled = code == PurchasesErrorCode.purchaseCancelledError;
      throw PurchaseFailure(
        cancelled
            ? 'Cancelled'
            : (e.message ?? 'The purchase did not go through.'),
        cancelled: cancelled,
      );
    }
  }

  @override
  Future<PatronStatus> restore() async {
    try {
      return _status(await Purchases.restorePurchases());
    } on PlatformException catch (e) {
      throw PurchaseFailure(e.message ?? 'Could not restore purchases.');
    }
  }
}

/// RevenueCat when this build carries a key, otherwise a store that sells
/// nothing.
///
/// [entitlements] are the ones that unlock this app: Patron for a core app, or
/// [plusEntitlementsFor] for a Patron Plus app.
PatronStore defaultPatronStore({
  Set<String> entitlements = const {kPatronEntitlement},
}) {
  final key = defaultTargetPlatform == TargetPlatform.iOS
      ? _iosKey
      : _androidKey;
  return key.isEmpty ? _NoStore() : _RevenueCatStore(key, entitlements);
}
