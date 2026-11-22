import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'off by default, on by default when the app asks, and remembered',
    () async {
      final off = VedafolkPref();
      await off.load();
      expect(off.on.value, isFalse);
      final on = VedafolkPref(defaultOn: true, prefKey: 'garden_friends');
      await on.load();
      expect(on.on.value, isTrue);
      await on.set(false);
      final again = VedafolkPref(defaultOn: true, prefKey: 'garden_friends');
      await again.load();
      expect(again.on.value, isFalse); // the person's choice beats the default
    },
  );

  test('a visit rises, waits and sinks', () {
    final f = kForestFriends.first;
    expect(VedafolkVisit(f, 1, 0).rise, 0);
    expect(VedafolkVisit(f, 1, 0.5).rise, 1);
    expect(VedafolkVisit(f, 1, 1).rise, closeTo(0, 1e-9));
    expect(VedafolkVisit(f, 1, 0.1).rise, inExclusiveRange(0, 1));
  });

  testWidgets('nobody visits while the friends are off', (t) async {
    final pref = VedafolkPref();
    VedafolkVisit? seen;
    await t.pumpWidget(
      MaterialApp(
        home: VedafolkVisits(
          pref: pref,
          firstAfter: const Duration(milliseconds: 10),
          builder: (_, v) {
            seen = v ?? seen;
            return const SizedBox();
          },
        ),
      ),
    );
    await t.pump(const Duration(seconds: 2));
    expect(seen, isNull);
    await t.pumpWidget(const SizedBox());
  });

  testWidgets('a visit comes when they are on, and goes', (t) async {
    final pref = VedafolkPref(defaultOn: true);
    final seen = <double>[];
    await t.pumpWidget(
      MaterialApp(
        home: VedafolkVisits(
          pref: pref,
          firstAfter: const Duration(milliseconds: 10),
          every: const Duration(hours: 1),
          stays: const Duration(seconds: 2),
          builder: (_, v) {
            if (v != null) seen.add(v.rise);
            return const SizedBox();
          },
        ),
      ),
    );
    for (var i = 0; i < 30; i++) {
      await t.pump(const Duration(milliseconds: 100));
    }
    expect(seen.any((r) => r > 0.99), isTrue);
    await t.pumpWidget(const SizedBox());
  });
}
