import 'patterns.dart';

/// Provisional streaming layer for the markdown/LaTeX parser.
///
/// The finalized patterns in [RegexPatterns] all REQUIRE the closing
/// delimiter, so while tokens are still arriving a message briefly exposes
/// raw syntax — `**hello`, `\(...`, `\[…`, an open ``` fence, a forming
/// `| Model | Context` table row — until the model emits the closing half.
/// [parseText] calls
/// [closeStreamingDelimiters] while a message is still streaming
/// (`isFinished == false`) to fix the visual half of that problem WITHOUT
/// touching the finalized rules: it only ever ADDS the missing closing
/// structure to the current text — a paired delimiter's closer, and for a
/// forming table the separator row it still lacks — and the unchanged
/// parser then renders the unfinished construct immediately.
///
/// Safety contract:
///  * The finalized patterns are used verbatim — both to pair completed
///    constructs (masking) and to validate every synthesis. A closer is
///    kept only if it creates a new complete match under the finalized rule
///    for that construct, so provisional rendering can never invent a
///    construct the finalized parser would refuse.
///  * Bounds: single-line constructs (`\(`, inline code, links) close at the
///    end of their line; display/emphasis constructs (`\[`, `$$`, `**`,
///    `***`, `*`, `~~`) close at the end of their paragraph; an open fence
///    closes at the end of the text. An abandoned opener therefore can never
///    swallow unrelated following content.
///  * Closer-candidate rule: if the claimed region already contains a
///    possible closer (e.g. the mid-line `\]` in `\[x\] trailing text`),
///    nothing is synthesized — the model already spent that delimiter and
///    the finalized (literal) verdict stands.
///  * Code precedence: completed code fences, code spans, display math
///    blocks, thinking blocks and widget markers are masked out before
///    openers are scanned, and an unclosed fence/code-span/math/link claims
///    its whole body so no other construct is completed inside it. Escaped
///    delimiters (`\$`, `\\(`) never open — every opener pattern mirrors
///    the lookaround context of its finalized regex exactly.
///  * Emphasis (bold/italic/strikethrough) re-processes its content through
///    the inline pipeline, so candidates inside it stay live: candidates are
///    completed rightmost-first, which yields the natural nesting
///    `**bold \(math` → `**bold \(math\)**`.
///  * Tables: a finalized table needs its separator row before it can
///    match, so a streaming `| Model | Context` would expose raw pipes
///    until `| --- | --- |` arrives. The provisional layer gives a chain of
///    pipe-led lines that reaches the streaming frontier exactly the
///    structure the finalized parser requires — a separator row after the
///    header line plus, when the last row is still open, its closing pipe —
///    and keeps the synthesis only when [RegexPatterns.table] itself
///    accepts it. Columns are inferred from the UNESCAPED pipe structure
///    (`\|` is content), completed code/math/fence regions can never open a
///    row, the chain stops at the first blank or prose line, and once the
///    real separator arrives the synthesis is a byte-identical no-op that
///    hands off to the finalized parser. A one-cell row (`|x|`, `| Foo |`)
///    stays literal: alone it is indistinguishable from math or prose.
///  * The function is pure and never throws; [parseText] additionally
///    guards the call. Once the real closer arrives the synthesized one is
///    simply not needed anymore, so the handoff to the finalized parser is
///    seamless — closed constructs are byte-identical no-ops.
const int _maxInsertions = 6;

/// A dangling (not yet closed) paired construct found at the streaming
/// frontier.
class _Dangling {
  final String key;
  final int start; // opener start offset
  final int bodyStart; // offset just past the opener
  final int bound; // offset where the closer is synthesized
  final int openerLength;
  final String closer; // text inserted at [bound]
  final bool claimsBody; // body is exclusive content (math/code/link)
  final bool trimBeforeInsert; // drop invisible trailing spaces/tabs first
  final RegExp full; // the finalized regex that must gain a new match

  const _Dangling({
    required this.key,
    required this.start,
    required this.bodyStart,
    required this.bound,
    required this.openerLength,
    required this.closer,
    required this.claimsBody,
    required this.trimBeforeInsert,
    required this.full,
  });
}

