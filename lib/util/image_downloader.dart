import 'dart:html' as html;
import 'package:http/http.dart' as http;

Future<void> downloadImageWeb(
  String imageUrl,
  String artist,
  String title,
) async {
  final response = await http.get(Uri.parse(imageUrl));

  if (response.statusCode == 200) {
    final bytes = response.bodyBytes;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);

    html.AnchorElement(href: url)
      ..setAttribute("download", "$artist-$title.jpg")
      ..click();

    html.Url.revokeObjectUrl(url);
  } else {
    print('Failed to download image.');
  }
}
