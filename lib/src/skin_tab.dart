// The Skin tab every companion app can show: the person's Véda skin results,
// read from Véda on this phone, kept in one place (the last tab before
// Profile) so skin is never the centre of an app that is about something
// else. On by default; Profile has the switch, with one gentle confirmation
// when turning it off. Without Véda it is still there, as a soft ghost chart
// and an invitation, because that is how a person learns Véda exists.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';
import 'charts.dart';
import 'chart_style.dart';
import 'common.dart';
import 'link_bridge.dart';
import 'metric_ghost.dart';
import 'metric_views.dart';
import 'open_veda.dart';
import 'theme.dart';
import 'veda_link.dart';

const _key = 'show_skin_tab';

/// Whether this app shows its Skin tab. Remembered on the phone.
class SkinTabPref {
  SkinTabPref._();

  static final instance = SkinTabPref._();

  final ValueNotifier<bool> shown = ValueNotifier(true);

  bool _loaded = false;

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    try {
      shown.value =
          (await SharedPreferences.getInstance()).getBool(_key) ?? true;
    } catch (_) {
      // On, as by default.
    }
  }

  Future<void> set(bool on) async {
    shown.value = on;
    try {
      await (await SharedPreferences.getInstance()).setBool(_key, on);
    } catch (_) {
      // Still applies for this session.
    }
  }
}

/// Profile's "Show the Skin tab" row. Turning it off asks once.
class SkinTabSection extends StatelessWidget {
  const SkinTabSection({super.key, required this.loseOnOff});

  /// What the person would lose, in a few words, for the confirmation:
  /// "your skin by cycle phase and your Skin Score charts".
  final String loseOnOff;

  Future<void> _change(BuildContext context, bool on) async {
    if (on) {
      await SkinTabPref.instance.set(true);
      return;
    }
    final off = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Turn off the Skin tab?'),
        content: Text(
          "You'll lose $loseOnOff here. Your link with Véda stays as it is, "
          'and you can turn the tab back on any time in Profile.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Turn off'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Keep it'),
          ),
        ],
      ),
    );
    if (off == true) await SkinTabPref.instance.set(false);
  }

  @override
  Widget build(BuildContext context) {
    return CardBox(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: ValueListenableBuilder<bool>(
        valueListenable: SkinTabPref.instance.shown,
        builder: (context, on, _) => ProfileRow(
          icon: PhosphorIconsThin.sparkle,
          title: 'Show the Skin tab',
          subtitle:
              'Your Véda skin results, beside what you track here. They come '
              'from Véda on this phone.',
          trailing: Switch(value: on, onChanged: (v) => _change(context, v)),
        ),
      ),
    );
  }
}

/// The Skin tab itself.
class SkinTabScreen extends StatelessWidget {
  const SkinTabScreen({
    super.key,
    required this.link,
    required this.bridge,
    this.cards = const [],
    this.hud = false,
  });

  final VedaLinkStore link;
  final LinkBridge bridge;

  /// The app's own skin cards, after the trend ("Your skin by sleep",
  /// "Your skin by phase").
  final List<Widget> cards;

  /// Bars in the readout look (Lifestyle).
  final bool hud;

