import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

void main() {
  Widget host(Widget child) =>
      MaterialApp(theme: vedaTheme(AppColors.nightfall), home: child);

  group('the friends', () {
    test('every friend says what kind of animal they are', () {
      for (final f in [...kForestFriends, ...kRestingFriends]) {
        expect(f.kind.trim(), isNotEmpty, reason: f.name);
        expect(
          f.kind.toLowerCase(),
          isNot(contains('wild ass')),
          reason: f.name,
        );
        expect(
          f.story.toLowerCase(),
          isNot(contains('wild ass')),
          reason: f.name,
        );
      }
    });

    test('every animal that visits has a friend with a story', () {
      for (final a in kForestRotation) {
        expect(forestFriendFor(a), isNotNull, reason: '$a');
      }
    });

    test('names are never reused', () {
      final names = [for (final f in kForestFriends) f.name];
      expect(names.toSet().length, names.length);
    });
  });

  group('the page', () {
    testWidgets('lists the friends four to a row and opens their sheet', (
      t,
    ) async {
      t.view.physicalSize = const Size(412, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      await t.pumpWidget(host(const ForestFriendsPage()));
      await t.pump();
      expect(find.text('Friends of the Forest'), findsOneWidget);
      final row = find.byKey(const Key('friendRow-Vesna'));
      await t.ensureVisible(row);
      await t.pump();
      await t.tap(row);
      await t.pumpAndSettle();
      expect(find.byKey(const Key('friendSheet')), findsOneWidget);
      expect(find.byKey(const Key('friendKind')), findsOneWidget);
      expect(
        find.textContaining('White stork'),
        findsOneWidget,
        reason: 'the sheet says what kind of animal',
      );
    });

    testWidgets('the peek shows a few faces and a way to see them all', (
      t,
    ) async {
      t.view.physicalSize = const Size(412, 900);
      t.view.devicePixelRatio = 1;
      addTearDown(t.view.reset);
      var all = 0;
      ForestFriend? opened;
      await t.pumpWidget(
        host(
          Scaffold(
            body: ForestFriendsPeek(
              onOpen: (f) => opened = f,
              onSeeAll: () => all++,
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('friend-Tara')), findsOneWidget);
      expect(find.byKey(const Key('friend-Vesna')), findsNothing);
      expect(
        find.text('Meet all ${kForestFriends.length} friends'),
        findsOneWidget,
      );
      await t.tap(find.byKey(const Key('friend-Tara')));
      expect(opened?.name, 'Tara');
      await t.tap(find.byKey(const Key('allFriends')));
      expect(all, 1);
    });
  });
}
