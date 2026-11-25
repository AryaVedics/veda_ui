// What the shared shelf (shelf_tab.dart, shelf_rings.dart) needs to know about
// one product, whatever the app: Routine's skin products, Hair's hair products.
// Each app turns its own product into one of these; the shelf never sees the
// app's own model, so neither app's data format is tied to it.

/// How a product is drawn on the shelf's ring. Only a look: it says nothing
/// about what the product is for.
enum BottleShape { bottle, jar, dropper, spray, comb }

class ShelfItem {
  const ShelfItem({
    required this.id,
    required this.name,
    required this.kindLabel,
    this.shape = BottleShape.bottle,
    this.opened,
    this.useBy,
    this.stopped,
    this.runningLow = false,
  });

  final String id;

  /// What to show: brand and name together, as the person knows it.
  final String name;

  /// The plain shelf category, only for grouping ("Cleanser", "Shampoo").
  final String kindLabel;

  final BottleShape shape;

  /// When the person opened it and the date their own "use within" period runs
  /// out, if they gave both.
  final DateTime? opened;
  final DateTime? useBy;

  /// Set when they stopped using it; null while it is on the shelf.
  final DateTime? stopped;

  /// A note the person made for themselves.
  final bool runningLow;

  bool get active => stopped == null;
}

/// The fraction (0 to 1) of an item's use-by period still left on [today], or
/// null when it has no use-by date. Past its date it is 0, never negative.
double? shelfTimeLeft(ShelfItem item, DateTime today) {
  final by = item.useBy, opened = item.opened;
  if (by == null || opened == null) return null;
  final total = by.difference(opened).inDays;
  if (total <= 0) return 0;
  final left = by
      .difference(DateTime(today.year, today.month, today.day))
      .inDays;
  return (left / total).clamp(0.0, 1.0);
}
