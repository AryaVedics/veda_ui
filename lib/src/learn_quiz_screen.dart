// Copy of Véda's template (flutter_app/lib/screens/learn_quiz_screen.dart). Keep in step.
//
//  * "Which is it?": a few gentle questions, one at a time. A tap shows the right
//    answer and a short, warm explanation, with a link to the note it came from.
//    From the front page: one question from each of five themes. From a theme
//    page: three questions from that theme.
//  * "Ingredient match": pair four ingredients with the kind of product each is
//    best known for.
//  * "Label detective": the same kind of question, about the words and symbols
//    on a pack, with the words shown in a little label.
//  * "Myth or fact": a short statement, and a tap on Myth or Fact.
//
// All are kind on purpose: no score, no timer, no streak, nothing recorded and
// nothing sent anywhere. A wrong answer only shows the answer.
//
// An app can give the games a host (Routine does: a forest friend asks the
// questions) by setting [quizHostBuilder]. Véda has no friends, so it leaves it
// unset.

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import 'app_colors.dart';
import 'brand.dart';
import 'learn_content.dart';
import 'learn_quiz.dart';
import 'learn_screen.dart' show LearnButton, LearnThemeScreen;

/// Someone who hosts the games: a name and a picture.
class QuizHost {
  const QuizHost({required this.name, required this.avatar});

  final String name;
  final Widget avatar;
}

/// Set by an app that wants a host. Called once each time a game opens, with
/// the theme the game is about (null for the mix of themes on the front page,
/// and the ingredients theme for Ingredient match), so a host can suit the
/// topic. Null, or returning null, means no host.
QuizHost? Function(LearnCategory? theme)? quizHostBuilder;

void _readNote(BuildContext context, String noteId) {
  final note = learnEntry(noteId);
  if (note == null) return;
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) =>
          LearnThemeScreen(category: note.category, openId: note.id),
    ),
  );
}

/// The host, saying [text], at the top of a game.
class _HostLine extends StatelessWidget {
  const _HostLine({required this.host, required this.text});

