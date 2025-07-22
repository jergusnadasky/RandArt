class Artwork {
  final String title;
  final String artist;
  final String imageUrl;
  final String link;
  final String description;
  final String id;
  final String date; // Optional date field, can be used for startDate or endDate

  // final String startDate;
  // final String endDate;

  Artwork({
    required this.date, // Optional, can be null
    required this.description,
    required this.title,
    required this.artist,
    required this.imageUrl,
    required this.link,
    required this.id,
    // required this.startDate,
    // required this.endDate,
  });
}
