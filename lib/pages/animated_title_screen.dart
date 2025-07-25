import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:art_gen/pages/home_page.dart';

//TODO fix randart ghost text

class TitleScreen extends StatefulWidget {
  const TitleScreen({super.key});

  @override
  State<TitleScreen> createState() => _TitleScreenState();
}

class _TitleScreenState extends State<TitleScreen> {
  final String _text = 'randart';
  String _displayed = '';
  int _currentIndex = 0;
  Timer? _typewriterTimer;
  Timer? _scrambleTimer;
  final Random _rand = Random();

  @override
  void initState() {
    super.initState();
    _startTypewriter();
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 100), (
      timer,
    ) {
      if (_currentIndex < _text.length) {
        setState(() {
          _displayed += _text[_currentIndex];
          _currentIndex++;
        });
      } else {
        timer.cancel();
        _startScramble();
      }
    });
  }

  void _startScramble() {
    const scrambleDuration = Duration(milliseconds: 2000);
    final startTime = DateTime.now();

    _scrambleTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      // Check if widget is still mounted before updating state
      if (!mounted) {
        timer.cancel();
        return;
      }

      final now = DateTime.now();
      final elapsed = now.difference(startTime);

      if (elapsed >= scrambleDuration) {
        setState(() {
          _displayed = _text;
        });
        timer.cancel();
      } else {
        setState(() {
          final fixedPart = _text.substring(0, 4); // "rand"
          final scramblePart = _generateRandomString(3); // scramble "art"
          _displayed = fixedPart + scramblePart;
        });
      }
    });

    // Start transition halfway through the scramble
    Future.delayed(const Duration(milliseconds: 800), () {
      // Stop scrambling animation before navigation
      _scrambleTimer?.cancel();
      setState(() {
        _displayed = _text; // Set final text
      });

      if (mounted) {
        Navigator.of(context).pushReplacement(_createRoute());
      }
    });
  }

  String _generateRandomString(int length) {
    const chars = '0123456789';
    return List.generate(
      length,
      (index) => chars[_rand.nextInt(chars.length)],
    ).join();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1200), // Slightly faster
      pageBuilder:
          (context, animation, secondaryAnimation) =>
              const ArtHomePage("RandArt"),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Only animate the title screen sliding left
        // The homepage (child) stays stationary at Offset.zero
        final titleScreenSlide = Tween<Offset>(
          begin: Offset.zero, // Title starts in place
          end: const Offset(-1.0, 0.0), // Title slides completely left
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOutCubic, // Smoother curve for the slide
          ),
        );

        // Optional: Add a subtle fade to the homepage as it's revealed
        final homepageFade = Tween<double>(
          begin: 0.3, // Start slightly faded
          end: 1.0, // End fully visible
        ).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(
              0.3,
              1.0,
              curve: Curves.easeOut,
            ), // Fade in during last 70%
          ),
        );

        return Stack(
          children: [
            // Homepage with subtle fade-in effect (optional)
            FadeTransition(opacity: homepageFade, child: child),
            // Title screen slides left over the homepage
            // Add AnimatedBuilder to control when title screen is visible
            AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                // Hide title screen completely when animation is done
                if (animation.value >= 0.95) {
                  return const SizedBox.shrink(); // Completely remove from widget tree
                }
                return SlideTransition(
                  position: titleScreenSlide,
                  child: _buildTitleScreen(),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildTitleScreen() {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Black vertical bar on right edge
          Align(
            alignment: Alignment.centerRight,
            child: Container(width: 2, color: Colors.black),
          ),
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _displayed,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w200,
                    color: Colors.black,
                    fontFamily: 'DIN',
                  ),
                ),
                const SizedBox(width: 4),
                // Cursor block
                Container(width: 8, height: 24, color: Colors.black),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _buildTitleScreen();
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _scrambleTimer?.cancel();
    super.dispose();
  }
}