enum _BoundKind { line, paragraph }

/// Widget markers are atomic block protocol — nothing inside them is
/// markdown.
final RegExp _widgetMarker = RegExp(
    r'<<<WIDGET:[A-Za-z0-9_-]+>>>[\s\S]*?<<<END>>>',
    caseSensitive: false);

/// Blank line — the paragraph boundary for display-level constructs.
final RegExp _blankLine = RegExp(r'\r?\n[ \t]*\r?\n');

/// Any line terminator — the boundary of single-line constructs.
final RegExp _lineEnd = RegExp(r'[\r\n]');

/// One line at a time, for the fence state machine.
final RegExp _anyLine = RegExp(r'^.*$', multiLine: true);
final RegExp _fenceLine = RegExp(r'^[ \t]*(`{3,})([^\r\n]*)$');

// Openers. Each mirrors the lookaround context of the finalized regex it
// feeds, so a synthesized closer can only ever complete a construct the
// finalized parser would itself have accepted.
final RegExp _displayBracketOpen = RegExp(r'^[ \t]*\\\[', multiLine: true);
final RegExp _displayDollarOpen = RegExp(r'(?<![\\$])\$\$(?!\$)');
final RegExp _parenOpen = RegExp(r'(?<!\\)\\\(');
final RegExp _codeOpen = RegExp(r'(?<!`)`(?!`)');
final RegExp _boldItalicOpen = RegExp(r'\*\*\*(?!\s)|___(?!\s)');
final RegExp _boldOpen = RegExp(r'\*\*(?!\s)|__(?!\s)');
final RegExp _strikeOpen = RegExp(r'~~(?!\s)');
final RegExp _italicOpen =
    RegExp(r'(?<![\w*_$])\*(?![\s*])|(?<![\w_])_(?![\s_])');
final RegExp _linkOpen = RegExp(r'(?<!\\)\[[^\]\r\n]+\]\(');

// Closer candidates: when one of these already sits inside a dangling
// opener's claim, nothing is synthesized (e.g. the mid-line `\]` in
// `\[x\] trailing text` must stay literal exactly as the finalized parser
// renders it).
final RegExp _bracketCloseHint = RegExp(r'\\]');
final RegExp _dollarCloseHint = RegExp(r'\$\$');
final RegExp _parenCloseHint = RegExp(r'\\\)');
final RegExp _linkCloseHint = RegExp(r'\)');

/// Per-construct synthesis recipe.
class _InlineSpec {
  final String key;
  final RegExp open;
  final RegExp full;
  final _BoundKind bound;
  final bool claimsBody;
  final RegExp? closeHint;
  final String Function(String openerText) closerOf;
  final bool Function(String body)? extraGuard;

  const _InlineSpec({
    required this.key,
    required this.open,
    required this.full,
    required this.bound,
    required this.claimsBody,
    required this.closeHint,
    required this.closerOf,
    this.extraGuard,
  });
}

