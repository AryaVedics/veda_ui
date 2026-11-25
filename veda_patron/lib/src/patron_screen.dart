// The Patron page for the companion apps, laid out and worded as Véda's own
// paywall (skin_app_wired/flutter_app/lib/screens/paywall_screen.dart; change
// both together). The one addition: buying or restoring first asks for a
// Google or Apple sign-in, so the membership works in every Véda app.
//
// [perks] lists only what ships in this app today: a paywall must not sell
// what isn't built yet.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:veda_ui/veda_ui.dart';

import 'patron_identity.dart';
import 'patron_service.dart';
import 'patron_store.dart';

typedef PatronPerk = ({IconData icon, String title, String body});

/// The perks every companion app's Patron has.
const kSharedPatronPerks = <PatronPerk>[
  (
    icon: PhosphorIconsThin.prohibit,
    title: 'No ads',
    body: 'A calm, uninterrupted app.',
  ),
  (
    icon: PhosphorIconsThin.squaresFour,
    title: 'Every Véda app',
    body:
        'One membership covers Véda and its companion apps (Véda Cycle and '
        'Véda Curio are bought separately).',
  ),
  (
    icon: PhosphorIconsThin.heart,
    title: 'Keeps Véda free for everyone',
    body:
        'Your membership helps keep almost all of Véda free for everyone, '
        'whatever they can pay.',
  ),
];

/// The perks of Patron Plus, in a Patron Plus app. Plus covers every Plus app
/// with one membership, so none is named here.
const kPlusPerks = <PatronPerk>[
  (
    icon: PhosphorIconsThin.prohibit,
    title: 'No ads',
    body: 'A calm, uninterrupted app, in every Patron Plus app.',
  ),
  (
    icon: PhosphorIconsThin.squaresFour,
    title: 'Every Plus app, one membership',
    body:
        'Patron Plus covers all the Patron Plus apps. Sign in once and each '
        'one opens.',
  ),
  (
    icon: PhosphorIconsThin.heartbeat,
    title: 'Your Véda skin, beside what you track',
    body:
        'The Skin tab is included with Plus, at no extra cost. It uses the '
        'free Véda app, which reads your skin from a quick photo.',
  ),
  (
    icon: PhosphorIconsThin.heart,
    title: 'Keeps Véda free for everyone',
    body:
        'Your membership helps keep almost all of Véda free for everyone, '
        'whatever they can pay.',
  ),
];

/// Turns a Patron screen into a Patron Plus app's: Plus is the main choice,
/// with this one app's own monthly plan beside it.
class PlusPitch {
  const PlusPitch({required this.appName});

  /// "Véda Allergy": the app this screen is in.
  final String appName;
}

bool get _onIos => defaultTargetPlatform == TargetPlatform.iOS;
String get _storeName => _onIos ? 'App Store' : 'Google Play';

Future<void> openPatronScreen(
  BuildContext context,
  PatronService service, {
  List<PatronPerk> perks = kSharedPatronPerks,
  PlusPitch? plus,
}) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => PatronScreen(service: service, perks: perks, plus: plus),
  ),
);

class PatronScreen extends StatefulWidget {
  const PatronScreen({
    super.key,
    required this.service,
    this.perks = kSharedPatronPerks,
    this.plus,
  });

  final PatronService service;
  final List<PatronPerk> perks;

  /// Set in a Patron Plus app.
  final PlusPitch? plus;

  @override
  State<PatronScreen> createState() => _PatronScreenState();
}

class _PatronScreenState extends State<PatronScreen> {
  PatronService get _service => widget.service;
  PlusPitch? get _plus => widget.plus;

  List<PatronPerk> get _perkList =>
      _plus != null && identical(widget.perks, kSharedPatronPerks)
      ? kPlusPerks
      : widget.perks;

