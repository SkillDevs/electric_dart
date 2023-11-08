import 'package:code_builder/code_builder.dart';

/// generates: .clientDefault(() => DateTime.now()) to chain with the
/// other modifiers
Expression clientDefaultDateTimeNowExpression(
  Expression columnBuilderExpression,
) {
  final nowExpression = refer('DateTime').property('now').call([]);

  // generates: () => DateTime.now()
  final closure = Method(
    (b) => b..body = nowExpression.code,
  ).closure;

  // generates: .clientDefault(() => DateTime.now()) to chain with the
  // other modifiers
  return columnBuilderExpression.property('clientDefault').call(
    [closure],
  );
}