final List<_InlineSpec> _inlineSpecs = [
  // Math and code claim their bodies exclusively.
  _InlineSpec(
    key: 'displayBracket',
    open: _displayBracketOpen,
    full: RegexPatterns.displayMathBracket,
    bound: _BoundKind.paragraph,
    claimsBody: true,
    closeHint: _bracketCloseHint,
    closerOf: (_) => r'\]',
  ),
  _InlineSpec(
    key: 'displayDollar',
    open: _displayDollarOpen,
    full: RegexPatterns.displayMath,
    bound: _BoundKind.paragraph,
    claimsBody: true,
    closeHint: _dollarCloseHint,
    closerOf: (_) => r'$$',
  ),
  _InlineSpec(
    key: 'paren',
    open: _parenOpen,
    full: RegexPatterns.inlineMathParen,
    bound: _BoundKind.line,
    claimsBody: true,
    closeHint: _parenCloseHint,
    closerOf: (_) => r'\)',
  ),
  _InlineSpec(
    key: 'codeSpan',
    open: _codeOpen,
    full: RegexPatterns.inlineCode,
    bound: _BoundKind.line,
    claimsBody: true,
    // A later backtick inside the claim is itself the closer candidate.
    closeHint: null,
    closerOf: (_) => '`',
  ),
  _InlineSpec(
    key: 'link',
    open: _linkOpen,
    full: RegexPatterns.link,
    bound: _BoundKind.line,
    claimsBody: true,
    closeHint: _linkCloseHint,
    closerOf: (_) => ')',
    // Only complete URL-shaped targets: a streamed link target never
    // contains spaces or a bare `)`. Prose like "see [note](see chapter 3"
    // is left entirely alone.
    extraGuard: (body) =>
        !body.contains(' ') &&
        !body.contains('\t') &&
        !body.contains(')'),
  ),
  // Emphasis re-processes its content through the inline pipeline, so its
  // body stays open for inner candidates (rightmost-first ordering). The
  // guards reject marker-only bodies (`****`, `***` …) — those are
  // horizontal-rule-shaped or undecided input and must keep rendering
  // exactly as the finalized parser does.
  _InlineSpec(
    key: 'boldItalic',
    open: _boldItalicOpen,
    full: RegexPatterns.boldItalic,
    bound: _BoundKind.paragraph,
    claimsBody: false,
    closeHint: null,
    closerOf: (opener) => opener,
    extraGuard: (body) => RegExp(r'[^\s*_]').hasMatch(body),
  ),
  _InlineSpec(
    key: 'bold',
    open: _boldOpen,
    full: RegexPatterns.bold,
    bound: _BoundKind.paragraph,
    claimsBody: false,
    closeHint: null,
    closerOf: (opener) => opener,
    extraGuard: (body) => RegExp(r'[^\s*_]').hasMatch(body),
  ),
  _InlineSpec(
    key: 'strikethrough',
    open: _strikeOpen,
    full: RegexPatterns.strikethrough,
    bound: _BoundKind.paragraph,
    claimsBody: false,
    closeHint: null,
    closerOf: (opener) => opener,
    extraGuard: (body) => RegExp(r'[^\s~]').hasMatch(body),
  ),
  _InlineSpec(
    key: 'italic',
    open: _italicOpen,
    full: RegexPatterns.italic,
    bound: _BoundKind.paragraph,
    claimsBody: false,
    closeHint: null,
    closerOf: (opener) => opener,
    extraGuard: (body) => RegExp(r'[^\s*_]').hasMatch(body),
  ),
];

/// Completes the trailing, still-open paired constructs of a streaming
/// message so the finalized parser can render them immediately. See the
/// library comment for the full safety contract. Never throws.
String closeStreamingDelimiters(String text) {
  if (text.isEmpty) return text;
  var out = text;
  final exhausted = <String>{};
  for (var i = 0; i < _maxInsertions; i++) {
    final next = _closeRightmostDangling(out, exhausted);
    if (next == null) break;
    out = next;
  }
  // Tables synthesize after the paired delimiters so inline closers (a
  // bold `**`, a `\)`) land INSIDE the forming cells, exactly where the
  // finalized cell pipeline expects them.
  return _completeStreamingTables(out);
}

/// Finds the rightmost dangling construct that is safe to close, appends
/// its closer and returns the result. A construct whose synthesis fails
/// validation (the finalized regex refuses it — e.g. a `$$` body ending in
/// a backslash) is marked exhausted and the next candidate is tried.
String? _closeRightmostDangling(String text, Set<String> exhausted) {
  while (true) {
    final masked = _maskCompleted(text);
    final candidates = <_Dangling>[];
    if (!exhausted.contains('fence')) {
      _collectFence(text, masked, candidates);
    }
    for (final spec in _inlineSpecs) {
      if (exhausted.contains(spec.key)) continue;
      _collectInline(text, masked, spec, candidates);
    }
    if (candidates.isEmpty) return null;
    final kept = _suppressShadowed(candidates);
    if (kept.isEmpty) return null;
    final pick = _rightmost(kept);
    final synthesized = _insertCloser(text, pick);
    if (pick.full.allMatches(synthesized).length >
        pick.full.allMatches(text).length) {
      return synthesized;
    }
    exhausted.add(pick.key);
  }
}

