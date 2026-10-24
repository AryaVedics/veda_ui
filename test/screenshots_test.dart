// Renders the real chart cards with sample data into PNGs, so they can be
// looked at without installing anything:
//
//   flutter test test/screenshots_test.dart --update-goldens
//
// The pictures land in test/goldens/. Not a regression test (it only writes
// the files when run with --update-goldens); the sample data is invented.

import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

Future<void> _loadFonts() async {
  Future<void> load(String family, Future<ByteData> bytes) async {
    final l = FontLoader(family)..addFont(bytes);
    await l.load();
  }

  await load(
    'packages/veda_ui/Marcellus',
    rootBundle.load('assets/fonts/Marcellus-Regular.ttf'),
  );
  await load(
    'packages/phosphor_flutter/PhosphorThin',
    rootBundle.load('packages/phosphor_flutter/lib/fonts/Phosphor-Thin.ttf'),
  );
  await load(
    'packages/phosphor_flutter/PhosphorFill',
    rootBundle.load('packages/phosphor_flutter/lib/fonts/Phosphor-Fill.ttf'),
  );
  // Véda's body text is the system sans (Roboto on Android). Flutter's test
  // engine draws every font it has not been given as solid blocks ("Ahem"), so
  // give it all the real Roboto weights in ONE loader.
  const root = 'C:/src/flutter/bin/cache/artifacts/material_fonts/';
  final files = [
    for (final n in ['thin', 'light', 'regular', 'medium', 'bold', 'black'])
      File(
        '$root'
        'roboto-$n.ttf',
      ),
    File('${root}roboto-italic.ttf'),
  ].where((f) => f.existsSync()).toList();
  final l = FontLoader('Roboto');
  for (final f in files) {
    l.addFont(Future.value(ByteData.sublistView(f.readAsBytesSync())));
  }
  await l.load();
}

/// Forty days of invented readings with a gentle pattern.
VedaLinkData _readings() {
  final rnd = math.Random(7);
  final out = <VedaReading>[];
  for (var i = 0; i < 44; i++) {
    final day = DateTime(2026, 10, 22).subtract(Duration(days: 43 - i));
    double v(double base, double spread) =>
        (base + (rnd.nextDouble() - .5) * spread).clamp(40, 100);
    final good = (i % 9) / 9.0; // a slow wave, so groups differ a little
    out.add(
      VedaReading(
        takenAt: day.add(const Duration(hours: 9)),
        slot: 'morning',
        skinScore: v(82 + good * 8, 4),
        scores: {
          'redness': v(84 + good * 6, 6),
          'texture': v(80 + good * 7, 6),
          'pores': v(66 + good * 8, 8),
          'spots': v(90 + good * 4, 5),
          'acne': v(88 + good * 5, 5),
          'evenness': v(91 + good * 3, 4),
          'wrinkles': v(86 + good * 3, 4),
        },
      ),
    );
  }
  return VedaLinkData(readings: out);
}

