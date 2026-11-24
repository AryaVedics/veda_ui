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

/// The social accounts, the same as Véda's own menu: Instagram and TikTok.
const String kInstagramUrl = 'https://www.instagram.com/aryavedics/';
const String kTikTokUrl = 'https://www.tiktok.com/@aryavedics';

void _openUrl(String url) =>
    launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

/// A quiet "Health data privacy" link, set under any switch that reads health
/// data (a watch, Health Connect, Apple Health). It opens the separate
/// consumer health data page on the website in the person's own browser.
class HealthDataLink extends StatelessWidget {
  const HealthDataLink({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.only(top: 6, left: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: InkWell(
          key: const Key('healthDataLink'),
          onTap: () => _openUrl('$kWebsiteUrl/health-data'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              'Health data privacy',
              style: TextStyle(
                fontSize: 12.5,
                color: colors.accentText,
                decoration: TextDecoration.underline,
                decorationColor: colors.accentText,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The social accounts as one quiet row of icons, as in Véda: gold at the foot
/// of a Profile page ([gold]), muted in the logo menu. Tapping one opens the
/// account in the person's own browser or app; nothing is sent from here.
class SocialLinksRow extends StatelessWidget {
  const SocialLinksRow({super.key, this.gold = false, this.onOpen});

  final bool gold;

  /// Opens an address; the menu passes one that closes itself first.
  final void Function(String url)? onOpen;

  static const links = <(IconData, String, String)>[
    (PhosphorIconsThin.instagramLogo, 'Instagram', kInstagramUrl),
    (PhosphorIconsThin.tiktokLogo, 'TikTok', kTikTokUrl),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < links.length; i++) ...[
          if (i > 0) const SizedBox(width: 22),
          InkWell(
            key: Key('social-${links[i].$2}'),
            customBorder: const CircleBorder(),
            onTap: () => (onOpen ?? _openUrl)(links[i].$3),
            child: Tooltip(
              message: links[i].$2,
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  links[i].$1,
                  size: 22,
                  color: gold ? colors.accent : colors.textMuted,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

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
              // the social accounts, one quiet row at the foot, as in Véda
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Divider(height: 14, color: colors.divider),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                child: Center(
                  child: SocialLinksRow(
                    onOpen: (url) => pick(c, () => _openUrl(url)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
