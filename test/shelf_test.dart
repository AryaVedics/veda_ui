import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:veda_ui/veda_ui.dart';

// The shelf shared by the apps that keep one (Routine, Hair): the use-by arcs,
// the Shelf tab and the shelf cards.

// the header's logo needs the app's brand, which each app supplies
const _brand = VedaBrand(
  appName: 'Véda Test',
  word: 'TEST',
  markAsset: 'packages/veda_ui/assets/branding/veda_mark.png',
  ringTrack: Color(0xFF123456),
);

ShelfItem _item(
  String id, {
  String? name,
  DateTime? opened,
  DateTime? useBy,
  DateTime? stopped,
  bool low = false,
  BottleShape shape = BottleShape.bottle,
}) => ShelfItem(
  id: id,
  name: name ?? 'Product $id',
  kindLabel: 'Oil',
  shape: shape,
  opened: opened,
  useBy: useBy,
  stopped: stopped,
  runningLow: low,
);

Widget _tab({
  required List<ShelfItem> active,
  List<ShelfItem> stopped = const [],
  VoidCallback? onAdd,
  void Function(ShelfItem)? onEdit,
  List<Widget> leading = const [],
  int soon = 0,
}) => MaterialApp(
  theme: vedaTheme(AppColors.henna),
  builder: (context, child) => VedaBrandScope(brand: _brand, child: child!),
  home: Scaffold(
    body: ShelfTab(
      active: active,
      stopped: stopped,
      soonCount: soon,
      today: DateTime(2026, 11, 24),
      fireflies: false,
      leading: leading,
      detail: (i) => 'details of ${i.id}',
      emptyText: 'Nothing here yet.',
      onAdd: onAdd ?? () {},
      onEdit: onEdit ?? (_) {},
    ),
  ),
);

