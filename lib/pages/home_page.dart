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

//TODO fix image loading when image is too big. 

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
  bool _isLoadingArt = false;

  final randomNum = Random();

  List<ColorInfo> _extractedColors = [];
  int? _hoveredColorIndex;

  @override
  Widget build(BuildContext context) {
    return _isFirstLoad
        ? AnimatedOpacity(
          opacity: _scaffoldOpacity,
          duration: const Duration(milliseconds: 400), // Reduced from 800ms
          curve: Curves.easeOut, // Faster curve
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
          duration: const Duration(milliseconds: 600), // Reduced from 800ms
          curve: Curves.easeOut,
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
                          ? Image.asset(
                            "assets/logo_white.png",
                            fit: BoxFit.contain,
                          )
                          : Image.asset(
                            "assets/logo_black.png",
                            fit: BoxFit.contain,
                          ),
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
        duration: const Duration(milliseconds: 300), // Reduced from 400ms
        curve: Curves.easeOut,
        color: bgColor,
        child: Stack(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 600), // Reduced from 800ms
              curve: Curves.easeOut,
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
                              duration: const Duration(
                                milliseconds: 400,
                              ), // Reduced from 600ms
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxHeight: 350,
                                    ),
                                    child: MouseRegion(
                                      cursor: SystemMouseCursors.click,

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
                                            milliseconds:
                                                200, // Reduced from 300ms
                                          ),
                                          curve: Curves.easeOut,
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
                                                  milliseconds:
                                                      200, // Reduced from 400ms
                                                ),
                                                fadeOutDuration: const Duration(
                                                  milliseconds:
                                                      100, // Reduced from 200ms
                                                ),
                                                // Add memory cache settings for better performance
                                                memCacheWidth:
                                                    800, // Limit memory usage
                                                memCacheHeight: 800,
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
                                      width: 200,
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
                          // Show loading indicator when no image is loaded yet
                          if (imageURL.isEmpty && _isLoadingArt)
                            Container(
                              height: 350,
                              width: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.transparent,
                              ),
                              child: const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      color: Colors.black,
                                    ),
                                    SizedBox(height: 16),
                                  ],
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
                  child: GestureDetector(
                    child: TextButton(
                      style: const ButtonStyle(
                        overlayColor: WidgetStatePropertyAll(
                          Colors.transparent,
                        ),
                      ),
                      onPressed:
                          _isLoadingArt
                              ? null
                              : () {
                                getRandomArt();
                              },
                      child: Text(
                        _isLoadingArt ? "LOADING..." : "EXPLORE ART",
                        style: TextStyle(
                          fontFamily: 'dots',
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
                    onPressed:
                        imageURL.isEmpty
                            ? null
                            : () {
                              downloadImageWeb(imageURL, artistName, title);
                            },
                    child: Text(
                      "DOWNLOAD",
                      style: TextStyle(
                        fontFamily: 'dots',
                        color:
                            imageURL.isEmpty
                                ? Colors.grey
                                : (isDarkColor(bgColor)
                                    ? Colors.white
                                    : Colors.black),
                        fontSize: 25,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_hoveredColorIndex != null)
              Positioned(
                left: _hoverPosition.dx + 10,
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
      _isLoadingArt = false;
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
      barrierColor: Colors.black.withOpacity(0.7),
      transitionDuration: const Duration(
        milliseconds: 200,
      ), // Reduced from 300ms
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
                              width: MediaQuery.of(context).size.width * 0.9,
                              height: MediaQuery.of(context).size.height * 0.8,
                              padding: const EdgeInsets.all(32),
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
                                    Expanded(
                                      flex: 3,
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
                                              milliseconds:
                                                  200, // Reduced from 300ms
                                            ),
                                            fadeOutDuration: const Duration(
                                              milliseconds:
                                                  100, // Reduced from 150ms
                                            ),
                                            imageBuilder:
                                                (context, imageProvider) =>
                                                    ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            16,
                                                          ),
                                                      child: Image(
                                                        image: imageProvider,
                                                        fit: BoxFit.contain,
                                                        filterQuality:
                                                            FilterQuality.high,
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
                                    const SizedBox(width: 32),
                                    Expanded(
                                      flex: 2,
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
                                                  fontSize: 32,
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
                                            const SizedBox(height: 16),

                                            Text(
                                              artwork.artist,
                                              style: const TextStyle(
                                                fontSize: 24,
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
                                                  height: 1.5,
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

                      Positioned(
                        top: 24,
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
    // Start loading art immediately
    getRandomArt();

    // Show UI after a very short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _scaffoldOpacity = 1.0;
          _isFirstLoad = false;
        });
      }
    });
  }

  Future<void> getRandomArt() async {
    if (_isLoadingArt) return; // Prevent multiple simultaneous loads

    setState(() {
      _isLoadingArt = true;
      imageVisible = false;
    });

    // Only fade out if we already have an image loaded
    if (imageURL.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final int apiChoice = randomNum.nextInt(2);
    final ChicagoArtService chicagoService = ChicagoArtService();
    Artwork? artwork;

    try {
      if (apiChoice == 0) {
        artwork = await chicagoService.getRandomArtwork();
      } else {
        artwork = await MetArtService().getRandomArtwork();
      }

      if (artwork == null) {
        _setError("Failed to fetch artwork.");
        return;
      }

      // Set artwork data immediately - this allows image to start loading
      setState(() {
        _description = artwork!.description;
        artworkLink = artwork.link;
        title = artwork.title;
        artistName = artwork.artist;
        imageURL = artwork.imageUrl;
        _date = artwork.date;
        dominantColor = Colors.grey.shade300; // Temporary color
        imageVisible = true; // Show immediately
        _isLoadingArt = false;
      });

      // Process colors in the background without blocking UI
      _processColorsInBackground(artwork.imageUrl);
    } catch (e) {
      _setError("Failed to fetch artwork.");
    }
  }

  // Process colors asynchronously without blocking the UI
  void _processColorsInBackground(String imageUrl) async {
    try {
      final smallImageProvider = ResizeImage(
        NetworkImage(imageUrl),
        width: 100, // Even smaller for faster processing
        height: 100,
      );

      // Process colors with a timeout to prevent hanging
      final colorFutures = await Future.wait([
        PaletteGenerator.fromImageProvider(
          smallImageProvider,
          size: const Size(100, 100),
        ).timeout(const Duration(seconds: 3)),
        extractColorsFromImage(
          smallImageProvider,
        ).timeout(const Duration(seconds: 3)),
      ]);

      final palette = colorFutures[0] as PaletteGenerator;
      final extractedColors = colorFutures[1] as List<ColorInfo>;

      // Only update if we're still showing the same image
      if (mounted && imageURL == imageUrl) {
        setState(() {
          dominantColor = palette.dominantColor?.color ?? Colors.white;
          _extractedColors = extractedColors;
        });
      }
    } catch (e) {
      // Silently fail color extraction - the image still works
      if (mounted && imageURL == imageUrl) {
        setState(() {
          dominantColor = Colors.white;
          _extractedColors = [];
        });
      }
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
