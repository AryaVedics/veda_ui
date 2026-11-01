// The bottom tab bar, drawn in the app's own language instead of Material's
// NavigationBar: the selected tab gets a short glowing gold line on the bar's
// top edge and a gold icon and label; the others stay quiet. Each tab is
// announced to screen readers as a selectable button with its label.

import 'package:flutter/material.dart';

import 'app_colors.dart';

class VedaTab {
  const VedaTab({
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });

  final Widget icon;
  final Widget selectedIcon;
  final String label;

  /// A tab from a Phosphor icon pair (thin when idle, filled when selected).
  static VedaTab of(
    AppColors colors,
    IconData thin,
    IconData fill,
    String label,
  ) => VedaTab(
    icon: Icon(thin, size: 24, color: colors.textMuted),
    selectedIcon: Icon(fill, size: 24, color: colors.accentText),
    label: label,
  );
}

class VedaTabBar extends StatefulWidget {
  const VedaTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<VedaTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const height = 64.0;

  @override
  State<VedaTabBar> createState() => _VedaTabBarState();
}

class _VedaTabBarState extends State<VedaTabBar> {
  /// How far a swipe along the bar must travel to change the tab, as in Véda.
  static const _swipeThreshold = 50.0;

  double? _dragStartX;

  List<VedaTab> get tabs => widget.tabs;
  int get selectedIndex => widget.selectedIndex;
  ValueChanged<int> get onSelected => widget.onSelected;

  void _onDragUpdate(DragUpdateDetails details) {
    final start = _dragStartX;
    if (start == null) return;
    final delta = details.globalPosition.dx - start;
    if (delta.abs() < _swipeThreshold) return;
    if (delta > 0 && selectedIndex > 0) {
      onSelected(selectedIndex - 1);
      _dragStartX = null;
    } else if (delta < 0 && selectedIndex < tabs.length - 1) {
      onSelected(selectedIndex + 1);
      _dragStartX = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onHorizontalDragStart: (d) => _dragStartX = d.globalPosition.dx,
      onHorizontalDragUpdate: _onDragUpdate,
      onHorizontalDragEnd: (_) => _dragStartX = null,
      child: Material(
        color: colors.card,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: VedaTabBar.height,
            child: Row(
              children: [
                for (var i = 0; i < tabs.length; i++)
                  Expanded(child: _tab(colors, i)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _tab(AppColors colors, int i) {
    final tab = tabs[i];
    final selected = i == selectedIndex;
    return Semantics(
      button: true,
      selected: selected,
      label: tab.label,
      onTap: () => onSelected(i),
      excludeSemantics: true,
      child: InkWell(
        onTap: () => onSelected(i),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedOpacity(
                  opacity: selected ? 1 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Container(
                    width: 22,
                    height: 2,
                    decoration: BoxDecoration(
                      color: colors.accent,
                      borderRadius: BorderRadius.circular(1),
                      boxShadow: [
                        BoxShadow(
                          color: colors.accent.withValues(alpha: 0.6),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 24,
                  child: selected ? tab.selectedIcon : tab.icon,
                ),
                const SizedBox(height: 4),
                Text(
                  tab.label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11.5,
                    letterSpacing: 0.3,
                    color: selected ? colors.accentText : colors.textMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// The Skin tab's icon in the accessory apps: Véda's own medallion, the same
/// mark Véda shows for itself. Dimmed when idle, full when selected.
class SkinMedalIcon extends StatelessWidget {
  const SkinMedalIcon({super.key, required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: selected ? 1 : 0.6,
    child: Image.asset(
      'packages/veda_ui/assets/branding/skin_medal.png',
      width: 26,
      height: 26,
      filterQuality: FilterQuality.medium,
    ),
  );
}
