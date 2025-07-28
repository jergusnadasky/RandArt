import 'dart:convert';
import 'dart:math';
import 'package:art_gen/util/artwork.dart';
import 'package:http/http.dart' as http;

class ChicagoArtService {
  final Random _random = Random();

  //TODO fix image not loading when image is too big
  /// Fetches a random artwork from the Art Institute of Chicago API.
  /// EXAMPLE USAGE: https://www.artic.edu/iiif/2/76b5a746-c165-4acd-9b5d-1443df68b42e/full/843,/0/default.jpg
  /// https://www.artic.edu/artworks/228301/tales-of-ise
  /// weed these out or skip them 

  Future<Artwork?> getRandomArtwork() async {
    try {
      final idResponse = await http.get(
        Uri.parse(
          'https://api.artic.edu/api/v1/artworks?limit=100&page=${_random.nextInt(100) + 1}&fields=id,image_id,title,artist_title,short_description,date_display,thumbnail',
        ),
      );

      if (idResponse.statusCode != 200) {
        return null;
      }

      final idData = jsonDecode(idResponse.body);
      final List<dynamic> artList = idData['data'];



      for (var art in artList) {
        final imageId = art['image_id'];
        if (imageId == null || imageId.isEmpty) continue;

        final imageUrl =
            'https://www.artic.edu/iiif/2/$imageId/full/843,/0/default.jpg';

        final artwork = Artwork(
          title: art['title'] ?? 'Untitled',
          artist: art['artist_title'] ?? 'Unknown Artist',
          imageUrl: imageUrl,
          link: "https://www.artic.edu/artworks/${art['id']}",
          description: art['short_description'] ?? art['thumbnail']['alt_text'],
          id: art['id'].toString(),
          date: art['date_display'].toString(), 
        );
        return artwork;
      }

      return null; // If no image found
    } catch (error) {
      return null;
    }
  }
}
