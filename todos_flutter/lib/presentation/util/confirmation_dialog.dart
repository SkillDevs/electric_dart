import 'package:flutter/material.dart';

Future<bool?> launchConfirmationDialog({
  required BuildContext context,
  required String title,
  Widget? content,
  IconData? icon,
  String? confirmationAction,
  String? cancelAction,
  bool barrierDismissible = true,
}) {
  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (BuildContext context) {
      void confirmationOnPressed() async {
        Navigator.pop(context, true);
      }

      final confirmationLabel = Text(confirmationAction?.toUpperCase() ?? 'OK');

      return AlertDialog(
        contentPadding: content == null
            ? const EdgeInsets.all(5)
            : const EdgeInsets.fromLTRB(24.0, 20.0, 24.0, 24.0),
        title: Text(title),
        content: SingleChildScrollView(child: content),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: <Widget>[
          Padding(
            // Fake padding
            padding: const EdgeInsets.only(left: 8.0),
            child: TextButton(
              onPressed: () async {
                Navigator.pop(context, false);
              },
              child: Text((cancelAction ?? "Cancel").toUpperCase()),
            ),
          ),
          if (icon != null)
            ElevatedButton.icon(
              icon: Icon(icon),
              onPressed: confirmationOnPressed,
              label: confirmationLabel,
            )
          else
            ElevatedButton(
              onPressed: confirmationOnPressed,
              child: confirmationLabel,
            ),
        ],
      );
    },
  );
}
