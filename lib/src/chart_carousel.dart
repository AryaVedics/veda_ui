// Stacked charts as a carousel: one card at a time, a row of dots beneath, and
// a swipe (or a tap on a dot) to move between them. Every card keeps its own
// state while it is out of view, and the carousel is as tall as its tallest
// card, so the page never jumps as the cards change.
//
// A swipe anywhere on a card moves to the previous or next card. The charts
// inside a card do not swipe between Rings, Petals and Bars; their buttons
// do that by tap, so the swipe is never split between the two.
//
// House rule: any screen with more than one chart card uses this. A screen
// with a single chart passes it as the only child and gets no dots, so adding
// a second chart later makes it a carousel without any other change.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'charts.dart';
import 'group_metrics.dart';
import 'theme.dart';

/// Tells the charts inside a carousel card that the carousel owns the swipe:
/// a horizontal drag moves between cards, and the chart's own Rings, Petals
/// and Bars change by tapping the buttons above it instead.
class ChartCarouselScope extends InheritedWidget {
  const ChartCarouselScope({
    super.key,
    required this.titleInHeader,
    required super.child,
  });

  /// True when the carousel shows this card's title in its own dropdown, so the
  /// card leaves its title out.
  final bool titleInHeader;

  /// Whether the chart at [context] sits inside a carousel.
  static bool of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ChartCarouselScope>() != null;

  /// Whether the card at [context] has its title shown by the carousel above it.
  static bool titleInHeaderOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<ChartCarouselScope>()
          ?.titleInHeader ??
      false;

  @override
  bool updateShouldNotify(ChartCarouselScope old) =>
      old.titleInHeader != titleInHeader;
}

/// The title of a chart card, if it is one of ours (its own [title]).
String? _titleOf(Widget w) => switch (w) {
  GroupMetricsCard() => w.title,
  ChartCard() => w.title,
  _ => null,
};

class ChartCarousel extends StatefulWidget {
  const ChartCarousel({super.key, required this.children});

  final List<Widget> children;

  @override
  State<ChartCarousel> createState() => _ChartCarouselState();
}

class _ChartCarouselState extends State<ChartCarousel> {
  int _page = 0;

  /// How far the finger has gone sideways in the current drag, so a slow drag
  /// counts as well as a quick flick.
  double _drag = 0;

  int get _shown => _page.clamp(0, widget.children.length - 1);

  void _go(int to) {
    final n = widget.children.length;
    if (to < 0 || to >= n || to == _page) return;
    setState(() => _page = to);
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children;
    if (children.isEmpty) return const SizedBox.shrink();
    if (children.length == 1) return children.first;
    final colors = context.colors;
    final page = _shown;
    // With every card's title known, the title becomes the carousel's own
    // dropdown: tap it to pick a chart by name.
    final titles = [for (final c in children) _titleOf(c)];
    final showHeader = titles.every((t) => t != null);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showHeader) ...[
          _TitleMenu(
            titles: [for (final t in titles) t!],
            page: page,
            onPick: _go,
          ),
          const SizedBox(height: 6),
        ],
        GestureDetector(
          onHorizontalDragStart: (_) => _drag = 0,
          onHorizontalDragUpdate: (d) => _drag += d.delta.dx,
          onHorizontalDragEnd: (d) {
            final v = d.primaryVelocity ?? 0;
            // a quick flick decides by its direction, a slow drag by how far
            final dir = v.abs() > 250 ? v : _drag;
            if (v.abs() > 250 || _drag.abs() > 48) {
              _go(page + (dir < 0 ? 1 : -1));
            }
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              for (var i = 0; i < children.length; i++)
                IgnorePointer(
                  ignoring: i != page,
                  child: AnimatedSlide(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeOutCubic,
                    offset: Offset((i - page) * 0.06, 0),
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 260),
                      opacity: i == page ? 1 : 0,
                      // Only the card's own animations rest while it is out of
                      // view. The fade above must keep running, or a card
                      // swiped away from freezes half-faded on top of the next.
                      child: TickerMode(
                        enabled: i == page,
                        child: ChartCarouselScope(
                          titleInHeader: showHeader,
                          child: children[i],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < children.length; i++)
              InkWell(
                key: Key('carouselDot$i'),
                onTap: () => _go(i),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == page ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == page ? colors.accent : colors.accentDim,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// The chart's name, as a dropdown: the current chart's title with a caret.
/// Tap it to choose any chart in the carousel by name.
class _TitleMenu extends StatelessWidget {
  const _TitleMenu({
    required this.titles,
    required this.page,
    required this.onPick,
  });

  final List<String> titles;
  final int page;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return PopupMenuButton<int>(
      key: const Key('carouselTitleMenu'),
      initialValue: page,
      onSelected: onPick,
      color: colors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colors.accentDim),
      ),
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (var i = 0; i < titles.length; i++)
          PopupMenuItem<int>(
            value: i,
            child: Text(
              titles[i],
              style: TextStyle(
                fontSize: 14,
                color: i == page ? colors.accentText : colors.textPrimary,
              ),
            ),
          ),
      ],
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              titles[page],
              style: TextStyle(
                fontSize: 18,
                fontFamily: kDisplayFont,
                color: colors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Icon(PhosphorIconsThin.caretDown, size: 14, color: colors.textMuted),
        ],
      ),
    );
  }
}
