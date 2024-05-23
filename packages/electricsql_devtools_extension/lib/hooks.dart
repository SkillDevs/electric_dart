import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:highlight/highlight_core.dart';

CodeController useCodeController({String? text, Mode? language}) {
  final codeController = useMemoized(
    () => CodeController(
      text: text,
      language: language,
    ),
  );
  useEffect(
    () {
      return codeController.dispose;
    },
    [codeController],
  );

  return codeController;
}
