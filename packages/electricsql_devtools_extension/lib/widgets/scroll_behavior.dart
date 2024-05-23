import 'package:flutter/material.dart';

class _AlwaysScrollbarScrollBehavior extends MaterialScrollBehavior {
  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return Scrollbar(
      controller: details.controller,
      thumbVisibility: true,
      thickness: 7,
      child: child,
    );
  }
}

class AlwaysScrollbarConfiguration extends StatelessWidget {
  final Widget child;

  const AlwaysScrollbarConfiguration({
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: _AlwaysScrollbarScrollBehavior(),
      child: child,
    );
  }
}
