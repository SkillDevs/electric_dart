import 'package:flutter/material.dart';

ThemeData getElectricTheme() {
  return ThemeData.from(colorScheme: kElectricColorScheme);
}

const ColorScheme kElectricColorScheme = ColorScheme(
  brightness: Brightness.dark,

  primary: Color(0xFF00d2a0),
  onPrimary: Color(0xFF111111),
  primaryContainer: Color(0xFF226857),
  //onPrimaryContainer: Color(0xFFEADDFF),
  secondary: Color(0xFF00d2a0),
  onSecondary: Color(0xFF111111),
  // secondaryContainer: Color(0xFF4A4458),
  // onSecondaryContainer: Color(0xFFE8DEF8),
  // tertiary: Color(0xFFEFB8C8),
  // onTertiary: Color(0xFF492532),
  // tertiaryContainer: Color(0xFF633B48),
  // onTertiaryContainer: Color(0xFFFFD8E4),
  error: Color(0xFFf87373),
  onError: Color(0xFF601410),
  errorContainer: Color(0xFF8C1D18),
  onErrorContainer: Color(0xFFF9DEDC),
  surface: Color(0xFF131517),
  onSurface: Color(0xFFdadde1),
  surfaceContainerLow: Color(0xFF242428),
  outline: Color(0xb0f4fefb),
  outlineVariant: Color(0xFF49454F),
  shadow: Color(0xFF000000),
  scrim: Color(0xFF000000),
  inverseSurface: Color(0xFFE6E1E5),
  onInverseSurface: Color(0xFF313033),
  //inversePrimary: Color(0xFF6750A4),
  // The surfaceTint color is set to the same color as the primary.
  surfaceTint: Color(0xFF000000),
);
