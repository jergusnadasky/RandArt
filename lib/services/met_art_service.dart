import 'dart:convert';
import 'dart:math';
import 'package:art_gen/util/artwork.dart';
import 'package:http/http.dart' as http;

class MetArtService {
  final Random _random = Random();

  Future<Artwork?> getRandomArtwork() async {
    try {
      // 1. Search for image-enabled objects
      final searchRes = await http.get(Uri.parse(
        'https://collectionapi.metmuseum.org/public/collection/v1/search?hasImages=true&q=*'
      ));
      if (searchRes.statusCode != 200) return null;

      final searchJson = jsonDecode(searchRes.body);
      final List<dynamic>? objectIDs = searchJson['objectIDs'];
      if (objectIDs == null || objectIDs.isEmpty) return null;

      // 2. Pick one ID randomly
      final id = objectIDs[_random.nextInt(objectIDs.length)];

      // 3. Fetch object data
      final objectRes = await http.get(Uri.parse(
        'https://collectionapi.metmuseum.org/public/collection/v1/objects/$id'
      ));
      if (objectRes.statusCode != 200) return null;

      final obj = jsonDecode(objectRes.body);
      final imageUrl = obj['primaryImage'] as String?;
      if (imageUrl == null || imageUrl.isEmpty) return null;

      return Artwork(
        title: obj['title'] ?? 'Untitled',
        artist: obj['artistDisplayName'] ?? 'Unknown Artist',
        imageUrl: imageUrl,
        link: obj['objectURL'] ?? '',
        description: obj['objectDate'] ?? '',
        id: obj['objectID'].toString(),
      );
    } catch (e) {
      return null;
    }
  }
}
