import 'dart:convert';
import 'dart:math';
import 'package:art_gen/util/artwork.dart';
import 'package:http/http.dart' as http;

class MetArtService {
  final Random _random = Random();

  Future<Artwork?> getRandomArtwork() async {
    try {
      // Step 1: Search for artworks with images and use a more specific query
      final searchRes = await http.get(
        Uri.parse(
          'https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=painting',
        ),
      );
      if (searchRes.statusCode != 200) return null;

      final searchJson = jsonDecode(searchRes.body);
      final List<dynamic>? objectIDs = searchJson['objectIDs'];
      if (objectIDs == null || objectIDs.isEmpty) return null;

      // Step 2: Try up to 10 times to find a valid artwork with image
      for (int i = 0; i < 10; i++) {
        final id = objectIDs[_random.nextInt(objectIDs.length)];

        final objectRes = await http.get(
          Uri.parse(
            'https://collectionapi.metmuseum.org/public/collection/v1/objects/$id',
          ),
        );
        if (objectRes.statusCode != 200) continue;

        final obj = jsonDecode(objectRes.body);
        final imageUrl = obj['primaryImageSmall'] ?? obj['primaryImage'];

        // Check if the image URL is valid and skips if not
        if (imageUrl == null || imageUrl.isEmpty || imageUrl == '') continue;

        return Artwork(
          title: obj['title'] ?? 'Untitled',
          artist: obj['artistDisplayName'] ?? 'Unknown Artist',
          imageUrl: imageUrl,
          link: obj['objectURL'] ?? '',
          description: obj['medium'],
          id: obj['objectID'].toString(),
          date: obj['objectDate'] ?? '', // Optional date field
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
