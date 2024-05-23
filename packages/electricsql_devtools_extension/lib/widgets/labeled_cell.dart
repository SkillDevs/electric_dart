import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LabeledTextCell extends StatelessWidget {
  const LabeledTextCell(this.text, {super.key, this.style, this.maxLines = 2});
  final String text;
  final TextStyle? style;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Clipboard.setData(ClipboardData(text: text));
          final messenger = ScaffoldMessenger.of(context);
          messenger.removeCurrentSnackBar();
          messenger.showSnackBar(
            const SnackBar(
              content: Text('Copied to clipboard!'),
            ),
          );
        },
        child: Tooltip(
          message: text,
          waitDuration: const Duration(milliseconds: 500),
          child: Text(
            text,
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
            style: style,
          ),
        ),
      ),
    );
  }
}
