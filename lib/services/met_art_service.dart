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

        // Check if image is accessible and handle CORS errors
        try {
          final imageCheck = await http.head(Uri.parse(imageUrl));
          if (imageCheck.statusCode != 200) continue;

          // If CORS error occurs, a new artwork request will be made
          if (i >= 14) {
            getRandomArtwork();
          }

          // Additional check: try to make a GET request to ensure the image is truly accessible
          // This will catch CORS errors that might not appear in HEAD requests
          final imageTest = await http
              .get(Uri.parse(imageUrl))
              .timeout(
                Duration(seconds: 5),
                onTimeout: () => throw Exception('Image request timeout'),
              );

          if (imageTest.statusCode != 200) continue;
        } catch (e) {
          // This will catch CORS errors, timeouts, and other network issues
          print('Image accessibility check failed for $imageUrl: $e');
          continue; // Skip this artwork and try the next one
        }

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
      print('General error in getRandomArtwork: $e');
      return null;
    }
  }
}
