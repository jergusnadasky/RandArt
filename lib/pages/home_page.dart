import 'dart:math';
import 'package:art_gen/services/art_generator.dart';
import 'package:art_gen/services/color_service.dart';
import 'package:art_gen/util/image_downloader.dart';
import 'package:art_gen/util/is_dark_color.dart';
import 'package:art_gen/util/is_mobile.dart';
import 'package:art_gen/widgets/appbar.dart';
import 'package:art_gen/widgets/art_overlay_mobile.dart';
import 'package:flutter/services.dart';
import 'package:art_gen/pages/about_page.dart';
import 'package:art_gen/services/spectrum_creator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:after_layout/after_layout.dart';

import 'package:art_gen/widgets/art_overlay_web.dart';

import 'package:art_gen/util/artwork.dart';

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
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOut,
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
      appBar: CustomAppBar(
        bgColor: bgColor,
        textColor: textColor,
        dominantColor: dominantColor,
        title: widget.title,
        customWidget: IconButton(
          icon: Icon(Icons.pages, color: textColor),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder:
                    (context, animation1, animation2) => AboutPage(
                      bgColor: dominantColor ?? Colors.white,
                      title: title,
                    ),
                transitionDuration: Duration.zero,
                reverseTransitionDuration: Duration.zero,
              ),
            );
          },
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshArtwork,
        color: textColor,
        backgroundColor: bgColor.withOpacity(0.9),
        strokeWidth: 2.5,
        displacement: 60.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          color: bgColor,
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                color: overlay,
              ),
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - kToolbarHeight,
                  child: Column(
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
                                    ),
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
                                                if (isMobile()) {
                                                  showMobileArtworkOverlay(
                                                    context,
                                                    currentArtwork,
                                                    dominantColor,
                                                  );
                                                } else {
                                                  // Show web overlay
                                                  showWebArtworkOverlay(
                                                    context,
                                                    currentArtwork,
                                                    dominantColor,
                                                  );
                                                }
                                              },
                                              child: AnimatedScale(
                                                scale: _hovering ? 1.1 : 1.0,
                                                duration: const Duration(
                                                  milliseconds: 200,
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
                                                        milliseconds: 200,
                                                      ),
                                                      fadeOutDuration: const Duration(
                                                        milliseconds: 100,
                                                      ),
                                                      memCacheWidth: 800,
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
                ),
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
      ),
    );
  }

  // New refresh method for pull-to-refresh
  Future<void> _refreshArtwork() async {
    try {
      await getRandomArt();

    } catch (e) {
      // Handle any errors during refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load new artwork'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
          ),
        );
      }
    }
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
    if (_isLoadingArt) return;

    setState(() {
      _isLoadingArt = true;
      imageVisible = false;
    });

    // Optional fade-out if image already exists
    if (imageURL.isNotEmpty) {
      await Future.delayed(const Duration(milliseconds: 100));
    }

    final artwork = await ArtLoaderService.fetchRandomArtwork();

    if (artwork == null) {
      _setError("Failed to fetch artwork.");
      return;
    }

    // Set new artwork state
    setState(() {
      _description = artwork.description;
      artworkLink = artwork.link;
      title = artwork.title;
      artistName = artwork.artist;
      imageURL = artwork.imageUrl;
      _date = artwork.date;
      dominantColor = Colors.grey.shade300;
      imageVisible = true;
      _isLoadingArt = false;
    });

    // Extract background color (async)
    _processColorsInBackground(artwork.imageUrl);
  }

  // Process colors asynchronously without blocking the UI
  void _processColorsInBackground(String imageUrl) async {
    final result = await ColorService.processImageColors(imageUrl);

    if (!mounted || imageURL != imageUrl) return;

    setState(() {
      dominantColor = result['dominantColor'] as Color;
      _extractedColors = result['extractedColors'] as List<ColorInfo>;
    });
  }
}