/// Replaces every construct the finalized parser considers COMPLETE with
/// same-length NUL runs, so opener scanning never fires inside code fences,
/// code spans, closed math blocks, thinking blocks or widget markers, and
/// never re-fires for already-paired delimiters. Positions in the masked
/// string map 1:1 to the original text.
String _maskCompleted(String text) {
  var masked = text;
  masked = _maskAll(masked, RegexPatterns.thinking);
  masked = _maskAll(masked, RegexPatterns.codeBlock);
  masked = _maskAll(masked, RegexPatterns.displayMathBracket);
  masked = _maskAll(masked, _widgetMarker);
  masked = _maskAll(masked, RegexPatterns.combinedInlinePattern);
  return masked;
}

String _maskAll(String text, RegExp pattern) {
  if (!pattern.hasMatch(text)) return text;
  return text.replaceAllMapped(
      pattern, (m) => '\u0000' * (m.end - m.start));
}

// --- Provisional streaming tables -----------------------------------------

/// A line that begins (after optional indentation) with an UNESCAPED pipe —
/// the finalized table grammar's shape for header and body rows. A leading
/// backslash fails this, so `\|` never opens a row.
final RegExp _tableRowOpen = RegExp(r'^[ \t]*\|');

/// A finished separator row, mirroring the finalized separator exactly:
/// leading pipe, then one or more `-`/`:` cells, each ending with a pipe.
/// When such a line exists the table belongs to the finalized parser and
/// the provisional layer must be a byte-identical no-op.
final RegExp _tableSeparatorLine =
    RegExp(r'^[ \t]*\|(?:[ \t]*:?-+:?[ \t]*\|)+[ \t]*$');

/// The frontier line could be a separator row still being typed (`| ---`,
/// `|---|`). Rendering its dashes as data would be wrong, and the shape
/// decides nothing until it is finished — wait for the next token.
final RegExp _tableSeparatorLike = RegExp(r'^[ \t]*\|[ \t:|-]*$');

/// One line of [text]: [content] excludes the `\r?\n` terminator (a single
/// trailing `\r` is stripped as well — the finalized patterns treat it as
/// line noise) and offsets map 1:1 onto the original string.
class _TableLine {
  const _TableLine(this.start, this.content);

  final int start;
  final String content;

  int get end => start + content.length;
}

List<_TableLine> _tableLines(String text) {
  final lines = <_TableLine>[];
  var start = 0;
  for (var i = 0; i < text.length; i++) {
    if (text.codeUnitAt(i) == 0x0A) {
      lines.add(_TableLine(start, _stripCr(text, start, i)));
      start = i + 1;
    }
  }
  lines.add(_TableLine(start, _stripCr(text, start, text.length)));
  return lines;
}

String _stripCr(String text, int start, int end) {
  if (end > start && text.codeUnitAt(end - 1) == 0x0D) end--;
  return text.substring(start, end);
}

/// Length (0, 1 or 2) of the `\r?\n` terminator starting at [at].
int _terminatorLength(String text, int at) {
  if (at >= text.length) return 0;
  if (text.codeUnitAt(at) == 0x0A) return 1;
  if (text.codeUnitAt(at) == 0x0D &&
      at + 1 < text.length &&
      text.codeUnitAt(at + 1) == 0x0A) {
    return 2;
  }
  return 0;
}

/// Offsets of the pipes that are NOT escaped — an escaped `\|` is cell
/// content and never a delimiter.
List<int> _unescapedPipes(String line) {
  final pipes = <int>[];
  var backslashes = 0;
  for (var i = 0; i < line.length; i++) {
    final c = line.codeUnitAt(i);
    if (c == 0x5C) {
      backslashes++;
      continue;
    }
    if (c == 0x7C && backslashes % 2 == 0) pipes.add(i);
    backslashes = 0;
  }
  return pipes;
}

