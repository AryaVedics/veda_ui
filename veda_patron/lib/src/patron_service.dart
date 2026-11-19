// Patron in a companion app: whether this person is a member, and the steps
// to become one or bring a membership over from another Véda app.
//
// The rules:
// - Free users never sign in. The sign-in is asked for only to buy or restore.
// - A membership belongs to the sign-in, so the same Google or Apple account
//   unlocks it in every Véda app except Cycle.
// - With no store key built in, nothing is sold and nobody is a member.
// - The membership is also told to the other Véda apps on this phone
//   (PatronLink), and one found there counts here too, so a Patron who never
//   signed in here still loses the ads.

import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart' show PatronLink;

import 'patron_identity.dart';
import 'patron_store.dart';

class PatronService with WidgetsBindingObserver {
  PatronService({
    required this.appKey,
    PatronStore? store,
    PatronSignIn? signIn,
    Future<bool> Function()? readLink,
    Future<void> Function({required bool active, DateTime? until})? publish,
  }) : _store = store ?? defaultPatronStore(),
       _signIn = signIn ?? PlatformPatronSignIn(),
       _readLink = readLink ?? PatronLink.read,
       _publish =
           publish ??
           (({required bool active, DateTime? until}) =>
               PatronLink.publish(app: appKey, active: active, until: until));

  /// This app's id for PatronLink ("lifestyle", "sun", ...).
  final String appKey;

  final PatronStore _store;
  final PatronSignIn _signIn;
  final Future<bool> Function() _readLink;
  final Future<void> Function({required bool active, DateTime? until}) _publish;

  static const _identityKey = 'patron_identity';

  /// Whether this person is a Patron here, from either this app's own
  /// membership or another Véda app's on this phone.
  final ValueNotifier<bool> isPatron = ValueNotifier(false);

  /// The sign-in the membership is tied to here, if any.
  final ValueNotifier<PatronIdentity?> identity = ValueNotifier(null);

  bool _own = false;
  bool _linked = false;
  Future<void>? _ready;

  /// False when no store key was built in: nothing to buy, the Patron row
  /// stays hidden.
  bool get available => _store.available;

  /// The providers this phone offers for the sign-in.
  List<PatronProvider> get providers => _signIn.providers;

  /// Completes once the first check has run, so a member never sees an ad
  /// flash up first. Safe to call more than once.
  Future<void> ready() => _ready ??= _start();

  Future<void> _start() async {
    WidgetsBinding.instance.addObserver(this);
    try {
      final raw = (await SharedPreferences.getInstance()).getString(
        _identityKey,
      );
      identity.value = raw == null
          ? null
          : PatronIdentity.fromJson(jsonDecode(raw));
    } catch (_) {}
    if (_store.available) {
      try {
        await _store.start(_ownChanged);
        final id = identity.value;
        if (id != null) _ownChanged(await _store.logIn(id.customerId));
      } catch (e) {
        debugPrint('Patron did not start: $e');
      }
    }
    await _readOthers();
  }

  void _ownChanged(PatronStatus s) {
    final was = _own;
    _own = s.active;
    _update();
    if (was != _own || s.active) _publish(active: s.active, until: s.until);
  }

  Future<void> _readOthers() async {
    try {
      _linked = await _readLink();
    } catch (_) {
      _linked = false;
    }
    _update();
  }

  void _update() => isPatron.value = _own || _linked;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _readOthers();
  }

  /// Signs in with [provider] and ties this app's purchases to it. Returns
  /// whether a membership was found for that account. Throws
  /// [SignInCancelled] if the person backs out.
  Future<bool> signIn(PatronProvider provider) async {
    final account = await _signIn.accountId(provider);
    final id = PatronIdentity(provider, patronCustomerId(provider, account));
    final status = await _store.logIn(id.customerId);
    identity.value = id;
    try {
      await (await SharedPreferences.getInstance()).setString(
        _identityKey,
        jsonEncode(id.toJson()),
      );
    } catch (_) {}
    _ownChanged(status);
    return status.active;
  }

  Future<List<PatronPackage>> packages() => _store.packages();

  /// Buys [package] for the signed-in account. The screen signs in first:
  /// buying without a sign-in would tie the membership to this app alone.
  Future<bool> buy(PatronPackage package) async {
    if (identity.value == null) {
      throw StateError('Sign in before buying Patron');
    }
    final status = await _store.buy(package);
    _ownChanged(status);
    return status.active;
  }

  /// Looks again for a membership on the signed-in account (and asks the
  /// store to re-attach this phone's own purchases).
  Future<bool> restore() async {
    if (identity.value == null) {
      throw StateError('Sign in before restoring Patron');
    }
    final status = await _store.restore();
    _ownChanged(status);
    return status.active;
  }

  /// Forgets the sign-in on this phone. The membership itself is untouched:
  /// signing in again finds it.
  Future<void> signOut() async {
    final id = identity.value;
    if (id != null) await _signIn.signOut(id.provider);
    await _store.logOut();
    identity.value = null;
    try {
      await (await SharedPreferences.getInstance()).remove(_identityKey);
    } catch (_) {}
    _own = false;
    _update();
    await _publish(active: false);
  }
}