  final QuizHost host;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      key: const Key('quizHost'),
      children: [
        SizedBox.square(dimension: 56, child: host.avatar),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            '${host.name}: $text',
            style: TextStyle(
              fontSize: 13.5,
              height: 1.45,
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

/// "Which is it?"
class LearnQuizScreen extends StatefulWidget {
  const LearnQuizScreen({
    super.key,
    this.category,
    this.random,
    this.count,
    this.labels = false,
  });

  /// Label detective: questions about the words and symbols on a pack.
  final bool labels;

  /// One theme's questions; null for a mix from five themes.
  final LearnCategory? category;

  /// For tests: a seeded source of chance.
  final math.Random? random;

  /// How many questions; five from the front page, three from a theme.
  final int? count;

  @override
  State<LearnQuizScreen> createState() => _LearnQuizScreenState();
}

class _LearnQuizScreenState extends State<LearnQuizScreen> {
  late final math.Random _rnd = widget.random ?? math.Random();
  late final QuizHost? _host = quizHostBuilder?.call(
    widget.labels ? LearnCategory.labels : widget.category,
  );
  late List<QuizQuestion> _qs;
  late List<List<int>> _orders;
  int _i = 0;
  int? _picked;
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final n =
        widget.count ?? (widget.labels ? 4 : (widget.category == null ? 5 : 3));
    final List<QuizQuestion> pool;
    if (widget.labels) {
      pool = ([...kLabelQuestions]..shuffle(_rnd)).take(n).toList();
    } else if (widget.category == null) {
      final themes = [...learnCategoriesShown()]..shuffle(_rnd);
      pool = [
        for (final c in themes.take(n))
          (quizQuestionsIn(c)..shuffle(_rnd)).first,
      ];
    } else {
      pool = (quizQuestionsIn(
        widget.category!,
      )..shuffle(_rnd)).take(n).toList();
    }
    _qs = pool;
    _orders = [
      for (final q in pool)
        List<int>.generate(q.options.length, (i) => i)..shuffle(_rnd),
    ];
    _i = 0;
    _picked = null;
    _done = false;
  }

  void _next() => setState(() {
    if (_i + 1 >= _qs.length) {
      _done = true;
    } else {
      _i++;
      _picked = null;
    }
  });

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
          widget.labels
              ? 'Label detective'
              : (widget.category == null
                    ? 'Which is it?'
                    : widget.category!.title),
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: _done ? _finish(colors) : _question(colors),
        ),
      ),
    );
  }

  List<Widget> _question(AppColors colors) {
    final q = _qs[_i];
    final answered = _picked != null;
    final right = _picked == q.correct;
    return [
      if (_host != null) ...[
        _HostLine(
          host: _host,
          text: _i == 0
              ? 'I have a few questions. There is no score, and nothing to '
                    'lose.'
              : 'Here is another.',
        ),
        const SizedBox(height: 18),
      ],
      Text(
        'Question ${_i + 1} of ${_qs.length}',
        key: const Key('quizProgress'),
        style: TextStyle(fontSize: 12, color: colors.textMuted),
      ),
      const SizedBox(height: 8),
      if (q.snippet != null) ...[
        Container(
          key: const Key('quizSnippet'),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 22),
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: colors.cardSunken,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.accent.withValues(alpha: 0.5)),
          ),
          child: Text(
            q.snippet!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              letterSpacing: 1.2,
              color: colors.textPrimary,
            ),
          ),
        ),
      ],
      Text(
        q.prompt,
        key: const Key('quizPrompt'),
        style: TextStyle(fontSize: 17, height: 1.4, color: colors.textPrimary),
      ),
      const SizedBox(height: 16),
      for (final (pos, o) in _orders[_i].indexed) ...[
        _OptionTile(
          key: Key('quizOption-$pos'),
          text: q.options[o],
          state: !answered
              ? _OptionState.open
              : o == q.correct
              ? _OptionState.right
              : o == _picked
              ? _OptionState.missed
              : _OptionState.faded,
          onTap: answered ? null : () => setState(() => _picked = o),
        ),
        const SizedBox(height: 10),
      ],
      if (answered) ...[
        const SizedBox(height: 6),
        Container(
          key: const Key('quizFeedback'),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: colors.cardSunken,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                right ? 'Yes, that is it.' : 'Not quite. Here is the answer.',
                style: TextStyle(fontSize: 14, color: colors.accentText),
              ),
              const SizedBox(height: 6),
              Text(
                q.explanation,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LearnButton(
          key: const Key('quizReadNote'),
          label: 'Read the note',
          onPressed: () => _readNote(context, q.noteId),
        ),
        const SizedBox(height: 10),
        LearnButton(
          key: const Key('quizNext'),
          label: _i + 1 >= _qs.length ? 'Finish' : 'Next question',
          onPressed: _next,
        ),
      ],
    ];
  }

  List<Widget> _finish(AppColors colors) => [
    const SizedBox(height: 20),
    if (_host != null) ...[
      Center(child: SizedBox.square(dimension: 110, child: _host.avatar)),
      const SizedBox(height: 14),
    ],
    Text(
      'That is the round.',
      key: const Key('quizDone'),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, color: colors.textPrimary),
    ),
    const SizedBox(height: 8),
    Text(
      _host == null
          ? 'Thank you for stopping by. Come back whenever you like.'
          : 'Thank you for stopping by, says ${_host.name}. Come back '
                'whenever you like.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: colors.textSecondary,
      ),
    ),
    const SizedBox(height: 22),
    LearnButton(
      key: const Key('quizAgain'),
      label: 'Another round',
      onPressed: () => setState(_newRound),
    ),
    const SizedBox(height: 10),
    LearnButton(
      key: const Key('quizBack'),
      label: 'Back',
      onPressed: () => Navigator.of(context).pop(),
    ),
  ];
}

