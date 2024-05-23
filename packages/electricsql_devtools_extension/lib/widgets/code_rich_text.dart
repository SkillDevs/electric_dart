import 'package:auto_size_text/auto_size_text.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:electricsql_devtools_extension/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/atom-one-dark.dart';

class CodeRichText extends StatelessWidget {
  const CodeRichText(
    this.codeController, {
    super.key,
  });

  final CodeController codeController;

  @override
  Widget build(BuildContext context) {
    return CodeTheme(
      data: const CodeThemeData(styles: atomOneDarkTheme),
      child: Builder(
        builder: (context) {
          return Container(
            padding: const EdgeInsets.all(8),
            color: CodeTheme.of(context)!.styles['root']!.backgroundColor ??
                Colors.grey.shade900,
            child: AutoSizeText.rich(
              codeController.buildTextSpan(
                context: context,
                style: getMonospaceTextStyle(),
              ),
              minFontSize: 10,
            ),
          );
        },
      ),
    );
  }
}
