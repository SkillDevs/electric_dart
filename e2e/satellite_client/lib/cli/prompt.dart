import 'dart:async';
import 'dart:io';

import 'package:electricsql/drivers/drift.dart';
import 'package:electricsql/satellite.dart';
import 'package:satellite_dart_client/client_commands.dart';
import 'package:satellite_dart_client/cli/reader.dart';
import 'package:satellite_dart_client/cli/tokens.dart';
import 'package:satellite_dart_client/drift/database.dart';
import 'package:satellite_dart_client/cli/state.dart';

const promptChar = "> ";

Future<void> start() async {
  final state = AppState();

  await runReplAsync((input) async {
    try {
      final command = await parseCommand(input, state);

      if (command == null) {
        return NextAction.stop;
      }

      //print(command);

      final name = command.name;

      if (name == "exit") {
        return NextAction.stop;
      } else if (name == "echo") {
        final Object? variable = command.arguments[0];
        await processCommand<String>(state, command, () async {
          return "var=$variable  type=${variable.runtimeType}";
        });
      } else if (name == "get_shell_db_path") {
        await processCommand1Param<String, String>(
          state,
          command,
          (luxShellName) {
            final dbPath =
                "${Platform.environment["SATELLITE_DB_PATH"]!}/$luxShellName";
            return dbPath;
          },
        );
      } else if (name == "make_db") {
        await processCommand1Param<String, ClientDatabase>(
          state,
          command,
          makeDb,
        );
      } else if (name == "assignVar") {
        await processCommand1Param<Object?, dynamic>(
          state,
          command,
          (value) => value,
        );
      } else if (name == "showVar") {
        await processCommand1Param<Object?, dynamic>(
          state,
          command,
          (value) => value,
        );
      } else if (name == "electrify_db") {
        await processCommand5Params<ClientDatabase, String, int, List<dynamic>,
            bool, MyDriftElectricClient>(
          state,
          command,
          electrifyDb,
        );
      } else if (name == "sync_table") {
        await processCommand2Params<MyDriftElectricClient, String, void>(
          state,
          command,
          syncTable,
        );
      } else if (name == "low_level_subscribe") {
        await processCommand2Params<MyDriftElectricClient, Map<String, Object?>,
            void>(
          state,
          command,
          (electric, shapeJson) =>
              lowLevelSubscribe(electric, Shape.fromMap(shapeJson)),
        );
      } else if (name == "get_tables") {
        await processCommand1Param<DriftElectricClient, Rows>(
          state,
          command,
          getTables,
        );
      } else if (name == "get_columns") {
        await processCommand2Params<DriftElectricClient, String, Rows>(
          state,
          command,
          getColumns,
        );
      } else if (name == "get_rows") {
        await processCommand2Params<DriftElectricClient, String, Rows>(
          state,
          command,
          getRows,
        );
      } else if (name == "print_num_rows") {
        await processCommand2Params<DriftElectricClient, String, String>(
          state,
          command,
          (electric, table) async {
            final rows = await getRows(electric, table);
            return 'There are ${rows.rows.length} rows in table $table';
          },
        );
      } else if (name == "get_timestamps") {
        await processCommand1Param<MyDriftElectricClient, void>(
          state,
          command,
          getTimestamps,
        );
      } else if (name == "assert_timestamp") {
        await processCommand4Params<MyDriftElectricClient, String, String,
            String, bool>(
          state,
          command,
          assertTimestamp,
        );
      } else if (name == "write_timestamp") {
        await processCommand2Params<MyDriftElectricClient, Map<String, Object?>,
            void>(
          state,
          command,
          writeTimestamp,
        );
      } else if (name == "write_datetime") {
        await processCommand2Params<MyDriftElectricClient, Map<String, Object?>,
            void>(
          state,
          command,
          writeDatetime,
        );
      } else if (name == "assert_datetime") {
        await processCommand4Params<MyDriftElectricClient, String, String,
            String, bool>(
          state,
          command,
          assertDatetime,
        );
      } else if (name == "write_bool") {
        await processCommand3Params<MyDriftElectricClient, String, bool,
            SingleRow>(
          state,
          command,
          writeBool,
        );
      } else if (name == "get_bool") {
        await processCommand2Params<MyDriftElectricClient, String, bool?>(
          state,
          command,
          getBool,
        );
      } else if (name == "write_uuid") {
        await processCommand2Params<MyDriftElectricClient, String, SingleRow>(
          state,
          command,
          writeUUID,
        );
      } else if (name == "get_uuid") {
        await processCommand2Params<MyDriftElectricClient, String, SingleRow>(
          state,
          command,
          getUUID,
        );
      } else if (name == "write_int") {
        await processCommand5Params<MyDriftElectricClient, String, int, int,
            Object, SingleRow>(state, command, (electric, id, i2, i4, i8Raw) {
          final BigInt i8;
          if (i8Raw is int) {
            i8 = BigInt.from(i8Raw);
          } else if (i8Raw is String) {
            i8 = BigInt.parse(i8Raw.replaceAll('n', ''));
          } else {
            throw Exception("Invalid i8 value: $i8Raw");
          }

          return writeInt(electric, id, i2, i4, i8);
        });
      } else if (name == "get_int") {
        await processCommand2Params<MyDriftElectricClient, String, SingleRow>(
          state,
          command,
          getInt,
        );
      } else if (name == "write_float") {
        await processCommand4Params<MyDriftElectricClient, String, num, num,
            SingleRow>(
          state,
          command,
          (electric, id, f4, f8) =>
              writeFloat(electric, id, f4.toDouble(), f8.toDouble()),
        );
      } else if (name == "get_float") {
        await processCommand2Params<MyDriftElectricClient, String, SingleRow>(
          state,
          command,
          getFloat,
        );
      } else if (name == "get_jsonb") {
        await processCommand2Params<MyDriftElectricClient, String, SingleRow>(
          state,
          command,
          getJsonb,
        );
      } else if (name == "get_json") {
        await processCommand2Params<MyDriftElectricClient, String, SingleRow>(
          state,
          command,
          getJson,
        );
      } else if (name == "get_json_raw") {
        await processCommand2Params<MyDriftElectricClient, String, String?>(
          state,
          command,
          getJsonRaw,
        );
      } else if (name == "get_jsonb_raw") {
        await processCommand2Params<MyDriftElectricClient, String, String?>(
          state,
          command,
          getJsonbRaw,
        );
      } else if (name == "write_json") {
        await processCommand4Params<MyDriftElectricClient, String, Object?,
            Object?, SingleRow>(
          state,
          command,
          writeJson,
        );
      } else if (name == "write_enum") {
        await processCommand3Params<MyDriftElectricClient, String, String?,
            SingleRow>(state, command, (electric, id, enumStr) {
          //final enumValue = enumStr == null ? null : enumFromString(enumStr);
          return writeEnum(electric, id, enumStr);
        });
      } else if (name == "get_enum") {
        await processCommand2Params<MyDriftElectricClient, String, SingleRow>(
          state,
          command,
          getEnum,
        );
      } else if (name == "get_items") {
        await processCommand1Param<MyDriftElectricClient, Rows>(
          state,
          command,
          getItems,
        );
      } else if (name == "get_item_ids") {
        await processCommand1Param<MyDriftElectricClient, Rows>(
          state,
          command,
          getItemIds,
        );
      } else if (name == "exists_item_with_content") {
        await processCommand2Params<MyDriftElectricClient, String, bool>(
          state,
          command,
          existsItemWithContent,
        );
      } else if (name == "get_item_columns") {
        await processCommand3Params<MyDriftElectricClient, String, String,
            Rows>(
          state,
          command,
          getItemColumns,
        );
      } else if (name == "insert_item") {
        await processCommand2Params<MyDriftElectricClient, List<dynamic>, void>(
          state,
          command,
          (electric, keys) => insertItem(electric, keys.cast<String>()),
        );
      } else if (name == "insert_extended_into") {
        await processCommand3Params<MyDriftElectricClient, String,
            Map<String, Object?>, void>(
          state,
          command,
          insertExtendedInto,
        );
      } else if (name == "insert_extended_item") {
        await processCommand2Params<MyDriftElectricClient, Map<String, Object?>,
            void>(
          state,
          command,
          insertExtendedItem,
        );
      } else if (name == "delete_item") {
        await processCommand2Params<MyDriftElectricClient, List<dynamic>, void>(
          state,
          command,
          (electric, keys) => deleteItem(electric, keys.cast<String>()),
        );
      } else if (name == "get_other_items") {
        await processCommand1Param<MyDriftElectricClient, Rows>(
          state,
          command,
          getOtherItems,
        );
      } else if (name == "insert_other_item") {
        await processCommand2Params<MyDriftElectricClient, List<dynamic>, void>(
          state,
          command,
          (electric, keys) => insertOtherItem(electric, keys.cast<String>()),
        );
      } else if (name == "stop") {
        await processCommand1Param<MyDriftElectricClient, void>(
          state,
          command,
          stop,
        );
      } else if (name == "raw_statement") {
        await processCommand2Params<MyDriftElectricClient, String, void>(
          state,
          command,
          rawStatement,
        );
      } else if (name == "connect") {
        await processCommand1Param<MyDriftElectricClient, void>(
          state,
          command,
          connect,
        );
      } else if (name == "disconnect") {
        await processCommand1Param<MyDriftElectricClient, void>(
          state,
          command,
          disconnect,
        );
      } else {
        throw Exception("Unknown command: $name");
      }

      return NextAction.goOn;
    } catch (e, st) {
      print("Uncaught error: $e\n$st");

      return NextAction.goOn;
    }
  });
}

