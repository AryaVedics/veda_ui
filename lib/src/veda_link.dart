// Véda Link: how a companion app gets the person's Véda readings, so it can
// chart them next to its own data (a product started in Routine, sleep in
// Lifestyle, phases in Cycle, UV days in Sun). The charts live in the
// companion app; Véda itself stays uncluttered. See BRIDGE.md.
//
// Only what a chart needs is kept: when the reading was taken, the time of
// day, the Skin Score and the seven measurements. Never photos, face
// geometry, per-region detail, account details or consent records.
//
// Stage 1 (now): the person exports from Véda (Profile > Export my data) and
// picks that file here. Stage 2: Véda shares the same fields on the phone
// directly, with the person's permission; the readings arrive in exactly
// this shape, so nothing that draws the charts changes.

import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';

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

/// Reads either Véda's own "Export my data" file or the Véda Link format
/// ("veda-link/1"). Returns the readings, oldest first; throws FormatException
/// for a file that is neither.
List<VedaReading> parseVedaReadings(String text) {
  final json = jsonDecode(text);
  if (json is! Map) throw const FormatException('Not a Véda file');
  final List rows;
  if (json['schema'] == 'veda-link/1') {
    rows = (json['readings'] as List?) ?? const [];
    return [
      for (final r in rows)
        VedaReading.fromJson((r as Map).cast<String, Object?>()),
    ]..sort((a, b) => a.takenAt.compareTo(b.takenAt));
  }
  final scans = json['scans'];
  if (scans is! List) throw const FormatException('No readings in this file');
  final out = <VedaReading>[];
  for (final s in scans) {
    if (s is! Map) continue;
    final created = s['created_at'];
    if (created is! String) continue;
    final rawScores = (s['scores'] as Map?) ?? const {};
    final scores = <String, double>{};
    for (final m in kVedaMetrics) {
      final v = rawScores[m];
      if (v is num) scores[m] = v.toDouble();
    }
    final skin = rawScores['skin_score'];
    out.add(
      VedaReading(
        takenAt: DateTime.parse(created).toLocal(),
        slot: s['time_of_day'] as String?,
        skinScore: skin is num ? skin.toDouble() : null,
        scores: scores,
      ),
    );
  }
  out.sort((a, b) => a.takenAt.compareTo(b.takenAt));
  return out;
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

  /// Replaces what is held with the readings in [text]. Returns how many.
  Future<int> importText(String text) async {
    final readings = parseVedaReadings(text);
    await set(VedaLinkData(readings: readings, importedAt: clock()));
    return readings.length;
  }

  /// Lets the person pick the file Véda exported. Null if they cancelled.
  Future<int?> pickAndImport() async {
    final picked = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );
    final file = picked?.files.singleOrNull;
    if (file == null) return null;
    final text = file.bytes != null
        ? utf8.decode(file.bytes!)
        : await File(file.path!).readAsString();
    return importText(text);
  }
}
