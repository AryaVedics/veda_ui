// "Your measurements on days like this": the person's Véda readings, grouped by
// something in a companion app (slept 7-8h, a luteal-phase day, a high-UV day),
// shown in Véda's own Rings, Petals or Bars, switchable, as in Véda.
//
// Descriptive only: the average of the person's readings on days that match,
// with the number of days it rests on. Always captioned "A difference, not
// proof of a cause", because a handful of days can look like a pattern.

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'charts.dart';
import 'common.dart';
import 'metric_views.dart';
import 'theme.dart';
import 'veda_link.dart';

/// One group's averages: the Skin Score and each of the seven measurements.
class GroupMetrics {
  const GroupMetrics(this.label, this.days, this.skinScore, this.scores);

  final String label;

  /// How many days (with at least one reading) it rests on.
  final int days;
  final double? skinScore;

  /// The seven measurements, in Véda's order, only those that had values.
  final Map<String, double> scores;

  bool get isEmpty => days == 0;
}

/// Groups the person's Véda readings by [groupOf] (a group name for a day, or
/// null for a day that belongs to none), averaging within each day first so a
/// day with three readings counts once.
List<GroupMetrics> groupMetrics({
  required VedaLinkData readings,
  required List<String> groups,
  required String? Function(DateTime day) groupOf,
}) {
  final byDay = <DateTime, List<VedaReading>>{};
  for (final r in readings.readings) {
    byDay.putIfAbsent(dayOf(r.takenAt), () => []).add(r);
  }
  final perGroup = {for (final g in groups) g: <Map<String, double>>[]};
  byDay.forEach((day, rs) {
    final g = groupOf(day);
    if (g == null || !perGroup.containsKey(g)) return;
    final avg = <String, double>{};
    for (final key in [skinScoreName, ...kVedaMetrics]) {
      final values = [
        for (final r in rs)
          if (key == skinScoreName
              ? r.skinScore != null
              : r.scores[key] != null)
            key == skinScoreName ? r.skinScore! : r.scores[key]!,
      ];
      if (values.isNotEmpty) {
        avg[key] = values.reduce((a, b) => a + b) / values.length;
      }
    }
    perGroup[g]!.add(avg);
  });
  return [
    for (final g in groups)
      () {
        final days = perGroup[g]!;
        double? mean(String key) {
          final v = [
            for (final d in days)
              if (d[key] != null) d[key]!,
          ];
          return v.isEmpty ? null : v.reduce((a, b) => a + b) / v.length;
        }

        return GroupMetrics(g, days.length, mean(skinScoreName), {
          for (final m in kVedaMetrics)
            if (mean(m) != null) m: mean(m)!,
        });
      }(),
  ];
}

/// The key the Skin Score is kept under inside a group's averages.
const skinScoreName = 'skin_score';

const _styleKey = 'metric_chart_style';

/// The card: a chip per group, then the picked group's measurements in the
/// style chosen (remembered, shared by every chart in the app).
class GroupMetricsCard extends StatefulWidget {
  const GroupMetricsCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.groups,
    required this.caveat,
    this.empty,
    this.defaultStyle = MetricStyle.petals,
  });

  final String title;
  final String subtitle;
  final List<GroupMetrics> groups;

  /// What the figures rest on, e.g. "Days with both a Véda reading and a check-in."
  final String caveat;

  /// Shown instead of the chart when there is nothing to chart yet.
  final String? empty;

  /// The style shown until the person picks one (then theirs is remembered).
  final MetricStyle defaultStyle;

  @override
  State<GroupMetricsCard> createState() => _GroupMetricsCardState();
}

class _GroupMetricsCardState extends State<GroupMetricsCard> {
  late MetricStyle _style = widget.defaultStyle;
  String? _picked;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance()
        .then((prefs) {
          final saved = prefs.getString(_styleKey);
          final s = MetricStyle.values
              .where((v) => v.name == saved)
              .firstOrNull;
          if (s != null && mounted) setState(() => _style = s);
        })
        .catchError((_) {});
  }

  void _setStyle(MetricStyle s) {
    setState(() => _style = s);
    SharedPreferences.getInstance()
        .then((p) => p.setString(_styleKey, s.name))
        .catchError((_) => false);
  }

  GroupMetrics? get _current {
    final withDays = widget.groups.where((g) => !g.isEmpty).toList();
    if (withDays.isEmpty) return null;
    return widget.groups
            .where((g) => g.label == _picked && !g.isEmpty)
            .firstOrNull ??
        withDays.first;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final current = _current;
    return ChartCard(
      title: widget.title,
      subtitle: widget.subtitle,
      empty:
          widget.empty ??
          (current == null
              ? 'Nothing to show yet: this fills in once a day has both a Véda '
                    'reading and an entry here.'
              : null),
      child: current == null
          ? const SizedBox.shrink()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final g in widget.groups)
                      ChoiceChip(
                        label: Text(
                          g.isEmpty ? g.label : '${g.label} · ${g.days}d',
                        ),
                        selected: g.label == current.label,
                        labelStyle: TextStyle(
                          fontSize: 13,
                          color: g.label == current.label
                              ? colors.accentText
                              : g.isEmpty
                              ? colors.textMuted
                              : colors.textSecondary,
                        ),
                        onSelected: g.isEmpty
                            ? null
                            : (_) => setState(() => _picked = g.label),
                      ),
                  ],
                ),
                const SizedBox(height: 14),
                if (current.skinScore != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        current.skinScore!.round().toString(),
                        style: TextStyle(
                          fontSize: 34,
                          height: 1,
                          fontFamily: kDisplayFont,
                          color: colors.accentText,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Text(
                          'average Skin Score over ${current.days} '
                          '${current.days == 1 ? 'day' : 'days'}',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: colors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 12),
                MetricStyleToggle(value: _style, onChanged: _setStyle),
                const SizedBox(height: 10),
                SizedBox(
                  height: 285,
                  child: SwipeableChartPager<MetricStyle>(
                    value: _style,
                    values: const [
                      MetricStyle.rings,
                      MetricStyle.petals,
                      MetricStyle.bars,
                    ],
                    onChanged: _setStyle,
                    builder: (s) => Center(
                      child: switch (s) {
                        MetricStyle.bars => MetricBarsView(
                          scores: current.scores,
                          colors: colors,
                          onTap: (_) {},
                        ),
                        MetricStyle.rings => MetricRingsView(
                          scores: current.scores,
                          colors: colors,
                          onTap: (_) {},
                        ),
                        MetricStyle.petals => MetricPetalsView(
                          scores: current.scores,
                          colors: colors,
                          onTap: (_) {},
                        ),
                      },
                    ),
                  ),
                ),
                ChartCaveat(widget.caveat),
              ],
            ),
    );
  }
}
