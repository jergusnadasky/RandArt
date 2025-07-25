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
    _typewriterTimer =
        Timer.periodic(const Duration(milliseconds: 200), (timer) {
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
    const scrambleDuration = Duration(milliseconds: 1500);
    final startTime = DateTime.now();

    _scrambleTimer =
        Timer.periodic(const Duration(milliseconds: 20), (timer) {
      final now = DateTime.now();
      final elapsed = now.difference(startTime);

      if (elapsed >= scrambleDuration) {
        setState(() {
          _displayed = _text;
        });
        timer.cancel();
      } else {
        setState(() {
          _displayed = _generateRandomString(_text.length);
        });
      }
    });

    // Start transition halfway through the scramble
    Future.delayed(const Duration(milliseconds: 700), () {
      Navigator.of(context).pushReplacement(_createRoute());
    });
  }

  String _generateRandomString(int length) {
    const chars = '0123456789!@#%^&*()';
    return List.generate(
      length,
      (index) => chars[_rand.nextInt(chars.length)],
    ).join();
  }

  Route _createRoute() {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 1500),
      pageBuilder: (context, animation, secondaryAnimation) =>
          const ArtHomePage("RandArt"),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final currentPageSlide =
            Tween<Offset>(begin: Offset.zero, end: const Offset(-1.0, 0.0))
                .animate(animation);
        final newPageSlide =
            Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
                .animate(animation);

        return Stack(
          children: [
            SlideTransition(position: newPageSlide, child: child),
            SlideTransition(
              position: currentPageSlide,
              child: _buildTitleScreen(),
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
            child: Container(
              width: 2,
              color: Colors.black,
            ),
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
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                    fontFamily: 'DIN',
                  ),
                ),
                const SizedBox(width: 4),
                // Cursor block
                Container(
                  width: 8,
                  height: 24,
                  color: Colors.black,
                ),
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
