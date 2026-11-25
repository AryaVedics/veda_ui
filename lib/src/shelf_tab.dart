// The Shelf tab, shared by the apps that keep a shelf (Routine, Hair): every
// product the person uses as a ring of bottles, a note of the ones they marked
// as running low, the same products as a list, and the ones they stopped. No
// ratings, no suggestions.
//
// The app decides what a row says ([detail]), what goes above the products
// ([leading]) and what adding or editing a product opens; the shelf only
// shows what it is given.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'common.dart';
import 'shelf_item.dart';
import 'shelf_rings.dart';

class ShelfTab extends StatefulWidget {
  const ShelfTab({
    super.key,
    required this.active,
    required this.stopped,
    required this.soonCount,
    required this.detail,
    required this.onAdd,
    required this.onEdit,
    required this.emptyText,
    this.leading = const [],
    this.sky = ShelfSky.night,
    this.fireflies = true,
    this.today,
  });

  /// The products on the shelf, and those the person stopped, each in the
  /// order the app wants them shown.
  final List<ShelfItem> active;
  final List<ShelfItem> stopped;

  /// How many are within a month of their use-by date.
  final int soonCount;

  /// The small line under a product's name in the list.
  final String Function(ShelfItem) detail;
  final VoidCallback onAdd;
  final void Function(ShelfItem) onEdit;

  /// What the empty shelf says.
  final String emptyText;

  /// Cards above the products (Routine puts its Education row here).
  final List<Widget> leading;
  final ShelfSky sky;
  final bool fireflies;

  /// The day the use-by arcs count to; today when null.
  final DateTime? today;

  @override
  State<ShelfTab> createState() => _ShelfTabState();
}

class _ShelfTabState extends State<ShelfTab> {
  bool _showStopped = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final active = widget.active, stopped = widget.stopped;
    final low = [
      for (final p in active)
        if (p.runningLow) p,
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Column(
        children: [
          ScreenHeader(
            title: 'Shelf',
            actions: [
              HeaderIconButton(
                icon: PhosphorIconsThin.plus,
                tooltip: 'Add a product',
                onTap: widget.onAdd,
              ),
            ],
          ),
          // the shelf itself scrolls when there are many products; the button
          // below stays anchored
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 18, bottom: 12),
              children: [
                for (final w in widget.leading) ...[
                  w,
                  const SizedBox(height: 14),
                ],
                if (active.isEmpty)
                  EmptyNote(
                    icon: PhosphorIconsThin.drop,
                    text: widget.emptyText,
                  )
                else ...[
                  Center(
                    child: ShelfRings(
                      items: active,
                      soonCount: widget.soonCount,
                      today: widget.today ?? DateTime.now(),
                      onEdit: widget.onEdit,
                      sky: widget.sky,
                      fireflies: widget.fireflies,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (low.isNotEmpty) ...[
                    _RunningLowCard(items: low),
                    const SizedBox(height: 12),
                  ],
                  CardBox(
                    padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                    child: Column(
                      children: [
                        for (var i = 0; i < active.length; i++) ...[
                          if (i > 0) Divider(height: 1, color: colors.divider),
                          _ItemRow(
                            item: active[i],
                            detail: widget.detail(active[i]),
                            onTap: () => widget.onEdit(active[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                if (stopped.isNotEmpty) ...[
                  const SizedBox(height: 22),
                  InkWell(
                    onTap: () => setState(() => _showStopped = !_showStopped),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Icon(
                            PhosphorIconsThin.archive,
                            size: 18,
                            color: colors.textMuted,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Stopped (${stopped.length})',
                              style: TextStyle(
                                fontSize: 13.5,
                                color: colors.textSecondary,
                              ),
                            ),
                          ),
                          Icon(
                            _showStopped
                                ? PhosphorIconsThin.caretUp
                                : PhosphorIconsThin.caretDown,
                            size: 16,
                            color: colors.textMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showStopped)
                    CardBox(
                      padding: const EdgeInsets.fromLTRB(16, 6, 8, 6),
                      child: Column(
                        children: [
                          for (var i = 0; i < stopped.length; i++) ...[
                            if (i > 0)
                              Divider(height: 1, color: colors.divider),
                            _ItemRow(
                              item: stopped[i],
                              detail: widget.detail(stopped[i]),
                              onTap: () => widget.onEdit(stopped[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          GoldButton(label: 'Add a product', onPressed: widget.onAdd),
        ],
      ),
    );
  }
}

/// The products the person has marked as running low: their own note, shown
/// back to them. It says nothing about what to buy.
class _RunningLowCard extends StatelessWidget {
  const _RunningLowCard({required this.items});

  final List<ShelfItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      child: Row(
        children: [
          Icon(PhosphorIconsThin.drop, size: 20, color: colors.accentText),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Running low: ${items.map((p) => p.name).join(', ')}',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.4,
                color: colors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({
    required this.item,
    required this.detail,
    required this.onTap,
  });

  final ShelfItem item;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: item.active
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    detail,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ),
            ),
            Icon(
              PhosphorIconsThin.pencilSimple,
              size: 16,
              color: colors.textMuted,
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
    );
  }
}