  /// The average Skin Score of the last seven days, and of the seven before.
  ({double? now, double? before}) _weeks(DateTime today) {
    double? avg(int fromAgo, int toAgo) {
      final scores = <double>[];
      for (var i = fromAgo; i <= toAgo; i++) {
        final s = link.data.skinScoreOn(
          DateTime(today.year, today.month, today.day - i),
        );
        if (s != null) scores.add(s);
      }
      return scores.isEmpty
          ? null
          : scores.reduce((a, b) => a + b) / scores.length;
    }

    return (now: avg(0, 6), before: avg(7, 13));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final readings = link.data.readings;
    final children = <Widget>[const SizedBox(height: 8)];
    if (readings.isEmpty) {
      children.add(_Invite(bridge: bridge));
    } else {
      final today = DateTime.now();
      final latest =
          (readings.toList()..sort((a, b) => a.takenAt.compareTo(b.takenAt)))
              .last;
      final w = _weeks(today);
      final change = w.now == null || w.before == null
          ? null
          : (w.now! - w.before!).round();
      children
        ..add(
          _Hero(score: latest.skinScore, change: change, on: latest.takenAt),
        )
        ..add(const SizedBox(height: 16))
        ..add(_Latest(scores: latest.scores, hud: hud))
        ..add(const SizedBox(height: 14))
        ..add(
          ChartCard(
            title: 'Skin Score, last 30 days',
            subtitle: 'From your Véda readings',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TrendChart(
                  days: [
                    for (var i = 29; i >= 0; i--)
                      () {
                        final d = DateTime(
                          today.year,
                          today.month,
                          today.day - i,
                        );
                        return TrendDay(d, score: link.data.skinScoreOn(d));
                      }(),
                  ],
                ),
                const ChartCaveat('A reading, not a diagnosis.'),
              ],
            ),
          ),
        );
      for (final c in cards) {
        children
          ..add(const SizedBox(height: 14))
          ..add(c);
      }
      children
        ..add(const SizedBox(height: 18))
        ..add(
          Center(
            child: TextButton(
              onPressed: openVeda,
              child: Text(
                'Open Véda for a new reading',
                style: TextStyle(color: colors.accentText),
              ),
            ),
          ),
        );
    }
    return PinnedHeaderList(
      header: const ScreenHeader(title: 'Skin'),
      children: children,
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.score, required this.change, required this.on});

  final double? score;
  final int? change;
  final DateTime on;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = score;
    final line = change == null
        ? 'Latest reading ${dayMonth(on)}'
        : change == 0
        ? 'About the same as the week before'
        : change! > 0
        ? 'Up $change on the week before'
        : 'Down ${-change!} on the week before';
    return Column(
      children: [
        SizedBox(
          width: 150,
          height: 150,
          child: CustomPaint(
            painter: _RingPainter(
              fraction: ((shown ?? 0) / 100).clamp(0.0, 1.0),
              track: colors.accentDim,
              fill: colors.accent,
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    shown == null ? '–' : '${shown.round()}',
                    style: TextStyle(
                      fontSize: 46,
                      fontFamily: kDisplayFont,
                      height: 1,
                      color: colors.accent,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKIN SCORE',
                    style: TextStyle(
                      fontSize: 10,
                      letterSpacing: 1.2,
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          line,
          style: TextStyle(fontSize: 13.5, color: colors.textSecondary),
        ),
      ],
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.fraction,
    required this.track,
    required this.fill,
  });

  final double fraction;
  final Color track;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 13.0;
    final rect = (Offset.zero & size).deflate(stroke / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, 6.2831853, false, paint..color = track);
    if (fraction > 0) {
      canvas.drawArc(
        rect,
        -1.5707963,
        6.2831853 * fraction,
        false,
        paint..color = fill,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.fraction != fraction || old.track != track || old.fill != fill;
}

/// The latest reading's measurements, in the app's chosen chart style.
class _Latest extends StatelessWidget {
  const _Latest({required this.scores, required this.hud});

  final Map<String, double> scores;
  final bool hud;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final shown = {
      for (final k in kVedaMetrics)
        if (scores[k] != null) k: scores[k]!,
    };
    return ValueListenableBuilder<MetricStyle>(
      valueListenable: ChartStylePref.instance.style,
      builder: (context, style, _) => CardBox(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your latest measurements',
              style: TextStyle(
                fontSize: 18,
                fontFamily: kDisplayFont,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            MetricStyleToggle(
              value: style,
              onChanged: ChartStylePref.instance.set,
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 285,
              child: SwipeableChartPager<MetricStyle>(
                value: style,
                values: const [
                  MetricStyle.rings,
                  MetricStyle.petals,
                  MetricStyle.bars,
                ],
                onChanged: ChartStylePref.instance.set,
                builder: (s) => Center(
                  child: switch (s) {
                    MetricStyle.bars => MetricBarsView(
                      scores: shown,
                      colors: colors,
                      onTap: (_) {},
                      hud: hud,
                    ),
                    MetricStyle.rings => MetricRingsView(
                      scores: shown,
                      colors: colors,
                      onTap: (_) {},
                    ),
                    MetricStyle.petals => MetricPetalsView(
                      scores: shown,
                      colors: colors,
                      onTap: (_) {},
                    ),
                  },
                ),
              ),
            ),
            const ChartCaveat('Taken from your latest Véda reading.'),
          ],
        ),
      ),
    );
  }
}

/// Without any Véda readings here yet: a ghost of the chart and what to do.
class _Invite extends StatelessWidget {
  const _Invite({required this.bridge});

  final LinkBridge bridge;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ListenableBuilder(
      listenable: bridge,
      builder: (context, _) {
        final status = bridge.readOf(LinkApp.skin).status;
        final installed =
            status != LinkStatus.notInstalled && status != LinkStatus.unknown;
        final unlinked = status == LinkStatus.unlinked;
        return CardBox(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'See your skin here too',
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: kDisplayFont,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                unlinked
                    ? 'You have unlinked Véda from this app. Switch it back on in '
                          'Profile, under "My other Véda apps", and your Skin Score '
                          'and measurements appear here.'
                    : installed
                    ? 'Véda is on this phone. In Véda, turn on "Let my other '
                          'Véda apps use my readings", and switch on "Use '
                          'entries from my other Véda apps" in Profile here. '
                          'Your Skin Score and measurements appear beside '
                          'what you track.'
                    : 'Véda is our skin app. It reads your skin from a quick '
                          'photo, and its results show up here, beside what '
                          'you track. Nothing leaves your phone.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.45,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 230,
                child: ValueListenableBuilder<MetricStyle>(
                  valueListenable: ChartStylePref.instance.style,
                  builder: (context, style, _) => GhostMetricChart(
                    style: style,
                    keys: const ['redness', 'texture', 'pores', 'spots'],
                    colors: colors,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton(
                  onPressed: openVeda,
                  child: Text(installed ? 'Open Véda' : 'Get Véda'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
