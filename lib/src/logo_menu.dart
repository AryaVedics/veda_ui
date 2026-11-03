// The menu the header logo opens, on every tab, in the same style as Véda's:
// a small soft card under the logo with the page dimmed behind it. Each app
// supplies its own shortcuts; the links to the website and support are the
// same everywhere.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_colors.dart';
import 'open_veda.dart';

/// The website every app links to.
const String kWebsiteUrl = 'https://aryavedics.com';

class VedaMenuItem {
  const VedaMenuItem(this.icon, this.label, this.onTap, {this.primary = false});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
}

class LogoMenuScope extends InheritedWidget {
  const LogoMenuScope({
    super.key,
    required this.items,
    this.onLink,
    this.showOpenVeda = true,
    required super.child,
  });

  /// Whether the menu offers "Open Véda". It opens the Véda app through
  /// Android, so an app on a platform without that (an iPhone) turns it off.
  final bool showOpenVeda;

  static bool openVedaOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<LogoMenuScope>()
          ?.showOpenVeda ??
      true;

  /// Opens the Connect card, for the "Link my Véda apps" shortcut. Null hides
  /// the shortcut (Véda's store builds, until Véda Link ships).
  final VoidCallback? onLink;

  static VoidCallback? linkOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LogoMenuScope>()?.onLink;

  /// The app's own shortcuts, shown above the website and support links.
  final List<VedaMenuItem> items;

  static List<VedaMenuItem>? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LogoMenuScope>()?.items;

  @override
  bool updateShouldNotify(LogoMenuScope old) => false;
}

void _openUrl(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

/// Opens the menu under the widget [context] belongs to (the logo).
Future<void> showLogoMenu(BuildContext context) async {
  final items = LogoMenuScope.maybeOf(context) ?? const [];
  final onLink = LogoMenuScope.linkOf(context);
  final showOpenVeda = LogoMenuScope.openVedaOf(context);
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? Offset.zero : box.localToGlobal(Offset.zero);
  final size = box?.size ?? Size.zero;

  final picked = await showGeneralDialog<VoidCallback>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Close menu',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 160),
    transitionBuilder: (context, animation, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
      child: child,
    ),
    pageBuilder: (dialogContext, _, _) => LayoutBuilder(
      builder: (_, box) {
        final cardWidth = _MenuCard.width.clamp(0.0, box.maxWidth - 16);
        final centered = origin.dx + size.width / 2 - cardWidth / 2;
        final left = centered.clamp(
          8.0,
          (box.maxWidth - cardWidth - 8).clamp(8.0, double.infinity),
        );
        final top = (origin.dy + size.height).clamp(0.0, box.maxHeight);
        return Stack(
          children: [
            Positioned(
              top: top,
              left: left,
              width: cardWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: (box.maxHeight - top - 8).clamp(0.0, 600.0),
                ),
                child: SingleChildScrollView(
                  child: _MenuCard(
                    items: items,
                    onLink: onLink,
                    showOpenVeda: showOpenVeda,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
  picked?.call();
}

class _MenuCard extends StatelessWidget {
  const _MenuCard({required this.items, this.onLink, this.showOpenVeda = true});

  final VoidCallback? onLink;
  final bool showOpenVeda;

  static const double width = 244;

  final List<VedaMenuItem> items;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    Widget item(
      IconData icon,
      String label,
      VoidCallback onTap, {
      bool primary = false,
    }) => InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            Icon(
              icon,
              size: 19,
              color: primary ? colors.accentText : colors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  color: primary ? colors.textPrimary : colors.textSecondary,
                  decoration: TextDecoration.none,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    // Pops with the thing to do, so it runs after the menu has closed.
    void pick(BuildContext c, VoidCallback action) =>
        Navigator.of(c).pop(action);

    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Builder(
          builder: (c) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final it in items)
                item(
                  it.icon,
                  it.label,
                  () => pick(c, it.onTap),
                  primary: it.primary,
                ),
              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Divider(height: 1, color: colors.divider),
                ),
              if (onLink != null)
                item(
                  PhosphorIconsThin.shareNetwork,
                  'Link my Véda apps',
                  () => pick(c, onLink!),
                ),
              if (showOpenVeda)
                item(
                  PhosphorIconsThin.arrowSquareOut,
                  'Open Véda',
                  () => pick(c, openVeda),
                ),
              item(
                PhosphorIconsThin.globe,
                'Our website',
                () => pick(c, () => _openUrl(kWebsiteUrl)),
              ),
              item(
                PhosphorIconsThin.chatCircle,
                'Support',
                () => pick(c, () => _openUrl('$kWebsiteUrl/support')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