Future<void> processCommand1Param<P1, R>(
  AppState state,
  Command command,
  FutureOr<R> Function(P1) handler,
) async {
  final p1 = command.arguments[0] as P1;

  await processCommand<R>(state, command, () async {
    return await handler(p1);
  });
}

Future<void> processCommand2Params<P1, P2, R>(
  AppState state,
  Command command,
  FutureOr<R> Function(P1, P2) handler,
) async {
  final p1 = command.arguments[0] as P1;
  final p2 = command.arguments[1] as P2;

  await processCommand<R>(state, command, () async {
    return await handler(p1, p2);
  });
}

Future<void> processCommand3Params<P1, P2, P3, R>(
  AppState state,
  Command command,
  FutureOr<R> Function(P1, P2, P3) handler,
) async {
  final p1 = command.arguments[0] as P1;
  final p2 = command.arguments[1] as P2;
  final p3 = command.arguments[2] as P3;

  await processCommand<R>(state, command, () async {
    return await handler(p1, p2, p3);
  });
}

Future<void> processCommand4Params<P1, P2, P3, P4, R>(
  AppState state,
  Command command,
  FutureOr<R> Function(P1, P2, P3, P4) handler,
) async {
  final p1 = command.arguments[0] as P1;
  final p2 = command.arguments[1] as P2;
  final p3 = command.arguments[2] as P3;
  final p4 = command.arguments[3] as P4;

  await processCommand<R>(state, command, () async {
    return await handler(p1, p2, p3, p4);
  });
}

