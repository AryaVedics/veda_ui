// Véda Link: how a companion app gets the person's Véda readings, so it can
// chart them next to its own data (a product started in Routine, sleep in
// Lifestyle, phases in Cycle, UV days in Sun). The charts live in the
// companion app; Véda itself stays uncluttered. See BRIDGE.md.
//
// Only what a chart needs is kept: when the reading was taken, the time of
// day, the Skin Score and the seven measurements. Never photos, face
// geometry, per-region detail, account details or consent records.
//
// The readings arrive live from Véda over Véda Link (the person switches
// sharing on in Véda and "use" in this app); see link_bridge.dart.

import 'dart:convert';

import 'json_store.dart';

/// The seven measurements, in Véda's order.
const kVedaMetrics = [
  'redness',
  'texture',
  'pores',
  'spots',
  'acne',
  'evenness',
  'wrinkles',
];

class VedaReading {
  const VedaReading({
    required this.takenAt,
    this.slot,
    this.skinScore,
    this.scores = const {},
  });

  final DateTime takenAt;

  /// "morning", "midday" or "evening", when Véda knew it.
  final String? slot;
  final double? skinScore;
  final Map<String, double> scores;

  Map<String, Object?> toJson() => {
    'taken_at': takenAt.toUtc().toIso8601String(),
    'slot': ?slot,
    'skin_score': ?skinScore,
    'scores': scores,
  };

  static VedaReading fromJson(Map<String, Object?> j) => VedaReading(
    takenAt: DateTime.parse(j['taken_at'] as String).toLocal(),
    slot: j['slot'] as String?,
    skinScore: (j['skin_score'] as num?)?.toDouble(),
    scores: ((j['scores'] as Map?) ?? {}).map(
      (k, v) => MapEntry(k as String, (v as num).toDouble()),
    ),
  );
}

class VedaLinkData {
  const VedaLinkData({this.readings = const [], this.importedAt});

  final List<VedaReading> readings;
  final DateTime? importedAt;

  /// The day's average Skin Score, or null if there was no reading that day.
  double? skinScoreOn(DateTime day) {
    final scores = [
      for (final r in readings)
        if (r.skinScore != null &&
            r.takenAt.year == day.year &&
            r.takenAt.month == day.month &&
            r.takenAt.day == day.day)
          r.skinScore!,
    ];
    if (scores.isEmpty) return null;
    return scores.reduce((a, b) => a + b) / scores.length;
  }
}

/// The readings this app has been given, kept in their own file on the phone.
class VedaLinkStore extends JsonStore<VedaLinkData> {
  VedaLinkStore({JsonFile? file, super.clock})
    : super(file ?? DocumentsJsonFile('veda_readings.json'));

  @override
  VedaLinkData get empty => const VedaLinkData();

  @override
  VedaLinkData fromJson(Map<String, Object?> json) => VedaLinkData(
    readings: [
      for (final r in (json['readings'] as List? ?? const []))
        VedaReading.fromJson((r as Map).cast<String, Object?>()),
    ],
    importedAt: json['imported_at'] == null
        ? null
        : DateTime.parse(json['imported_at'] as String).toLocal(),
  );

  @override
  Map<String, Object?> toJson(VedaLinkData v) => {
    'schema': 'veda-link/1',
    'imported_at': v.importedAt?.toUtc().toIso8601String(),
    'readings': [for (final r in v.readings) r.toJson()],
  };

  /// Takes the readings from Véda's live feed (Véda Link, the "data" part of
  /// its feed). Returns whether anything changed; the same readings again do
  /// nothing, so listeners are not woken for no reason.
  Future<bool> takeLive(Map<String, Object?> feedData) async {
    final rows = (feedData['readings'] as List?) ?? const [];
    final readings = <VedaReading>[];
    for (final r in rows) {
      if (r is! Map) continue;
      try {
        readings.add(VedaReading.fromJson(r.cast<String, Object?>()));
      } catch (_) {
        // A row this app cannot read is skipped, not fatal.
      }
    }
    readings.sort((a, b) => a.takenAt.compareTo(b.takenAt));
    final mine = data.readings;
    if (mine.length == readings.length &&
        [
          for (var i = 0; i < mine.length; i++)
            jsonEncode(mine[i].toJson()) == jsonEncode(readings[i].toJson()),
        ].every((same) => same)) {
      return false;
    }
    await set(VedaLinkData(readings: readings, importedAt: clock()));
    return true;
  }
}
