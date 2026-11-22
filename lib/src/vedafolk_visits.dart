// The Little Vedafolk's visits, in one place for the apps that came after the
// first few (Sleep, Hair, Garden, Learn, Today). Each of the older apps (Routine,
// Kitchen, Allergy, Curio) keeps its own copy of this; this one is parameter-
// ised so a new app only says where its friends hide and whether they start on.
//
// An optional visit, switched in Profile. When on, now and then one of the
// Vedafolk comes up from behind something in the app, waits a few quiet seconds
// and goes back. Company, nothing more: they never react to a reading, a
// missed day or anything the person logged. They stay still when the phone
// asks for reduced motion, and when another page or a sheet is on top.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'forest_animals.dart';
import 'forest_friends.dart';
import 'vedafolk.dart';

/// Whether the friends are on in this app, remembered on the phone.
///
/// Most apps start with them off ([defaultOn] false) and the person turns them
/// on in Profile; Véda Garden starts with them on, as Kitchen does.
class VedafolkPref {
  VedafolkPref({this.defaultOn = false, this.prefKey = 'forest_friends'})
    : on = ValueNotifier(defaultOn);

  final bool defaultOn;
  final String prefKey;
  final ValueNotifier<bool> on;

  /// Reads what was kept; with nothing kept, the default stands.
  Future<void> load() async {
    try {
      on.value =
          (await SharedPreferences.getInstance()).getBool(prefKey) ?? defaultOn;
    } catch (_) {
      // the default stands
    }
  }

  Future<void> set(bool value) async {
    on.value = value;
    try {
      await (await SharedPreferences.getInstance()).setBool(prefKey, value);
    } catch (_) {
      // still applies for this session
    }
  }
}

/// One visit: which friend, which side, how far along (0 to 1).
class VedafolkVisit {
  const VedafolkVisit(this.friend, this.side, this.progress);

  final ForestFriend friend;

  /// -1 on the left, 1 on the right.
  final double side;
  final double progress;

  /// How far out the head is, 0 hidden to 1 fully out: a slow rise, a quiet
  /// wait, a slow sink, all eased, nothing bouncing.
  double get rise {
    const edge = 0.26;
    return progress < edge
        ? Curves.easeInOutCubic.transform(progress / edge)
        : progress < 1 - edge
        ? 1.0
        : Curves.easeInOutCubic.transform((1 - progress) / edge);
  }
}

/// Schedules the visits and hands the current one to [builder] every frame
/// (null when nobody is visiting). Nothing happens while the friends are off.
class VedafolkVisits extends StatefulWidget {
  const VedafolkVisits({
    super.key,
    required this.pref,
    required this.builder,
    this.firstAfter = const Duration(seconds: 9),
    this.every = kVedafolkEvery,
    this.stays = const Duration(milliseconds: 9500),
  });

  final VedafolkPref pref;
  final Widget Function(BuildContext context, VedafolkVisit? visit) builder;
  final Duration firstAfter;
  final Duration every;
  final Duration stays;

  /// Where the dice come from; tests swap in a stand-in.
  @visibleForTesting
  static math.Random Function() random = math.Random.new;

  /// For renders: shows this visit and none other.
  @visibleForTesting
  static VedafolkVisit? debugVisit;

  @override
  State<VedafolkVisits> createState() => _VedafolkVisitsState();
}

class _VedafolkVisitsState extends State<VedafolkVisits>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: widget.stays,
  );
  final _rnd = VedafolkVisits.random();
  Timer? _timer;
  ForestFriend? _friend;
  ForestFriend? _last;
  var _side = 1.0;

  @override
  void initState() {
    super.initState();
    widget.pref.on.addListener(_schedule);
    _schedule();
  }

  void _schedule() {
    _timer?.cancel();
    _timer = null;
    if (widget.pref.on.value) {
      _timer = Timer(widget.firstAfter, _visit);
    } else {
      _c.value = 0;
    }
  }

  void _visit() {
    if (!mounted || !widget.pref.on.value) return;
    final quiet =
        MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled ||
        !(ModalRoute.of(context)?.isCurrent ?? true);
    if (!quiet) {
      final pool = [
        for (final f in kForestFriends)
          if (f != _last && kForestRotation.contains(f.animal)) f,
      ];
      _friend = pool[_rnd.nextInt(pool.length)];
      _last = _friend;
      _side = -_side; // alternate sides, so it is never the same corner twice
      _c.forward(from: 0);
    }
    // the next visit: between 0.7 and 1.3 times the usual gap
    final gap = widget.every.inMilliseconds * (0.7 + 0.6 * _rnd.nextDouble());
    _timer = Timer(Duration(milliseconds: gap.round()), _visit);
  }

  @override
  void dispose() {
    widget.pref.on.removeListener(_schedule);
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (context, _) {
      final debug = VedafolkVisits.debugVisit;
      if (debug != null) return widget.builder(context, debug);
      final p = _c.value;
      final f = _friend;
      return widget.builder(
        context,
        f == null || p <= 0 || p >= 1 ? null : VedafolkVisit(f, _side, p),
      );
    },
  );
}

/// Draws [friend]'s face with its centre at [at], radius [r], slightly turned.
void paintVedafolkHead(
  Canvas canvas,
  ForestFriend friend,
  Offset at,
  double r, {
  double turn = 0,
  double alpha = 1,
}) {
  canvas.save();
  if (alpha < 1) {
    canvas.saveLayer(
      Rect.fromCircle(center: at, radius: r * 2),
      Paint()..color = Color.fromRGBO(0, 0, 0, alpha),
    );
  }
  canvas.translate(at.dx, at.dy);
  canvas.rotate(turn);
  paintAnimalHead(
    canvas,
    friend.animal,
    Offset.zero,
    r,
    special: friend.special,
  );
  if (alpha < 1) canvas.restore();
  canvas.restore();
}

/// A friend who peeks up over the top edge of [child] (a card, a button): the
/// head rises from behind it, and the child is drawn over the chin. Costs no
/// room when nobody is visiting.
class VedafolkPeekOver extends StatelessWidget {
  const VedafolkPeekOver({
    super.key,
    required this.pref,
    required this.child,
    this.radius = 22,
  });

  final VedafolkPref pref;
  final Widget child;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: VedafolkVisits(
              pref: pref,
              builder: (context, visit) =>
                  CustomPaint(painter: _PeekOverPainter(visit, radius)),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _PeekOverPainter extends CustomPainter {
  _PeekOverPainter(this.visit, this.r);

  final VedafolkVisit? visit;
  final double r;

  @override
  void paint(Canvas canvas, Size size) {
    final v = visit;
    if (v == null || v.rise <= 0) return;
    // behind the child: drawn first, then the child covers the chin
    final x = size.width / 2 + v.side * size.width * 0.28;
    final y = r * 1.3 - v.rise * r * 2.2;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(x - r * 2, -r * 3, x + r * 2, size.height));
    paintVedafolkHead(canvas, v.friend, Offset(x, y), r, turn: v.side * 0.04);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_PeekOverPainter old) =>
      old.visit?.progress != visit?.progress ||
      old.visit?.friend != visit?.friend;
}

/// The Profile row with the switch, the same wording and pace in every app.
class VedafolkRow extends StatelessWidget {
  const VedafolkRow({super.key, required this.pref, required this.where});

  final VedafolkPref pref;

  /// Where the friends hide in this app: "behind the braid".
  final String where;

  @override
  Widget build(BuildContext context) =>
      VedafolkSwitchRow(on: pref.on, onChanged: pref.set, where: where);
}
