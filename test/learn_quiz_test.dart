import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

Widget host(Widget child) =>
    MaterialApp(theme: vedaTheme(AppColors.nightfall), home: child);

// Véda Education's practice games. The content rules matter as much as the
// screens: the games are gentle (no score, no timer, no streak), and every
// question keeps the same rules as the notes it comes from.
void main() {
  group('the questions', () {
    test('every question comes from a real note and has one right answer', () {
      for (final q in kQuizQuestions) {
        expect(learnEntry(q.noteId), isNotNull, reason: q.noteId);
        expect(q.prompt.trim(), isNotEmpty, reason: q.noteId);
        expect(q.explanation.trim(), isNotEmpty, reason: q.noteId);
        expect(q.options.length, inInclusiveRange(2, 4), reason: q.noteId);
        expect(q.options.toSet().length, q.options.length, reason: q.noteId);
        expect(q.correct, inInclusiveRange(0, q.options.length - 1));
      }
    });

    test('every theme has at least three questions', () {
      for (final c in LearnCategory.values) {
        expect(
          quizQuestionsIn(c).length,
          greaterThanOrEqualTo(3),
          reason: c.title,
        );
      }
    });

    test('nothing reads as a prescription, a cure or a claim', () {
      // whole words: "whenever" is not "never"
      final banned = [
        RegExp(r'you should'),
        RegExp(r'you must'),
        RegExp(r'you need to'),
        RegExp(r'you have to'),
        RegExp(r'(?<!not )always'),
        RegExp(r'never'),
        RegExp(r'cure[sd]?'),
        RegExp(r'treat'),
        RegExp(r'heal'),
        RegExp(r'prevent'),
        RegExp(r'diagnos'),
        RegExp(r'guarantee'),
        RegExp(r'proven'),
        RegExp(r'fix(es)?'),
        RegExp(r'supplement'),
        RegExp(r'brand'),
        RegExp(r'recommend'),
      ];
      for (final q in kQuizQuestions) {
        final text = '${q.prompt} ${q.options.join(' ')} ${q.explanation}'
            .toLowerCase();
        for (final pattern in banned) {
          expect(
            pattern.hasMatch(text),
            isFalse,
            reason: '${pattern.pattern} in ${q.noteId}',
          );
        }
      }
    });

    test('ingredient names come up only in questions about ingredients', () {
      const names = ['retinol', 'retinoid', 'niacinamide', 'vitamin c'];
      for (final q in kQuizQuestions) {
        if (q.category == LearnCategory.ingredients) continue;
        final text = '${q.prompt} ${q.options.join(' ')} ${q.explanation}'
            .toLowerCase();
        for (final n in names) {
          expect(text.contains(n), isFalse, reason: '"$n" in ${q.noteId}');
        }
      }
    });

    test('Ingredient Match pairs name real notes, and no kind repeats', () {
      expect(kMatchPairs.length, greaterThanOrEqualTo(8));
      for (final p in kMatchPairs) {
        expect(learnEntry(p.noteId), isNotNull, reason: p.noteId);
      }
      expect(kMatchPairs.map((p) => p.kind).toSet().length, kMatchPairs.length);
      expect(
        kMatchPairs.map((p) => p.ingredient).toSet().length,
        kMatchPairs.length,
      );
    });
  });

  group('the games', () {
    tearDown(() => quizHostBuilder = null);

    void tall(WidgetTester t) {
      t.view.physicalSize = const Size(412, 1600);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
    }

    /// The tile on the option that is right for the question on screen.
    Finder rightOption(WidgetTester t) {
      final prompt = t.widget<Text>(find.byKey(const Key('quizPrompt'))).data;
      final q = kQuizQuestions.firstWhere((q) => q.prompt == prompt);
      return find.ancestor(
        of: find.text(q.options[q.correct]),
        matching: find.byType(InkWell),
      );
    }

    testWidgets('the front page offers both games', (t) async {
      t.view.physicalSize = const Size(412, 4000); // the whole page is built
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(const LearnScreen()));
      await t.pump();
      expect(find.byKey(const Key('learnQuiz')), findsOneWidget);
      expect(find.byKey(const Key('learnMatch')), findsOneWidget);
      await t.tap(find.byKey(const Key('learnQuiz')));
      await t.pumpAndSettle();
      expect(find.text('Question 1 of 5'), findsOneWidget);
    });

    testWidgets('a right answer says so and a round ends warmly', (t) async {
      tall(t);
      await t.pumpWidget(
        host(LearnQuizScreen(random: math.Random(1), count: 2)),
      );
      await t.pump();
      expect(find.text('Question 1 of 2'), findsOneWidget);
      expect(find.byKey(const Key('quizFeedback')), findsNothing);
      await t.tap(rightOption(t));
      await t.pump();
      expect(find.text('Yes, that is it.'), findsOneWidget);
      await t.tap(find.byKey(const Key('quizNext')));
      await t.pump();
      expect(find.text('Question 2 of 2'), findsOneWidget);
      await t.tap(rightOption(t));
      await t.pump();
      await t.tap(find.byKey(const Key('quizNext')));
      await t.pump();
      expect(find.byKey(const Key('quizDone')), findsOneWidget);
      expect(
        find.textContaining('score'),
        findsNothing,
        reason: 'nothing is counted or shown as a score',
      );
    });

    testWidgets('a wrong answer shows the answer and links to the note', (
      t,
    ) async {
      tall(t);
      await t.pumpWidget(
        host(LearnQuizScreen(random: math.Random(3), count: 1)),
      );
      await t.pump();
      final prompt = t.widget<Text>(find.byKey(const Key('quizPrompt'))).data;
      final q = kQuizQuestions.firstWhere((q) => q.prompt == prompt);
      final wrong = (q.correct + 1) % q.options.length;
      await t.tap(
        find.ancestor(
          of: find.text(q.options[wrong]),
          matching: find.byType(InkWell),
        ),
      );
      await t.pump();
      expect(find.text('Not quite. Here is the answer.'), findsOneWidget);
      expect(find.text(q.explanation), findsOneWidget);
      await t.tap(find.byKey(const Key('quizReadNote')));
      await t.pumpAndSettle();
      expect(
        find.byKey(Key('learn-body-${q.noteId}')),
        findsOneWidget,
        reason: 'the note opens, already open',
      );
    });

    testWidgets('a theme page offers three of its own questions', (t) async {
      tall(t);
      await t.pumpWidget(
        host(LearnThemeScreen(category: LearnCategory.labels)),
      );
      await t.pump();
      await t.ensureVisible(find.byKey(const Key('themeQuiz')));
      await t.tap(find.byKey(const Key('themeQuiz')));
      await t.pumpAndSettle();
      expect(find.text('Question 1 of 3'), findsOneWidget);
      final prompt = t.widget<Text>(find.byKey(const Key('quizPrompt'))).data;
      expect(
        quizQuestionsIn(LearnCategory.labels).map((q) => q.prompt),
        contains(prompt),
      );
    });

    testWidgets('Ingredient Match pairs four, and a wrong tap only says try '
        'another', (t) async {
      tall(t);
      await t.pumpWidget(host(IngredientMatchScreen(random: math.Random(2))));
      await t.pump();
      final shown = [
        for (final p in kMatchPairs)
          if (find
              .byKey(Key('matchIngredient-${p.ingredient}'))
              .evaluate()
              .isNotEmpty)
            p,
      ];
      expect(shown.length, 4);
      // a wrong pairing changes nothing but the message
      await t.tap(find.byKey(Key('matchIngredient-${shown[0].ingredient}')));
      await t.pump();
      await t.tap(find.byKey(Key('matchKind-${shown[1].kind}')));
      await t.pump();
      expect(find.text('Not quite. Try another.'), findsOneWidget);
      expect(find.byKey(const Key('matchDone')), findsNothing);
      // the right ones lock in
      for (final p in shown) {
        await t.tap(find.byKey(Key('matchIngredient-${p.ingredient}')));
        await t.pump();
        await t.tap(find.byKey(Key('matchKind-${p.kind}')));
        await t.pump();
      }
      expect(find.byKey(const Key('matchDone')), findsOneWidget);
      expect(find.byKey(const Key('matchAgain')), findsOneWidget);
    });

    testWidgets('an app can give the games a host', (t) async {
      tall(t);
      quizHostBuilder = (_) => const QuizHost(
        name: 'Nefer',
        avatar: SizedBox(key: Key('hostAvatar')),
      );
      await t.pumpWidget(
        host(LearnQuizScreen(random: math.Random(1), count: 1)),
      );
      await t.pump();
      expect(find.byKey(const Key('quizHost')), findsOneWidget);
      expect(find.byKey(const Key('hostAvatar')), findsOneWidget);
      expect(find.textContaining('Nefer:'), findsOneWidget);
      await t.tap(rightOption(t));
      await t.pump();
      await t.tap(find.byKey(const Key('quizNext')));
      await t.pump();
      expect(find.textContaining('says Nefer'), findsOneWidget);
    });

    testWidgets('without a host there is none', (t) async {
      tall(t);
      await t.pumpWidget(
        host(LearnQuizScreen(random: math.Random(1), count: 1)),
      );
      await t.pump();
      expect(find.byKey(const Key('quizHost')), findsNothing);
    });
  });
}
