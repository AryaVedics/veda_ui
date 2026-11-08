// Copy of Véda's template (flutter_app/lib/screens/learn_screen.dart). Keep in step.
//
// The front page has a search box, an A to Z of definitions, the notes a person
// saved, the themes in three groups (Your skin, Everyday life, Products and
// labels) and, last, four practice games. A theme is a page of its own, with its
// notes closed to their titles; an open note offers "Also see" links to notes
// that go with it, and a bookmark to keep it for later.
//
// It is reached from the "Education" row (at the top of Trends in Véda, where it
// sits above the scores on purpose, and on the Shelf and Profile in Routine)
// and from the "Education" item in the logo menu.
//
// Everything here is descriptive, never advice (see learn_content.dart for the
// rules, and consent_screen.dart / score_info_screen.dart for the "not a
// medical device" wording this repeats, so the app never says it two ways).
//
// [LearnScreen.openId] opens one note straight away (its theme page opens over
// the front page), so a card elsewhere can point at a note.

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'brand.dart';
import 'learn_content.dart';
import 'learn_read.dart';
import 'learn_saved.dart';
import 'learn_quiz_screen.dart';
import 'learn_share.dart';

/// The education-only note under the heading of the front page and of each
/// theme page (the website's pages carry the same words).
const String kLearnTopNote =
    'Véda does not recommend, promote or sell any product or ingredient '
    'mentioned here. These notes are for education only and are not medical '
    'advice.';

const String _skinDisclaimer =
    'This is general information, not medical advice. If something changes '
    'suddenly or concerns you, that is a conversation for a doctor or '
    'dermatologist, not a note in this app.';

const String _foodDisclaimer =
    'This is general information, not medical or nutrition advice. What is '
    'right for one person to eat is a conversation for a doctor or a '
    'dietitian, not a note in this app.';

String get _disclaimer => _foodOnly ? _foodDisclaimer : _skinDisclaimer;

/// The three games about products and labels are for the skin apps; a food
/// app has the quiz alone.
bool get _skinPractice => learnGroupsShown.contains(LearnGroup.products);

/// Wording that names the subject: skin, or food.
bool get _foodOnly => !learnGroupsShown.contains(LearnGroup.skin);

/// Opens [entry]'s theme page with the note already open.
void openLearnNote(BuildContext context, LearnEntry entry) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          LearnThemeScreen(category: entry.category, openId: entry.id),
    ),
  );
}

void _push(BuildContext context, Widget page) =>
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));

/// The portal's front page.
class LearnScreen extends StatefulWidget {
  const LearnScreen({super.key, this.openId});

  /// A note to show open when the page appears.
  final String? openId;