Future<void> processCommand5Params<P1, P2, P3, P4, P5, R>(
  AppState state,
  Command command,
  FutureOr<R> Function(P1, P2, P3, P4, P5) handler,
) async {
  final p1 = command.arguments[0] as P1;
  final p2 = command.arguments[1] as P2;
  final p3 = command.arguments[2] as P3;
  final p4 = command.arguments[3] as P4;
  final p5 = command.arguments[4] as P5;

  await processCommand<R>(state, command, () async {
    return await handler(p1, p2, p3, p4, p5);
  });
}

Future<void> processCommand<T>(
  AppState state,
  Command command,
  FutureOr<T> Function() handler,
) async {
  final res = await handler();

  // Assign variable if needed
  if (command.variable != null) {
    state.variables[command.variable!] = res;
  }

  // Log output of the command
  print(res);
}

Future<Command?> parseCommand(String input, AppState appState) async {
  input = input.trim();

  if (input.isEmpty) return null;

  var tokens = await extractTokens(appState, input);

  String? variable;
  if (tokens.length >= 3) {
    if (tokens[1].text == "=") {
      variable = tokens[0].text;
      tokens = tokens.sublist(2);
    }
  }

  final String name;
  final List<Token> effectiveArgs;
  if (tokens.length == 1 && variable != null) {
    name = "assignVar";
    effectiveArgs = tokens;
  } else if (tokens.length == 1 && tokens.first.dartValue is! ArgIdentifier) {
    name = "showVar";
    effectiveArgs = [tokens.first];
  } else if (tokens.isEmpty) {
    throw Exception("Empty command");
  } else {
    name = (tokens.removeAt(0).dartValue as ArgIdentifier).name;
    effectiveArgs = tokens;
  }

  for (final arg in effectiveArgs) {
    if (arg.isVariable) {
      throw Exception("Variable unknown: ${arg.text}");
    }
  }

  final dartValues = effectiveArgs.map((e) => e.dartValue).toList();

  return Command(
    name,
    dartValues,
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

enum NextAction { goOn, stop }

// We cannot use cli_repl runAsync because it doesn't correctly handle async
// executions on the callback
// https://github.com/jathak/cli_repl/issues/3#issuecomment-526851764
Future<void> runReplAsync(FutureOr<NextAction> Function(String) onLine) async {
  stdin.echoMode = false;
  stdin.lineMode = false;

  var stream = stdin.expand((b) => b);
  stdout.write(promptChar);
  final buf = StringBuffer();
  await for (int i in stream) {
    final c = String.fromCharCode(i);
    stdout.write(c);
    if (c == '\n') {
      final current = buf.toString();
      if (replValidator(current)) {
        final action = await onLine(current);
        buf.clear();
        if (action == NextAction.stop) break;
        stdout.write(promptChar);
        continue;
      }
    }

    // Continue buffering
    buf.write(c);
  }
}
