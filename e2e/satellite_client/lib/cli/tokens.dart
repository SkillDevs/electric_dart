import 'dart:convert';
import 'dart:io';

import 'package:electricsql/electricsql.dart';
import 'package:satellite_dart_client/cli/state.dart';

Future<List<Token>> extractTokens(AppState state, String text) async {
  final parts = extractTokenParts(text);

  final out = <Token>[];
  for (final e in parts) {
    if (e == "null") {
      out.add(Token(text: e, dartValue: null));
    } else if (e == "client.JsonNull") {
      out.add(Token(text: e, dartValue: kJsonNull));
    } else if (e == "true") {
      out.add(Token(text: e, dartValue: true));
    } else if (e == "false") {
      out.add(Token(text: e, dartValue: false));
    } else if (state.variables.containsKey(e)) {
      out.add(Token(text: e, dartValue: state.variables[e]));
    } else if (e.startsWith('"') && e.endsWith('"')) {
      final text = e.substring(1, e.length - 1);
      out.add(Token(text: e, dartValue: text));
    } else if (e.startsWith("'") && e.endsWith("'")) {
      final text = e.substring(1, e.length - 1);
      out.add(Token(text: e, dartValue: text));
    } else if (e.startsWith("[") && e.endsWith("]")) {
      final j = await stringifyJavascriptObj(e);
      out.add(Token(text: text, dartValue: json.decode(j) as List<dynamic>));
    } else if (e.startsWith("{") && e.endsWith("}")) {
      final j = await stringifyJavascriptObj(e);
      out.add(
          Token(text: text, dartValue: json.decode(j) as Map<String, dynamic>));
    } else {
      // Number
      final argNum = num.tryParse(e);
      if (argNum == null) {
        out.add(Token(text: e, dartValue: ArgIdentifier(e), isVariable: true));
      } else {
        out.add(Token(text: e, dartValue: argNum));
      }
    }
  }

  return out;
}

List<String> extractTokenParts(String text) {
  final stack = <String>[];
  final buffer = StringBuffer();

  final tokens = <String>[];

  String? waitingStringCloseChar;

  for (var i = 0; i < text.length; ++i) {
    final ch = text[i];

    if (ch == " ") {
      if (buffer.isNotEmpty &&
          stack.isEmpty &&
          waitingStringCloseChar == null) {
        tokens.add(buffer.toString());
        buffer.clear();
        continue;
      }
    }

    if (ch == "'" || ch == '"') {
      if (ch == waitingStringCloseChar) {
        waitingStringCloseChar = null;
      } else {
        waitingStringCloseChar ??= ch;
      }
    } else if (waitingStringCloseChar == null) {
      if (_leftBrackets.contains(ch)) {
        stack.add(ch);
      } else if (_rightToLeftBracketMap.containsKey(ch)) {
        // not check matching pairs currently, since user can
        // input a wrong grammar
        if (stack.isNotEmpty) stack.removeLast();
      }
    }

    buffer.write(ch);
  }

  if (buffer.isNotEmpty) {
    tokens.add(buffer.toString());
    buffer.clear();
  }

  return tokens;
}

const _leftBrackets = ['{', '[', '('];
const _rightToLeftBracketMap = {'}': '{', ']': '[', ')': '('};

class Token {
  final String text;
  final Object? dartValue;
  final bool isVariable;

  Token({
    required this.text,
    required this.dartValue,
    this.isVariable = false,
  });

  @override
  String toString() {
    return "Token(text:$text, value:$dartValue, type:${dartValue.runtimeType})";
  }
}

Future<String> stringifyJavascriptObj(String objStr) async {
  final command = "console.log(JSON.stringify($objStr))";
  final res = await Process.run('node', ['-e', command]);
  if (res.exitCode != 0) {
    throw Exception(
        "Failed to stringify javascript object: $objStr. Command: '$command'");
  }
  final out = res.stdout.toString();
  return out;
}

class ArgIdentifier {
  final String name;

  ArgIdentifier(this.name);

  @override
  String toString() {
    return 'ArgIdentifier{name: $name}';
  }
}
