import 'dart:ui';

import 'package:art_gen/util/artwork.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showMobileArtworkOverlay(
  BuildContext context,
  Artwork artwork,
  Color? backgroundColor,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Artwork Details',
    barrierColor: Colors.black.withOpacity(0.7),
    transitionDuration: const Duration(milliseconds: 200),
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
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.92,
                            height: MediaQuery.of(context).size.height * 0.85,
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: (backgroundColor ?? Colors.white)
                                  .withOpacity(0.25),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () {},
                              child: Column(
                                children: [
                                  // Image section - fixed height
                                  Container(
                                    height: MediaQuery.of(context).size.height * 0.45,
                                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(16),
                                      child: CachedNetworkImage(
                                        imageUrl: artwork.imageUrl,
                                        fit: BoxFit.contain,
                                        width: double.infinity,
                                        fadeInDuration: const Duration(
                                          milliseconds: 200,
                                        ),
                                        fadeOutDuration: const Duration(
                                          milliseconds: 100,
                                        ),
                                        imageBuilder: (context, imageProvider) =>
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              child: Image(
                                                image: imageProvider,
                                                fit: BoxFit.contain,
                                                filterQuality: FilterQuality.high,
                                              ),
                                            ),
                                        placeholder: (context, url) => Container(
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                            color: (backgroundColor ??
                                                    Colors.white)
                                                .withOpacity(0.2),
                                          ),
                                          child: const Center(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                CircularProgressIndicator(
                                                  valueColor:
                                                      AlwaysStoppedAnimation<Color>(
                                                    Colors.white70,
                                                  ),
                                                ),
                                                SizedBox(height: 12),
                                                Text(
                                                  'Loading artwork...',
                                                  style: TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(16),
                                                color: Colors.white
                                                    .withOpacity(0.1),
                                              ),
                                              child: const Center(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.error_outline,
                                                      size: 40,
                                                      color: Colors.white70,
                                                    ),
                                                    SizedBox(height: 6),
                                                    Text(
                                                      'Failed to load image',
                                                      style: TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                  
                                  // Divider line
                                  Container(
                                    height: 1,
                                    margin: const EdgeInsets.symmetric(horizontal: 20),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.transparent,
                                          Colors.white.withOpacity(0.3),
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                  ),
                                  
                                  // Text content section - scrollable
                                  Expanded(
                                    child: SingleChildScrollView(
                                      padding: const EdgeInsets.all(20),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          // Title
                                          InkWell(
                                            onTap: () async {
                                              final Uri url = Uri.parse(artwork.link);
                                              if (await canLaunchUrl(url)) {
                                                await launchUrl(
                                                  url,
                                                  mode: LaunchMode.externalApplication,
                                                );
                                              } else {
                                                print('Could not launch $url');
                                              }
                                            },
                                            child: Text(
                                              artwork.title,
                                              style: const TextStyle(
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                decoration: TextDecoration.underline,
                                                decorationColor: Colors.white70,
                                                height: 1.3,
                                              ),
                                            ),
                                          ),
                                          
                                          const SizedBox(height: 12),
                                          
                                          // Artist
                                          Text(
                                            artwork.artist,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.white70,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          
                                          // Date
                                          if (artwork.date != '') ...[
                                            const SizedBox(height: 8),
                                            Text(
                                              artwork.date,
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                          
                                          // Description
                                          if (artwork.description != '') ...[
                                            const SizedBox(height: 20),
                                            const Text(
                                              'About this artwork:',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Colors.white70,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              artwork.description,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.white70,
                                                height: 1.4,
                                              ),
                                            ),
                                          ],
                                          
                                          const SizedBox(height: 24),
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
                      top: 32,
                      right: 32,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
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