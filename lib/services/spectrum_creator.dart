import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';

Future<List<ColorInfo>> extractColorsFromImage(
  ImageProvider imageProvider,
) async {
  final palette = await PaletteGenerator.fromImageProvider(
    imageProvider,
    maximumColorCount: 10,
    size: const Size(200, 200),
  );

  final totalPopulation = palette.colors.length;

  // Dummy calculation: equal weights (you can improve this with pixel analysis later)
  return palette.colors.map((color) {
    return ColorInfo(color: color, percentage: 1.0 / totalPopulation);
  }).toList();
}

class ColorInfo {
  final Color color;
  final double percentage;
  ColorInfo({required this.color, required this.percentage});
}
