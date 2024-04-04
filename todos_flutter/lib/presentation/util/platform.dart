import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

IconData getIconForPlatform() {
  if (kIsWeb) {
    return MdiIcons.web;
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return MdiIcons.android;
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return MdiIcons.appleIos;
  } else if (defaultTargetPlatform == TargetPlatform.fuchsia) {
    return MdiIcons.google;
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    return MdiIcons.linux;
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    return MdiIcons.microsoftWindows;
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    return MdiIcons.apple;
  } else {
    return Icons.help_outline;
  }
}

String getPlatformName() {
  if (kIsWeb) {
    return "Web";
  } else if (defaultTargetPlatform == TargetPlatform.android) {
    return "Android";
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    return "iOS";
  } else if (defaultTargetPlatform == TargetPlatform.fuchsia) {
    return "Fuchsia";
  } else if (defaultTargetPlatform == TargetPlatform.linux) {
    return "Linux";
  } else if (defaultTargetPlatform == TargetPlatform.windows) {
    return "Windows";
  } else if (defaultTargetPlatform == TargetPlatform.macOS) {
    return "macOS";
  } else {
    return "Unknown";
  }
}