/// Number of cells implied by the unescaped pipe structure, matching how
/// the finalized renderer splits the row: every pipe after the leading one
/// delimits a cell, and a trailing pipe only terminates the last one.
int _columnCount(String line) {
  final pipes = _unescapedPipes(line);
  if (pipes.isEmpty) return 0;
  return _endsWithUnescapedPipe(line) ? pipes.length - 1 : pipes.length;
}

/// True when the line ends with a pipe that is not escaped (trailing
/// spaces/tabs are allowed after it, as the row grammar permits).
bool _endsWithUnescapedPipe(String line) {
  final cut = _withoutTrailingSpace(line);
  if (cut == 0 || line.codeUnitAt(cut - 1) != 0x7C) return false;
  return _backslashRunBefore(line, cut) % 2 == 0;
}

/// True when the line ends in a lone (odd-run) backslash: a pipe appended
/// now would only become an escaped literal `\|`, never a row closer.
bool _endsWithOddBackslash(String line) {
  return _backslashRunBefore(line, _withoutTrailingSpace(line)) % 2 == 1;
}

int _withoutTrailingSpace(String line) {
  var end = line.length;
  while (end > 0 &&
      (line.codeUnitAt(end - 1) == 0x20 || line.codeUnitAt(end - 1) == 0x09)) {
    end--;
  }
  return end;
}

int _backslashRunBefore(String line, int at) {
  var slashes = 0;
  for (var i = at - 1; i >= 0 && line.codeUnitAt(i) == 0x5C; i--) {
    slashes++;
  }
  return slashes;
}

/// [_maskCompleted] plus the bodies of fences that are still OPEN at the
/// end of the text: provisional table detection must never fire inside
/// streamed code content.
String _maskForTables(String text) {
  var masked = _maskCompleted(text);
  var inFence = false;
  String? run;
  var openerStart = -1;
  for (final line in _tableLines(masked)) {
    if (inFence) {
      if (line.content.trim() == run) {
        inFence = false;
        run = null;
      }
      continue;
    }
    final m = _fenceLine.firstMatch(line.content);
    if (m == null) continue;
    inFence = true;
    run = m.group(1);
    openerStart = line.start;
  }
  if (inFence && openerStart >= 0 && openerStart < masked.length) {
    masked = masked.replaceRange(
        openerStart, masked.length, '\u0000' * (masked.length - openerStart));
  }
  return masked;
}

/// Provisional table completion — the table counterpart of the paired
/// delimiter closers above. Two mutually exclusive situations:
///  * a table already has its separator, so only the frontier row may be
///    missing its closing pipe ([_growStreamingTable]);
///  * no separator exists yet, and a chain of pipe-led lines reaching the
///    frontier is given one after its header line ([_startProvisionalTable]).
/// Only the missing structure is ever appended/inserted, and a synthesis is
/// kept only when the finalized [RegexPatterns.table] itself accepts it.
/// Every no-op returns [text] unchanged (same instance).
String _completeStreamingTables(String text) {
  if (!text.contains('|')) return text;
  try {
    final masked = _maskForTables(text);
    final grown = _growStreamingTable(text, masked);
    if (!identical(grown, text)) return grown;
    return _startProvisionalTable(text, masked);
  } catch (_) {
    // Never throws: on any unexpected failure render exactly as before.
    return text;
  }
}

/// A completed table (its separator has arrived) absorbing the row that is
/// still being typed: a single unterminated pipe-led line at the very end
/// of the text gains one closing pipe. Pure append.
String _growStreamingTable(String text, String masked) {
  final matches = RegexPatterns.table.allMatches(masked).toList();
  if (matches.isEmpty) return text;
  final rest = masked.substring(matches.last.end);
  if (rest.isEmpty) return text; // fully complete: byte-identical no-op
  if (rest.contains('\n') || rest.contains('\r')) {
    return text; // the table already ended; later content is not a row
  }
  if (!_tableRowOpen.hasMatch(rest)) return text;
  if (_endsWithUnescapedPipe(rest)) return text;
  if (_endsWithOddBackslash(rest)) return text;
  final grown = '$text|';
  final after = RegexPatterns.table.allMatches(grown).toList();
  if (after.isEmpty || after.last.end != grown.length) return text;
  return grown;
}

