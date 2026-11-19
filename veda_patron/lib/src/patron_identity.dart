// Who the Patron is, across apps: a Google or Apple sign-in, asked for only
// when someone buys or restores Patron. Free users never see it.
//
// Nothing about the person is kept or sent to Véda. The sign-in gives a
// stable account number (Google's account id, or Apple's user identifier,
// which Apple keeps the same across one developer's apps); it is turned
// into a one-way code on the phone, and only that code goes to RevenueCat as
// the customer id. The same account gives the same code in every Véda app,
// which is how one membership is found from all of them. No email, no name.

import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

enum PatronProvider { google, apple }

extension PatronProviderWords on PatronProvider {
  String get label => switch (this) {
    PatronProvider.google => 'Google',
    PatronProvider.apple => 'Apple',
  };
}

/// A signed-in Patron identity: which provider, and the coded customer id.
class PatronIdentity {
  const PatronIdentity(this.provider, this.customerId);

  final PatronProvider provider;

  /// The one-way code sent to RevenueCat; never the account itself.
  final String customerId;

  Map<String, Object?> toJson() => {
    'provider': provider.name,
    'id': customerId,
  };

  static PatronIdentity? fromJson(Object? j) {
    if (j is! Map) return null;
    final p = PatronProvider.values
        .where((v) => v.name == j['provider'])
        .firstOrNull;
    final id = j['id'];
    if (p == null || id is! String || id.isEmpty) return null;
    return PatronIdentity(p, id);
  }
}

/// The customer id for an account: the same in every Véda app for the same
/// account, and not reversible to the account number.
String patronCustomerId(PatronProvider provider, String accountId) {
  final digest = sha256.convert(
    utf8.encode('veda-patron/1:${provider.name}:$accountId'),
  );
  return 'vp_${digest.toString().substring(0, 40)}';
}

/// The person backed out of the sign-in: not an error worth showing.
class SignInCancelled implements Exception {}

class SignInFailure implements Exception {
  SignInFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

/// The platform's sign-in, behind an interface for tests.
abstract class PatronSignIn {
  /// The providers this phone offers: Google everywhere; Apple on iPhone,
  /// where the App Store asks for it whenever Google is offered.
  List<PatronProvider> get providers;

  /// The account number of whoever signs in. Throws [SignInCancelled] if the
  /// person backs out.
  Future<String> accountId(PatronProvider provider);

  /// Forgets the sign-in on this phone.
  Future<void> signOut(PatronProvider provider);
}

class PlatformPatronSignIn implements PatronSignIn {
  // No scopes: only the account's id is needed, not its email or profile.
  final GoogleSignIn _google = GoogleSignIn(scopes: const []);

  @override
  List<PatronProvider> get providers => [
    PatronProvider.google,
    if (defaultTargetPlatform == TargetPlatform.iOS) PatronProvider.apple,
  ];

  @override
  Future<String> accountId(PatronProvider provider) async {
    switch (provider) {
      case PatronProvider.google:
        try {
          final account = await _google.signIn();
          if (account == null) throw SignInCancelled();
          return account.id;
        } on PlatformException catch (e) {
          if (e.code == GoogleSignIn.kSignInCanceledError) {
            throw SignInCancelled();
          }
          throw SignInFailure(
            e.code == GoogleSignIn.kNetworkError
                ? 'No connection. Try again when you are online.'
                : 'Google sign-in did not work.',
          );
        }
      case PatronProvider.apple:
        try {
          final c = await SignInWithApple.getAppleIDCredential(
            scopes: const [],
          );
          final id = c.userIdentifier;
          if (id == null || id.isEmpty) {
            throw SignInFailure('Apple sign-in did not work.');
          }
          return id;
        } on SignInWithAppleAuthorizationException catch (e) {
          if (e.code == AuthorizationErrorCode.canceled) {
            throw SignInCancelled();
          }
          throw SignInFailure('Apple sign-in did not work.');
        }
    }
  }

  @override
  Future<void> signOut(PatronProvider provider) async {
    if (provider == PatronProvider.google) {
      try {
        await _google.signOut();
      } catch (_) {}
    }
    // Apple keeps no session in the app to end.
  }
}
