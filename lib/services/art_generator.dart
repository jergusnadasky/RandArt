import 'package:flutter/material.dart';
import 'package:art_gen/services/chicago_art_service.dart';
import 'package:art_gen/services/met_art_service.dart';
import 'package:art_gen/util/artwork.dart';
import 'package:art_gen/util/is_mobile.dart';

class ArtLoaderService {
  static final ChicagoArtService _chicagoService = ChicagoArtService();
  static final MetArtService _metService = MetArtService();

  static Future<Artwork?> fetchRandomArtwork() async {
    final int apiChoice = DateTime.now().millisecondsSinceEpoch % 2;

    try {
      if (isMobile() || apiChoice == 0) {
        return await _chicagoService.getRandomArtwork();
      } else {
        return await _metService.getRandomArtwork();
      }
    } catch (e) {
      debugPrint('Error fetching artwork: $e');
      return null;
    }
  }
}
