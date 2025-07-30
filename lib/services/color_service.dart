import 'package:art_gen/services/spectrum_creator.dart';
import 'package:flutter/material.dart';
import 'package:palette_generator/palette_generator.dart';


class ColorService {
  static Future<Map<String, dynamic>> processImageColors(String imageUrl) async {
    try {
      final smallImageProvider = ResizeImage(
        NetworkImage(imageUrl),
        width: 100,
        height: 100,
      );

      final results = await Future.wait([
        PaletteGenerator.fromImageProvider(
          smallImageProvider,
          size: const Size(100, 100),
        ).timeout(const Duration(seconds: 3)),
        extractColorsFromImage(smallImageProvider).timeout(const Duration(seconds: 3)),
      ]);

      return {
        'dominantColor': (results[0] as PaletteGenerator).dominantColor?.color ?? Colors.white,
        'extractedColors': results[1] as List<ColorInfo>,
      };
    } catch (e) {
      return {
        'dominantColor': Colors.white,
        'extractedColors': <ColorInfo>[],
      };
    }
  }
}
