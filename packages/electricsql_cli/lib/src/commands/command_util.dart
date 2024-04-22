import 'package:args/args.dart';
import 'package:args/command_runner.dart';
import 'package:recase/recase.dart';

Map<String, Object?> getOptsFromCommand(Command<dynamic> command) {
  final ArgResults argResults = command.argResults!;

  final Map<String, Object?> out = {};

  for (final opt in argResults.options) {
    final value = argResults[opt];

    out[opt] = argResults[opt];

    // Options come as paramCase from the CLI, but we want to support
    // both internally, to mimick better how the CLI works in the official client
    final camelCaseOpt = opt.camelCase;
    if (camelCaseOpt != opt) {
      out[camelCaseOpt] = value;
    }
  }

  return out;
}
