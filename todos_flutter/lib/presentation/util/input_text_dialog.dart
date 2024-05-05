import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class InputTextDialog extends HookWidget {
  final String? title;
  final String? initialValue;
  final String? hint;
  final String? action;
  final IconData? actionIcon;

  const InputTextDialog({
    super.key,
    this.title,
    this.initialValue,
    this.hint,
    this.action,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    final textController =
        useMemoized(() => TextEditingController(text: initialValue ?? ''));
    useEffect(
      () {
        return () => textController.dispose();
      },
      [],
    );

    final _hint = hint ?? 'Text';
    final _action = action ?? 'OK';
    final _actionIcon = actionIcon ?? Icons.done;

    final GlobalKey<FormState> formKey =
        useMemoized(() => GlobalKey<FormState>());

    return AlertDialog(
      title: title == null ? null : Text(title!),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Form(
            key: formKey,
            child: TextFormField(
              autofocus: true,
              controller: textController,
              decoration: InputDecoration(
                labelText: _hint,
                filled: true,
              ),
              validator: (String? value) =>
                  (value ?? '').trim().isNotEmpty ? null : "Can't be empty",
            ),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: () {
            if (formKey.currentState!.validate() == false) {
              return;
            }

            Navigator.pop(context, textController.text);
          },
          icon: Icon(_actionIcon),
          label: Text(_action),
        ),
      ],
    );
  }
}
