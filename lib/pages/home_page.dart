import 'dart:math';
import 'package:art_gen/pages/about_page.dart';
import 'package:art_gen/services/chicago_art_service.dart';
import 'package:art_gen/services/met_art_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:palette_generator/palette_generator.dart';
import 'dart:ui';
import 'package:after_layout/after_layout.dart';

import 'package:art_gen/util/artwork.dart';

import 'package:url_launcher/url_launcher.dart';

import 'dart:html' as html;

class ArtHomePage extends StatefulWidget {
  const ArtHomePage(this.title, {super.key});

  final String title;

  @override
  State<ArtHomePage> createState() => _ArtHomePageState();
}

class _ArtHomePageState extends State<ArtHomePage>
    with AfterLayoutMixin<ArtHomePage> {
  String imageURL = "";
  String title = "";
  String artistName = "";
  String artworkLink = "";
  String _description = "";
  String startDate = "";
  String endDate = "";
  String id = "";
  String _date = "";
  Color? dominantColor;
  bool imageVisible = false;
  bool _hovering = false;

  final randomNum = Random();

  @override
  Widget build(BuildContext context) {
    final bgColor = dominantColor ?? Colors.white;
    final textColor = isDarkColor(bgColor) ? Colors.white : Colors.black;
    final overlay =
        isDarkColor(bgColor)
            ? Colors.black.withOpacity(0.5)
            : Colors.white.withOpacity(0.5);
    return Scaffold(
      backgroundColor: Colors.transparent, // Now handled by AnimatedContainer
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOut,
          color: bgColor,
          child: AppBar(
            automaticallyImplyLeading: false,
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: textColor,
            title: GestureDetector(
              child: Center(
                child: SizedBox(
                  height:
                      250, // Adjust this value as needed (default AppBar height is 56)
                  child:
                      isDarkColor(bgColor)
                          ? Image.asset("logo_white.png", fit: BoxFit.contain)
                          : Image.asset("logo_black.png", fit: BoxFit.contain),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.pages, color: textColor),
                onPressed:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => AboutPage(
                              bgColor: dominantColor ?? Colors.white,
                              title: widget.title,
                            ),
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeInOut,
        color: bgColor,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              color: overlay,
            ),
            Column(
              children: [
                Expanded(
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 600, // Fixed height "canvas"
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageURL.isNotEmpty)
                            AnimatedOpacity(
                              opacity: imageVisible ? 1.0 : 0.0,
                              duration: const Duration(seconds: 1),
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxHeight:
                                      350, // Adjusted height to avoid overflow
                                ),
                                child: MouseRegion(
                                  onEnter:
                                      (_) => setState(() => _hovering = true),
                                  onExit:
                                      (_) => setState(() => _hovering = false),
                                  child: GestureDetector(
                                    onTap: () {
                                      final currentArtwork = Artwork(
                                        title: title,
                                        artist: artistName,
                                        imageUrl: imageURL,
                                        link: artworkLink,
                                        description: _description,
                                        id: id,
                                        date: _date,
                                      );
                                      _showArtworkOverlay(
                                        context,
                                        currentArtwork,
                                        dominantColor,
                                      );
                                    },
                                    child: AnimatedScale(
                                      scale:
                                          _hovering
                                              ? 1.1
                                              : 1.0, // 10% zoom on hover
                                      duration: const Duration(
                                        milliseconds: 500,
                                      ),
                                      curve: Curves.easeInOut,
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 350,
                                        ),
                                        child: CachedNetworkImage(
                                          imageUrl: imageURL,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: ElevatedButton(
                    onPressed: () {
                      getRandomArt();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bgColor,
                      //isDarkColor(bgColor) ? Colors.white : Colors.black,
                    ),
                    child: Text(
                      "Explore Art",
                      style: TextStyle(
                        color:
                            isDarkColor(bgColor) ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: IconButton(
                    onPressed: () {
                      downloadImageWeb(imageURL, artistName, title);
                    },
                    icon: Icon(Icons.download_rounded),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setError(String message) {
    setState(() {
      imageURL = "";
      title = message;
      artistName = "";
      dominantColor = Colors.white;
      imageVisible = true; // Show error message with fade-in
    });
  }

  void _showArtworkOverlay(
    BuildContext context,
    Artwork artwork,
    Color? backgroundColor,
  ) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Artwork Details',
      barrierColor: Colors.black.withOpacity(0.6),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            behavior:
                HitTestBehavior
                    .opaque, // Important to detect taps outside dialog
            onTap: () {
              Navigator.of(context).pop(); // Close dialog on tap outside
            },
            child: Center(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Stack(
                    children: [
                      // Wrap dialog in IgnorePointer to avoid closing when tapping inside dialog
                      IgnorePointer(
                        ignoring: false,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.7,
                              height: MediaQuery.of(context).size.height * 0.5,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: (backgroundColor ?? Colors.white)
                                    .withOpacity(0.25),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 2,
                                ),
                              ),
                              child: GestureDetector(
                                onTap:
                                    () {}, // Prevent tap event from bubbling up to the outer GestureDetector
                                child: Row(
                                  children: [
                                    // LEFT: Large artwork image
                                    Expanded(
                                      flex: 2,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(24),
                                        child: CachedNetworkImage(
                                          imageUrl: imageURL,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 24),
                                    //TODO make this section scrollable
                                    // RIGHT: Artwork info
                                    Expanded(
                                      flex: 3,
                                      child: Align(
                                        alignment: Alignment.topLeft,
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InkWell(
                                              onTap: () async {
                                                final Uri url = Uri.parse(
                                                  artworkLink,
                                                );
                                                if (await canLaunchUrl(url)) {
                                                  await launchUrl(
                                                    url,
                                                    mode:
                                                        LaunchMode
                                                            .externalApplication,
                                                  );
                                                } else {
                                                  // Handle error, e.g., show a message
                                                  print(
                                                    'Could not launch $url',
                                                  );
                                                }
                                              },
                                              child: Text(
                                                artwork.title,
                                                style: const TextStyle(
                                                  fontSize: 28,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      Colors.white70,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              artwork.artist,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 20),
                                            if (_description != '')
                                              Text(
                                                artwork.description,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white60,
                                                ),
                                              ),

                                            const Spacer(),

                                            if (_date != '')
                                              Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  _date,
                                                  style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Close 'X' button
                      Positioned(
                        top: 16,
                        right: 16,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void afterFirstLayout(BuildContext context) {
    // Calling the same function "after layout" to resolve the issue.
    getRandomArt();
  }

  Future<void> getRandomArt() async {
    setState(() {
      imageVisible = false;
    });

    await Future.delayed(const Duration(milliseconds: 300));


    final int apiChoice = randomNum.nextInt(2); // 0 or 1
    final ChicagoArtService chicagoService = ChicagoArtService();
    Artwork? artwork;

    if (apiChoice == 0) {
      artwork = await chicagoService.getRandomArtwork();
    } else {
      artwork = await MetArtService().getRandomArtwork();
    }

    if (artwork == null) {
      _setError("Failed to fetch artwork.");
      return;
    }

    final palette = await PaletteGenerator.fromImageProvider(
      NetworkImage(artwork.imageUrl),
      size: const Size(200, 200),
    );

    setState(() {
      _description = artwork!.description;
      artworkLink = artwork.link;
      title = artwork.title;
      artistName = artwork.artist;
      imageURL = artwork.imageUrl;
      dominantColor = palette.dominantColor?.color ?? Colors.white;
      imageVisible = true;
      _date = artwork.date;
    });
  }
}

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

    html.Url.revokeObjectUrl(url); // Clean up after download
  } else {
    print('Failed to download image.');
  }
}

bool isDarkColor(Color color) {
  return color.computeLuminance() < 0.5;
}