/// A tall phone, so the ring, the note and the list are all built.
Future<void> _pump(WidgetTester t, Widget app) async {
  t.view.physicalSize = const Size(420, 2400);
  t.view.devicePixelRatio = 1;
  addTearDown(t.view.reset);
  await t.pumpWidget(app);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('use-by time left', () {
    final today = DateTime(2026, 10, 23);

    test('is the fraction of the period still ahead', () {
      final left = shelfTimeLeft(
        _item('a', opened: DateTime(2026, 9, 23), useBy: DateTime(2027, 3, 23)),
        today,
      )!;
      expect(left, greaterThan(0.8));
      expect(left, lessThan(0.9));
    });

    test('is nothing without both dates', () {
      expect(shelfTimeLeft(_item('a'), today), isNull);
      expect(
        shelfTimeLeft(_item('a', opened: DateTime(2026, 9, 1)), today),
        isNull,
      );
      expect(
        shelfTimeLeft(_item('a', useBy: DateTime(2027, 1, 1)), today),
        isNull,
      );
    });

    test('is empty, never negative, past the date', () {
      expect(
        shelfTimeLeft(
          _item('a', opened: DateTime(2025, 1, 1), useBy: DateTime(2025, 7, 1)),
          today,
        ),
        0,
      );
    });

    test('a stopped item is not active', () {
      expect(_item('a').active, isTrue);
      expect(_item('a', stopped: DateTime(2026, 1, 1)).active, isFalse);
    });
  });

  group('the card file', () {
    const format = ShelfCardFormat(
      schema: 'test-shelf/1',
      kindKey: 'kind',
      tagsKey: 'times',
      max: 3,
    );

    test('reads back what was written', () {
      final text = encodeShelfCardEntries(
        format,
        const [
          ShelfCardEntry(
            name: 'Serum',
            brand: 'Acme',
            kind: 'serum',
            tags: ['morning', 'evening'],
          ),
        ],
        from: '  Glow  ',
        note: 'Hello',
      );
      final card = decodeShelfCardEntries(format, text)!;
      expect(card.from, 'Glow');
      expect(card.note, 'Hello');
      final e = card.entries.single;
      expect(e.name, 'Serum');
      expect(e.brand, 'Acme');
      expect(e.kind, 'serum');
      expect(e.tags, ['morning', 'evening']);
      expect(e.displayName, 'Acme Serum');
    });

    test('an app without tags writes and reads none', () {
      const plain = ShelfCardFormat(schema: 'plain/1', kindKey: 'kind');
      final text = encodeShelfCardEntries(plain, const [
        ShelfCardEntry(name: 'Oil', kind: 'oil', tags: ['ignored']),
      ]);
      expect(text, isNot(contains('ignored')));
      expect(decodeShelfCardEntries(plain, text)!.entries.single.tags, isEmpty);
    });

    test('is only a list: names, brands and kinds', () {
      final text = encodeShelfCardEntries(format, const [
        ShelfCardEntry(name: 'Oil', kind: 'oil'),
      ]);
      expect(text, isNot(contains('barcode')));
      expect(text, isNot(contains('note')));
    });

    test('rejects a file that is not this app\'s card', () {
      expect(decodeShelfCardEntries(format, 'not json'), isNull);
      expect(
        decodeShelfCardEntries(format, '{"schema":"other","products":[]}'),
        isNull,
      );
      expect(
        decodeShelfCardEntries(
          format,
          '{"schema":"test-shelf/1","products":[]}',
        ),
        isNull,
      );
    });

    test('tolerates odd entries', () {
      final card = decodeShelfCardEntries(
        format,
        '{"schema":"test-shelf/1","products":['
        '{"name":"  ","kind":"serum"},"junk",'
        '{"name":"Mystery","kind":5,"times":["morning",3]}]}',
      )!;
      expect(card.entries.length, 1);
      expect(card.entries.single.kind, isNull);
      expect(card.entries.single.tags, ['morning']);
    });

    test('a card is a short list', () {
      final text = encodeShelfCardEntries(format, [
        for (var i = 0; i < 6; i++) ShelfCardEntry(name: 'P$i', kind: 'oil'),
      ]);
      expect(decodeShelfCardEntries(format, text)!.entries.length, 3);
    });
  });

  group('the Shelf tab', () {
    testWidgets('an empty shelf says so and has no ring', (t) async {
      await _pump(t, _tab(active: const []));
      expect(find.text('Nothing here yet.'), findsOneWidget);
      expect(find.text('ON YOUR SHELF'), findsNothing);
    });

    testWidgets('shows the count, what is soon, the list and the note', (
      t,
    ) async {
      await _pump(
        t,
        _tab(active: [_item('a'), _item('b', low: true)], soon: 1),
      );
      expect(find.text('2'), findsOneWidget);
      expect(find.text('ON YOUR SHELF'), findsOneWidget);
      expect(find.text('1 to use soon'), findsOneWidget);
      expect(find.text('Running low: Product b'), findsOneWidget);
      expect(find.text('details of a'), findsOneWidget);
    });

    testWidgets('every bottle shape draws', (t) async {
      await _pump(
        t,
        _tab(
          active: [for (final s in BottleShape.values) _item(s.name, shape: s)],
        ),
      );
      expect(t.takeException(), isNull);
    });

    testWidgets('Add and a tapped row call back', (t) async {
      var added = 0;
      String? edited;
      await _pump(
        t,
        _tab(
          active: [_item('a'), _item('b')],
          onAdd: () => added++,
          onEdit: (i) => edited = i.id,
        ),
      );
      await t.tap(find.text('Add a product'));
      expect(added, 1);
      await t.tap(find.text('details of b'));
      expect(edited, 'b');
    });

    testWidgets('stopped products are hidden until opened', (t) async {
      await _pump(
        t,
        _tab(
          active: [_item('a')],
          stopped: [_item('old', stopped: DateTime(2026, 1, 1))],
        ),
      );
      expect(find.text('Stopped (1)'), findsOneWidget);
      expect(find.text('details of old'), findsNothing);
      await t.tap(find.text('Stopped (1)'));
      await t.pump();
      expect(find.text('details of old'), findsOneWidget);
    });

    testWidgets('a tapped bottle shows its name to edit', (t) async {
      await _pump(t, _tab(active: [_item('a', name: 'Amla oil')]));
      await t.tap(
        find.byWidgetPredicate(
          (w) => w is Semantics && w.properties.label == 'Amla oil, Oil',
        ),
      );
      await t.pump();
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Oil'), findsOneWidget);
    });

    testWidgets('a ninth product starts a second shelf', (t) async {
      await _pump(t, _tab(active: [for (var i = 0; i < 9; i++) _item('p$i')]));
      // the first shelf shows the whole count
      expect(find.text('9'), findsOneWidget);
      await t.drag(find.text('9'), const Offset(-300, 0));
      // the header's logo never stops moving, so settle by hand
      await t.pump(const Duration(milliseconds: 600));
      expect(find.text('Shelf 2'), findsOneWidget);
    });

    testWidgets('leading cards sit above the products', (t) async {
      await _pump(
        t,
        _tab(active: [_item('a')], leading: const [Text('Education row')]),
      );
      expect(find.text('Education row'), findsOneWidget);
    });
  });

  testWidgets('the card preview adds nothing until products are picked', (
    t,
  ) async {
    t.view.physicalSize = const Size(420, 1200);
    t.view.devicePixelRatio = 1;
    addTearDown(t.view.reset);
    List<ShelfCardEntry>? added;
    await _pump(
      t,
      MaterialApp(
        theme: vedaTheme(AppColors.henna),
        home: Scaffold(
          body: ShelfCardPreviewSheet(
            card: const ShelfCardData(
              from: 'Glow',
              entries: [
                ShelfCardEntry(name: 'Oil', kind: 'oil'),
                ShelfCardEntry(name: 'Mask', kind: 'mask'),
              ],
            ),
            subtitle: (e) => e.kind ?? '',
            add: (chosen) async {
              added = chosen;
              return chosen.length;
            },
          ),
        ),
      ),
    );
    expect(find.text('A shelf card from Glow'), findsOneWidget);
    expect(find.text('Pick products to add'), findsOneWidget);
    expect(
      t.widget<CheckboxListTile>(find.byKey(const Key('cardItem0'))).value,
      isFalse,
    );
    await t.tap(find.byKey(const Key('cardItem1')));
    await t.pump();
    await t.tap(find.text('Add 1 to my shelf'));
    await t.pump();
    expect(added!.map((e) => e.name), ['Mask']);
  });
}
