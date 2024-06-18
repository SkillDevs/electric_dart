import 'dart:convert';

import 'package:code_text_field/code_text_field.dart';
// ignore: invalid_use_of_internal_member, implementation_imports
import 'package:electricsql/src/devtools/shared.dart';
import 'package:electricsql_devtools_extension/hooks.dart';
import 'package:electricsql_devtools_extension/remote.dart';
import 'package:electricsql_devtools_extension/tabs.dart';
import 'package:electricsql_devtools_extension/theme.dart';
import 'package:electricsql_devtools_extension/widgets/db_rows_table.dart';
import 'package:electricsql_devtools_extension/widgets/scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:highlight/languages/json.dart' as json_highlight;
import 'package:highlight/languages/sql.dart' as sql_highlight;
import 'package:hooks_riverpod/hooks_riverpod.dart';

// ignore: prefer_interpolation_to_compose_strings
const kDefaultSqliteStmt = 'SELECT name FROM sqlite_schema\n' +
    "WHERE type='table'\n" +
    'ORDER BY name;';

const kDefaultPgStmt = 'SELECT table_name FROM information_schema.tables\n' +
    "WHERE table_schema = 'public';";

final _queryCodeControllerProvider =
    ProviderFamily<CodeController, DevToolsDbProps>((ref, dbProps) {
  final String source = switch (dbProps.dialect) {
    SqlDialect.sqlite => kDefaultSqliteStmt,
    SqlDialect.postgres => kDefaultPgStmt,
  };

  final c = CodeController(
    text: source,
    language: sql_highlight.sql,
  );
  ref.onDispose(() => c.dispose());

  return c;
});

final _queryResultProvider =
    StateProviderFamily<AsyncValue<RemoteQueryRes>?, DevToolsDbProps>(
        (ref, props) {
  return null;
});

final _queryHistoryProvider =
    StateProviderFamily<String, DevToolsDbProps>((ref, props) {
  return '';
});

final _resultsSideTabIndexProvider =
    StateProviderFamily<int, DevToolsDbProps>((ref, props) {
  return 0;
});

class ShellTab extends HookWidget {
  const ShellTab({super.key, required this.props});

  final DevToolsDbProps props;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Flexible(
          flex: 40,
          child: _QuerySide(props: props),
        ),
        const SizedBox(width: 10),
        Flexible(
          flex: 60,
          child: _ResultsSide(props: props),
        ),
      ],
    );
  }
}

class _QuerySide extends StatelessWidget {
  final DevToolsDbProps props;

  const _QuerySide({required this.props});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          return Column(
            children: <Widget>[
              const TabBar(
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: [
                  Tab(text: 'Query'),
                  Tab(text: 'History'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    _QueryTab(props: props),
                    _HistoryTab(props: props),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QueryTab extends ConsumerWidget {
  const _QueryTab({required this.props});

  final DevToolsDbProps props;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _codeController = ref.watch(
      _queryCodeControllerProvider(props),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () async {
            final sql = _codeController.text;
            final queryResNotifier =
                ref.read(_queryResultProvider(props).notifier);

            ref
                .read(_queryHistoryProvider(props).notifier)
                .update((prev) => prev.isEmpty ? sql : '$prev\n\n$sql');

            queryResNotifier.state = const AsyncLoading();
            final res = await kRemoteToolbar.queryDb(props.dbName, sql, []);
            queryResNotifier.state = AsyncData(res);
          },
          icon: const Icon(Icons.play_arrow),
          label: const Text('Submit'),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
            ),
            child: CodeSection(_codeController),
          ),
        ),
      ],
    );
  }
}

class _HistoryTab extends HookConsumerWidget {
  final DevToolsDbProps props;

  const _HistoryTab({required this.props});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final codeController = useCodeController(language: sql_highlight.sql);

    final history = ref.watch(_queryHistoryProvider(props));

