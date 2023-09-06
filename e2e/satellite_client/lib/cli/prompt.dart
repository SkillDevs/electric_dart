import 'dart:async';
import 'dart:io';

import 'package:electricsql/electricsql.dart';
import 'package:satellite_dart_client/cli/commands.dart';
import 'package:satellite_dart_client/generic_db.dart';
import 'package:satellite_dart_client/state.dart';

Future<void> start() async {
  final state = AppState();

  while (true) {
    try {
      final command = _prompt(state);

      //print("command: $command");

      if (command == null) break;

      final name = command.name;

      if (name == "exit") {
        break;
      } else if (name == "get_shell_db_path") {
        final luxShellName = command.arguments[0] as String;

        final dbPath =
            "${Platform.environment["SATELLITE_DB_PATH"]!}/$luxShellName";
        await processCommand<String>(state, command, () {
          return dbPath;
        });
      } else if (name == "make_db") {
        final dbPath = command.arguments[0] as String;
        await processCommand<GenericDb>(state, command, () async {
          return await makeDb(dbPath);
        });
      } else if (name == "assignVar") {
        await processCommand<dynamic>(state, command, () async {
          final value = command.arguments[0];
          return value;
        });
      } else if (name == "electrify_db") {
        await processCommand<ElectricClient>(state, command, () async {
          final db = command.arguments[0] as GenericDb;
          final dbName = command.arguments[1] as String;
          final host = command.arguments[2] as String;
          final port = command.arguments[3] as int;
          final migrationsJ = command.arguments[4] as String;

          return await electrifyDb(
            db,
            dbName,
            host,
            port,
            migrationsJ,
          );
        });
      } else {
        throw Exception("Unknown command: $name");
      }
    } catch (e, st) {
      print("ERROR: $e\n$st");

      exit(1);
    }
  }
}

Future<void> processCommand<T>(
  AppState state,
  Command command,
  FutureOr<T> Function() handler,
) async {
  final res = await handler();

  if (command.variable != null) {
    state.variables[command.variable!] = res;
  }
}

Command? _prompt(AppState appState) {
  stdout.write('> ');

  //String? input = readInputSync();
  //String? input = stdin.readLineSync();
  String? input = myReadLine();

  if (input == null) return null;

  input = input.trim();

  if (input.isEmpty) return null;

  String? variable;
  final byEquals = input.split('=');
  if (byEquals.length > 1) {
    variable = byEquals[0].trim();
    if (variable.isEmpty) {
      throw Exception("Invalid variable name");
    }
    input = byEquals[1].trim();
  }

  final parts = input.split(' ');

  // final name = parts[0];
  // final argumentsRaw = parts.length < 2 ? <String>[] : parts.sublist(1);

  final joinedArgs = joinArguments(parts);

  // print("ARGS:");
  // for (final arg in joinedArgs) {
  //   final cleaned = arg.replaceAll('\n', '\\n');
  //   print("  <<$cleaned>>");
  // }

  // Process arguments and variables
  final List<Object?> arguments = joinedArgs.map((argRaw) {
    if (argRaw == "null") {
      return null;
    }

    //print("argRaw: '$argRaw'");
    if (appState.variables.containsKey(argRaw)) {
      // Resolve argument
      return appState.variables[argRaw];
    } else {
      if (argRaw.startsWith("'''") &&
          argRaw.endsWith("'''") &&
          argRaw.length >= 6) {
        // String multiline
        return argRaw.substring(3, argRaw.length - 3);
      } else if (argRaw.startsWith('"') &&
          argRaw.endsWith('"') &&
          argRaw.length >= 2) {
        // String
        return argRaw.substring(1, argRaw.length - 1);
      } else {
        // Number
        final argNum = num.tryParse(argRaw);
        if (argNum == null) {
          return ArgIdentifier(argRaw);
        }
        return argNum;
      }
    }
  }).toList();

  final String name;
  final List<Object?> effectiveArgs;
  if (arguments.length == 1 && variable != null) {
    name = "assignVar";
    effectiveArgs = arguments;
  } else if (arguments.isEmpty) {
    throw Exception("Empty command");
  } else {
    name = (arguments.removeAt(0) as ArgIdentifier).name;
    effectiveArgs = arguments;
  }

  for (final arg in effectiveArgs) {
    if (arg is ArgIdentifier) {
      throw Exception("Variable unknown: ${arg.name}");
    }
  }

  return Command(
    name,
    effectiveArgs,
    variable: variable,
  );
}

class Command {
  final String name;
  final List<Object?> arguments;
  final String? variable;

  Command(this.name, this.arguments, {this.variable});

  @override
  String toString() {
    return 'Command{name: $name, arguments: $arguments, variable: $variable}';
  }
}

String? myReadLine() {
  StringBuffer? buf;
  int numMultiLineBlocks = 0;

  while (true) {
    String? input = stdin.readLineSync();

    //print("read line: <<$input>>");

    if (input == null) {
      return buf?.toString();
    }

    buf ??= StringBuffer();

    buf.write(input);

    final numMultiLine = "'''".allMatches(input).length;
    // print("num matches: $numMultiLine");
    numMultiLineBlocks += numMultiLine;

    if (numMultiLineBlocks % 2 == 1) {
      buf.write('\n');
      continue;
    }

    break;
  }

  //print("DONE: <${cleanInput(buf.toString())}>)}");

  return buf.toString();
}

String cleanInput(String input) {
  final cleaned = input.replaceAll('\n', '\\n');
  return cleaned;
}

List<String> joinArguments(List<String> argsRaw) {
  final List<String> args = [];

  while (argsRaw.isNotEmpty) {
    var argRaw = argsRaw.removeAt(0);
    argRaw = argRaw.trimLeft();

    if (argRaw.startsWith("'''")) {
      final multiLine = readUntilEndMultiLine(argRaw, argsRaw);
      args.add(multiLine);
      continue;
    } else if (argRaw.startsWith('"')) {
      final str = readUntilEndQuotes(argRaw, argsRaw);
      args.add(str);
      continue;
    } else {
      argRaw = argRaw.trim();
      if (argRaw.isEmpty) continue;

      args.add(argRaw);
    }
  }

  return args;
}

String readUntilEndMultiLine(String start, List<String> argsRaw) {
  final buf = StringBuffer(start);
  if (start.startsWith("'''") && start.endsWith("'''") && start.length >= 6) {
    return start;
  }

  bool foundEnd = false;
  while (argsRaw.isNotEmpty) {
    final argRaw = argsRaw.removeAt(0);

    if (argRaw.endsWith("'''")) {
      buf.write(argRaw);
      foundEnd = true;
      break;
    }

    buf.write(argRaw);
    buf.write(' ');
  }

  if (!foundEnd) {
    throw Exception("Missing end of multiline string");
  }

  return buf.toString();
}

String readUntilEndQuotes(String start, List<String> argsRaw) {
  if (start.startsWith('"') && start.endsWith('"') && start.length >= 2) {
    return start;
  }

  final buf = StringBuffer(start);
  bool foundEnd = false;
  while (argsRaw.isNotEmpty) {
    final argRaw = argsRaw.removeAt(0);

    if (argRaw.endsWith('"')) {
      buf.write(argRaw);
      foundEnd = true;
      break;
    }

    buf.write(argRaw);
    buf.write(' ');
  }

  if (!foundEnd) {
    throw Exception("Missing end of quotes");
  }

  return buf.toString();
}

class ArgIdentifier {
  final String name;

  ArgIdentifier(this.name);

  @override
  String toString() {
    return 'ArgIdentifier{name: $name}';
  }
}
