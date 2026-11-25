import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_patron/veda_patron.dart';
import 'package:veda_ui/veda_ui.dart';

/// A store that sells for pretend: memberships live in [members], by
/// customer id, the way RevenueCat keeps them.
class FakeStore implements PatronStore {
  FakeStore({this.available = true, this.plusOffer = false});

  @override
  final bool available;

  /// Sells a Patron Plus app's two plans (Plus and the app's own) instead of
  /// Patron's monthly and annual.
  final bool plusOffer;

  final members = <String>{};
  String? current;
  final logIns = <String>[];
  int buys = 0, restores = 0, logOuts = 0;

  PatronStatus get _status => PatronStatus(active: members.contains(current));

  @override
  Future<void> start(void Function(PatronStatus) onChange) async =>
      onChange(PatronStatus.none);

  @override
  Future<PatronStatus> logIn(String appUserId) async {
    logIns.add(appUserId);
    current = appUserId;
    return _status;
  }

  @override
  Future<void> logOut() async {
    logOuts++;
    current = null;
  }

  @override
  Future<List<PatronPackage>> packages() async => plusOffer
      ? const [
          PatronPackage(
            id: kSinglePackageId,
            isAnnual: false,
            priceString: r'$4.99',
            price: 4.99,
          ),
          PatronPackage(
            id: kPlusPackageId,
            isAnnual: false,
            priceString: r'$9.99',
            price: 9.99,
          ),
        ]
      : const [
          PatronPackage(
            id: 'monthly',
            isAnnual: false,
            priceString: r'$4.99',
            price: 4.99,
          ),
          PatronPackage(
            id: 'annual',
            isAnnual: true,
            priceString: r'$44.99',
            price: 44.99,
          ),
        ];

  @override
  Future<PatronStatus> buy(PatronPackage package) async {
    buys++;
    if (current != null) members.add(current!);
    return _status;
  }

  @override
  Future<PatronStatus> restore() async {
    restores++;
    return _status;
  }
}

class FakeSignIn implements PatronSignIn {
  FakeSignIn(this.account, {this.list = const [PatronProvider.google]});
  String? account; // null: the person backs out
  final List<PatronProvider> list;
  int signOuts = 0;

  @override
  List<PatronProvider> get providers => list;

  @override
  Future<PatronCredential> credential(PatronProvider provider) async {
    if (account == null) throw SignInCancelled();
    return PatronCredential(provider, 'token-for-$account');
  }

  @override
  Future<void> signOut(PatronProvider provider) async => signOuts++;
}

/// The server, for pretend: the id is a fixed coding of provider and account,
/// as the real one is (with its secret).
String fakeId(PatronProvider p, String account) => 'vp_${p.name}_$account';

class FakeServer implements PatronIdServer {
  int calls = 0;
  @override
  Future<String> customerId(PatronCredential c) async {
    calls++;
    return fakeId(c.provider, c.idToken.replaceFirst('token-for-', ''));
  }
}

