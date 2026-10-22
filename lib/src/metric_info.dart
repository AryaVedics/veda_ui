// What each of the seven measurements actually looks for — the one place
// this copy is written, so it can't drift between where it's shown:
//
//   - the website's "How your score works" page (backend/site/how-your-score-works.html)
//     repeats this copy: change it there too.
//   - score_info_screen.dart shows all seven, in order, for anyone who
//     wants the full picture (Profile > About > "How your score works").
//   - reading_screen.dart shows one at a time, for whichever metric is
//     currently selected on an actual reading — the moment someone is
//     looking at "Redness 84" and wants to know what that means, without
//     leaving the screen they're on.
//
// Content mirrors backend/skincv/METRICS.md, translated out of CV
// vocabulary into what a person actually wants to know: what's being
// looked at, and what higher means (always: clearer skin, for all seven).

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class MetricInfo {
  const MetricInfo(
      {required this.key,
      required this.icon,
      required this.name,
      required this.body,
      required this.identityColor});

  /// The server's key for this metric (matches ScanResult.scores), e.g.
  /// "redness" — how reading_screen.dart looks one of these up.
  final String key;
  final IconData icon;
  final String name;
  final String body;

  /// A fixed, per-metric accent used only to tell metrics apart at a
  /// glance (a border on a bar, a ring's edge, a petal's vein) — never as
  /// the thing that carries the actual value. That's still always gold,
  /// the same for a 40 as a 90: see app_colors.dart's "no color encodes
  /// valence" rule. This is identity, not judgment.
  final Color identityColor;
}

/// Same order the backend returns them in (skincv/metrics/__init__.py).
const List<MetricInfo> metricInfoList = [
  MetricInfo(
    key: 'redness',
    icon: PhosphorIconsThin.drop,
    name: 'Redness',
    body: 'Extra redness across your skin, measured apart from your '
        'natural skin tone.',
    identityColor: Color(0xFFD1453B),
  ),
  MetricInfo(
    key: 'texture',
    icon: PhosphorIconsThin.fingerprint,
    name: 'Texture',
    body: "How rough or smooth your skin's surface looks — bumps, "
        'dryness, and unevenness you might feel more than see.',
    // A muted sage rather than the warm tan this used to be (2026-09-27):
    // that tan sat close enough to both Wrinkles' brown below and the
    // app's own gold accent to blur into either at a glance — green is
    // otherwise unused across all seven metrics, so it stands apart
    // cleanly instead.
    identityColor: Color(0xFF9CAF88),
  ),
  MetricInfo(
    key: 'pores',
    icon: PhosphorIconsThin.dotsNine,
    name: 'Pores',
    body: 'How visible your pores are.',
    // A clean blue rather than the blue-grey this used to be — picked
    // away from both the plum canvas's own blue-violet hue and
    // Evenness's teal below, so it doesn't blend into the background or
    // crowd its nearest neighbor on the wheel.
    identityColor: Color(0xFF87A6C5),
  ),
  MetricInfo(
    key: 'spots',
    icon: PhosphorIconsThin.circle,
    name: 'Spots',
    body: 'Dark spots and discoloration, counted separately from '
        'redness and from overall evenness.',
    identityColor: Color(0xFFC7C7CC),
  ),
  MetricInfo(
    key: 'acne',
    icon: PhosphorIconsThin.bandaids,
    name: 'Acne',
    body: 'Active breakouts — inflamed bumps, not scarring left behind '
        'afterward.',
    identityColor: Color(0xFFED93B1),
  ),
  MetricInfo(
    key: 'evenness',
    icon: PhosphorIconsThin.gradient,
    name: 'Evenness',
    body: 'How uniform your overall tone is across your face, apart '
        'from any spots.',
    identityColor: Color(0xFF7FAFB3),
  ),
  MetricInfo(
    key: 'wrinkles',
    icon: PhosphorIconsThin.waves,
    name: 'Wrinkles',
    body: 'Fine lines and creases, mostly around the eyes and '
        'forehead.',
    identityColor: Color(0xFF9C8570),
  ),
];

final Map<String, MetricInfo> metricInfoByKey = {
  for (final m in metricInfoList) m.key: m,
};
