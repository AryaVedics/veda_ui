// Small pieces every Véda companion screen shares, drawn the way Véda draws
// them: the title-and-medallion header, header icons, cards, section labels,
// empty states, the gold button, profile rows and date wording.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'brand.dart';
import 'logo_menu.dart';
import 'theme.dart';

/// Same size as Véda's header medallion, so the apps read as one family.
const double kLockupMarkSize = 56;

/// The app's medallion with its word under it; tapping it opens the menu.
class VedaLockup extends StatelessWidget {
  const VedaLockup({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final brand = VedaBrandScope.of(context);
    return Builder(
      builder: (context) => InkWell(
        onTap: () => showLogoMenu(context),
        customBorder: const CircleBorder(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(4),
              child: Image.asset(
                brand.markAsset,
                width: kLockupMarkSize,
                height: kLockupMarkSize,
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -6),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 14),
                  Text(
                    brand.word,
                    style: TextStyle(
                      fontSize: 11,
                      fontFamily: kDisplayFont,
                      height: 1,
                      letterSpacing: 2,
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(width: 3),
                  Icon(
                    PhosphorIconsThin.caretDown,
                    size: 9,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({super.key, required this.title, this.actions = const []});

  final String title;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 23,
              fontFamily: kDisplayFont,
              color: colors.textPrimary,
            ),
          ),
        ),
        for (final a in actions) ...[a, const SizedBox(width: 10)],
        const VedaLockup(),
      ],
    );
  }
}

/// A screen laid out like Véda's: the [header] (title and logo) stays fixed at
/// the top and only the [children] scroll beneath it.
class PinnedHeaderList extends StatelessWidget {
  const PinnedHeaderList({
    super.key,
    required this.header,
    required this.children,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 24),
    this.controller,
  });

  final Widget header;
  final List<Widget> children;

  /// Around the whole screen: the header takes the top, the list the rest.
  final EdgeInsets padding;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          padding.top,
          padding.right,
          0,
        ),
        child: header,
      ),
      Expanded(
        child: ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
            padding.left,
            14,
            padding.right,
            padding.bottom,
          ),
          children: children,
        ),
      ),
    ],
  );
}

class HeaderIconButton extends StatelessWidget {
  const HeaderIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip,
    child: InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Icon(icon, size: 22, color: context.colors.textPrimary),
      ),
    ),
  );
}

class CardBox extends StatelessWidget {
  const CardBox({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: context.colors.card,
      borderRadius: BorderRadius.circular(16),
    ),
    padding: padding ?? const EdgeInsets.fromLTRB(16, 14, 16, 14),
    child: child,
  );
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8, top: 4),
    child: Text(
      text,
      style: TextStyle(fontSize: 13, color: context.colors.textSecondary),
    ),
  );
}

/// A gentle empty state: what this place is for, and the one thing to do.
class EmptyNote extends StatelessWidget {
  const EmptyNote({super.key, required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return CardBox(
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      child: Column(
        children: [
          Icon(icon, size: 30, color: colors.accentText),
          const SizedBox(height: 10),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The gold primary action, same as Véda's Save buttons.
class GoldButton extends StatelessWidget {
  const GoldButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.quiet = true,
  });

  final String label;
  final VoidCallback? onPressed;

  /// The app's standard button: a dark fill, a thin gold edge and a soft glow
  /// on the label, so it reads as a button without taking the eye from the
  /// artwork. Pass false only for the one bright action a screen exists for.
  final bool quiet;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: quiet ? colors.card : colors.accent,
          foregroundColor: quiet ? colors.accentText : colors.onAccent,
          disabledBackgroundColor: quiet ? colors.card : colors.accentDim,
          disabledForegroundColor: quiet ? colors.textMuted : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
            side: quiet
                ? BorderSide(color: colors.accent.withValues(alpha: 0.6))
                : BorderSide.none,
          ),
        ),
        onPressed: onPressed,
        child: quiet
            ? _BreathingLabel(label: label, color: colors.accent)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
      ),
    );
  }
}

/// The label of a quiet [GoldButton]: its glow breathes slowly, about every
/// four seconds, and stays still for anyone who has animations turned off.
class _BreathingLabel extends StatefulWidget {
  const _BreathingLabel({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  State<_BreathingLabel> createState() => _BreathingLabelState();
}

class _BreathingLabelState extends State<_BreathingLabel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    _c.repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = MediaQuery.disableAnimationsOf(context);
    if (still) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final alpha = still
            ? 0.5
            : 0.35 + 0.25 * Curves.easeInOut.transform(_c.value);
        return Text(
          widget.label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: widget.color.withValues(alpha: alpha),
                blurRadius: 12,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// One row in Profile: an icon, a title, a quiet line under it.
class ProfileRow extends StatelessWidget {
  const ProfileRow({
    super.key,
    this.icon,
    this.iconWidget,
    required this.title,
    this.subtitle,
    this.onTap,
    this.trailing,
  }) : assert(
         (icon == null) != (iconWidget == null),
         'Give a ProfileRow an icon or an iconWidget, not both',
       );

  /// A plain icon, drawn in the accent colour.
  final IconData? icon;

  /// An app's own icon, drawn as it is (for the Véda Link list).
  final Widget? iconWidget;

  final String title;
  final String? subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            iconWidget ?? Icon(icon, size: 22, color: colors.accentText),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 15, color: colors.textPrimary),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12.5,
                        height: 1.35,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}

/// A row of tappable choices, one selected: the chips every check-in uses.
class ChoiceRow<T> extends StatelessWidget {
  const ChoiceRow({
    super.key,
    required this.options,
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final List<T> options;
  final String Function(T) label;
  final T? selected;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final o in options)
          ChoiceChip(
            label: Text(label(o)),
            selected: o == selected,
            labelStyle: TextStyle(
              fontSize: 13,
              color: o == selected ? colors.accentText : colors.textSecondary,
            ),
            // Tapping the selected one again clears it: nothing is required.
            onSelected: (_) => onSelected(o == selected ? null : o),
          ),
      ],
    );
  }
}

const _months = [
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
const _longMonths = [
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
const _days = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

String shortDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String dayMonth(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String longToday(DateTime d) =>
    '${_days[d.weekday - 1]}, ${d.day} ${_longMonths[d.month - 1]}';

String timeOfDay(DateTime d) {
  final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
  final m = d.minute.toString().padLeft(2, '0');
  return '$h:$m ${d.hour < 12 ? 'AM' : 'PM'}';
}

/// Midnight of [d]'s day, for keying things by calendar day.
DateTime dayOf(DateTime d) => DateTime(d.year, d.month, d.day);

/// "2026-10-22": how every app keys a calendar day in its file.
String dayKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

DateTime parseDayKey(String k) {
  final p = k.split('-').map(int.parse).toList();
  return DateTime(p[0], p[1], p[2]);
}
