import 'dart:math';
import 'package:flutter/services.dart';
import 'package:art_gen/pages/about_page.dart';
import 'package:art_gen/services/chicago_art_service.dart';
import 'package:art_gen/services/met_art_service.dart';
import 'package:art_gen/services/spectrum_creator.dart';
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
//TODO change universal font to something nicer
//TODO add bottom bar with number of artworks viewed out of however many were queried in both APIs. Do the math and increment on every click of the button.

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
  Offset _hoverPosition = Offset.zero;
  bool _isFirstLoad = true;
  double _scaffoldOpacity = 0.0;

  final randomNum = Random();

  List<ColorInfo> _extractedColors = [];
  int? _hoveredColorIndex;

  @override
  Widget build(BuildContext context) {
    return _isFirstLoad
        ? AnimatedOpacity(
          opacity: _scaffoldOpacity,
          duration: const Duration(milliseconds: 800), // Reduced from 2 seconds
          curve: Curves.easeInOut,
          child: _buildScaffold(),
        )
        : _buildScaffold();
  }

  Widget _buildScaffold() {
    final bgColor = dominantColor ?? Colors.white;
    final textColor = isDarkColor(bgColor) ? Colors.white : Colors.black;
    final overlay =
        isDarkColor(bgColor)
            ? Colors.black.withOpacity(0.5)
            : Colors.white.withOpacity(0.5);

    return Scaffold(
      backgroundColor: Colors.transparent,
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
                  height: 250,
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
                      PageRouteBuilder(
                        pageBuilder:
                            (context, animation1, animation2) => AboutPage(
                              bgColor: dominantColor ?? Colors.white,
                              title: widget.title,
                            ),
                        transitionDuration: Duration.zero,
                        reverseTransitionDuration: Duration.zero,
                      ),
                    ),
              ),
            ],
          ),
        ),
      ),

      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
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
                      height: 600,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (imageURL.isNotEmpty)
                            AnimatedOpacity(
                              opacity: imageVisible ? 1.0 : 0.0,
                              duration: const Duration(milliseconds: 600),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 350,
                                    ),
                                    child: MouseRegion(
                                      onEnter:
                                          (_) =>
                                              setState(() => _hovering = true),
                                      onExit:
                                          (_) =>
                                              setState(() => _hovering = false),
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
                                          scale: _hovering ? 1.1 : 1.0,
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxHeight: 350,
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: CachedNetworkImage(
                                                imageUrl: imageURL,
                                                fit: BoxFit.contain,
                                                fadeInDuration: const Duration(
                                                  milliseconds: 400,
                                                ), // Reduced from 800ms
                                                fadeOutDuration: const Duration(
                                                  milliseconds: 200,
                                                ), // Reduced from 300ms
                                                imageBuilder:
                                                    (
                                                      context,
                                                      imageProvider,
                                                    ) => ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      child: Image(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain,
                                                        // This helps with performance
                                                        filterQuality:
                                                            FilterQuality
                                                                .medium,
                                                      ),
                                                    ),
                                                placeholder:
                                                    (context, url) => Container(
                                                      height: 300,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        color:
                                                            dominantColor
                                                                ?.withOpacity(
                                                                  0.1,
                                                                ) ??
                                                            Colors
                                                                .grey
                                                                .shade100,
                                                      ),
                                                      child: Center(
                                                        child: CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(
                                                                dominantColor ??
                                                                    Colors.grey,
                                                              ),
                                                        ),
                                                      ),
                                                    ),
                                                errorWidget:
                                                    (
                                                      context,
                                                      url,
                                                      error,
                                                    ) => Container(
                                                      height: 300,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              16,
                                                            ),
                                                        color:
                                                            Colors
                                                                .grey
                                                                .shade100,
                                                      ),
                                                      child: const Center(
                                                        child: Icon(
                                                          Icons.error_outline,
                                                          size: 48,
                                                          color: Colors.grey,
                                                        ),
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 48),

                                  // Spectrum gradient below the image
                                  if (_extractedColors.isNotEmpty)
                                    Container(
                                      height: 20,
                                      width: 200, // adjust width as needed
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: List.generate(
                                          _extractedColors.length,
                                          (index) {
                                            final colorData =
                                                _extractedColors[index];
                                            final hexCode =
                                                '#${colorData.color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase()}';

                                            return MouseRegion(
                                              onEnter:
                                                  (event) => setState(() {
                                                    _hoverPosition =
                                                        event.position;
                                                    _hoveredColorIndex = index;
                                                  }),
                                              onExit:
                                                  (_) => setState(
                                                    () =>
                                                        _hoveredColorIndex =
                                                            null,
                                                  ),
                                              onHover:
                                                  (event) => setState(
                                                    () =>
                                                        _hoverPosition =
                                                            event.position,
                                                  ),
                                              child: GestureDetector(
                                                onTap: () {
                                                  Clipboard.setData(
                                                    ClipboardData(
                                                      text: hexCode,
                                                    ),
                                                  );
                                                  ScaffoldMessenger.of(
                                                    context,
                                                  ).showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                        style: TextStyle(
                                                          color:
                                                              isDarkColor(
                                                                    colorData
                                                                        .color,
                                                                  )
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                        ),
                                                        'Copied $hexCode to clipboard',
                                                      ),
                                                      backgroundColor:
                                                          colorData.color,
                                                      behavior:
                                                          SnackBarBehavior
                                                              .floating,
                                                      duration: const Duration(
                                                        seconds: 2,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: Container(
                                                  width:
                                                      200 *
                                                      colorData.percentage,
                                                  height: 60,
                                                  color: colorData.color,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                ],
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

                  child: GestureDetector(
                    child: TextButton(
                      style: const ButtonStyle(
                        overlayColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                      onPressed: () {
                        getRandomArt();
                      },
                      child: Text(
                        "EXPLORE ART",
                        style: TextStyle(
                          fontFamily: 'dots', // TODO fix font for button
                          color:
                              isDarkColor(bgColor)
                                  ? Colors.white
                                  : Colors.black,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 30),
                  child: TextButton(
                    style: const ButtonStyle(
                      overlayColor: WidgetStatePropertyAll(Colors.transparent),
                    ),
                    onPressed: () {
                      downloadImageWeb(imageURL, artistName, title);
                    },
                    child: Text(
                      "DOWNLOAD",
                      style: TextStyle(
                        fontFamily: 'dots',
                        color:
                            isDarkColor(bgColor) ? Colors.white : Colors.black,
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_hoveredColorIndex != null)
              Positioned(
                left:
                    _hoverPosition.dx + 10, // Changes popup horizontal position
                top: _hoverPosition.dy + 10,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 0.5),
                      boxShadow: [
                        BoxShadow(blurRadius: 8, color: Colors.black26),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _extractedColors[_hoveredColorIndex!].color,
                            border: Border.all(color: Colors.black),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Akkurat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.end,
                                  "HEX: #",
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Akkurat',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.end,
                                  _extractedColors[_hoveredColorIndex!]
                                      .color
                                      .value
                                      .toRadixString(16)
                                      .substring(2)
                                      .toUpperCase(),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Akkurat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.end,
                                  "RGB: (",
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Akkurat',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.end,
                                  "${_extractedColors[_hoveredColorIndex!].color.red}, ${_extractedColors[_hoveredColorIndex!].color.green}, ${_extractedColors[_hoveredColorIndex!].color.blue})",
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Akkurat',
                                    fontWeight: FontWeight.w700,
                                  ),
                                  textAlign: TextAlign.start,
                                  "HSL: ",
                                ),
                                Text(
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontFamily: 'Akkurat',
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.end,
                                  HSLColor.fromColor(
                                    _extractedColors[_hoveredColorIndex!].color,
                                  ).toString(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
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
      imageVisible = true;
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
      barrierColor: Colors.black.withOpacity(0.7), // Slightly darker for focus
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Center(
              child: StatefulBuilder(
                builder: (BuildContext context, StateSetter setModalState) {
                  return Stack(
                    children: [
                      IgnorePointer(
                        ignoring: false,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                            child: Container(
                              width:
                                  MediaQuery.of(context).size.width *
                                  0.9, // Increased from 0.7
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.8, // Increased from 0.5
                              padding: const EdgeInsets.all(
                                32,
                              ), // Increased padding
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
                                onTap: () {},
                                child: Row(
                                  children: [
                                    // Image section - increased flex
                                    Expanded(
                                      flex:
                                          3, // Increased from 2 for larger image
                                      child: Container(
                                        constraints: BoxConstraints(
                                          maxHeight:
                                              MediaQuery.of(
                                                context,
                                              ).size.height *
                                              0.7,
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                          child: CachedNetworkImage(
                                            imageUrl: imageURL,
                                            fit: BoxFit.contain,
                                            fadeInDuration: const Duration(
                                              milliseconds: 300,
                                            ),
                                            fadeOutDuration: const Duration(
                                              milliseconds: 150,
                                            ),
                                            imageBuilder:
                                                (
                                                  context,
                                                  imageProvider,
                                                ) => ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(16),
                                                  child: Image(
                                                    image: imageProvider,
                                                    fit: BoxFit.contain,
                                                    filterQuality:
                                                        FilterQuality
                                                            .high, // Higher quality for inspection
                                                  ),
                                                ),
                                            placeholder:
                                                (context, url) => Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    color: (backgroundColor ??
                                                            Colors.white)
                                                        .withOpacity(0.2),
                                                  ),
                                                  child: Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        CircularProgressIndicator(
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                Color
                                                              >(Colors.white70),
                                                        ),
                                                        const SizedBox(
                                                          height: 16,
                                                        ),
                                                        const Text(
                                                          'Loading artwork...',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                            errorWidget:
                                                (
                                                  context,
                                                  url,
                                                  error,
                                                ) => Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                    color: Colors.white
                                                        .withOpacity(0.1),
                                                  ),
                                                  child: const Center(
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.error_outline,
                                                          size: 48,
                                                          color: Colors.white70,
                                                        ),
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Failed to load image',
                                                          style: TextStyle(
                                                            color:
                                                                Colors.white70,
                                                            fontSize: 14,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 32,
                                    ), // Increased spacing
                                    // Details section - made scrollable for long descriptions
                                    Expanded(
                                      flex:
                                          2, // Reduced from 3 to give more space to image
                                      child: SingleChildScrollView(
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
                                                  print(
                                                    'Could not launch $url',
                                                  );
                                                }
                                              },
                                              child: Text(
                                                artwork.title,
                                                style: const TextStyle(
                                                  fontSize:
                                                      32, // Increased font size
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  decoration:
                                                      TextDecoration.underline,
                                                  decorationColor:
                                                      Colors.white70,
                                                  height: 1.2,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 16,
                                            ), // Increased spacing

                                            Text(
                                              artwork.artist,
                                              style: const TextStyle(
                                                fontSize:
                                                    24, // Increased font size
                                                color: Colors.white70,
                                                fontStyle: FontStyle.italic,
                                              ),
                                            ),

                                            if (_date != '') ...[
                                              const SizedBox(height: 12),
                                              Text(
                                                _date,
                                                style: const TextStyle(
                                                  color: Colors.white60,
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ],

                                            if (_description != '') ...[
                                              const SizedBox(height: 24),
                                              const Text(
                                                'About this artwork:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                artwork.description,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.white70,
                                                  height:
                                                      1.5, // Better line spacing
                                                ),
                                              ),
                                            ],

                                            const SizedBox(height: 32),
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

                      // Close button
                      Positioned(
                        top: 24, // Adjusted for larger overlay
                        right: 24,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 24,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
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
    setState(() {
      _scaffoldOpacity = 1.0;
    });

    // Reduced delay before loading first artwork
    Future.delayed(const Duration(milliseconds: 800), () {
      // Reduced from 2 seconds
      setState(() {
        _isFirstLoad = false;
      });
      getRandomArt();
    });
  }

  Future<void> getRandomArt() async {
    // Start fade out immediately
    setState(() {
      imageVisible = false;
    });

    // Minimal delay for fade out (reduced from 300ms)
    await Future.delayed(const Duration(milliseconds: 100));

    final int apiChoice = randomNum.nextInt(2);
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

    // Create a smaller image provider for color processing
    final smallImageProvider = ResizeImage(
      NetworkImage(artwork.imageUrl),
      width: 150,
      height: 150,
    );

    // Start both color operations in parallel
    final paletteFuture = PaletteGenerator.fromImageProvider(
      smallImageProvider,
      size: const Size(150, 150),
    );

    final extractedColorsFuture = extractColorsFromImage(smallImageProvider);

    // Set artwork data immediately so CachedNetworkImage can start loading
    setState(() {
      _description = artwork!.description;
      artworkLink = artwork.link;
      title = artwork.title;
      artistName = artwork.artist;
      imageURL = artwork.imageUrl;
      _date = artwork.date;
      // Set a temporary color to start the transition
      dominantColor = Colors.grey.shade300;
    });

    try {
      // Wait for both color operations to complete
      final results = await Future.wait([paletteFuture, extractedColorsFuture]);

      final palette = results[0] as PaletteGenerator;
      final extractedColors = results[1] as List<ColorInfo>;

      // Update with final colors and show image
      setState(() {
        dominantColor = palette.dominantColor?.color ?? Colors.white;
        _extractedColors = extractedColors;
        imageVisible = true;
      });
    } catch (e) {
      // Fallback if color extraction fails
      setState(() {
        dominantColor = Colors.white;
        _extractedColors = [];
        imageVisible = true;
      });
    }
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

    html.Url.revokeObjectUrl(url);
  } else {
    print('Failed to download image.');
  }
}

bool isDarkColor(Color color) {
  return color.computeLuminance() < 0.5;
}
