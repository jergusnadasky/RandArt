import 'dart:ui';

bool isDarkColor(Color color) {
  return color.computeLuminance() < 0.5;
}