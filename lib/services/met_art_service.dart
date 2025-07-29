import 'dart:convert';
import 'dart:math';
import 'package:art_gen/util/artwork.dart';
import 'package:http/http.dart' as http;

class MetArtService {
  final Random _random = Random();

  Future<Artwork?> getRandomArtwork() async {
    try {
      final searchRes = await http.get(
        Uri.parse(
          'https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=painting',
        ),
      );
      if (searchRes.statusCode != 200) return null;

      final searchJson = jsonDecode(searchRes.body);
      final List<dynamic>? objectIDs = searchJson['objectIDs'];
      if (objectIDs == null || objectIDs.isEmpty) return null;

      // Try up to 15 times to find a valid, working image
      for (int i = 0; i < 15; i++) {
        final id = objectIDs[_random.nextInt(objectIDs.length)];

        final objectRes = await http.get(
          Uri.parse(
            'https://collectionapi.metmuseum.org/public/collection/v1/objects/$id',
          ),
        );
        if (objectRes.statusCode != 200) continue;

        final obj = jsonDecode(objectRes.body);
        final imageUrl = obj['primaryImageSmall'] ?? obj['primaryImage'];

        // Skip if no valid image URL
        if (imageUrl == null || imageUrl.isEmpty) continue;

        // Make a HEAD request to validate if image is accessible (e.g., not blocked)
        final imageCheck = await http.head(Uri.parse(imageUrl));
        if (imageCheck.statusCode != 200) continue;

        return Artwork(
          title: obj['title'] ?? 'Untitled',
          artist: obj['artistDisplayName'] ?? 'Unknown Artist',
          imageUrl: imageUrl,
          link: obj['objectURL'] ?? '',
          description: obj['medium'],
          id: obj['objectID'].toString(),
          date: obj['objectDate'] ?? '',
        );
      }

      return null;
    } catch (e) {
      return null;
    }
  }
}