/// No separator yet: when the text ends with a contiguous chain of pipe-led
/// lines — the header plus any rows typed so far — insert the separator row
/// right after the header line and close the frontier row, so the unchanged
/// table pipeline renders it immediately. The chain must reach the very end
/// of the text: a blank or prose line anywhere means the model moved on and
/// the whole region stays literal (an unfinished table can never swallow a
/// following paragraph).
String _startProvisionalTable(String text, String masked) {
  final lines = _tableLines(masked);
  var frontierIdx = lines.length - 1;
  // A text that ends in a terminator contributes an empty final segment;
  // that is the frontier's line break, not a line.
  if (lines[frontierIdx].content.isEmpty) {
    frontierIdx--;
    if (frontierIdx < 0) return text;
  }
  var idx = frontierIdx;
  var sawSeparator = false;
  while (idx >= 0) {
    final content = lines[idx].content;
    if (content.isEmpty) break; // blank line: the chain is abandoned
    if (!_tableRowOpen.hasMatch(content)) break; // prose: not a row
    if (_tableSeparatorLine.hasMatch(content)) {
      sawSeparator = true; // finalized territory — never synthesize
      break;
    }
    idx--;
  }
  if (sawSeparator) return text;
  final headerIdx = idx + 1;
  if (headerIdx > frontierIdx) return text; // no chain at the frontier
  final header = lines[headerIdx];
  final frontier = lines[frontierIdx];
  // A single cell is not "clearly a table": `|x|` math prose and a lone
  // `| Foo |` must stay literal until the separator settles the question.
  if (_columnCount(header.content) < 2) return text;
  // Rows the model already finished keep their closing pipes — the
  // provisional layer never rewrites a completed line.
  for (var i = headerIdx; i < frontierIdx; i++) {
    if (!_endsWithUnescapedPipe(lines[i].content)) return text;
  }
  if (_tableSeparatorLike.hasMatch(frontier.content)) return text;
  if (_endsWithOddBackslash(frontier.content)) return text;
  final needsClose = !_endsWithUnescapedPipe(frontier.content);
  if (needsClose && frontier.end != text.length) {
    return text; // the frontier line is already terminated: nothing to add
  }
  if (needsClose) {
    // A sentence being typed ends in punctuation; a cell being typed does
    // not. Keeps line-start math prose like `|x| is the value of x.` from
    // taking the table shape while it is still the frontier.
    final cut = _withoutTrailingSpace(frontier.content);
    final c = cut == 0 ? 0 : frontier.content.codeUnitAt(cut - 1);
    if (c == 0x2E || c == 0x21 || c == 0x3F) return text; // . ! ?
  }
  final separator = '|${'---|' * _columnCount(header.content)}\n';
  final insertAt = header.end + _terminatorLength(text, header.end);
  final headerIsFrontier = headerIdx == frontierIdx;
  final terminator =
      insertAt > header.end ? text.substring(header.end, insertAt) : '\n';
  var out = text.substring(0, header.end) +
      (headerIsFrontier && needsClose ? '|' : '') +
      terminator +
      separator;
  if (!headerIsFrontier) {
    out += text.substring(insertAt);
    if (needsClose) out += '|';
  }
  final matches = RegexPatterns.table.allMatches(out).toList();
  if (matches.isEmpty ||
      matches.last.end != out.length ||
      matches.last.start != header.start) {
    return text;
  }
  return out;
}

