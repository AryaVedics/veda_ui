// Copy of Véda's TodayTabIcon (flutter_app/lib/widgets/today_tab_icon.dart),
// which is the template: change it there first, then here. Keep in step.
// The Today tab's own icon — a calendar showing the actual day of the
// month, the way a real calendar app icon does, instead of Phosphor's
// calendar glyph, which has a fixed illustrative number (12) baked into
// the artwork and can never be anything else.
//
// Built on calendarBlank — the same calendar frame with no number drawn
// in — with the real day layered on top as text. The vertical offset is
// tuned by eye against Phosphor's own icon grid, not computed from
// anything: there's no metadata exposing where a glyph's "body" starts.
//
// Self-updating: a Stateful widget with its own midnight timer, rather
// than reading DateTime.now() once in build(). Without this, someone who
// leaves the app open overnight (or just backgrounded, not force-closed)
// would see yesterday's date until something else happened to trigger a
// rebuild — a calendar icon that's wrong is worse than no date at all.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';

class TodayTabIcon extends StatefulWidget {
  const TodayTabIcon({super.key, required this.selected, required this.color});

  final bool selected;
  final Color color;

  @override
  State<TodayTabIcon> createState() => _TodayTabIconState();
}

class _TodayTabIconState extends State<TodayTabIcon>
    with WidgetsBindingObserver {
  late int _day = DateTime.now().day;
  Timer? _midnightTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleMidnightRefresh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) return;
    _midnightTimer?.cancel();
    setState(() => _day = DateTime.now().day);
    _scheduleMidnightRefresh();
  }

  void _scheduleMidnightRefresh() {
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      if (!mounted) return;
      setState(() => _day = DateTime.now().day);
      _scheduleMidnightRefresh();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final color = widget.color;
    // The fill glyph's body is a solid shape in `color` — text in that
    // same color disappears into it. onAccent (used everywhere else for
    // text sitting on a gold fill) is the one that actually shows up
    // there; the thin outline has no such fill to fight, so plain
    // `color` still reads fine against it.
    final numberColor = selected ? context.colors.onAccent : color;
    return Stack(
      alignment: Alignment.center,
      children: [
        Icon(
          selected
              ? PhosphorIconsFill.calendarBlank
              : PhosphorIconsThin.calendarBlank,
          color: color,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '$_day',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              height: 1,
              color: numberColor,
            ),
          ),
        ),
      ],
    );
  }
}