enum _OptionState { open, right, missed, faded }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    super.key,
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final right = state == _OptionState.right;
    final missed = state == _OptionState.missed;
    return Material(
      color: right ? colors.accentDim : colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: right
                  ? colors.accent
                  : missed
                  ? colors.textMuted
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 14.5,
                    height: 1.4,
                    color: state == _OptionState.faded
                        ? colors.textMuted
                        : colors.textPrimary,
                  ),
                ),
              ),
              if (right)
                Icon(
                  PhosphorIconsThin.checkCircle,
                  size: 20,
                  color: colors.accentText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Ingredient match".
class IngredientMatchScreen extends StatefulWidget {
  const IngredientMatchScreen({super.key, this.random});

  /// For tests: a seeded source of chance.
  final math.Random? random;

  @override
  State<IngredientMatchScreen> createState() => _IngredientMatchScreenState();
}

class _IngredientMatchScreenState extends State<IngredientMatchScreen> {
  late final math.Random _rnd = widget.random ?? math.Random();
  late final QuizHost? _host = quizHostBuilder?.call(LearnCategory.ingredients);
  late List<MatchPair> _pairs;
  late List<int> _kindOrder;
  final Set<int> _matched = {};
  int? _selIngredient;
  int? _selKind;
  String? _message;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    _pairs = ([...kMatchPairs]..shuffle(_rnd)).take(4).toList();
    _kindOrder = List<int>.generate(_pairs.length, (i) => i)..shuffle(_rnd);
    _matched.clear();
    _selIngredient = null;
    _selKind = null;
    _message = null;
  }

  void _check() {
    final a = _selIngredient, b = _selKind;
    if (a == null || b == null) return;
    if (a == b) {
      _matched.add(a);
      _message =
          '${_pairs[a].ingredient} is best known in '
          '${_pairs[a].kind.toLowerCase()}.';
    } else {
      _message = 'Not quite. Try another.';
    }
    _selIngredient = null;
    _selKind = null;
  }

  bool get _allMatched => _matched.length == _pairs.length;

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
          'Ingredient match',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            if (_host != null) ...[
              _HostLine(
                host: _host,
                text:
                    'Pair each ingredient with the kind of product it is best '
                    'known for. There is no score.',
              ),
              const SizedBox(height: 18),
            ] else ...[
              Text(
                'Pair each ingredient with the kind of product it is best '
                'known for. There is no score, and a wrong tap only says try '
                'another.',
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: 18),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      for (final (i, p) in _pairs.indexed) ...[
                        _MatchChip(
                          key: Key('matchIngredient-${p.ingredient}'),
                          text: p.ingredient,
                          matched: _matched.contains(i),
                          selected: _selIngredient == i,
                          onTap: () {
                            if (_matched.contains(i)) {
                              _readNote(context, p.noteId);
                              return;
                            }
                            setState(() {
                              _selIngredient = i;
                              _message = null;
                              _check();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      for (final i in _kindOrder) ...[
                        _MatchChip(
                          key: Key('matchKind-${_pairs[i].kind}'),
                          text: _pairs[i].kind,
                          matched: _matched.contains(i),
                          selected: _selKind == i,
                          onTap: _matched.contains(i)
                              ? null
                              : () => setState(() {
                                  _selKind = i;
                                  _message = null;
                                  _check();
                                }),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (_message != null)
              Text(
                _message!,
                key: const Key('matchMessage'),
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.5,
                  color: colors.accentText,
                ),
              ),
            if (_allMatched) ...[
              const SizedBox(height: 14),
              Text(
                _host == null
                    ? 'All matched. Tap an ingredient to read its note.'
                    : 'All matched, says ${_host.name}. Tap an ingredient to '
                          'read its note.',
                key: const Key('matchDone'),
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 14),
              LearnButton(
                key: const Key('matchAgain'),
                label: 'Another round',
                onPressed: () => setState(_newRound),
              ),
              const SizedBox(height: 10),
              LearnButton(
                key: const Key('matchBack'),
                label: 'Back',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchChip extends StatelessWidget {
  const _MatchChip({
    super.key,
    required this.text,
    required this.matched,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool matched;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: matched || selected ? colors.accentDim : colors.card,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 54),
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected || matched ? colors.accent : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.3,
                    color: colors.textPrimary,
                  ),
                ),
              ),
              if (matched)
                Icon(
                  PhosphorIconsThin.checkCircle,
                  size: 18,
                  color: colors.accentText,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Myth or fact".
class LearnMythScreen extends StatefulWidget {
  const LearnMythScreen({super.key, this.random, this.count = 5});

  /// For tests: a seeded source of chance.
  final math.Random? random;
  final int count;

  @override
  State<LearnMythScreen> createState() => _LearnMythScreenState();
}

class _LearnMythScreenState extends State<LearnMythScreen> {
  late final math.Random _rnd = widget.random ?? math.Random();
  late final QuizHost? _host = quizHostBuilder?.call(null);
  late List<MythCard> _cards;
  int _i = 0;
  bool? _said; // true: "Fact", false: "Myth"
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    _cards = ([...kMythCards]..shuffle(_rnd)).take(widget.count).toList();
    _i = 0;
    _said = null;
    _done = false;
  }

  void _next() => setState(() {
    if (_i + 1 >= _cards.length) {
      _done = true;
    } else {
      _i++;
      _said = null;
    }
  });

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
          'Myth or fact',
          style: TextStyle(fontSize: 15, color: colors.textPrimary),
        ),
      ),
      body: CanvasBackdrop(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: _done ? _finish(colors) : _card(colors),
        ),
      ),
    );
  }

  List<Widget> _card(AppColors colors) {
    final c = _cards[_i];
    final answered = _said != null;
    final right = _said == c.isFact;
    return [
      if (_host != null) ...[
        _HostLine(
          host: _host,
          text: _i == 0
              ? 'Is it true? Tap to say, and I will tell you. There is no '
                    'score.'
              : 'Here is another.',
        ),
        const SizedBox(height: 18),
      ],
      Text(
        'Statement ${_i + 1} of ${_cards.length}',
        key: const Key('mythProgress'),
        style: TextStyle(fontSize: 12, color: colors.textMuted),
      ),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 24),
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.accent.withValues(alpha: 0.35)),
        ),
        child: Text(
          c.statement,
          key: const Key('mythStatement'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17,
            height: 1.45,
            color: colors.textPrimary,
          ),
        ),
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: LearnButton(
              key: const Key('mythButton'),
              label: 'Myth',
              onPressed: answered ? () {} : () => setState(() => _said = false),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: LearnButton(
              key: const Key('factButton'),
              label: 'Fact',
              onPressed: answered ? () {} : () => setState(() => _said = true),
            ),
          ),
        ],
      ),
      if (answered) ...[
        const SizedBox(height: 16),
        Container(
          key: const Key('mythFeedback'),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          decoration: BoxDecoration(
            color: colors.cardSunken,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${right ? 'Yes, that is it.' : 'Not quite.'} '
                '${c.isFact ? 'It is a fact.' : 'It is a myth.'}',
                style: TextStyle(fontSize: 14, color: colors.accentText),
              ),
              const SizedBox(height: 6),
              Text(
                c.explanation,
                style: TextStyle(
                  fontSize: 13.5,
                  height: 1.55,
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        LearnButton(
          key: const Key('mythReadNote'),
          label: 'Read the note',
          onPressed: () => _readNote(context, c.noteId),
        ),
        const SizedBox(height: 10),
        LearnButton(
          key: const Key('mythNext'),
          label: _i + 1 >= _cards.length ? 'Finish' : 'Next',
          onPressed: _next,
        ),
      ],
    ];
  }

  List<Widget> _finish(AppColors colors) => [
    const SizedBox(height: 20),
    if (_host != null) ...[
      Center(child: SizedBox.square(dimension: 110, child: _host.avatar)),
      const SizedBox(height: 14),
    ],
    Text(
      'That is the round.',
      key: const Key('mythDone'),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18, color: colors.textPrimary),
    ),
    const SizedBox(height: 8),
    Text(
      _host == null
          ? 'Thank you for stopping by. Come back whenever you like.'
          : 'Thank you for stopping by, says ${_host.name}. Come back '
                'whenever you like.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13.5,
        height: 1.5,
        color: colors.textSecondary,
      ),
    ),
    const SizedBox(height: 22),
    LearnButton(
      key: const Key('mythAgain'),
      label: 'Another round',
      onPressed: () => setState(_newRound),
    ),
    const SizedBox(height: 10),
    LearnButton(
      key: const Key('mythBack'),
      label: 'Back',
      onPressed: () => Navigator.of(context).pop(),
    ),
  ];
}
