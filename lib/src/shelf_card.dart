// A shelf card: a plain list of products one person chose to share with
// another, for example an aesthetician or a stylist handing someone the
// products they talked about. A file made on one phone and opened on the
// other; nothing goes through a server, and nothing is added to the receiving
// shelf unless the receiver picks it.
//
// A card holds only names, brands, the kind of product and, for an app that
// has them, when it is used. Never dates, notes, barcodes or a diary. An app
// does not recommend products, and a card is not a recommendation from the
// app.
//
// This is the file's shape, shared by the apps that keep a shelf. Each app
// gives its own [ShelfCardFormat] (its own schema name and field names) and
// turns [ShelfCardEntry] into its own kinds.

import 'dart:convert';

/// How an app writes and reads its cards.
class ShelfCardFormat {
  const ShelfCardFormat({
    required this.schema,
    required this.kindKey,
    this.tagsKey,
    this.max = 40,
  });

  /// The name and version that mark a file as this app's card.
  final String schema;

  /// The field that holds a product's kind ("type", "kind").
  final String kindKey;

  /// The field for a list of tags on a product (Routine's times of day), or
  /// null when the app has none.
  final String? tagsKey;

  /// A card is a short list; more than this is not a card.
  final int max;
}

/// One product on a card, as plain text: the app turns [kind] and [tags] into
/// its own kinds.
class ShelfCardEntry {
  const ShelfCardEntry({
    required this.name,
    this.brand,
    this.kind,
    this.tags = const [],
  });

  final String name;
  final String? brand;
  final String? kind;
  final List<String> tags;

  String get displayName => brand == null ? name : '$brand $name';
}

/// A card read from a file.
class ShelfCardData {
  const ShelfCardData({this.from, this.note, required this.entries});

  /// Who made the card, in their words ("Glow Med Spa"), if they said.
  final String? from;
  final String? note;
  final List<ShelfCardEntry> entries;
}

/// Trimmed text of at most [max] characters, or null when there is none.
String? cleanCardText(Object? v, [int max = 80]) {
  if (v is! String) return null;
  final t = v.trim();
  if (t.isEmpty) return null;
  return t.length > max ? t.substring(0, max) : t;
}

/// The text of a card for [entries].
String encodeShelfCardEntries(
  ShelfCardFormat format,
  List<ShelfCardEntry> entries, {
  String? from,
  String? note,
}) {
  return jsonEncode({
    'schema': format.schema,
    if (cleanCardText(from) != null) 'from': cleanCardText(from),
    if (cleanCardText(note, 200) != null) 'note': cleanCardText(note, 200),
    'products': [
      for (final e in entries.take(format.max))
        {
          'name': e.name,
          if (e.brand != null) 'brand': e.brand,
          if (e.kind != null) format.kindKey: e.kind,
          if (format.tagsKey != null) format.tagsKey!: e.tags,
        },
    ],
  });
}

/// The card in [text], or null when it is not one of this app's.
ShelfCardData? decodeShelfCardEntries(ShelfCardFormat format, String text) {
  try {
    final j = jsonDecode(text);
    if (j is! Map || j['schema'] != format.schema) return null;
    final raw = j['products'];
    if (raw is! List) return null;
    final entries = <ShelfCardEntry>[];
    for (final r in raw.take(format.max)) {
      if (r is! Map) continue;
      final name = cleanCardText(r['name']);
      if (name == null) continue;
      final tags = format.tagsKey == null
          ? const <String>[]
          : [
              for (final t in (r[format.tagsKey] as List? ?? const []))
                if (t is String) t,
            ];
      entries.add(
        ShelfCardEntry(
          name: name,
          brand: cleanCardText(r['brand']),
          kind: r[format.kindKey] is String
              ? r[format.kindKey] as String
              : null,
          tags: tags,
        ),
      );
    }
    if (entries.isEmpty) return null;
    return ShelfCardData(
      from: cleanCardText(j['from']),
      note: cleanCardText(j['note'], 200),
      entries: entries,
    );
  } catch (_) {
    return null;
  }
}
