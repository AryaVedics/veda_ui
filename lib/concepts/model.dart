// What a concept app is made of (its config) and what it keeps (one JSON file
// on the phone). These apps are for testing ideas: they record what the person
// types and describe it back, and give no advice.

import 'package:flutter/widgets.dart';

import '../veda_ui.dart';

// ---------------------------------------------------------------- data

/// One day: what was ticked, which words were chosen, which saved things were
/// used, and a note.
class DayLog {
  const DayLog({
    required this.day,
    this.checks = const {},
    this.words = const {},
    this.used = const {},
    this.note = '',
  });

  /// "2026-11-28".
  final String day;
  final Set<String> checks;
  final Set<String> words;

  /// Ids of records ticked as used that day.
  final Set<String> used;
  final String note;

  bool get isEmpty =>
      checks.isEmpty && words.isEmpty && used.isEmpty && note.isEmpty;

  DayLog copyWith({
    Set<String>? checks,
    Set<String>? words,
    Set<String>? used,
    String? note,
  }) => DayLog(
    day: day,
    checks: checks ?? this.checks,
    words: words ?? this.words,
    used: used ?? this.used,
    note: note ?? this.note,
  );

  Map<String, Object?> toJson() => {
    'day': day,
    if (checks.isNotEmpty) 'checks': [...checks],
    if (words.isNotEmpty) 'words': [...words],
    if (used.isNotEmpty) 'used': [...used],
    if (note.isNotEmpty) 'note': note,
  };

  static Set<String> _set(Object? v) => {
    for (final e in (v as List? ?? const [])) e as String,
  };

  static DayLog fromJson(Map<String, Object?> j) => DayLog(
    day: j['day'] as String,
    checks: _set(j['checks']),
    words: _set(j['words']),
    used: _set(j['used']),
    note: j['note'] as String? ?? '',
  );
}

/// One saved thing (a product, a pet, a visit): its fields by key. Text,
/// choices and dates ("2026-11-28") are strings; a multi-pick is a list of ids.
class Rec {
  const Rec(this.id, this.values);

  final String id;
  final Map<String, Object?> values;

  String text(String key) => values[key] as String? ?? '';

  List<String> ids(String key) => [
    for (final e in (values[key] as List? ?? const [])) e as String,
  ];

  DateTime? date(String key) {
    final v = text(key);
    if (v.isEmpty) return null;
    try {
      return parseDayKey(v);
    } catch (_) {
      return null;
    }
  }

  double? number(String key) => double.tryParse(text(key).replaceAll(',', '.'));
}

class ConceptData {
  const ConceptData({this.days = const {}, this.records = const {}});

  final Map<String, DayLog> days;

  /// By collection id, in the order saved.
  final Map<String, List<Rec>> records;

  List<Rec> of(String collection) => records[collection] ?? const [];

  Rec? find(String id) {
    for (final list in records.values) {
      for (final r in list) {
        if (r.id == id) return r;
      }
    }
    return null;
  }

  /// The noted days within the last [span] days up to [today], newest first.
  List<DayLog> within(DateTime today, int span) {
    final t = dayOf(today);
    final from = DateTime(t.year, t.month, t.day - (span - 1));
    return [
      for (final d in days.values)
        if (!parseDayKey(d.day).isBefore(from) &&
            !parseDayKey(d.day).isAfter(t))
          d,
    ]..sort((a, b) => b.day.compareTo(a.day));
  }

  /// The last seven days, oldest first, ending today; null where nothing was
  /// noted.
  List<DayLog?> week(DateTime today) => [
    for (var i = 6; i >= 0; i--)
      days[dayKey(DateTime(today.year, today.month, today.day - i))],
  ];

  /// On how many noted days record [id] was ticked as used.
  int usedDays(String id) =>
      days.values.where((d) => d.used.contains(id)).length;

  Map<String, Object?> toJson() => {
    'v': 1,
    'days': [for (final d in days.values) d.toJson()],
    'records': {
      for (final e in records.entries)
        e.key: [
          for (final r in e.value) {'id': r.id, 'values': r.values},
        ],
    },
  };

  static ConceptData fromJson(Map<String, Object?> j) => ConceptData(
    days: {
      for (final d in (j['days'] as List? ?? const []))
        (d as Map)['day'] as String: DayLog.fromJson(d.cast<String, Object?>()),
    },
    records: {
      for (final e in ((j['records'] as Map?) ?? const {}).entries)
        e.key as String: [
          for (final r in e.value as List)
            Rec(
              (r as Map)['id'] as String,
              (r['values'] as Map).cast<String, Object?>(),
            ),
        ],
    },
  );
}

class ConceptStore extends JsonStore<ConceptData> {
  ConceptStore(String appId, {JsonFile? file, super.clock})
    : super(file ?? DocumentsJsonFile('$appId.json'));

  @override
  ConceptData get empty => const ConceptData();

  @override
  ConceptData fromJson(Map<String, Object?> json) => ConceptData.fromJson(json);