void main() {
  plusEntitlementTests();
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  PatronService service(
    FakeStore store,
    FakeSignIn signIn, {
    bool linked = false,
    List<bool>? published,
    String app = 'lifestyle',
  }) => PatronService(
    appKey: app,
    store: store,
    signIn: signIn,
    server: FakeServer(),
    readLink: () async => linked,
    publish: ({required bool active, DateTime? until}) async =>
        published?.add(active),
  );

  group('asking the server', () {
    test('sends the token and takes the id it answers', () async {
      late Map body;
      final server = HttpPatronIdServer(
        base: 'https://example.test',
        client: MockClient((r) async {
          body = jsonDecode(r.body) as Map;
          return http.Response('{"customer_id": "vp_abc"}', 200);
        }),
      );
      final id = await server.customerId(
        const PatronCredential(PatronProvider.apple, 'tok', nonce: 'raw'),
      );
      expect(id, 'vp_abc');
      expect(body, {'provider': 'apple', 'id_token': 'tok', 'nonce': 'raw'});
    });

    test('a refused sign-in or a server problem is a plain message', () async {
      Future<String> with_(int code) => HttpPatronIdServer(
        base: 'https://example.test',
        client: MockClient((_) async => http.Response('{}', code)),
      ).customerId(const PatronCredential(PatronProvider.google, 'tok'));
      expect(
        () => with_(401),
        throwsA(
          isA<SignInFailure>().having(
            (e) => e.message,
            'message',
            contains('could not be checked'),
          ),
        ),
      );
      expect(() => with_(503), throwsA(isA<SignInFailure>()));
    });

    test('no connection says so', () async {
      final server = HttpPatronIdServer(
        base: 'https://example.test',
        client: MockClient((_) async => throw Exception('offline')),
      );
      expect(
        () => server.customerId(
          const PatronCredential(PatronProvider.google, 'tok'),
        ),
        throwsA(
          isA<SignInFailure>().having(
            (e) => e.message,
            'message',
            contains('No connection'),
          ),
        ),
      );
    });
  });

  group('the service', () {
    test('with no store key nothing is sold and nobody is a Patron', () async {
      final s = service(FakeStore(available: false), FakeSignIn('acct'));
      await s.ready();
      expect(s.available, isFalse);
      expect(s.isPatron.value, isFalse);
    });

    test('buying needs a sign-in first', () async {
      final s = service(FakeStore(), FakeSignIn('acct'));
      await s.ready();
      final plans = await s.packages();
      expect(() => s.buy(plans.first), throwsStateError);
    });

    test(
      'a purchase in one app is found from another with the same account',
      () async {
        final store = FakeStore(); // one RevenueCat project behind both apps
        final published = <bool>[];
        final lifestyle = service(
          store,
          FakeSignIn('acct-1'),
          published: published,
        );
        await lifestyle.ready();
        expect(await lifestyle.signIn(PatronProvider.google), isFalse);
        expect(await lifestyle.buy((await lifestyle.packages()).last), isTrue);
        expect(lifestyle.isPatron.value, isTrue);
        expect(published.last, isTrue, reason: 'told to the other apps');

        // each app keeps its own preferences: Sun starts with none
        SharedPreferences.resetStatic();
        SharedPreferences.setMockInitialValues({});
        final sun = service(store, FakeSignIn('acct-1'), app: 'sun');
        await sun.ready();
        expect(sun.isPatron.value, isFalse, reason: 'not signed in there yet');
        expect(await sun.signIn(PatronProvider.google), isTrue);
        expect(sun.isPatron.value, isTrue);

        SharedPreferences.resetStatic();
        SharedPreferences.setMockInitialValues({});
        final stranger = service(store, FakeSignIn('acct-2'), app: 'routine');
        await stranger.ready();
        expect(await stranger.signIn(PatronProvider.google), isFalse);
      },
    );

    test(
      'the sign-in is remembered: the next launch finds the membership',
      () async {
        final store = FakeStore();
        final first = service(store, FakeSignIn('acct-1'));
        await first.ready();
        await first.signIn(PatronProvider.google);
        await first.buy((await first.packages()).first);

        final next = service(store, FakeSignIn(null)); // no prompt this time
        await next.ready();
        expect(next.identity.value?.provider, PatronProvider.google);
        expect(next.isPatron.value, isTrue);
      },
    );

    test('a membership from another app on this phone counts too', () async {
      final s = service(FakeStore(), FakeSignIn('acct'), linked: true);
      await s.ready();
      expect(s.isPatron.value, isTrue);
      expect(s.identity.value, isNull, reason: 'no sign-in needed for that');
    });

    test('signing out forgets the sign-in, not the membership', () async {
      final store = FakeStore();
      final signIn = FakeSignIn('acct-1');
      final s = service(store, signIn);
      await s.ready();
      await s.signIn(PatronProvider.google);
      await s.buy((await s.packages()).first);
      await s.signOut();
      expect(s.identity.value, isNull);
      expect(s.isPatron.value, isFalse);
      expect(store.logOuts, 1);
      expect(signIn.signOuts, 1);
      expect(
        await s.signIn(PatronProvider.google),
        isTrue,
        reason: 'still there',
      );
    });
  });

  group('the screen', () {
    Future<PatronService> open(
      WidgetTester t,
      FakeStore store,
      FakeSignIn signIn,
    ) async {
      t.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      t.view.physicalSize = const Size(420, 1600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final s = service(store, signIn);
      await t.runAsync(s.ready);
      await t.pumpWidget(
        MaterialApp(
          theme: vedaTheme(AppColors.nightfall),
          home: PatronScreen(service: s),
        ),
      );
      await t.pumpAndSettle();
      return s;
    }

    testWidgets('a Plus app offers Plus first, then its own plan', (t) async {
      t.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
      t.view.physicalSize = const Size(420, 1800);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      final store = FakeStore(plusOffer: true);
      final s = service(store, FakeSignIn('acct-1'));
      await t.runAsync(s.ready);
      await t.pumpWidget(
        MaterialApp(
          theme: vedaTheme(AppColors.nightfall),
          home: PatronScreen(
            service: s,
            plus: const PlusPitch(appName: 'Véda Allergy'),
          ),
        ),
      );
      await t.pumpAndSettle();
      expect(find.text('Patron Plus'), findsOneWidget);
      expect(find.text('Best value'), findsOneWidget);
      expect(find.text('Véda Allergy only'), findsOneWidget);
      expect(find.textContaining('included with Plus'), findsOneWidget);
      expect(find.text('Every Véda app'), findsNothing);
      // Plus is the first plan and starts selected, so the buy button says so
      expect(find.textContaining(r'$9.99 / month'), findsWidgets);
      final plus = t.getTopLeft(
        find.byKey(const ValueKey('plan-$kPlusPackageId')),
      );
      final single = t.getTopLeft(
        find.byKey(const ValueKey('plan-$kSinglePackageId')),
      );
      expect(plus.dy, lessThan(single.dy));
    });

    testWidgets('says why it asks for a sign-in, and buys after it', (t) async {
      final store = FakeStore();
      final s = await open(t, store, FakeSignIn('acct-1'));
      expect(find.byKey(const Key('patronSignInNote')), findsOneWidget);
      expect(find.text('Every Véda app'), findsOneWidget);
      await t.tap(find.byKey(const Key('patronBuy')));
      await t.pumpAndSettle();
      expect(store.buys, 1);
      expect(s.isPatron.value, isTrue);
      expect(find.byKey(const Key('patronMember')), findsOneWidget);
      expect(find.textContaining('Signed in with Google'), findsOneWidget);
    });

    testWidgets('an account that is already a Patron is not charged again', (
      t,
    ) async {
      final store = FakeStore()
        ..members.add(fakeId(PatronProvider.google, 'acct-1'));
      await open(t, store, FakeSignIn('acct-1'));
      await t.tap(find.byKey(const Key('patronBuy')));
      await t.pumpAndSettle();
      expect(store.buys, 0);
      expect(find.byKey(const Key('patronMember')), findsOneWidget);
    });

    testWidgets('backing out of the sign-in buys nothing', (t) async {
      final store = FakeStore();
      await open(t, store, FakeSignIn(null));
      await t.tap(find.byKey(const Key('patronBuy')));
      await t.pumpAndSettle();
      expect(store.buys, 0);
      expect(find.byKey(const Key('patronMessage')), findsNothing);
    });

    testWidgets('"I already have Patron" says so when there is none', (
      t,
    ) async {
      final store = FakeStore();
      await open(t, store, FakeSignIn('acct-9'));
      await t.tap(find.byKey(const Key('patronRestore')));
      await t.pumpAndSettle();
      expect(store.restores, 1);
      expect(
        find.text('No membership found for this Google account.'),
        findsOneWidget,
      );
    });

    testWidgets('on iPhone both sign-ins are offered', (t) async {
      final store = FakeStore();
      await open(
        t,
        store,
        FakeSignIn(
          'acct-1',
          list: const [PatronProvider.google, PatronProvider.apple],
        ),
      );
      await t.tap(find.byKey(const Key('patronBuy')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('patronSignIn-google')), findsOneWidget);
      expect(find.byKey(const Key('patronSignIn-apple')), findsOneWidget);
      await t.tap(find.byKey(const Key('patronSignIn-apple')));
      await t.pumpAndSettle();
      expect(store.buys, 1);
      expect(find.textContaining('Signed in with Apple'), findsOneWidget);
    });
  });
}

// Patron Plus: which entitlements unlock a Plus app.
void plusEntitlementTests() {
  test('a Plus app is unlocked by Plus or its own plan, never by Patron', () {
    final e = plusEntitlementsFor('allergy');
    expect(e, {'veda_plus', 'veda_allergy'});
    expect(e.contains(kPatronEntitlement), isFalse);
  });
}
