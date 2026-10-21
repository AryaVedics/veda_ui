import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:veda_ui/veda_ui.dart';

double _lum(Color c) {
  double lin(double v) =>
      v <= 0.03928 ? v / 12.92 : math.pow((v + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * lin(c.r) + 0.7152 * lin(c.g) + 0.0722 * lin(c.b);
}

double _contrast(Color a, Color b) {
  final la = _lum(a), lb = _lum(b);
  final hi = la > lb ? la : lb, lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('every palette keeps body text readable on cards and canvas', () {
    for (final entry in AppColors.all.entries) {
      final c = entry.value;
      for (final bg in [c.card, c.canvas]) {
        expect(_contrast(c.textPrimary, bg), greaterThanOrEqualTo(4.5),
            reason: '${entry.key} primary');
        expect(_contrast(c.textSecondary, bg), greaterThanOrEqualTo(4.5),
            reason: '${entry.key} secondary');
        expect(_contrast(c.textMuted, bg), greaterThanOrEqualTo(4.5),
            reason: '${entry.key} muted');
        expect(_contrast(c.accentText, bg), greaterThanOrEqualTo(4.5),
            reason: '${entry.key} gold text');
      }
    }
  });

  test('Véda\'s own export file becomes readings, and nothing else is kept', () {
    final export = jsonEncode({
      'account': {'id': 7, 'email': 'someone@example.com'},
      'consent_history': [],
      'scans': [
        {
          'created_at': '2026-10-20T14:00:00Z',
          'time_of_day': 'midday',
          'scores': {'redness': 89, 'texture': 82, 'skin_score': 88.4},
          'raw': {'redness': 1.2},
          'per_region': {'cheek': 3},
        },
        {
          'created_at': '2026-10-19T08:00:00Z',
          'time_of_day': 'morning',
          'scores': {'redness': 80},
        },
      ],
    });
    final readings = parseVedaReadings(export);
    expect(readings, hasLength(2));
    expect(readings.first.slot, 'morning'); // oldest first
    expect(readings.last.skinScore, 88.4);
    expect(readings.last.scores, {'redness': 89.0, 'texture': 82.0});
    final kept = jsonEncode([for (final r in readings) r.toJson()]);
    expect(kept.contains('example.com'), isFalse);
    expect(kept.contains('per_region'), isFalse);
  });

  test('the store round-trips through its file', () async {
    final file = MemoryJsonFile();
    final store = VedaLinkStore(file: file);
    await store.load();
    final n = await store.importText(jsonEncode({
      'schema': 'veda-link/1',
      'readings': [
        {'taken_at': '2026-10-20T14:00:00Z', 'skin_score': 86, 'scores': {}}
      ],
    }));
    expect(n, 1);
    final again = VedaLinkStore(file: file);
    await again.load();
    expect(again.data.readings.single.skinScore, 86);
  });

  test('a file that is not from Véda is refused', () {
    expect(() => parseVedaReadings('{"hello": 1}'), throwsFormatException);
  });
}
