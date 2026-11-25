import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

const _brand = VedaBrand(
  appName: 'Véda Lifestyle',
  word: 'LIFESTYLE',
  markAsset: 'assets/branding/lifestyle_mark.png',
  ringTrack: Color(0xFF2B3B6B),
);

Widget _app(Widget child) => MaterialApp(
  theme: vedaTheme(AppColors.nightfall),
  builder: (context, c) => VedaBrandScope(brand: _brand, child: c!),
  home: Scaffold(body: child),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> still(WidgetTester t) async {
    t.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(t.platformDispatcher.clearAccessibilityFeaturesTestValue);
    t.view.physicalSize = const Size(420, 1800);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  testWidgets('without Véda the tab invites, with a ghost chart and a way in', (
    t,
  ) async {
    await still(t);
    SharedPreferences.setMockInitialValues({});
    final link = VedaLinkStore(file: MemoryJsonFile());
    await link.load();
    await t.pumpWidget(
      _app(SkinTabScreen(link: link, bridge: LinkBridge(LinkApp.lifestyle))),
    );
    await t.pump();
    expect(find.text('Skin'), findsOneWidget);
    expect(find.text('See your skin here too'), findsOneWidget);
    expect(find.text('Get Véda'), findsOneWidget);
  });

  testWidgets(
    'with readings it shows the score, the week change and its own cards',
    (t) async {
      await still(t);
      SharedPreferences.setMockInitialValues({});
      final now = DateTime.now();
      DateTime ago(int d) => DateTime(now.year, now.month, now.day - d, 9);
      final link = VedaLinkStore(file: MemoryJsonFile());
      await link.load();
      await link.takeLive({
        'readings': [
          for (var i = 0; i < 14; i++)
            VedaReading(
              takenAt: ago(i),
              skinScore: i < 7 ? 84 : 80,
              scores: const {
                'redness': 80,
                'texture': 82,
                'pores': 70,
                'spots': 90,
              },
            ).toJson(),
        ],
      });
      await t.pumpWidget(
        _app(
          SkinTabScreen(
            link: link,
            bridge: LinkBridge(LinkApp.lifestyle),
            cards: const [Text('an app card')],
          ),
        ),
      );
      await t.pump();
      // The ring counts up to the score, as it does on Véda's Today tab.
      await t.pump(const Duration(seconds: 2));
      expect(find.text('84'), findsOneWidget);
      expect(find.byType(ScoreRing), findsOneWidget);
      expect(find.text('Up 4 on the week before'), findsOneWidget);
      expect(find.text('an app card'), findsOneWidget);
      expect(find.text('Get Véda'), findsNothing);
      // The app's own charts sit straight under the score ring, above the
      // metric rings and the 30-day trend.
      expect(
        t.getTopLeft(find.text('an app card')).dy,
        lessThan(t.getTopLeft(find.text('Skin Score, last 30 days')).dy),
      );
    },
  );

  testWidgets(
    'an app can leave out the 30-day chart and add cards after the latest ones',
    (t) async {
      await still(t);
      SharedPreferences.setMockInitialValues({});
      final now = DateTime.now();
      DateTime ago(int d) => DateTime(now.year, now.month, now.day - d, 9);
      final link = VedaLinkStore(file: MemoryJsonFile());
      await link.load();
      await link.takeLive({
        'readings': [
          for (var i = 0; i < 10; i++)
            VedaReading(
              takenAt: ago(i),
              skinScore: 80,
              scores: const {'redness': 80, 'texture': 82},
            ).toJson(),
        ],
      });
      await t.pumpWidget(
        _app(
          SkinTabScreen(
            link: link,
            bridge: LinkBridge(LinkApp.lifestyle),
            showTrend: false,
            cards: const [Text('before the latest')],
            more: const [Text('after the latest')],
          ),
        ),
      );
      await t.pump();
      await t.pump(const Duration(seconds: 2));
      expect(find.text('Skin Score, last 30 days'), findsNothing);
      final before = t.getTopLeft(find.text('before the latest')).dy;
      final latest = t.getTopLeft(find.text('Your latest measurements')).dy;
      final after = t.getTopLeft(find.text('after the latest')).dy;
      expect(before, lessThan(latest));
      expect(latest, lessThan(after));
    },
  );

  testWidgets('turning the tab off asks once, and Keep it keeps it', (t) async {
    await still(t);
    SharedPreferences.setMockInitialValues({});
    SkinTabPref.instance.shown.value = true;
    await t.pumpWidget(
      _app(const SkinTabSection(loseOnOff: 'your skin charts')),
    );
    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    expect(find.text('Turn off the Skin tab?'), findsOneWidget);
    await t.tap(find.text('Keep it'));
    await t.pumpAndSettle();
    expect(SkinTabPref.instance.shown.value, isTrue);

    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    await t.tap(find.text('Turn off'));
    await t.pumpAndSettle();
    expect(SkinTabPref.instance.shown.value, isFalse);
    // Turning it back on needs no question.
    await t.tap(find.byType(Switch));
    await t.pumpAndSettle();
    expect(SkinTabPref.instance.shown.value, isTrue);
  });

  group('the Patron Plus lock', () {
    Future<VedaLinkStore> emptyLink() async {
      SharedPreferences.setMockInitialValues({});
      final link = VedaLinkStore(file: MemoryJsonFile());
      await link.load();
      return link;
    }

    testWidgets('a non-member sees the lock, and can get Plus', (t) async {
      await still(t);
      final link = await emptyLink();
      var asked = 0;
      await t.pumpWidget(
        _app(
          SkinTabScreen(
            link: link,
            bridge: LinkBridge(LinkApp.sleep),
            lock: SkinTabLock(
              unlocked: ValueNotifier(false),
              ready: Future.value(),
              onGetPlus: () => asked++,
            ),
          ),
        ),
      );
      await t.pump();
      await t.pump();
      expect(
        find.text('Your skin, beside everything you track'),
        findsOneWidget,
      );
      expect(find.textContaining('included'), findsOneWidget);
      expect(find.text('Get Véda'), findsOneWidget);
      // not the open invitation a member sees
      expect(find.text('See your skin here too'), findsNothing);
      await t.tap(find.byKey(const Key('skinGetPlus')));
      expect(asked, 1);
    });

    testWidgets('a non-member sees none of Véda\'s results behind the lock', (
      t,
    ) async {
      await still(t);
      final link = await emptyLink();
      await link.takeLive({
        'readings': [
          VedaReading(
            takenAt: DateTime.now(),
            skinScore: 84,
            scores: const {'redness': 80, 'texture': 82},
          ).toJson(),
        ],
      });
      await t.pumpWidget(
        _app(
          SkinTabScreen(
            link: link,
            bridge: LinkBridge(LinkApp.sleep),
            cards: const [Text('an app card')],
            lock: SkinTabLock(
              unlocked: ValueNotifier(false),
              ready: Future.value(),
              onGetPlus: () {},
            ),
          ),
        ),
      );
      await t.pump();
      await t.pump();
      expect(
        find.text('Your skin, beside everything you track'),
        findsOneWidget,
      );
      expect(find.text('an app card'), findsNothing);
      expect(find.text('Skin Score, last 30 days'), findsNothing);
    });

    testWidgets('a member sees the tab, told it is included with Plus', (
      t,
    ) async {
      await still(t);
      final link = await emptyLink();
      await t.pumpWidget(
        _app(
          SkinTabScreen(
            link: link,
            bridge: LinkBridge(LinkApp.sleep),
            lock: SkinTabLock(
              unlocked: ValueNotifier(true),
              ready: Future.value(),
              onGetPlus: () {},
            ),
          ),
        ),
      );
      await t.pump();
      await t.pump();
      expect(find.text('See your skin here too'), findsOneWidget);
      expect(
        find.textContaining('included with your Plus membership'),
        findsOneWidget,
      );
      expect(find.byKey(const Key('skinGetPlus')), findsNothing);
    });

    testWidgets('nothing flashes up before the membership check ends', (
      t,
    ) async {
      await still(t);
      final link = await emptyLink();
      final ready = Completer<void>();
      final unlocked = ValueNotifier(false);
      await t.pumpWidget(
        _app(
          SkinTabScreen(
            link: link,
            bridge: LinkBridge(LinkApp.sleep),
            lock: SkinTabLock(
              unlocked: unlocked,
              ready: ready.future,
              onGetPlus: () {},
            ),
          ),
        ),
      );
      await t.pump();
      expect(find.byKey(const Key('skinGetPlus')), findsNothing);
      expect(find.text('See your skin here too'), findsNothing);
      // a member: the check ends with Plus found, and the tab opens
      unlocked.value = true;
      ready.complete();
      await t.pump();
      await t.pump();
      expect(find.text('See your skin here too'), findsOneWidget);
      expect(find.byKey(const Key('skinGetPlus')), findsNothing);
    });

    testWidgets('buying Plus opens the tab at once', (t) async {
      await still(t);
      final link = await emptyLink();
      final unlocked = ValueNotifier(false);
      await t.pumpWidget(
        _app(
          SkinTabScreen(
            link: link,
            bridge: LinkBridge(LinkApp.sleep),
            lock: SkinTabLock(
              unlocked: unlocked,
              ready: Future.value(),
              onGetPlus: () {},
            ),
          ),
        ),
      );
      await t.pump();
      await t.pump();
      expect(find.byKey(const Key('skinGetPlus')), findsOneWidget);
      unlocked.value = true;
      await t.pump();
      expect(find.byKey(const Key('skinGetPlus')), findsNothing);
      expect(find.text('See your skin here too'), findsOneWidget);
    });
  });
}
