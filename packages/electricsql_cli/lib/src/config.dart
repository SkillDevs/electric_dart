import 'package:args/command_runner.dart';
import 'package:electricsql_cli/src/config_options.dart';
import 'package:electricsql_cli/src/env.dart';
import 'package:electricsql_cli/src/util/util.dart';
import 'package:recase/recase.dart';

typedef ConfigMap = Map<String, Object?>;

class ConfigOption<T extends Object> {
  final String? valueTypeName;
  final String doc;
  final List<String>? groups;
  final String? shortForm;
  final T? Function(ConfigMap)? inferVal;
  final T Function(ConfigMap)? defaultValueFun;
  final T? defaultValueStatic;
  final String? constructedDefault;

  T Function()? getDefaultValue(ConfigMap options) {
    if (defaultValueFun != null) {
      return () => defaultValueFun!(options);
    } else if (defaultValueStatic != null) {
      return () => defaultValueStatic!;
    } else {
      return null;
    }
  }

  Type get dartType => T;

  ConfigOption({
    this.valueTypeName,
    required this.doc,
    this.groups,
    this.shortForm,
    this.inferVal,
    T? defaultValue,
    this.defaultValueFun,
    this.constructedDefault,
  }) : defaultValueStatic = defaultValue;
}

T? inferDbUrlPart<T>(
  String part, {
  Map<String, Object?> options = const {},
  T? defaultValue,
}) {
  final url = options['databaseUrl'] as String? ??
      options['DATABASE_URL'] as String? ??
      programEnv['ELECTRIC_DATABASE_URL'];

  if (notBlank(url)) {
    final parsed = extractDatabaseURL(url!);
    return parsed[part] as T? ?? defaultValue;
  }
  return defaultValue;
}

T? inferProxyUrlPart<T>(
  String part, {
  Map<String, Object?> options = const {},
  T? defaultValue,
}) {
  final url = options['proxy'] as String? ??
      options['PROXY'] as String? ??
      programEnv['ELECTRIC_PROXY'];

  if (notBlank(url)) {
    final parsed = extractDatabaseURL(url!);
    return parsed[part] as T? ?? defaultValue;
  }
  return defaultValue;
}

T? inferServiceUrlPart<T>(
  String part, {
  Map<String, Object?> options = const {},
  T? defaultValue,
}) {
  final url = options['service'] as String? ??
      options['SERVICE'] as String? ??
      programEnv['ELECTRIC_SERVICE'];

  if (notBlank(url)) {
    final parsed = extractServiceURL(url!);
    return parsed[part] as T? ?? defaultValue;
  }
  return defaultValue;
}

T getConfigValue<T>(
  String name, [
  Map<String, Object?>? options,
]) {
  return getOptionalConfigValue<T>(name, options: options) as T;
}

T? getOptionalConfigValue<T>(
  String name, {
  Map<String, Object?>? options,
  bool checkType = true,
}) {
  if (checkType) {
    expectValidConfigName<T>(name);
  }

  // First check if the option was passed as a command line argument
  if (options != null) {
    final strippedName = name.startsWith('ELECTRIC_')
        ? name.substring('ELECTRIC_'.length)
        : name;
    final optName = strippedName.toLowerCase().camelCase;

    if (options[optName] != null) {
      return options[optName]! as T;
    } else if (options[name] != null) {
      return options[name]! as T;
    }
  }

  // Then check if the option has an method to infer a value from other options.
  // If we get a value from this method, use it.
  final inferVal = configOptions[name]!.inferVal;
  if (inferVal != null) {
    final val = inferVal(options ?? {});
    if (val != null) {
      return val as T;
    }
  }

  // Then check if the option was passed as an environment variable
  final envName = name.startsWith('ELECTRIC_') ? name : 'ELECTRIC_$name';
  final envVal = programEnv[envName];
  if (configOptions[name]! is ConfigOption<bool>) {
    final bool b = notBlank(envVal) &&
        !['f', 'false', '0', '', 'no'].contains(envVal!.toLowerCase());
    return b as T;
  }

  if (envVal != null) {
    if (configOptions[name]! is ConfigOption<int>) {
      return int.parse(envVal) as T;
    } else {
      return envVal as T;
    }
  }

  // Finally, check if the option has a default value
  final defaultValGetter =
      (configOptions[name]!).getDefaultValue(options ?? {});
  if (defaultValGetter != null) {
    return defaultValGetter() as T;
  } else {
    return null;
  }
}