  @override
  State<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends State<LearnScreen> {
  @override
  void initState() {
    super.initState();
    LearnSaved.load();
    final entry = widget.openId == null ? null : learnEntry(widget.openId!);
    if (entry != null) {
      // the theme page opens over the front page, so back returns to it
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) openLearnNote(context, entry);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Véda Education',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            Text(
              'Short, plain notes about skin, your readings, everyday life and '
              'the products on your shelf. They are general notes about what '
              'is commonly known or commonly done, not advice for you.',
              style: TextStyle(
                fontSize: 13.5,
                color: colors.textSecondary,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              kLearnTopNote,
              key: const Key('learnTopNote'),
              style: TextStyle(
                fontSize: 12.5,
                color: colors.textMuted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 18),
            Material(
              color: colors.card,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                key: const Key('learnSearch'),
                borderRadius: BorderRadius.circular(14),
                onTap: () => _push(context, const LearnSearchScreen()),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Row(
                    children: [
                      Icon(
                        PhosphorIconsThin.magnifyingGlass,
                        size: 20,
                        color: colors.accentText,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Search the notes',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            _TilePair(
              left: _Tile(
                key: const Key('learnGlossary'),
                icon: PhosphorIconsThin.listBullets,
                title: 'A to Z',
                blurb: 'Every definition, in alphabetical order.',
                onTap: () => _push(context, const LearnGlossaryScreen()),
              ),
              right: ValueListenableBuilder<Set<String>>(
                valueListenable: LearnSaved.ids,
                builder: (context, saved, _) => _Tile(
                  key: const Key('learnSaved'),
                  icon: PhosphorIconsThin.bookmarkSimple,
                  title: 'Saved',
                  blurb: saved.isEmpty
                      ? 'Notes you keep for later.'
                      : '${saved.length} kept for later.',
                  onTap: () => _push(context, const LearnSavedScreen()),
                ),
              ),
            ),
            for (final group in LearnGroup.values)
              if (learnGroupsShown.contains(group)) ...[
                const SizedBox(height: 24),
                Text(
                  group.title,
                  style: TextStyle(fontSize: 14, color: colors.textPrimary),
                ),
                const SizedBox(height: 10),
                _ThemeGrid(
                  themes: [
                    for (final c in LearnCategory.values)
                      if (c.group == group) c,
                  ],
                ),
              ],
            const SizedBox(height: 24),
            Text(
              'Practice',
              style: TextStyle(fontSize: 14, color: colors.textPrimary),
            ),
            const SizedBox(height: 10),
            if (!_skinPractice)
              _Tile(
                key: const Key('learnQuiz'),
                icon: PhosphorIconsThin.question,
                title: 'Which is it?',
                blurb: 'A few gentle questions. No score.',
                onTap: () => _push(context, const LearnQuizScreen()),
              )
            else ...[
              _TilePair(
                left: _Tile(
                  key: const Key('learnQuiz'),
                  icon: PhosphorIconsThin.question,
                  title: 'Which is it?',
                  blurb: 'A few gentle questions. No score.',
                  onTap: () => _push(context, const LearnQuizScreen()),
                ),
                right: _Tile(
                  key: const Key('learnMatch'),
                  icon: PhosphorIconsThin.arrowsLeftRight,
                  title: 'Ingredient match',
                  blurb: 'Pair an ingredient with where it turns up.',
                  onTap: () => _push(context, const IngredientMatchScreen()),
                ),
              ),
              const SizedBox(height: 10),
              _TilePair(
                left: _Tile(
                  key: const Key('learnLabels'),
                  icon: PhosphorIconsThin.magnifyingGlassPlus,
                  title: 'Label detective',
                  blurb: 'What do the words on a pack mean?',
                  onTap: () =>
                      _push(context, const LearnQuizScreen(labels: true)),
                ),
                right: _Tile(
                  key: const Key('learnMyth'),
                  icon: PhosphorIconsThin.sparkle,
                  title: 'Myth or fact',
                  blurb: 'Is it true? A tap to find out.',
                  onTap: () => _push(context, const LearnMythScreen()),
                ),
              ),
            ],
            const SizedBox(height: 24),
            InkWell(
              key: const Key('learnAbout'),
              borderRadius: BorderRadius.circular(10),
              onTap: () => _push(context, const LearnAboutScreen()),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Where these notes come from',
                        style: TextStyle(
                          fontSize: 13.5,
                          color: colors.accentText,
                        ),
                      ),
                    ),
                    Icon(
                      PhosphorIconsThin.caretRight,
                      size: 16,
                      color: colors.accentText,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _disclaimer,
              style: TextStyle(
                fontSize: 12,
                color: colors.textMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Two tiles side by side, level with each other.
class _TilePair extends StatelessWidget {
  const _TilePair({required this.left, required this.right});

  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) => IntrinsicHeight(
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(child: left),
        const SizedBox(width: 10),
        Expanded(child: right),
      ],
    ),
  );
}

/// A tile on the front page: a tool or a game, with a thin gold edge.
class _Tile extends StatelessWidget {
  const _Tile({
    super.key,
    required this.icon,
    required this.title,
    required this.blurb,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String blurb;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: colors.accentText),
              const SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                blurb,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The themes of one group, two to a row.
class _ThemeGrid extends StatelessWidget {
  const _ThemeGrid({required this.themes});

  final List<LearnCategory> themes;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < themes.length; i += 2) {
      if (i > 0) rows.add(const SizedBox(height: 10));
      rows.add(
        _TilePair(
          left: _ThemeTile(category: themes[i]),
          right: i + 1 < themes.length
              ? _ThemeTile(category: themes[i + 1])
              : const SizedBox.shrink(),
        ),
      );
    }
    return Column(children: rows);
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.category});

  final LearnCategory category;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final count = learnEntriesIn(category).length;
    return Material(
      color: colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        key: Key('learnTheme-${category.name}'),
        borderRadius: BorderRadius.circular(14),
        onTap: () => _push(context, LearnThemeScreen(category: category)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(category.icon, size: 22, color: colors.accentText),
              const SizedBox(height: 10),
              Text(
                category.title,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.3,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                category.blurb,
                style: TextStyle(
                  fontSize: 12,
                  height: 1.4,
                  color: colors.textSecondary,
                ),
              ),
              const Spacer(),
              const SizedBox(height: 8),
              Text(
                '$count notes',
                style: TextStyle(fontSize: 11.5, color: colors.textMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One theme: its notes, closed to their titles, opening on a tap. [openId]
/// opens one already.
class LearnThemeScreen extends StatelessWidget {
  const LearnThemeScreen({super.key, required this.category, this.openId});

  final LearnCategory category;
  final String? openId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entries = learnEntriesIn(category);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          category.title,
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            Row(
              children: [
                Icon(category.icon, size: 20, color: colors.accentText),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    category.blurb,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: colors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              kLearnTopNote,
              key: const Key('learnTopNote'),
              style: TextStyle(
                fontSize: 12.5,
                color: colors.textMuted,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 18),
            _NoteList(entries: entries, openId: openId),
            const SizedBox(height: 18),
            LearnButton(
              key: const Key('themeQuiz'),
              label: 'Try three questions',
              onPressed: () =>
                  _push(context, LearnQuizScreen(category: category)),
            ),
            const SizedBox(height: 28),
            Text(
              _disclaimer,
              style: TextStyle(
                fontSize: 12,
                color: colors.textMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card of notes, each closed to its title.
class _NoteList extends StatelessWidget {
  const _NoteList({required this.entries, this.openId, this.showTheme = false});

  final List<LearnEntry> entries;
  final String? openId;

  /// Name each note's theme under its title (search and the lists of kept notes).
  final bool showTheme;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          for (final (i, entry) in entries.indexed) ...[
            if (i > 0) Divider(height: 1, color: colors.divider),
            _EntryTile(
              entry: entry,
              startOpen: entry.id == openId,
              showTheme: showTheme,
            ),
          ],
        ],
      ),
    );
  }
}

/// A quiet button in the portal's own style: a dark fill and a thin gold edge.
class LearnButton extends StatelessWidget {
  const LearnButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: colors.card,
          foregroundColor: colors.accentText,
          side: BorderSide(color: colors.accent.withValues(alpha: 0.7)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: const TextStyle(fontSize: 14)),
      ),
    );
  }
}

class _EntryTile extends StatefulWidget {
  const _EntryTile({
    required this.entry,
    required this.startOpen,
    this.showTheme = false,
  });

  final LearnEntry entry;
  final bool startOpen;
  final bool showTheme;

  @override
  State<_EntryTile> createState() => _EntryTileState();
}

class _EntryTileState extends State<_EntryTile> {
  late bool _open = widget.startOpen;

  @override
  void initState() {
    super.initState();
    LearnSaved.load();
    LearnRead.load();
    if (_open) {
      // after this frame: the tick listens to the same notifier
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => LearnRead.mark(widget.entry.id),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final e = widget.entry;
    final related = _open ? learnRelated(e.id) : const <LearnEntry>[];
    return Semantics(
      button: true,
      expanded: _open,
      child: InkWell(
        key: Key('learn-${e.id}'),
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          setState(() => _open = !_open);
          if (_open) LearnRead.mark(e.id);
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.35,
                            color: colors.textPrimary,
                          ),
                        ),
                        if (widget.showTheme)
                          Text(
                            e.category.title,
                            style: TextStyle(
                              fontSize: 11.5,
                              color: colors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: LearnRead.ids,
                    builder: (context, read, _) => read.contains(e.id)
                        ? Padding(
                            padding: const EdgeInsets.only(right: 2),
                            child: Icon(
                              PhosphorIconsThin.check,
                              key: Key('learnRead-${e.id}'),
                              size: 15,
                              color: colors.textMuted,
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                  ValueListenableBuilder<Set<String>>(
                    valueListenable: LearnSaved.ids,
                    builder: (context, saved, _) {
                      final kept = saved.contains(e.id);
                      return IconButton(
                        key: Key('learnSave-${e.id}'),
                        tooltip: kept ? 'Saved' : 'Keep for later',
                        visualDensity: VisualDensity.compact,
                        icon: Icon(
                          kept
                              ? PhosphorIconsFill.bookmarkSimple
                              : PhosphorIconsThin.bookmarkSimple,
                          size: 20,
                          color: kept ? colors.accentText : colors.textMuted,
                        ),
                        onPressed: () => LearnSaved.toggle(e.id),
                      );
                    },
                  ),
                  Icon(
                    _open
                        ? PhosphorIconsThin.caretUp
                        : PhosphorIconsThin.caretDown,
                    size: 16,
                    color: colors.textMuted,
                  ),
                  const SizedBox(width: 4),
                ],
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                alignment: Alignment.topCenter,
                child: _open
                    ? Padding(
                        padding: const EdgeInsets.only(top: 8, right: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.body,
                              key: Key('learn-body-${e.id}'),
                              style: TextStyle(
                                fontSize: 13.5,
                                height: 1.6,
                                color: colors.textSecondary,
                              ),
                            ),
                            if (e.why != null) ...[
                              const SizedBox(height: 10),
                              Text(
                                'Why it is added',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                e.why!,
                                key: Key('learn-why-${e.id}'),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  height: 1.6,
                                  color: colors.textSecondary,
                                ),
                              ),
                            ],
                            if (e.sources.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Source: ${e.sources.join('; ')}',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  height: 1.45,
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),
                            InkWell(
                              key: Key('learnShare-${e.id}'),
                              onTap: () => openLearnShareCard(context, e),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      PhosphorIconsThin.shareNetwork,
                                      size: 16,
                                      color: colors.accentText,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Share as a card',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.accentText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (related.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Also see',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: colors.textMuted,
                                ),
                              ),
                              for (final r in related)
                                InkWell(
                                  key: Key('learnRelated-${r.id}'),
                                  onTap: () => openLearnNote(context, r),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            r.title,
                                            style: TextStyle(
                                              fontSize: 13.5,
                                              color: colors.accentText,
                                            ),
                                          ),
                                        ),
                                        Icon(
                                          PhosphorIconsThin.caretRight,
                                          size: 14,
                                          color: colors.accentText,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ],
                        ),
                      )
                    : const SizedBox(width: double.infinity),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search: type a word, see the notes that mention it.
class LearnSearchScreen extends StatefulWidget {
  const LearnSearchScreen({super.key});

  @override
  State<LearnSearchScreen> createState() => _LearnSearchScreenState();
}

class _LearnSearchScreenState extends State<LearnSearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final query = _controller.text.trim();
    final results = learnSearch(query);
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Search',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
          children: [
            TextField(
              key: const Key('learnSearchField'),
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              style: TextStyle(fontSize: 15, color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: 'A word, like pores or SPF',
                prefixIcon: Icon(
                  PhosphorIconsThin.magnifyingGlass,
                  color: colors.accentText,
                ),
                filled: true,
                fillColor: colors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),
            if (query.isEmpty)
              Text(
                'Type a word to find the notes that mention it.',
                style: TextStyle(fontSize: 13, color: colors.textMuted),
              )
            else if (results.isEmpty)
              Text(
                'No notes mention "$query". Try another word.',
                key: const Key('learnSearchEmpty'),
                style: TextStyle(fontSize: 13.5, color: colors.textSecondary),
              )
            else
              _NoteList(entries: results, showTheme: true),
          ],
        ),
      ),
    );
  }
}

/// The A to Z: every definition, in alphabetical order under its letter.
class LearnGlossaryScreen extends StatelessWidget {
  const LearnGlossaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final entries = learnGlossary();
    final children = <Widget>[];
    String? letter;
    for (final e in entries) {
      final l = learnGlossaryLetter(e);
      if (l != letter) {
        letter = l;
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 18, bottom: 6),
            child: Text(
              l,
              key: Key('glossaryLetter-$l'),
              style: TextStyle(fontSize: 14, color: colors.accentText),
            ),
          ),
        );
      }
      children.add(
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(14),
          ),
          child: InkWell(
            key: Key('glossary-${e.id}'),
            borderRadius: BorderRadius.circular(14),
            onTap: () => openLearnNote(context, e),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.title,
                          style: TextStyle(
                            fontSize: 14,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          e.category.title,
                          style: TextStyle(
                            fontSize: 11.5,
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    PhosphorIconsThin.caretRight,
                    size: 16,
                    color: colors.textMuted,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'A to Z',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: children,
        ),
      ),
    );
  }
}

/// The notes kept for later.
class LearnSavedScreen extends StatelessWidget {
  const LearnSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    LearnSaved.load();
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Saved',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ValueListenableBuilder<Set<String>>(
          valueListenable: LearnSaved.ids,
          builder: (context, saved, _) {
            final entries = [
              for (final e in kLearnEntries)
                if (saved.contains(e.id)) e,
            ];
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
              children: [
                if (entries.isEmpty)
                  Text(
                    'Nothing kept yet. Open a note and tap the bookmark to keep '
                    'it here. It stays on this phone.',
                    key: const Key('learnSavedEmpty'),
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.55,
                      color: colors.textSecondary,
                    ),
                  )
                else ...[
                  Text(
                    'Kept on this phone only.',
                    style: TextStyle(fontSize: 12, color: colors.textMuted),
                  ),
                  const SizedBox(height: 12),
                  _NoteList(entries: entries, showTheme: true),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// How the notes are written, and what they leave out.
class LearnAboutScreen extends StatelessWidget {
  const LearnAboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    Widget heading(String t) => Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 6),
      child: Text(t, style: TextStyle(fontSize: 14, color: colors.textPrimary)),
    );
    Widget para(String t) => Text(
      t,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.6,
        color: colors.textSecondary,
      ),
    );
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colors.canvas,
        foregroundColor: colors.textPrimary,
        elevation: 0,
        title: Text(
          'Where these notes come from',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
          children: [
            const SizedBox(height: 4),
            Text(
              kLearnTopNote,
              key: const Key('learnTopNote'),
              style: TextStyle(
                fontSize: 12.5,
                color: colors.textMuted,
                height: 1.55,
              ),
            ),
            heading('How they are written'),
            para(
              _foodOnly
                  ? 'Every note is written in plain words from general, widely '
                        'known information about food and labels. A note says what '
                        'is commonly known or commonly done, and none of it is '
                        'advice for you.'
                  : 'Every note is written in plain words from general, widely '
                        'known information about skin. A note says what is '
                        'commonly known or commonly done, and none of it is advice '
                        'for you.',
            ),
            heading('Sources'),
            para(
              _foodOnly
                  ? 'These notes are general knowledge about food and labels, '
                        'and none names a source.'
                  : 'Where one source clearly stands behind a note, the note '
                        'names it: the American Academy of Dermatology '
                        'Association for everyday skin habits and sun care, and '
                        'the World Health Organization for the UV index. A note '
                        'with no source named is general knowledge.',
            ),
            heading('What they leave out'),
            para(
              _foodOnly
                  ? 'No brands, diets, doses, supplements or promises. A note '
                        'says what something is and how it is commonly '
                        'described, and nothing about what to eat.'
                  : 'No brands, doses, supplements or promises. An ingredient '
                        'note says what something is and what kind of product it '
                        'turns up in, and nothing about whether to use it.',
            ),
            if (!_foodOnly) ...[
              heading('Pregnancy'),
              para(
                'Where an ingredient is known to carry risks in pregnancy '
                '(the retinoids, for example), its note says so and suggests '
                'speaking with a doctor first.',
              ),
            ],
            if (kLearnReviewedBy != null) ...[
              heading('Read by'),
              para('These notes were read by $kLearnReviewedBy.'),
            ],
            heading('If something looks wrong'),
            para(
              'Write to us from the Support page at aryavedics.com and we will '
              'look at it.',
            ),
            const SizedBox(height: 24),
            Text(
              _disclaimer,
              style: TextStyle(
                fontSize: 12,
                color: colors.textMuted,
                height: 1.55,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
