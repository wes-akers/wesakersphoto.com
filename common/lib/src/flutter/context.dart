import 'package:flutter/material.dart';

extension BuildContextExtensions on BuildContext {
  Brightness get brightness => theme.brightness;
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;
  ThemeData get theme => Theme.of(this);
}