/// Get the current configuration for Electric from environment variables and
/// any passed options.
/// @param options Object containing options to override the environment variables
/// @returns The current configuration
Config getConfig([Map<String, Object?>? options]) {
  final Map<String, Object?> _resolvedValues = Map.fromEntries(
    configOptions.entries.map(
      (optEntry) => MapEntry(
        optEntry.key,
        getOptionalConfigValue<dynamic>(
          optEntry.key,
          options: options ?? {},
          // We cannot check the type here because of dynamic
          checkType: false,
        ),
      ),
    ),
  );
  //print(_resolvedValues);

  return Config(_resolvedValues);
}

Map<String, String> envFromConfig(Config config) {
  return Map.fromEntries(
    config.entries.map(
      (entry) {
        final name = entry.key;
        return MapEntry(
          name.startsWith('ELECTRIC_') ? name : 'ELECTRIC_$name',
          config.read<Object?>(entry.key).toString(),
        );
      },
    ),
  );
}

void expectValidConfigName<T>(String name) {
  if (!configOptions.containsKey(name)) {
    throw ArgumentError('Invalid config name: $name');
  }
  final config = configOptions[name]!;

  // If it doesn't have a default value, there is nothing more to check
  if (config.getDefaultValue({}) == null) return;

  if (config.dartType != T) {
    throw ArgumentError('Invalid config name type: $name is not of type $T');
  }
}

void addOptionToCommand(Command<dynamic> command, String optionName) {
  String argName = optionName.toLowerCase().replaceAll('_', '-');
  if (argName.startsWith('electric-')) {
    argName = argName.substring('electric-'.length);
  }
  String localName = optionName;
  if (!optionName.startsWith('ELECTRIC_')) {
    localName = 'ELECTRIC_$optionName';
  }
  final opt = configOptions[optionName]!;

  String? valueHelp;

  if (opt.dartType != bool) {
    if (opt.valueTypeName != null) {
      valueHelp = opt.valueTypeName;
    } else if (opt.dartType == int) {
      valueHelp = 'number';
    } else if (opt.dartType == String) {
      valueHelp = 'string';
    } else {
      throw ArgumentError('Unknown option type: ${opt.dartType}');
    }
  }

  String doc = '${opt.doc}\nEnv var: $localName';
  if (opt.constructedDefault != null) {
    doc += '\nDefault: ${opt.constructedDefault}';
  } else if (opt.defaultValueStatic != null) {
    doc += '\nDefault: ${opt.defaultValueStatic}';
  }

  final List<String> aliases = opt.shortForm == null ? [] : [opt.shortForm!];

  if (opt.dartType == bool) {
    command.argParser.addFlag(
      argName,
      help: doc,
      aliases: aliases,
      negatable: false,
    );
  } else {
    command.argParser.addOption(
      argName,
      help: doc,
      valueHelp: valueHelp,
      aliases: aliases,
    );
  }
}

void addOptionGroupToCommand(Command<dynamic> command, String groupName) {
  command.argParser.addSeparator(
    "'$groupName' group options:",
  );
  for (final optEntry in configOptions.entries) {
    final optName = optEntry.key;
    final opt = optEntry.value;

    final groups = opt.groups ?? [];
    if (groups.contains(groupName)) {
      addOptionToCommand(command, optName);
    }
  }
}

void addSpecificOptionsSeparator(Command<dynamic> command) {
  command.argParser.addSeparator("'${command.name}' specific options:");
}

class Config {
  Config(this._map);

  final Map<String, Object?> _map;
  Map<String, Object?> get map => _map;

  Iterable<MapEntry<String, Object?>> get entries => _map.entries;

  T read<T>(String key) {
    if (!_map.containsKey(key)) {
      throw ArgumentError('Config name not loaded: $key');
    }
    final val = _map[key] as T;
    return val;
  }
}
