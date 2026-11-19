// Who the Patron is, across apps: a Google or Apple sign-in, asked for only
// when someone buys or restores Patron. Free users never see it.
//
// The phone never makes the Patron id itself. It sends the ID token its
// sign-in returned (signed by Google or Apple) to Véda's server, which checks
// the token against the provider's keys and answers with the id: a keyed hash
// of the provider's stable account id, made with a secret only the server
// holds (backend app/routers/patron.py). So an app that has been tampered
// with cannot make anyone's id, and the same account gets the same id in
// every Véda app. The server keeps and logs nothing. No email, no name.

import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show PlatformException;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Véda's server, which turns a checked sign-in into the Patron id.
const kPatronServer = String.fromEnvironment(
  'PATRON_BASE_URL',
  defaultValue: 'https://skin-app-backend-production.up.railway.app',
);

/// The Google sign-in web client id the server accepts tokens for (the same
/// one Véda's own sign-in uses), and the iOS client id, from the build.
const _googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');
const _googleIosClientId = String.fromEnvironment('GOOGLE_IOS_CLIENT_ID');

enum PatronProvider { google, apple }

extension PatronProviderWords on PatronProvider {
  String get label => switch (this) {
    PatronProvider.google => 'Google',
    PatronProvider.apple => 'Apple',
  };
}

/// A signed-in Patron identity: which provider, and the id the server gave.
class PatronIdentity {
  const PatronIdentity(this.provider, this.customerId);

  final PatronProvider provider;

  /// The id sent to RevenueCat; never the account itself.
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

/// What a sign-in returns: the provider's signed ID token, and for Apple the
/// raw nonce whose hash Apple put in the token (so a captured token cannot be
/// replayed).
class PatronCredential {
  const PatronCredential(this.provider, this.idToken, {this.nonce});

  final PatronProvider provider;
  final String idToken;
  final String? nonce;
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

  /// Signs in and returns the provider's token. Throws [SignInCancelled] if
  /// the person backs out.
  Future<PatronCredential> credential(PatronProvider provider);

  /// Forgets the sign-in on this phone.
  Future<void> signOut(PatronProvider provider);
}

class PlatformPatronSignIn implements PatronSignIn {
  bool get _ios => defaultTargetPlatform == TargetPlatform.iOS;

  // Only the ID token is needed; no email or profile scope is asked for.
  late final GoogleSignIn _google = GoogleSignIn(
    scopes: const [],
    serverClientId: _googleServerClientId.isEmpty
        ? null
        : _googleServerClientId,
    clientId: _ios && _googleIosClientId.isNotEmpty ? _googleIosClientId : null,
  );

  @override
  List<PatronProvider> get providers => [
    PatronProvider.google,
    if (_ios) PatronProvider.apple,
  ];

  @override
  Future<PatronCredential> credential(PatronProvider provider) async {
    switch (provider) {
      case PatronProvider.google:
        try {
          final account = await _google.signIn();
          if (account == null) throw SignInCancelled();
          final token = (await account.authentication).idToken;
          if (token == null || token.isEmpty) {
            throw SignInFailure('Google sign-in did not work.');
          }
          return PatronCredential(provider, token);
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
        final rnd = Random.secure();
        final raw = base64Url.encode([
          for (var i = 0; i < 32; i++) rnd.nextInt(256),
        ]);
        final hashed = sha256.convert(utf8.encode(raw)).toString();
        try {
          final c = await SignInWithApple.getAppleIDCredential(
            scopes: const [],
            nonce: hashed,
          );
          final token = c.identityToken;
          if (token == null || token.isEmpty) {
            throw SignInFailure('Apple sign-in did not work.');
          }
          return PatronCredential(provider, token, nonce: raw);
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

/// Véda's server: turns a checked sign-in into the Patron id.
abstract class PatronIdServer {
  /// The Patron id for [credential]. Throws [SignInFailure] when the server
  /// refuses the token or cannot be reached.
  Future<String> customerId(PatronCredential credential);
}

class HttpPatronIdServer implements PatronIdServer {
  HttpPatronIdServer({String base = kPatronServer, http.Client? client})
    : _base = base,
      _client = client ?? http.Client();

  final String _base;
  final http.Client _client;

  @override
  Future<String> customerId(PatronCredential c) async {
    final http.Response res;
    try {
      res = await _client
          .post(
            Uri.parse('$_base/patron/id'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'provider': c.provider.name,
              'id_token': c.idToken,
              if (c.nonce != null) 'nonce': c.nonce,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      throw SignInFailure('No connection. Try again when you are online.');
    }
    if (res.statusCode == 200) {
      final id = (jsonDecode(res.body) as Map)['customer_id'];
      if (id is String && id.startsWith('vp_')) return id;
    }
    throw SignInFailure(
      res.statusCode == 401
          ? '${c.provider.label} sign-in could not be checked. Try again.'
          : "Patron can't be set up right now. Try again later.",
    );
  }
}
