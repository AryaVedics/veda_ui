// The way every Véda calendar changes month: tap the month and year in its
// header and a drop-down opens just below it, with a year to choose and the
// twelve months to pick from. One place, so every app does it the same way
// (see UI_RULES.md, "Calendars").

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'theme.dart';

const _shortMonths = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _monthNames = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

/// The first month any Véda calendar reaches, in every app, for ever. Fixed on
/// purpose: it does not move with the years, so what a person logged long ago
/// is always within reach, and someone backfilling days from a few years back
/// always has somewhere to go.
final kCalendarEarliestMonth = DateTime(2023);

/// A calendar's month and year, as a tappable title that opens the drop-down.
class MonthYearTitle extends StatelessWidget {
  const MonthYearTitle({
    super.key,
    required this.month,
    required this.earliest,
    required this.latest,
    required this.onPicked,
  });

  /// The month showing now (the day is ignored).
  final DateTime month;

  /// The first and last months the list may reach.
  final DateTime earliest;
  final DateTime latest;
  final ValueChanged<DateTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Builder(
      builder: (anchor) => Semantics(
        button: true,
        label: 'Choose month and year',
        child: InkWell(
          onTap: () async {
            final picked = await showMonthYearDropdown(
              anchor,
              initial: month,
              earliest: earliest,
              latest: latest,
            );
            if (picked != null) onPicked(picked);
          },
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${_monthNames[month.month - 1]} ${month.year}',
                  style: TextStyle(
                    fontSize: 16,
                    fontFamily: kDisplayFont,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  PhosphorIconsThin.caretDown,
                  size: 14,
                  color: colors.textMuted,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens the drop-down just below [anchor]'s widget and returns the month the
/// person picked (the 1st of it), or null if they dismissed it.
Future<DateTime?> showMonthYearDropdown(
  BuildContext anchor, {
  required DateTime initial,
  required DateTime earliest,
  required DateTime latest,
}) {
  final box = anchor.findRenderObject() as RenderBox;
  final origin = box.localToGlobal(Offset.zero);
  final target = Rect.fromLTWH(
    origin.dx,
    origin.dy,
    box.size.width,
    box.size.height,
  );
  return showGeneralDialog<DateTime>(
    context: anchor,
    barrierDismissible: true,
    barrierLabel: 'Close',
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 160),
    pageBuilder: (context, _, _) => _Dropdown(
      target: target,
      initial: initial,
      earliest: earliest,
      latest: latest,
    ),
    transitionBuilder: (_, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
      child: child,
    ),
  );
}

class _Dropdown extends StatefulWidget {
  const _Dropdown({
    required this.target,
    required this.initial,
    required this.earliest,
    required this.latest,
  });

  final Rect target;
  final DateTime initial;
  final DateTime earliest;
  final DateTime latest;

  @override
  State<_Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<_Dropdown> {
  late int _year = widget.initial.year;

  bool _allowed(int year, int month) {
    final m = DateTime(year, month);
    return !m.isBefore(DateTime(widget.earliest.year, widget.earliest.month)) &&
        !m.isAfter(DateTime(widget.latest.year, widget.latest.month));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final screen = MediaQuery.sizeOf(context);
    final width = (screen.width - 40).clamp(240.0, 330.0);
    final left = (widget.target.center.dx - width / 2).clamp(
      20.0,
      screen.width - 20 - width,
    );
    final years = [
      for (var y = widget.latest.year; y >= widget.earliest.year; y--) y,
    ];
    return Stack(
      children: [
        Positioned(
          left: left,
          top: widget.target.bottom + 6,
          width: width,
          child: Material(
            color: colors.card,
            elevation: 8,
            shadowColor: Colors.black54,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: _year,
                      isExpanded: true,
                      dropdownColor: colors.card,
                      icon: Icon(
                        PhosphorIconsThin.caretDown,
                        size: 16,
                        color: colors.textMuted,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: kDisplayFont,
                        color: colors.textPrimary,
                      ),
                      items: [
                        for (final y in years)
                          DropdownMenuItem(value: y, child: Text('$y')),
                      ],
                      onChanged: (y) {
                        if (y != null) setState(() => _year = y);
                      },
                    ),
                  ),
                  const SizedBox(height: 6),
                  GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 6,
                    crossAxisSpacing: 6,
                    childAspectRatio: 1.7,
                    children: [
                      for (var m = 1; m <= 12; m++)
                        _monthCell(colors, m, _allowed(_year, m)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _monthCell(AppColors colors, int month, bool allowed) {
    final current =
        _year == widget.initial.year && month == widget.initial.month;
    return Semantics(
      button: allowed,
      label: _monthNames[month - 1],
      child: InkWell(
        onTap: allowed
            ? () => Navigator.of(context).pop(DateTime(_year, month))
            : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: current ? colors.accentDim : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _shortMonths[month - 1],
            style: TextStyle(
              fontSize: 14,
              color: !allowed
                  ? colors.textMuted.withValues(alpha: 0.35)
                  : current
                  ? colors.accentText
                  : colors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
