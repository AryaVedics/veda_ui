// The screens every concept app shares: Today (the app's scene and one or two
// buttons), Lists (what the person saves), Diary and Profile.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../veda_ui.dart';

import 'model.dart';

const _shortScreen = 620.0;

Future<void> runConcept(ConceptApp app) async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  final store = ConceptStore(app.id);
  await store.load();
  runApp(ConceptRoot(app: app, store: store));
}

class ConceptRoot extends StatelessWidget {
  const ConceptRoot({super.key, required this.app, required this.store});

  final ConceptApp app;
  final ConceptStore store;

  @override
  Widget build(BuildContext context) {
    final colors = paletteFrom(app.base);
    final base = vedaTheme(colors);
    final brand = VedaBrand(
      appName: app.name,
      word: app.word,
      markAsset: 'assets/branding/${app.id}_mark.png',
      ringTrack: Color.lerp(app.base, Colors.white, 0.1)!,
    );
    return MaterialApp(
      title: app.name,
      debugShowCheckedModeBanner: false,
      // no red anywhere: an input error shows in the gold accent
      theme: base.copyWith(
        colorScheme: base.colorScheme.copyWith(error: colors.accentText),
      ),
      scaffoldMessengerKey: vedaMessengerKey,
      builder: (context, child) => VedaBrandScope(brand: brand, child: child!),
      home: _Shell(app: app, store: store),
    );
  }
}

class _Shell extends StatefulWidget {
  const _Shell({required this.app, required this.store});

  final ConceptApp app;
  final ConceptStore store;

  @override
  State<_Shell> createState() => _ShellState();
}