  List<PatronPackage>? _packages;
  PatronPackage? _selected;
  bool _loadFailed = false;
  bool _busy = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loadFailed = false);
    try {
      final all = await _service.packages();
      // Annual first: it is the plan we'd rather someone chose. In a Plus app,
      // Plus comes first.
      final packages = [...all]
        ..sort(
          (a, b) => _plus != null
              ? (b.id == kPlusPackageId ? 1 : 0) -
                    (a.id == kPlusPackageId ? 1 : 0)
              : (b.isAnnual ? 1 : 0) - (a.isAnnual ? 1 : 0),
        );
      if (!mounted) return;
      setState(() {
        _packages = packages;
        _selected = packages.isEmpty ? null : packages.first;
        _loadFailed = packages.isEmpty;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadFailed = true);
    }
  }

  /// The provider to sign in with, when no sign-in is in place yet: the only
  /// one this phone offers, or the person's choice. Null if they back out.
  /// Asked before anything spins, so the button never turns behind the sheet.
  Future<PatronProvider?> _pickProvider() async {
    final providers = _service.providers;
    return providers.length == 1
        ? providers.single
        : await _chooseProvider(providers);
  }

  /// Signs in with [provider] when one was picked. Returns whether the account
  /// already has a membership, or null if the person backed out.
  Future<bool?> _signInWith(PatronProvider? provider) async {
    if (provider == null) return false;
    try {
      return await _service.signIn(provider);
    } on SignInCancelled {
      return null;
    }
  }

  Future<PatronProvider?> _chooseProvider(List<PatronProvider> providers) =>
      showModalBottomSheet<PatronProvider>(
        context: context,
        showDragHandle: true,
        backgroundColor: context.colors.card,
        builder: (c) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final p in providers) ...[
                  GoldButton(
                    key: Key('patronSignIn-${p.name}'),
                    label: 'Continue with ${p.label}',
                    onPressed: () => Navigator.pop(c, p),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            ),
          ),
        ),
      );

  Future<void> _run(Future<void> Function() step, String failed) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = null;
    });
    try {
      await step();
    } on PurchaseFailure catch (e) {
      if (!e.cancelled && mounted) setState(() => _message = e.message);
    } on SignInFailure catch (e) {
      if (mounted) setState(() => _message = e.message);
    } catch (_) {
      if (mounted) setState(() => _message = failed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _buy() async {
    final plan = _selected;
    if (plan == null || _busy) return;
    PatronProvider? provider;
    if (_service.identity.value == null) {
      provider = await _pickProvider();
      if (provider == null) return;
    }
    await _run(() async {
      final already = await _signInWith(provider);
      if (already == null || already) return;
      await _service.buy(plan);
    }, 'The purchase did not go through.');
  }

  Future<void> _restore() async {
    if (_busy) return;
    PatronProvider? provider;
    if (_service.identity.value == null) {
      provider = await _pickProvider();
      if (provider == null) return;
    }
    await _run(() async {
      final found = await _signInWith(provider);
      if (found == null) return;
      final active = found || await _service.restore();
      if (!active && mounted) {
        setState(
          () => _message =
              'No membership found for this '
              '${_service.identity.value?.provider.label ?? ''} account.',
        );
      }
    }, 'Could not restore your membership.');
  }

  void _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  /// How much cheaper the annual plan is than twelve monthly payments, as a
  /// whole percent; null when either plan is missing.
  int? _annualSaving(List<PatronPackage> all) {
    final annual = all.where((p) => p.isAnnual).firstOrNull;
    final monthly = all.where((p) => !p.isAnnual).firstOrNull;
    if (annual == null || monthly == null || monthly.price <= 0) return null;
    final saving = (1 - annual.price / (monthly.price * 12)) * 100;
    return saving >= 1 ? saving.round() : null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mark = VedaBrandScope.maybeOf(context)?.markAsset;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          _plus != null ? 'Véda Patron Plus' : 'Véda Patron',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ValueListenableBuilder<bool>(
          valueListenable: _service.isPatron,
          builder: (context, isPatron, _) => ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              if (mark != null)
                Center(child: Image.asset(mark, width: 72, height: 72)),
              const SizedBox(height: 14),
              Center(
                child: Text(
                  _plus != null ? 'Véda Patron Plus' : 'Véda Patron',
                  style: TextStyle(
                    fontSize: 26,
                    fontFamily: kDisplayFont,
                    letterSpacing: 2,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _plus != null
                    ? 'Everything you need day to day stays free. Plus goes '
                          'further: no ads, your Véda skin in the Skin tab, '
                          'and every Plus app with one membership.'
                    : 'Everything you need day to day stays free. Patrons go '
                          'further, with no ads, and help keep Véda open to '
                          'everyone.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              // The idea behind the name, once, quietly. Not a sales line.
              Text(
                'Artists have long been kept by patrons, so their work could '
                'reach people who never paid for it. Patrons do the same for '
                'Véda.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: 22),
              _perks(colors),
              const SizedBox(height: 22),
              if (isPatron) ..._member(colors) else ..._offer(colors),
            ],
          ),
        ),
      ),
    );
  }

  Widget _perks(AppColors colors) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: colors.card,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      children: [
        for (var i = 0; i < _perkList.length; i++) ...[
          if (i > 0) const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(_perkList[i].icon, size: 20, color: colors.accentText),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _perkList[i].title,
                      style: TextStyle(fontSize: 14, color: colors.textPrimary),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _perkList[i].body,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.4,
                        color: colors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );

  List<Widget> _member(AppColors colors) {
    final id = _service.identity.value;
    return [
      Container(
        key: const Key('patronMember'),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(
              _plus != null ? "You're a member." : "You're a Patron.",
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              id == null
                  ? 'Thank you for supporting Véda. Your membership comes from '
                        'another Véda app on this phone.'
                  : 'Thank you for supporting Véda. Signed in with '
                        '${id.provider.label}.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: colors.textSecondary),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      Center(
        child: TextButton(
          onPressed: () => _open(
            _onIos
                ? 'https://apps.apple.com/account/subscriptions'
                : 'https://play.google.com/store/account/subscriptions',
          ),
          child: Text(
            'Manage subscription',
            style: TextStyle(color: colors.accentText),
          ),
        ),
      ),
      if (id != null)
        Center(
          child: TextButton(
            key: const Key('patronSignOut'),
            onPressed: _busy ? null : _service.signOut,
            child: Text(
              'Sign out of Patron on this phone',
              style: TextStyle(color: colors.textSecondary),
            ),
          ),
        ),
    ];
  }

  List<Widget> _offer(AppColors colors) {
    final packages = _packages;
    if (packages == null && !_loadFailed) {
      return [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 24),
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
      ];
    }
    if (_loadFailed || packages == null) {
      return [
        Text(
          "Plans couldn't be loaded right now. Check your connection and "
          'try again.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, height: 1.5, color: colors.textMuted),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: _load,
            child: Text(
              'Try again',
              style: TextStyle(color: colors.accentText),
            ),
          ),
        ),
      ];
    }

    final saving = _annualSaving(packages);
    final plan = _selected!;
    final period = plan.isAnnual ? 'year' : 'month';
    final trial = plan.trialLabel;
    final signedIn = _service.identity.value != null;
    final providers = _service.providers.map((p) => p.label).join(' or ');
    return [
      for (final p in packages) ...[
        _planTile(colors, p, selected: p == plan, saving: saving),
        const SizedBox(height: 10),
      ],
      const SizedBox(height: 6),
      SizedBox(
        width: double.infinity,
        child: FilledButton(
          key: const Key('patronBuy'),
          onPressed: _busy ? null : _buy,
          style: FilledButton.styleFrom(
            backgroundColor: colors.accent,
            foregroundColor: colors.onAccent,
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          child: _busy
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(
                  trial != null
                      ? 'Start $trial'
                      : 'Subscribe · ${plan.priceString} / $period',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
      if (!signedIn) ...[
        const SizedBox(height: 10),
        Text(
          'You sign in with $providers first, so your membership works in '
          'every Véda app. Our server checks the sign-in and keeps nothing: '
          'only a coded number goes to the store, never your email or name.'
          '${_service.providers.length > 1 ? ' Google and Apple are '
                    'separate sign-ins: if you also use Véda on an Android phone, '
                    'choose Google on both.' : ''}',
          key: const Key('patronSignInNote'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            height: 1.45,
            color: colors.textSecondary,
          ),
        ),
      ],
      if (_message != null) ...[
        const SizedBox(height: 10),
        Text(
          _message!,
          key: const Key('patronMessage'),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12.5, color: colors.textSecondary),
        ),
      ],
      const SizedBox(height: 6),
      Center(
        child: TextButton(
          key: const Key('patronRestore'),
          onPressed: _busy ? null : _restore,
          child: Text(
            _plus != null ? 'I already have Plus' : 'I already have Patron',
            style: TextStyle(color: colors.accentText),
          ),
        ),
      ),
      const SizedBox(height: 6),
      Text(
        '${trial != null ? 'After the free trial, you will be charged' : 'You will be charged'} '
        '${plan.priceString} per $period. The membership renews '
        'automatically unless you cancel at least 24 hours before the '
        'current period ends. Payment is taken from your $_storeName '
        'account, and you can manage or cancel anytime in your $_storeName '
        'subscription settings.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11.5, height: 1.5, color: colors.textMuted),
      ),
      const SizedBox(height: 8),
      Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton(
            onPressed: () => _open('$kWebsiteUrl/terms'),
            child: Text(
              'Terms of use',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
          Text('·', style: TextStyle(color: colors.textMuted)),
          TextButton(
            onPressed: () => _open('$kWebsiteUrl/privacy'),
            child: Text(
              'Privacy policy',
              style: TextStyle(fontSize: 12, color: colors.textSecondary),
            ),
          ),
        ],
      ),
    ];
  }

  String _planName(PatronPackage p) {
    final plus = _plus;
    if (plus == null) return p.isAnnual ? 'Annual' : 'Monthly';
    return p.id == kPlusPackageId ? 'Patron Plus' : '${plus.appName} only';
  }

  String? _planNote(PatronPackage p) {
    if (_plus == null) return null;
    return p.id == kPlusPackageId
        ? 'Every Plus app, and the Skin tab in each'
        : 'This app, and its Skin tab';
  }

  Widget _planTile(
    AppColors colors,
    PatronPackage p, {
    required bool selected,
    required int? saving,
  }) => InkWell(
    key: ValueKey('plan-${p.id}'),
    borderRadius: BorderRadius.circular(14),
    onTap: _busy ? null : () => setState(() => _selected = p),
    child: Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? colors.accent : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            selected ? PhosphorIconsFill.checkCircle : PhosphorIconsThin.circle,
            size: 20,
            color: selected ? colors.accent : colors.textMuted,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      _planName(p),
                      style: TextStyle(
                        fontSize: 14.5,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (_plus != null && p.id == kPlusPackageId)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Best value',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.accentText,
                          ),
                        ),
                      ),
                    if (p.isAnnual && saving != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colors.accent.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Save $saving%',
                          style: TextStyle(
                            fontSize: 11,
                            color: colors.accentText,
                          ),
                        ),
                      ),
                  ],
                ),
                if (_planNote(p) case final note?) ...[
                  const SizedBox(height: 3),
                  Text(
                    note,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
                if (p.trialLabel != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    p.trialLabel!,
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                ],
              ],
            ),
          ),
          Text(
            '${p.priceString} / ${p.isAnnual ? 'year' : 'month'}',
            style: TextStyle(fontSize: 13.5, color: colors.textPrimary),
          ),
        ],
      ),
    ),
  );
}