  @override
  Map<String, Object?> toJson(ConceptData value) => value.toJson();

  /// Saves a day; a day with nothing left in it is removed.
  Future<void> saveDay(DayLog day) {
    final days = {...data.days}..remove(day.day);
    if (!day.isEmpty) days[day.day] = day;
    return set(ConceptData(days: days, records: data.records));
  }

  /// Adds a record, or puts it in place of the one with its id.
  Future<void> saveRecord(String collection, Rec rec) {
    final list = [...data.of(collection)];
    final at = list.indexWhere((r) => r.id == rec.id);
    if (at < 0) {
      list.add(rec);
    } else {
      list[at] = rec;
    }
    return set(
      ConceptData(
        days: data.days,
        records: {...data.records, collection: list},
      ),
    );
  }

  Future<void> removeRecord(String collection, String id) => set(
    ConceptData(
      days: data.days,
      records: {
        ...data.records,
        collection: [...data.of(collection).where((r) => r.id != id)],
      },
    ),
  );
}

// ---------------------------------------------------------------- config

enum FieldType { text, long, date, number, choice, multi }

class Field {
  const Field(
    this.key,
    this.label, {
    this.type = FieldType.text,
    this.options = const [],
    this.from,
    this.required = false,
  });

  final String key;
  final String label;
  final FieldType type;

  /// For [FieldType.choice].
  final List<String> options;

  /// For [FieldType.multi]: the collection picked from.
  final String? from;
  final bool required;
}

class Collection {
  const Collection({
    required this.id,
    required this.title,
    required this.one,
    required this.icon,
    required this.empty,
    required this.fields,
    required this.name,
    this.detail,
    this.searchable = false,
    this.usable = false,
    this.hint,
  });

  final String id;

  /// "My shelf".
  final String title;

  /// "a product", for "Add a product".
  final String one;
  final IconData icon;

  /// What the empty page says.
  final String empty;
  final List<Field> fields;

  /// The row's title.
  final String Function(Rec r, ConceptData d) name;

  /// The row's second line.
  final List<String> Function(Rec r, ConceptData d, DateTime now)? detail;

  /// The page has a search box over every field.
  final bool searchable;

  /// Its records can be ticked as used on a day.
  final bool usable;

  /// A line above the list.
  final String? hint;
}

class Check {
  const Check(this.id, this.label, this.icon);
  final String id;
  final String label;
  final IconData icon;
}

/// A short guided timer: a countdown, or a slow breathing circle.
class TimerSpec {
  const TimerSpec({
    required this.title,
    required this.seconds,
    required this.line,
    required this.icon,
    this.breathing = false,
    this.check,
  });

  final String title;
  final int seconds;
  final String line;
  final IconData icon;
  final bool breathing;

  /// The check ticked on today when the timer finishes.
  final String? check;
}

class ConceptApp {
  const ConceptApp({
    required this.id,
    required this.word,
    required this.name,
    required this.base,
    required this.greeting,
    required this.how,
    required this.checksLabel,
    required this.checks,
    required this.collections,
    required this.centrepiece,
    required this.sceneLabel,
    required this.since,
    required this.about,
    this.wordsLabel,
    this.words = const [],
    this.usedLabel = 'What did you use?',
    this.timer,
    this.noteInDay = true,
  });

  /// "beauty": the data file, backup and notice keys.
  final String id;
  final String word;
  final String name;

  /// The app's background colour; the rest of its palette comes from it.
  final Color base;
  final String greeting;

  /// The first message on Today.
  final String how;
  final String checksLabel;
  final List<Check> checks;
  final String? wordsLabel;
  final List<String> words;
  final String usedLabel;
  final List<Collection> collections;

  /// Draws the scene for [data] at time [t] (0 to 1, looping).
  final CustomPainter Function(
    ConceptData data,
    DateTime now,
    AppColors colors,
    double t,
  )
  centrepiece;
  final String sceneLabel;

  /// The line under the scene.
  final String Function(ConceptData d, DateTime now) since;
  final String about;
  final TimerSpec? timer;
  final bool noteInDay;
}

/// The family's gold on a background made from [base].
AppColors paletteFrom(Color base) {
  Color dark(double t) => Color.lerp(base, const Color(0xFF000000), t)!;
  Color light(double t) => Color.lerp(base, const Color(0xFFFFFFFF), t)!;
  return AppColors(
    canvas: base,
    canvasDeep: dark(0.34),
    card: light(0.09),
    cardSunken: light(0.045),
    accent: const Color(0xFFD9B863),
    accentDim: Color.lerp(base, const Color(0xFFD9B863), 0.28)!,
    accentText: const Color(0xFFE8C86A),
    onAccent: const Color(0xFF3A2E10),
    textPrimary: const Color(0xFFF7F0E4),
    textSecondary: light(0.80),
    textMuted: light(0.64),
    divider: light(0.22),
    overlay: const Color(0xFF9FC4D6),
    overlayLight: const Color(0xFFC6E0EC),
  );
}
