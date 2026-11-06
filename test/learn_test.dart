import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

// Learn: general notes about everyday habits and good-to-know skin facts. The
// content rules matter as much as the screens: the app measures skin and does
// not advise on it, so nothing here may read as a prescription, name an
// ingredient or a supplement, or cite a source we cannot stand behind.
void main() {
  group('the content', () {
    test('every note has its own id, a title and a body, in a real theme', () {
      final ids = kLearnEntries.map((e) => e.id).toList();
      expect(ids.toSet().length, ids.length, reason: 'ids are never reused');
      for (final e in kLearnEntries) {
        expect(e.title.trim(), isNotEmpty, reason: e.id);
        expect(e.body.trim().length, greaterThan(40), reason: e.id);
        expect(e.title.length, lessThanOrEqualTo(70), reason: e.id);
      }
      for (final c in LearnCategory.values) {
        expect(
          learnEntriesIn(c).length,
          greaterThanOrEqualTo(3),
          reason: 'a theme with fewer than three notes is not worth a heading',
        );
      }
    });

    test('nothing reads as a prescription, a cure or a claim', () {
      final banned = [
        RegExp(r'you should'),
        RegExp(r'you must'),
        RegExp(r'you need to'),
        RegExp(r'you have to'),
        // absolutes ("always use", "never go out"), but not "does not always"
        RegExp(r'(?<!not )always'),
        RegExp(r'never'),
        RegExp(r'cure[sd]?'),
        RegExp(r'treat'),
        RegExp(r'heal'),
        RegExp(r'prevent'),
        RegExp(r'diagnos'),
        RegExp(r'guarantee'),
        RegExp(r'proven'),
        RegExp(r'fix(es)?'),
      ];
      for (final e in kLearnEntries) {
        final text = '${e.title} ${e.body}'.toLowerCase();
        for (final pattern in banned) {
          expect(
            pattern.hasMatch(text),
            isFalse,
            reason:
                '${pattern.pattern} in ${e.id}: notes describe, they do '
                'not instruct',
          );
        }
      }
    });

    test('supplements, doses and products stay out of every note', () {
      // Ingredient names are allowed in the skin-care definitions only. The
      // rules below apply everywhere.
      const never = [
        'supplement',
        'capsule',
        'tablet',
        'gumm',
        'dose',
        ' mg',
        'brand',
        'buy ',
        'shop',
        'recommend',
      ];
      for (final e in kLearnEntries) {
        final text = '${e.title} ${e.body}'.toLowerCase();
        for (final word in never) {
          expect(text.contains(word), isFalse, reason: '"$word" in ${e.id}');
        }
      }
    });

    test('ingredient names appear only in the skin-care definitions', () {
      final names = [
        'retinol',
        'retinoid',
        'niacinamide',
        'vitamin c',
        'vitamin a',
      ];
      for (final e in kLearnEntries) {
        if (e.category == LearnCategory.ingredients) continue;
        final text = '${e.title} ${e.body}'.toLowerCase();
        for (final n in names) {
          expect(text.contains(n), isFalse, reason: '"$n" in ${e.id}');
        }
      }
    });

    test('only sources we can stand behind are named', () {
      const allowed = {
        'American Academy of Dermatology Association',
        'World Health Organization, Global Solar UV Index',
      };
      for (final e in kLearnEntries) {
        for (final s in e.sources) {
          expect(allowed, contains(s), reason: e.id);
        }
      }
    });

    test('a note can be found by its id', () {
      expect(learnEntry('sun-index')?.category, LearnCategory.sun);
      expect(learnEntry('no-such-note'), isNull);
    });
  });

  group('the Learn page', () {
    Widget host(Widget child) => MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        extensions: const [AppColors.nightfall],
      ),
      home: child,
    );

    Future<void> phone(WidgetTester t) async {
      t.view.physicalSize = const Size(412, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
    }

    testWidgets('lists every theme, with each note closed to its title', (
      t,
    ) async {
      await phone(t);
      await t.pumpWidget(host(const LearnScreen()));
      await t.pump();
      expect(find.text('Learn'), findsOneWidget);
      for (final c in LearnCategory.values) {
        await t.scrollUntilVisible(
          find.text(c.title),
          300,
          scrollable: find.byType(Scrollable).first,
        );
        expect(find.text(c.title), findsOneWidget);
      }
      // closed: no note's body is on the page yet
      expect(find.byKey(const Key('learn-body-sleep-repair')), findsNothing);
      await t.scrollUntilVisible(
        find.textContaining('not medical advice'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.textContaining('not medical advice'), findsOneWidget);
    });

    testWidgets('a note opens on a tap and closes on another', (t) async {
      await phone(t);
      await t.pumpWidget(host(const LearnScreen()));
      await t.pump();
      final tile = find.byKey(const Key('learn-sleep-repair'));
      await t.ensureVisible(tile);
      await t.tap(tile);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('learn-body-sleep-repair')), findsOneWidget);
      await t.tap(tile);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('learn-body-sleep-repair')), findsNothing);
    });

    testWidgets('a note with a source shows it, one without shows none', (
      t,
    ) async {
      await phone(t);
      await t.pumpWidget(host(const LearnScreen(openId: 'sun-index')));
      await t.pumpAndSettle();
      final withSource = find.byKey(const Key('learn-body-sun-index'));
      await t.ensureVisible(withSource);
      expect(withSource, findsOneWidget, reason: 'openId opens it');
      expect(
        find.textContaining('Source: World Health Organization'),
        findsOneWidget,
      );

      final plain = find.byKey(const Key('learn-sleep-repair'));
      await t.ensureVisible(plain);
      await t.tap(plain);
      await t.pumpAndSettle();
      expect(
        find.textContaining('Source:'),
        findsOneWidget,
        reason: 'only the note that names one shows it',
      );
    });
  });
}
