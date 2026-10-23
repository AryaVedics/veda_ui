// A slow 0 to 1 and back, for the soft "waiting for data" ghosts. Holds still
// (at the middle) when the phone asks for reduced motion.

import 'package:flutter/material.dart';

class Breathing extends StatefulWidget {
  const Breathing({super.key, required this.builder});

  /// [t] is 0 to 1, eased.
  final Widget Function(BuildContext context, double t) builder;

  @override
  State<Breathing> createState() => _BreathingState();
}

class _BreathingState extends State<Breathing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse
        ..stop()
        ..value = 0.5;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (context, _) =>
        widget.builder(context, Curves.easeInOut.transform(_pulse.value)),
  );
}