class _ShellState extends State<_Shell> with WidgetsBindingObserver {
  int _tab = 0;
  DateTime _now = DateTime.now();
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tick = Timer.periodic(const Duration(minutes: 1), (_) => _newDay());
  }

  void _newDay() {
    final now = DateTime.now();
    if (dayKey(now) != dayKey(_now) || now.hour != _now.hour) {
      setState(() => _now = now);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _newDay();
  }

  @override
  void dispose() {
    _tick?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = widget.app;
    final store = widget.store;
    VedaTab tab(IconData icon, String label) => VedaTab(
      icon: Icon(icon, color: colors.textMuted),
      selectedIcon: Icon(icon, color: colors.accentText),
      label: label,
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CanvasBackdrop(
        child: SafeArea(
          bottom: false,
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) => Stack(
              children: [
                BrandWatermark(quiet: _tab == 0),
                IndexedStack(
                  index: _tab,
                  children: [
                    TickerMode(
                      enabled: _tab == 0,
                      child: _Today(app: app, store: store, now: _now),
                    ),
                    _Lists(app: app, store: store, now: _now),
                    _Diary(app: app, store: store, now: _now),
                    _Profile(app: app, store: store),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: VedaTabBar(
        selectedIndex: _tab,
        onSelected: (i) => setState(() => _tab = i),
        tabs: [
          tab(PhosphorIconsThin.sunHorizon, 'Today'),
          tab(app.collections.first.icon, 'Lists'),
          VedaTab.line(colors, VedaIcon.notebook, 'Diary'),
          VedaTab.line(colors, VedaIcon.profile, 'Profile'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- Today

class _Today extends StatefulWidget {
  const _Today({required this.app, required this.store, required this.now});

  final ConceptApp app;
  final ConceptStore store;
  final DateTime now;

  @override
  State<_Today> createState() => _TodayState();
}

class _TodayState extends State<_Today> with SingleTickerProviderStateMixin {
  late final AnimationController _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );
  late final List<NoticeMessage> _messages = [
    NoticeMessage('how', PhosphorIconsThin.info, widget.app.how),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _loop.stop();
    } else if (!_loop.isAnimating) {
      _loop.repeat();
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = widget.app;
    final store = widget.store;
    final now = widget.now;
    final data = store.data;
    final noted = data.week(now).whereType<DayLog>().length;
    final today = data.days[dayKey(now)];
    void note() => showDaySheet(context, app, store, now);
    final timer = app.timer;
    final column = Column(
      children: [
        const ScreenHeader(title: 'Today'),
        const SizedBox(height: 14),
        NoticeCarousel(
          backup: BackupController(
            appKey: app.id,
            appName: app.name,
            exportJson: store.exportJson,
            restoreJson: store.restoreJson,
          ),
          appKey: app.id,
          messages: _messages,
          greeting: (_) => app.greeting,
          leading: Semantics(
            label: '$noted of 7 days noted this week',
            excludeSemantics: true,
            child: MiniRing(
              fraction: noted / 7,
              centre: '$noted/7',
              caption: 'This Week',
              gradient: [colors.accent, colors.accent],
              stops: const [0, 1],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: Semantics(
            label: app.sceneLabel,
            child: GestureDetector(
              onTap: note,
              child: ClipRect(
                child: AnimatedBuilder(
                  animation: _loop,
                  builder: (context, _) => CustomPaint(
                    size: Size.infinite,
                    painter: app.centrepiece(data, now, colors, _loop.value),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          app.since(data, now),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.5, color: colors.textSecondary),
        ),
        const SizedBox(height: 10),
        if (timer == null)
          GoldButton(
            key: const Key('noteToday'),
            label: today == null ? 'Note today' : 'Change today',
            onPressed: note,
          )
        else
          Row(
            children: [
              Expanded(
                child: TodayTile(
                  key: const Key('timerTile'),
                  icon: timer.icon,
                  label: timer.title,
                  tint: colors.accent,
                  done:
                      timer.check != null &&
                      (today?.checks.contains(timer.check) ?? false),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => TimerPage(spec: timer, store: store),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TodayTile(
                  key: const Key('noteToday'),
                  icon: PhosphorIconsThin.notePencil,
                  label: today == null ? 'Note today' : 'Change today',
                  tint: colors.accent,
                  done: today != null,
                  onTap: note,
                ),
              ),
            ],
          ),
      ],
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: LayoutBuilder(
        builder: (context, box) {
          final least =
              _shortScreen *
              math.max(1.0, MediaQuery.textScalerOf(context).scale(1));
          if (box.maxHeight >= least) return column;
          return SingleChildScrollView(
            child: SizedBox(height: least, child: column),
          );
        },
      ),
    );
  }
}

/// A countdown, or a slow breathing circle (four seconds in, six out).
class TimerPage extends StatefulWidget {
  const TimerPage({super.key, required this.spec, required this.store});

  final TimerSpec spec;
  final ConceptStore store;

  @override
  State<TimerPage> createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: Duration(seconds: widget.spec.seconds),
    animationBehavior: AnimationBehavior.preserve,
  )..addStatusListener(_status);
  bool _done = false;

  void _status(AnimationStatus s) {
    if (s != AnimationStatus.completed) return;
    HapticFeedback.mediumImpact();
    final check = widget.spec.check;
    if (check != null) {
      final key = dayKey(DateTime.now());
      final day = widget.store.data.days[key] ?? DayLog(day: key);
      widget.store.saveDay(day.copyWith(checks: {...day.checks, check}));
    }
    setState(() => _done = true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final spec = widget.spec;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CanvasBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            // scrolls when large text leaves no room for it all
            child: SingleChildScrollView(
              child: Column(
                children: [
                  ScreenHeader(title: spec.title),
                  SizedBox(
                    height: 300,
                    child: AnimatedBuilder(
                      animation: _c,
                      builder: (context, _) {
                        final passed = _c.value * spec.seconds;
                        final left = (spec.seconds - passed).ceil();
                        final phase = passed % 10;
                        final inward = phase < 4;
                        final breath = inward ? phase / 4 : 1 - (phase - 4) / 6;
                        final scale = spec.breathing && _c.isAnimating
                            ? 0.55 + 0.45 * Curves.easeInOut.transform(breath)
                            : 0.85;
                        return Center(
                          child: SizedBox(
                            width: 240,
                            height: 240,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 220 * scale,
                                  height: 220 * scale,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        colors.accent.withValues(alpha: 0.45),
                                        colors.accent.withValues(alpha: 0.04),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 230,
                                  height: 230,
                                  child: CircularProgressIndicator(
                                    value: _c.value,
                                    strokeWidth: 3,
                                    color: colors.accent,
                                    backgroundColor: colors.divider,
                                  ),
                                ),
                                Text(
                                  _done
                                      ? 'Done'
                                      : !_c.isAnimating
                                      ? '${left}s'
                                      : spec.breathing
                                      ? (inward ? 'In' : 'Out')
                                      : '${left}s',
                                  style: TextStyle(
                                    fontSize: 34,
                                    color: colors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Text(
                    spec.line,
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.5, color: colors.textSecondary),
                  ),
                  const SizedBox(height: 16),
                  GoldButton(
                    label: _done
                        ? 'Close'
                        : _c.isAnimating
                        ? 'Stop'
                        : 'Start',
                    onPressed: () {
                      if (_done) {
                        Navigator.pop(context);
                      } else if (_c.isAnimating) {
                        _c.reset();
                        setState(() {});
                      } else {
                        _c.forward(from: 0);
                        setState(() {});
                      }
                    },
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- sheets

Future<void> _sheet(BuildContext context, Widget child) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.canvas,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (c) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
          child: child,
        ),
      ),
    );

Widget _chips(
  BuildContext context,
  Map<String, String> options,
  Set<String> selected,
  ValueChanged<Set<String>> onChanged,
) {
  final colors = context.colors;
  return Wrap(
    spacing: 8,
    runSpacing: 8,
    children: [
      for (final o in options.entries)
        FilterChip(
          label: Text(o.value),
          selected: selected.contains(o.key),
          labelStyle: TextStyle(
            fontSize: 13,
            color: selected.contains(o.key)
                ? colors.accentText
                : colors.textSecondary,
          ),
          onSelected: (on) => onChanged(
            on ? {...selected, o.key} : ({...selected}..remove(o.key)),
          ),
        ),
    ],
  );
}

Future<void> showDaySheet(
  BuildContext context,
  ConceptApp app,
  ConceptStore store,
  DateTime day,
) => _sheet(context, _DaySheet(app: app, store: store, day: day));

class _DaySheet extends StatefulWidget {
  const _DaySheet({required this.app, required this.store, required this.day});

  final ConceptApp app;
  final ConceptStore store;
  final DateTime day;

  @override
  State<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends State<_DaySheet> {
  late DayLog _d =
      widget.store.data.days[dayKey(widget.day)] ??
      DayLog(day: dayKey(widget.day));
  late final _note = TextEditingController(text: _d.note);

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final app = widget.app;
    final data = widget.store.data;
    final usable = {
      for (final c in app.collections)
        if (c.usable)
          for (final r in data.of(c.id)) r.id: c.name(r, data),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _d.day == dayKey(DateTime.now()) ? 'Today' : longToday(widget.day),
          style: TextStyle(fontSize: 20, color: colors.textPrimary),
        ),
        const SizedBox(height: 14),
        SectionLabel(app.checksLabel),
        _chips(
          context,
          {for (final c in app.checks) c.id: c.label},
          _d.checks,
          (s) => setState(() => _d = _d.copyWith(checks: s)),
        ),
        if (app.words.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionLabel(app.wordsLabel ?? 'How was it?'),
          _chips(
            context,
            {for (final w in app.words) w: w},
            _d.words,
            (s) => setState(() => _d = _d.copyWith(words: s)),
          ),
        ],
        if (usable.isNotEmpty) ...[
          const SizedBox(height: 16),
          SectionLabel(app.usedLabel),
          _chips(
            context,
            usable,
            _d.used,
            (s) => setState(() => _d = _d.copyWith(used: s)),
          ),
        ],
        if (app.noteInDay) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _note,
            minLines: 1,
            maxLines: 3,
            inputFormatters: [LengthLimitingTextInputFormatter(500)],
            decoration: const InputDecoration(
              hintText: 'A note, in your own words',
            ),
          ),
        ],
        const SizedBox(height: 16),
        GoldButton(
          key: const Key('saveDay'),
          label: 'Save',
          quiet: false,
          onPressed: () async {
            await widget.store.saveDay(_d.copyWith(note: _note.text.trim()));
            if (context.mounted) Navigator.pop(context);
          },
        ),
      ],
    );
  }
}

Future<void> showRecordSheet(
  BuildContext context,
  ConceptStore store,
  Collection collection, [
  Rec? rec,
]) => _sheet(
  context,
  _RecordSheet(store: store, collection: collection, rec: rec),
);

class _RecordSheet extends StatefulWidget {
  const _RecordSheet({required this.store, required this.collection, this.rec});

  final ConceptStore store;
  final Collection collection;
  final Rec? rec;

  @override
  State<_RecordSheet> createState() => _RecordSheetState();
}

class _RecordSheetState extends State<_RecordSheet> {
  late final Map<String, Object?> _values = {...?widget.rec?.values};
  late final Map<String, TextEditingController> _text = {
    for (final f in widget.collection.fields)
      if (f.type == FieldType.text ||
          f.type == FieldType.long ||
          f.type == FieldType.number)
        f.key: TextEditingController(text: _values[f.key] as String? ?? ''),
  };

  @override
  void dispose() {
    for (final c in _text.values) {
      c.dispose();
    }
    super.dispose();
  }

  bool get _ready => widget.collection.fields.every(
    (f) =>
        !f.required ||
        (_text[f.key]?.text.trim().isNotEmpty ?? (_values[f.key] != null)),
  );

  Future<void> _save() async {
    for (final e in _text.entries) {
      _values[e.key] = e.value.text.trim();
    }
    _values.removeWhere(
      (_, v) => v == null || v == '' || (v is List && v.isEmpty),
    );
    await widget.store.saveRecord(
      widget.collection.id,
      Rec(widget.rec?.id ?? widget.store.newId(), _values),
    );
    if (mounted) Navigator.pop(context);
  }

  Widget _field(Field f) {
    final colors = context.colors;
    switch (f.type) {
      case FieldType.text:
      case FieldType.long:
      case FieldType.number:
        final number = f.type == FieldType.number;
        return TextField(
          key: Key('field_${f.key}'),
          controller: _text[f.key],
          onChanged: (_) => setState(() {}),
          minLines: 1,
          maxLines: f.type == FieldType.long ? 3 : 1,
          textCapitalization: TextCapitalization.sentences,
          keyboardType: number
              ? const TextInputType.numberWithOptions(decimal: true)
              : null,
          inputFormatters: [
            if (number) FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            LengthLimitingTextInputFormatter(
              f.type == FieldType.long ? 500 : 80,
            ),
          ],
          decoration: InputDecoration(labelText: f.label),
        );
      case FieldType.date:
        final value = Rec('', _values).date(f.key);
        return ProfileRow(
          icon: PhosphorIconsThin.calendarBlank,
          title: f.label,
          subtitle: value == null
              ? 'Not noted'
              : '${dayMonth(value)} ${value.year}',
          trailing: value == null
              ? null
              : HeaderIconButton(
                  icon: PhosphorIconsThin.x,
                  tooltip: 'Clear',
                  onTap: () => setState(() => _values.remove(f.key)),
                ),
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(DateTime.now().year + 10),
            );
            if (picked != null) {
              setState(() => _values[f.key] = dayKey(picked));
            }
          },
        );
      case FieldType.choice:
        final now = _values[f.key] as String?;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(f.label),
            _chips(
              context,
              {for (final o in f.options) o: o},
              {?now},
              (s) => setState(() {
                final other = s.difference({?now});
                _values[f.key] = other.isEmpty ? null : other.first;
              }),
            ),
          ],
        );
      case FieldType.multi:
        final from = widget.store.data.of(f.from!);
        final rec = Rec('', _values);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(f.label),
            if (from.isEmpty)
              Text(
                'Add some to your list first.',
                style: TextStyle(color: colors.textMuted),
              )
            else
              _chips(
                context,
                {for (final r in from) r.id: r.text('name')},
                rec.ids(f.key).toSet(),
                (s) => setState(() => _values[f.key] = [...s]),
              ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.collection;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.rec == null ? 'Add ${c.one}' : 'Change ${c.one}',
          style: TextStyle(fontSize: 20, color: context.colors.textPrimary),
        ),
        const SizedBox(height: 8),
        for (final f in c.fields)
          Padding(padding: const EdgeInsets.only(top: 10), child: _field(f)),
        const SizedBox(height: 16),
        GoldButton(
          key: const Key('saveRecord'),
          label: 'Save',
          quiet: false,
          onPressed: _ready ? _save : null,
        ),
        if (widget.rec != null)
          Center(
            child: TextButton(
              onPressed: () async {
                final yes = await showDialog<bool>(
                  context: context,
                  builder: (d) => AlertDialog(
                    title: const Text('Remove this?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(d, false),
                        child: const Text('Keep'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(d, true),
                        child: const Text('Remove'),
                      ),
                    ],
                  ),
                );
                if (yes != true) return;
                await widget.store.removeRecord(c.id, widget.rec!.id);
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Remove'),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Lists

class _Lists extends StatelessWidget {
  const _Lists({required this.app, required this.store, required this.now});

  final ConceptApp app;
  final ConceptStore store;
  final DateTime now;

  @override
  Widget build(BuildContext context) => PinnedHeaderList(
    header: const ScreenHeader(title: 'Lists'),
    children: [
      const SizedBox(height: 6),
      for (final c in app.collections)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: CardBox(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
            child: ProfileRow(
              key: Key('list_${c.id}'),
              icon: c.icon,
              title: c.title,
              subtitle: switch (store.data.of(c.id).length) {
                0 => 'Nothing yet',
                1 => '1 saved',
                final n => '$n saved',
              },
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => ListPage(store: store, collection: c),
                ),
              ),
            ),
          ),
        ),
    ],
  );
}

class ListPage extends StatefulWidget {
  const ListPage({super.key, required this.store, required this.collection});

  final ConceptStore store;
  final Collection collection;

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final c = widget.collection;
    final store = widget.store;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CanvasBackdrop(
        child: SafeArea(
          child: ListenableBuilder(
            listenable: store,
            builder: (context, _) {
              final data = store.data;
              final now = DateTime.now();
              final q = _query.trim().toLowerCase();
              final list = [
                for (final r in data.of(c.id).reversed)
                  if (q.isEmpty ||
                      '${c.name(r, data)} ${r.values.values.join(' ')}'
                          .toLowerCase()
                          .contains(q))
                    r,
              ];
              return PinnedHeaderList(
                header: MediaQuery.withClampedTextScaling(
                  maxScaleFactor: 1.2,
                  child: Row(
                    children: [
                      HeaderIconButton(
                        icon: PhosphorIconsThin.caretLeft,
                        tooltip: 'Back',
                        onTap: () => Navigator.pop(context),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ScreenHeader(
                          title: c.title,
                          actions: [
                            HeaderIconButton(
                              icon: PhosphorIconsThin.plus,
                              tooltip: 'Add ${c.one}',
                              onTap: () => showRecordSheet(context, store, c),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                children: [
                  if (c.hint != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        c.hint!,
                        style: TextStyle(
                          height: 1.45,
                          color: context.colors.textSecondary,
                        ),
                      ),
                    ),
                  if (c.searchable && data.of(c.id).isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        decoration: const InputDecoration(
                          hintText: 'Search what you already have',
                        ),
                      ),
                    ),
                  if (data.of(c.id).isEmpty)
                    EmptyNote(icon: c.icon, text: c.empty)
                  else if (list.isEmpty)
                    EmptyNote(icon: c.icon, text: 'Nothing matches.'),
                  for (final r in list)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: CardBox(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                        child: ProfileRow(
                          icon: c.icon,
                          title: c.name(r, data),
                          subtitle: c.detail
                              ?.call(r, data, now)
                              .where((s) => s.isNotEmpty)
                              .join(' · '),
                          onTap: () => showRecordSheet(context, store, c, r),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------- Diary

class _Diary extends StatelessWidget {
  const _Diary({required this.app, required this.store, required this.now});

  final ConceptApp app;
  final ConceptStore store;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final data = store.data;
    final month = data.within(now, 30);
    final days = data.within(now, 3650);
    return PinnedHeaderList(
      header: ScreenHeader(
        title: 'Diary',
        actions: [
          HeaderIconButton(
            icon: PhosphorIconsThin.plus,
            tooltip: 'Note a day',
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: now,
                firstDate: DateTime(2000),
                lastDate: now,
              );
              if (picked != null && context.mounted) {
                await showDaySheet(context, app, store, picked);
              }
            },
          ),
        ],
      ),
      children: [
        const SizedBox(height: 6),
        CardBox(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'The last 30 days',
                style: TextStyle(fontSize: 16, color: colors.textPrimary),
              ),
              for (final c in app.checks)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    '${c.label}: '
                    '${month.where((d) => d.checks.contains(c.id)).length} days',
                    style: TextStyle(color: colors.textSecondary),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        if (days.isEmpty)
          const EmptyNote(
            icon: PhosphorIconsThin.notebook,
            text: 'No days yet. Note today from the Today tab.',
          ),
        for (final d in days)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: CardBox(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
              child: ProfileRow(
                icon: PhosphorIconsThin.notePencil,
                title: longToday(parseDayKey(d.day)),
                subtitle: [
                  for (final c in app.checks)
                    if (d.checks.contains(c.id)) c.label,
                  ...d.words,
                  for (final id in d.used) data.find(id)?.text('name') ?? '',
                  d.note,
                ].where((s) => s.isNotEmpty).join(' · '),
                onTap: () =>
                    showDaySheet(context, app, store, parseDayKey(d.day)),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------- Profile

class _Profile extends StatelessWidget {
  const _Profile({required this.app, required this.store});

  final ConceptApp app;
  final ConceptStore store;

  @override
  Widget build(BuildContext context) => PinnedHeaderList(
    header: const ScreenHeader(title: 'Profile'),
    children: [
      const SizedBox(height: 16),
      const SectionLabel('Your data'),
      DataSection(
        backupKey: app.id,
        appName: app.name,
        store: store,
        exportFileName: 'veda-${app.id}-export.json',
        whatIsDeleted: 'Your lists and diary are deleted from this phone.',
      ),
      const SizedBox(height: 18),
      const SectionLabel('Help'),
      SupportSection(appName: app.name),
      const SizedBox(height: 18),
      const BrandFooter(),
      AboutNote('${app.about} Test build, for the AryaVedics team.'),
    ],
  );
}
