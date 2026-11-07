import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

Widget host(Widget child) =>
    MaterialApp(theme: vedaTheme(AppColors.nightfall), home: child);

// Véda Education beyond the notes: search, the A to Z, the saved notes, the
// "Also see" links, the two newer games and the page about where the notes
// come from.
void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LearnSaved.reset();
    quizHostBuilder = null;
  });

  void tall(WidgetTester t, [double h = 1800]) {
    t.view.physicalSize = Size(412, h);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
  }

  group('the data', () {
    test('every link cluster names real notes, and links run both ways', () {
      for (final cluster in kLearnLinks) {
        expect(cluster.length, greaterThanOrEqualTo(2));
        for (final id in cluster) {
          expect(learnEntry(id), isNotNull, reason: id);
        }
      }
      for (final e in kLearnEntries) {
        for (final r in learnRelated(e.id, limit: 100)) {
          expect(r.id, isNot(e.id));
          expect(
            learnRelated(r.id, limit: 100).map((x) => x.id),
            contains(e.id),
            reason: '${e.id} <-> ${r.id}',
          );
        }
      }
      expect(
        learnRelated('prod-sunscreen').map((e) => e.id),
        contains('label-spf'),
      );
      expect(learnRelated('prod-sunscreen').length, lessThanOrEqualTo(4));
    });

    test('search finds a word in a title or in the text, titles first', () {
      expect(learnSearch(''), isEmpty);
      expect(learnSearch('   '), isEmpty);
      expect(learnSearch('retinol').first.id, 'ingredient-retinol');
      expect(learnSearch('RETINOL').first.id, 'ingredient-retinol');
      final pores = learnSearch('pores');
      expect(pores.map((e) => e.id), contains('skin-pores'));
      expect(
        pores.first.title.toLowerCase(),
        contains('pores'),
        reason: 'a title match comes first',
      );
      // every word must be there
      expect(
        learnSearch('pillowcase week').map((e) => e.id),
        contains('sleep-pillowcase'),
      );
      expect(learnSearch('zzzzzz'), isEmpty);
    });

    test('the A to Z is in order, under the right letters', () {
      final g = learnGlossary();
      expect(g.length, greaterThan(40));
      for (final e in g) {
        expect(kGlossaryThemes, contains(e.category));
      }
      final keys = [
        for (final e in g)
          e.title.toLowerCase().replaceFirst(RegExp(r'^[^a-z0-9]+'), ''),
      ];
      final sorted = [...keys]..sort();
      expect(keys, sorted);
      expect(learnGlossaryLetter(learnEntry('ingredient-retinol')!), 'R');
    });

    test('Label Detective and Myth or fact keep to the same rules', () {
      final banned = [
        RegExp(r'you should'),
        RegExp(r'you must'),
        RegExp(r'you need to'),
        RegExp(r'you have to'),
        RegExp(r'(?<!not )\balways\b'),
        RegExp(r'\bnever\b'),
        RegExp(r'\bcure[sd]?\b'),
        RegExp(r'\btreat'),
        RegExp(r'\bheal'),
        RegExp(r'\bprevent'),
        RegExp(r'diagnos'),
        RegExp(r'guarantee'),
        RegExp(r'\bproven\b'),
        RegExp(r'\bfix(es)?\b'),
        RegExp(r'supplement'),
        RegExp(r'\bbrand'),
        RegExp(r'recommend'),
      ];
      void clean(String where, String text) {
        for (final p in banned) {
          expect(
            p.hasMatch(text.toLowerCase()),
            isFalse,
            reason: '${p.pattern} in $where',
          );
        }
      }

      expect(kLabelQuestions.length, greaterThanOrEqualTo(6));
      for (final q in kLabelQuestions) {
        expect(learnEntry(q.noteId), isNotNull, reason: q.noteId);
        expect(q.snippet, isNotNull);
        expect(q.correct, inInclusiveRange(0, q.options.length - 1));
        expect(q.options.toSet().length, q.options.length);
        clean(q.noteId, '${q.prompt} ${q.options.join(' ')} ${q.explanation}');
      }
      expect(kMythCards.length, greaterThanOrEqualTo(12));
      expect(kMythCards.where((c) => c.isFact).length, greaterThanOrEqualTo(4));
      expect(
        kMythCards.where((c) => !c.isFact).length,
        greaterThanOrEqualTo(4),
      );
      for (final c in kMythCards) {
        expect(learnEntry(c.noteId), isNotNull, reason: c.noteId);
        clean(c.noteId, '${c.statement} ${c.explanation}');
      }
    });

    test('the reviewer line is empty until it is true', () {
      expect(
        kLearnReviewedBy == null || kLearnReviewedBy!.trim().isNotEmpty,
        isTrue,
      );
    });
  });

  group('the screens', () {
    testWidgets('search finds notes and opens one', (t) async {
      tall(t);
      await t.pumpWidget(host(const LearnScreen()));
      await t.pump();
      await t.ensureVisible(find.byKey(const Key('learnSearch')));
      await t.tap(find.byKey(const Key('learnSearch')));
      await t.pumpAndSettle();
      await t.enterText(find.byKey(const Key('learnSearchField')), 'pores');
      await t.pump();
      expect(find.byKey(const Key('learn-skin-pores')), findsOneWidget);
      await t.enterText(find.byKey(const Key('learnSearchField')), 'zzzzzz');
      await t.pump();
      expect(find.byKey(const Key('learnSearchEmpty')), findsOneWidget);
    });

    testWidgets('the A to Z lists definitions under their letters', (t) async {
      tall(t, 6000);
      await t.pumpWidget(host(const LearnGlossaryScreen()));
      await t.pump();
      expect(find.byKey(const Key('glossaryLetter-S')), findsOneWidget);
      expect(
        find.byKey(const Key('glossary-ingredient-retinol')),
        findsOneWidget,
      );
      await t.tap(find.byKey(const Key('glossary-ingredient-retinol')));
      await t.pumpAndSettle();
      expect(
        find.byKey(const Key('learn-body-ingredient-retinol')),
        findsOneWidget,
      );
    });

    testWidgets('a note can be kept, and is found again under Saved', (
      t,
    ) async {
      tall(t);
      await t.pumpWidget(
        host(const LearnThemeScreen(category: LearnCategory.sleep)),
      );
      await t.pump();
      await t.tap(find.byKey(const Key('learnSave-sleep-repair')));
      await t.pump();
      expect(LearnSaved.ids.value, {'sleep-repair'});
      // and it is kept on the phone
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('learn_saved'), ['sleep-repair']);
      await t.pumpWidget(host(const LearnSavedScreen()));
      await t.pump();
      expect(find.byKey(const Key('learn-sleep-repair')), findsOneWidget);
      // letting it go empties the page
      await t.tap(find.byKey(const Key('learnSave-sleep-repair')));
      await t.pump();
      expect(find.byKey(const Key('learnSavedEmpty')), findsOneWidget);
    });

    testWidgets('saved notes come back after a restart', (t) async {
      SharedPreferences.setMockInitialValues({
        'learn_saved': ['skin-pores'],
      });
      LearnSaved.reset();
      await LearnSaved.load();
      expect(LearnSaved.ids.value, {'skin-pores'});
    });

    testWidgets('a theme page carries the education-only note', (t) async {
      tall(t);
      await t.pumpWidget(
        host(const LearnThemeScreen(category: LearnCategory.ingredients)),
      );
      await t.pump();
      expect(find.byKey(const Key('learnTopNote')), findsOneWidget);
      expect(
        find.textContaining('does not recommend, promote or sell'),
        findsOneWidget,
      );
    });

    testWidgets('an open note offers notes that go with it', (t) async {
      tall(t);
      await t.pumpWidget(
        host(
          const LearnThemeScreen(
            category: LearnCategory.productTypes,
            openId: 'prod-sunscreen',
          ),
        ),
      );
      await t.pump();
      expect(find.text('Also see'), findsOneWidget);
      expect(find.byKey(const Key('learnRelated-label-spf')), findsOneWidget);
      await t.ensureVisible(find.byKey(const Key('learnRelated-label-spf')));
      await t.tap(find.byKey(const Key('learnRelated-label-spf')));
      await t.pumpAndSettle();
      expect(find.byKey(const Key('learn-body-label-spf')), findsOneWidget);
    });

    testWidgets('the page about the notes says where they come from', (
      t,
    ) async {
      tall(t);
      await t.pumpWidget(host(const LearnAboutScreen()));
      await t.pump();
      expect(find.text('Where these notes come from'), findsOneWidget);
      expect(
        find.textContaining('American Academy of Dermatology'),
        findsOneWidget,
      );
      expect(find.textContaining('not medical advice'), findsWidgets);
      expect(find.byKey(const Key('learnTopNote')), findsOneWidget);
    });

    testWidgets('the front page shows every way in', (t) async {
      tall(t, 4000);
      await t.pumpWidget(host(const LearnScreen()));
      await t.pump();
      for (final k in [
        'learnSearch',
        'learnGlossary',
        'learnSaved',
        'learnQuiz',
        'learnMatch',
        'learnLabels',
        'learnMyth',
        'learnAbout',
      ]) {
        expect(find.byKey(Key(k)), findsOneWidget, reason: k);
      }
    });

    testWidgets('Label Detective shows the words from a pack', (t) async {
      tall(t);
      await t.pumpWidget(
        host(LearnQuizScreen(labels: true, random: math.Random(2), count: 2)),
      );
      await t.pump();
      expect(find.byKey(const Key('quizSnippet')), findsOneWidget);
      expect(find.text('Question 1 of 2'), findsOneWidget);
      final prompt = t.widget<Text>(find.byKey(const Key('quizPrompt'))).data;
      final snippet = t
          .widget<Text>(
            find.descendant(
              of: find.byKey(const Key('quizSnippet')),
              matching: find.byType(Text),
            ),
          )
          .data;
      final q = kLabelQuestions.firstWhere(
        (q) => q.prompt == prompt && q.snippet == snippet,
      );
      await t.tap(
        find.ancestor(
          of: find.text(q.options[q.correct]),
          matching: find.byType(InkWell),
        ),
      );
      await t.pump();
      expect(find.text('Yes, that is it.'), findsOneWidget);
    });

    testWidgets('Myth or fact says which it was, and a round ends warmly', (
      t,
    ) async {
      tall(t);
      await t.pumpWidget(
        host(LearnMythScreen(random: math.Random(5), count: 2)),
      );
      await t.pump();
      for (var i = 0; i < 2; i++) {
        final text = t
            .widget<Text>(find.byKey(const Key('mythStatement')))
            .data;
        final c = kMythCards.firstWhere((c) => c.statement == text);
        await t.tap(find.byKey(Key(c.isFact ? 'factButton' : 'mythButton')));
        await t.pump();
        expect(
          find.textContaining(c.isFact ? 'It is a fact.' : 'It is a myth.'),
          findsOneWidget,
        );
        expect(find.textContaining('Yes, that is it.'), findsOneWidget);
        await t.tap(find.byKey(const Key('mythNext')));
        await t.pump();
      }
      expect(find.byKey(const Key('mythDone')), findsOneWidget);
    });

    testWidgets('a wrong answer in Myth or fact is met kindly', (t) async {
      tall(t);
      await t.pumpWidget(
        host(LearnMythScreen(random: math.Random(5), count: 1)),
      );
      await t.pump();
      final text = t.widget<Text>(find.byKey(const Key('mythStatement'))).data;
      final c = kMythCards.firstWhere((c) => c.statement == text);
      await t.tap(find.byKey(Key(c.isFact ? 'mythButton' : 'factButton')));
      await t.pump();
      expect(find.textContaining('Not quite.'), findsOneWidget);
      expect(find.text(c.explanation), findsOneWidget);
    });
  });
}
