import 'package:args/args.dart';
import 'package:args/command_runner.dart';

Map<String, Object?> getOptsFromCommand(Command<dynamic> command) {
  final ArgResults argResults = command.argResults!;
  return Map<String, Object?>.fromEntries(
    argResults.options.map((opt) => MapEntry(opt, argResults[opt])),
  );
}