/// Fenced code blocks: a small line-level state machine using the finalized
/// fence rules (opener = a line of 3+ backticks plus optional info string;
/// closer = a line of EXACTLY the opener's backtick run). Only a fence that
/// is still open at the end of the text, with at least one body line, is
/// dangling; everything after its opener line is code content.
void _collectFence(String text, String masked, List<_Dangling> out) {
  var inFence = false;
  String? run;
  int openerStart = -1;
  int openerEnd = -1;
  var hasBody = false;
  for (final line in _anyLine.allMatches(masked)) {
    final content = line.group(0)!;
    if (inFence) {
      // Closer line = optional spaces/tabs, the opener's exact backtick run,
      // optional spaces/tabs — which for a single line is simply this:
      if (content.trim() == run) {
        inFence = false;
        run = null;
      }
      continue;
    }
    final m = _fenceLine.firstMatch(content);
    if (m == null) continue;
    inFence = true;
    run = m.group(1);
    openerStart = line.start;
    openerEnd = line.end;
    hasBody = text.length > openerEnd &&
        text.substring(openerEnd).trim().isNotEmpty;
  }
  if (inFence && run != null && hasBody) {
    out.add(_Dangling(
      key: 'fence',
      start: openerStart,
      bodyStart: openerEnd,
      bound: text.length,
      openerLength: run.length,
      closer: '\n$run',
      claimsBody: true,
      // Code content is verbatim: never trim inside a fence body.
      trimBeforeInsert: false,
      full: RegexPatterns.codeBlock,
    ));
  }
}

void _collectInline(
    String text, String masked, _InlineSpec spec, List<_Dangling> out) {
  for (final m in spec.open.allMatches(masked)) {
    final bound = _boundFor(text, m.end, spec.bound);
    if (bound <= m.end) continue; // no room for a body
    final body = text.substring(m.end, bound);
    if (body.trim().isEmpty) continue;
    final hint = spec.closeHint ?? RegExp(RegExp.escape(m.group(0)!));
    if (hint.hasMatch(masked.substring(m.end, bound))) continue;
    if (spec.extraGuard != null && !spec.extraGuard!(body)) continue;
    out.add(_Dangling(
      key: spec.key,
      start: m.start,
      bodyStart: m.end,
      bound: bound,
      openerLength: m.end - m.start,
      closer: spec.closerOf(m.group(0)!),
      claimsBody: spec.claimsBody,
      trimBeforeInsert: true,
      full: spec.full,
    ));
  }
}

int _boundFor(String text, int from, _BoundKind kind) {
  final matches =
      (kind == _BoundKind.line ? _lineEnd : _blankLine).allMatches(text, from);
  return matches.isEmpty ? text.length : matches.first.start;
}

/// Walks candidates left to right; a claiming candidate (math/code/link)
/// makes its whole body off-limits to later ones, mirroring the finalized
/// precedence: the construct that starts first claims the text.
List<_Dangling> _suppressShadowed(List<_Dangling> candidates) {
  final sorted = [...candidates]..sort((a, b) => a.start - b.start);
  final kept = <_Dangling>[];
  final zones = <List<int>>[];
  for (final c in sorted) {
    var shadowed = false;
    for (final z in zones) {
      if (c.start > z[0] && c.start < z[1]) {
        shadowed = true;
        break;
      }
    }
    if (shadowed) continue;
    kept.add(c);
    if (c.claimsBody) zones.add([c.start, c.bound]);
  }
  return kept;
}

/// Rightmost candidate wins (the most recently opened construct closes
/// first, which nests naturally inside enclosing emphasis); ties at the
/// same offset prefer the longer opener (`***` over `**` over `*`).
_Dangling _rightmost(List<_Dangling> kept) {
  var pick = kept.first;
  for (final c in kept) {
    if (c.start > pick.start ||
        (c.start == pick.start && c.openerLength > pick.openerLength)) {
      pick = c;
    }
  }
  return pick;
}

String _insertCloser(String text, _Dangling c) {
  var cut = c.bound;
  if (c.trimBeforeInsert) {
    // Only invisible end-of-line spaces/tabs — needed so closers with a
    // `(?<!\s)` lookbehind can match.
    while (cut > c.bodyStart &&
        (text.codeUnitAt(cut - 1) == 0x20 ||
            text.codeUnitAt(cut - 1) == 0x09)) {
      cut--;
    }
  }
  return text.substring(0, cut) + c.closer + text.substring(c.bound);
}
