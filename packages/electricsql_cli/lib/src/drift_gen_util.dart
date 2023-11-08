import 'package:code_builder/code_builder.dart';

/// Generates: <columnBuilder>.clientDefault(() => <value>) to chain with the
/// other drift column modifiers.
/// [columnBuilder] is the base [ColumnBuilder] expression from drift that gets modified
/// [value] is the value expression to be returned by the [clientDefault] closure.
///
/// Common usage would be if you have a `.clientDefault(() => DateTime.now())` in your
/// drift schema.
/// That can be defined as follows:
///
/// ```dart
/// clientDefaultExpression(
///   columnBuilder,
///   value: dateTimeNowExpression,
/// );
/// ```
///
/// If you need a custom value expression, refer to how to create expressions with the
/// [code_builder](https://pub.dev/packages/code_builder) package.
Expression clientDefaultExpression(
  Expression columnBuilder, {
  required Expression value,
}) {
  // generates: () => <value>
  final closure = Method(
    (b) => b..body = value.code,
  ).closure;

  // generates: <columnBuilder>.clientDefault(() => <value>)
  return columnBuilder.property('clientDefault').call(
    [closure],
  );
}

/// Returns the Expression that builds `DateTime.now()`
Expression get dateTimeNowExpression {
  final nowExpression = refer('DateTime').property('now').call([]);
  return nowExpression;
}