    useEffect(
      () {
        codeController.text = history;
        return null;
      },
      [history],
    );

    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        FilledButton.icon(
          onPressed: () async {
            ref.read(_queryHistoryProvider(props).notifier).state = '';
          },
          style: FilledButton.styleFrom(
            foregroundColor: theme.colorScheme.onErrorContainer,
            backgroundColor: theme.colorScheme.errorContainer,
          ),
          icon: const Icon(Icons.delete),
          label: const Text('Clear'),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: double.infinity,
              maxHeight: double.infinity,
            ),
            child: CodeSection(
              codeController,
              readOnly: true,
            ),
          ),
        ),
      ],
    );
  }
}

const _kMaxRowsInJsonPreview = 25;

class _ResultsSide extends ConsumerWidget {
  final DevToolsDbProps props;

  const _ResultsSide({required this.props});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _queryRes = ref.watch(_queryResultProvider(props));

    if (_queryRes == null) {
      return const SizedBox();
    }

    if (_queryRes is AsyncLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final res = _queryRes.requireValue;

    final tabIndex = ref.watch(_resultsSideTabIndexProvider(props));

    return HookBuilder(
      builder: (context) {
        final resRowsJsonStr = useMemoized(
          () => const JsonEncoder.withIndent('  ')
              .convert(res.rows.take(_kMaxRowsInJsonPreview).toList()),
          [res],
        );

        return DefaultTabController(
          length: 2,
          initialIndex: tabIndex,
          child: HookBuilder(
            builder: (context) {
              final tabController = DefaultTabController.of(context);
              useEffect(() {
                void l() {
                  ref.read(_resultsSideTabIndexProvider(props).notifier).state =
                      tabController.index;
                }

                tabController.addListener(l);
                return () {
                  tabController.removeListener(l);
                };
              });

              return Column(
                children: <Widget>[
                  const TabBar(
                    isScrollable: true,
                    tabAlignment: TabAlignment.start,
                    tabs: [
                      Tab(text: 'Table'),
                      Tab(text: 'JSON'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _TableTab(props: props, queryRes: res),
                        _JSONTab(
                          props: props,
                          queryRes: res,
                          resRowsJsonStr: resRowsJsonStr,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _TableTab extends StatelessWidget {
  const _TableTab({required this.props, required this.queryRes});

  final DevToolsDbProps props;
  final RemoteQueryRes queryRes;

  @override
  Widget build(BuildContext context) {
    if (queryRes.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SelectableText(
            queryRes.error!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    return DbRowsTable(rows: queryRes.rows);
  }
}

class _JSONTab extends HookWidget {
  const _JSONTab({
    required this.props,
    required this.queryRes,
    required this.resRowsJsonStr,
  });

  final DevToolsDbProps props;
  final RemoteQueryRes queryRes;
  final String resRowsJsonStr;

  @override
  Widget build(BuildContext context) {
    final String jsonString;
    if (queryRes.error != null) {
      jsonString = queryRes.error!;
    } else {
      jsonString = resRowsJsonStr;
    }

    final codeController =
        useCodeController(text: jsonString, language: json_highlight.json);

    return Column(
      children: [
        if (queryRes.rows.length > _kMaxRowsInJsonPreview)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Showing first $_kMaxRowsInJsonPreview rows out of ${queryRes.rows.length}',
            ),
          ),
        const SizedBox(height: 8),
        Expanded(
          child: CodeSection(
            codeController,
            readOnly: true,
            lineNumbers: false,
          ),
        ),
      ],
    );
  }
}

class CodeSection extends StatelessWidget {
  const CodeSection(
    this.codeController, {
    this.readOnly = false,
    this.lineNumbers = true,
  });

  final CodeController codeController;
  final bool readOnly;
  final bool lineNumbers;

  @override
  Widget build(BuildContext context) {
    return AlwaysScrollbarConfiguration(
      child: SingleChildScrollView(
        child: CodeTheme(
          data: const CodeThemeData(styles: atomOneDarkTheme),
          child: CodeField(
            controller: codeController,
            minLines: 50,
            readOnly: readOnly,
            lineNumbers: lineNumbers,
            textStyle: getMonospaceTextStyle(),
          ),
        ),
      ),
    );
  }
}
