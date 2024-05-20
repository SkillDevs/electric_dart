import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syntax_highlight/syntax_highlight.dart';

final highlighterProvider = FutureProvider<Highlighter>((ref) async {
  await Highlighter.initialize(['sql']);

  final theme = await HighlighterTheme.loadDarkTheme();
  final highlighter = Highlighter(
    language: 'sql',
    theme: theme,
  );
  return highlighter;
});