Widget _app(AppColors colors, VedaBrand brand, List<Widget> children) =>
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: vedaTheme(colors),
      builder: (context, child) => VedaBrandScope(brand: brand, child: child!),
      home: Scaffold(
        body: CanvasBackdrop(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              children: children,
            ),
          ),
        ),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(_loadFonts);

  Future<void> shoot(
    WidgetTester t,
    String name,
    AppColors colors,
    VedaBrand brand,
    List<Widget> children,
    MetricStyle style,
  ) async {
    SharedPreferences.setMockInitialValues({'metric_chart_style': style.name});
    t.view.physicalSize = const Size(840, 1700);
    t.view.devicePixelRatio = 2;
    addTearDown(t.view.reset);
    await t.pumpWidget(_app(colors, brand, children));
    // Images decode off the test clock: wait for the brand mark explicitly.
    await t.runAsync(() async {
      await precacheImage(
        AssetImage(brand.markAsset),
        t.element(find.byType(Scaffold)),
      );
    });
    await t.pumpAndSettle(const Duration(seconds: 2));
    await expectLater(
      find.byType(Scaffold),
      matchesGoldenFile('goldens/$name.png'),
    );
  }

  const sunBrand = VedaBrand(
    appName: 'Véda Sun',
    word: 'SUN',
    markAsset: 'assets/branding/sun_mark.png',
  );
  const lifeBrand = VedaBrand(
    appName: 'Véda Lifestyle',
    word: 'LIFESTYLE',
    markAsset: 'assets/branding/lifestyle_mark.png',
  );
  const cycleBrand = VedaBrand(
    appName: 'Véda Cycle',
    word: 'CYCLE',
    markAsset: 'assets/branding/cycle_mark.png',
  );

  // Sample entries for each app: which group each day falls in.
  String? sleepOf(DateTime d) => ['Under 6h', '6-7h', '7-8h', '8h+'][d.day % 4];
  String? phaseOf(DateTime d) => [
    'Period',
    'Follicular phase',
    'Around ovulation',
    'Luteal phase',
  ][(d.day ~/ 3) % 4];
  String? uvOf(DateTime d) =>
      ['Low', 'Moderate', 'High', 'Very high'][(d.day ~/ 2) % 4];

  for (final style in MetricStyle.values) {
    testWidgets('lifestyle ${style.name}', (t) async {
      await shoot(t, 'lifestyle_${style.name}', AppColors.nightfall, lifeBrand, [
        const Text(
          'Days',
          style: TextStyle(
            fontSize: 23,
            fontFamily: kDisplayFont,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        GroupMetricsCard(
          hud: true,
          title: 'Your skin by sleep',
          subtitle: 'Your Véda measurements on days you slept...',
          caveat: 'Days with both a Véda reading and a check-in.',
          groups: groupMetrics(
            readings: _readings(),
            groups: kSleepSample,
            groupOf: sleepOf,
          ),
        ),
      ], style);
    });

    testWidgets('cycle ${style.name}', (t) async {
      await shoot(t, 'cycle_${style.name}', AppColors.wine, cycleBrand, [
        const Text(
          'Today',
          style: TextStyle(
            fontSize: 23,
            fontFamily: kDisplayFont,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        GroupMetricsCard(
          title: 'Your skin by phase',
          subtitle: 'Your Véda measurements in each part of your cycle',
          caveat: 'Phases are estimates.',
          groups: groupMetrics(
            readings: _readings(),
            groups: kPhaseSample,
            groupOf: phaseOf,
          ),
        ),
      ], style);
    });
  }

  testWidgets('sun trend and UV bands', (t) async {
    final rnd = math.Random(3);
    final readings = _readings();
    final days = [
      for (var i = 29; i >= 0; i--)
        () {
          final d = DateTime(2026, 10, 22).subtract(Duration(days: i));
          final uv = (3 + 5 * math.sin(i / 4.5) + rnd.nextDouble() * 2)
              .clamp(1, 10)
              .toDouble();
          return TrendDay(
            d,
            score: readings.skinScoreOn(d),
            bar: uv,
            marked: uv > 4.5 && i % 3 != 0,
          );
        }(),
    ];
    await shoot(t, 'sun_trend_and_bands', AppColors.umber, sunBrand, [
      const Text(
        'Log',
        style: TextStyle(
          fontSize: 23,
          fontFamily: kDisplayFont,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 14),
      ChartCard(
        title: 'Skin Score and UV',
        subtitle: 'Last 30 days: your Véda readings beside your sun days',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TrendChart(
              days: days,
              barLabel: 'UV peak',
              markLabel: 'Sunscreen on',
            ),
            const ChartCaveat('Clear-sky UV from MET Norway.'),
          ],
        ),
      ),
      const SizedBox(height: 14),
      GroupMetricsCard(
        title: 'Your skin by UV',
        subtitle: 'Your Véda measurements on days the UV peak was...',
        caveat: 'Days with both a Véda reading and a UV lookup.',
        groups: groupMetrics(
          readings: readings,
          groups: const ['Low', 'Moderate', 'High', 'Very high'],
          groupOf: uvOf,
        ),
      ),
    ], MetricStyle.petals);
  });

  for (final e in {
    'sun': (AppColors.umber, sunBrand),
    'lifestyle': (AppColors.nightfall, lifeBrand),
    'cycle': (AppColors.wine, cycleBrand),
  }.entries) {
    testWidgets('footer ${e.key}', (t) async {
      await shoot(t, 'footer_${e.key}', e.value.$1, e.value.$2, [
        const SizedBox(height: 160),
        const BrandFooter(),
      ], MetricStyle.petals);
    });
  }
}

const kSleepSample = ['Under 6h', '6-7h', '7-8h', '8h+'];
const kPhaseSample = [
  'Period',
  'Follicular phase',
  'Around ovulation',
  'Luteal phase',
];
