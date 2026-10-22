// Plays a chart's data in from empty once, instead of it just appearing —
// used by the Bars/Rings/Petals metric views so a reading arriving reads as
// something settling into place, not a snap. (The Skin Score ring runs its
// own timeline, since its count-up is followed by a glint.)
//
// Runs once per mount, not on every rebuild: a StatefulWidget only calls
// initState (which starts the animation) when it's newly inserted into the
// tree, so a parent rebuilding with fresh scores doesn't replay this: only
// switching to a different chart style, or the card appearing for the
// first time, does.

import 'package:flutter/material.dart';

class DataReveal extends StatefulWidget {
  const DataReveal({
    super.key,
    required this.builder,
    this.duration = const Duration(milliseconds: 800),
  });

  /// [tAt] gives item [index] (of [count] total) its own 0-1 progress.
  /// Multiple items are staggered into a cascade rather than all animating
  /// in lockstep — each one starts a little after the last and takes most
  /// of the remaining duration to finish. A single item (count == 1) just
  /// runs the full duration.
  final Widget Function(
    BuildContext context,
    double Function(int index, int count) tAt,
  )
  builder;
  final Duration duration;

  @override
  State<DataReveal> createState() => _DataRevealState();
}

class _DataRevealState extends State<DataReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _tAt(int index, int count) {
    if (count <= 1) {
      return Curves.easeOutCubic.transform(_controller.value);
    }
    final start = (index / count) * 0.5;
    final end = (start + 0.6).clamp(0.0, 1.0);
    return Interval(
      start,
      end,
      curve: Curves.easeOutCubic,
    ).transform(_controller.value);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) => widget.builder(context, _tAt),
    );
  }
}
