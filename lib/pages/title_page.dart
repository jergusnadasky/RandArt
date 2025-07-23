import 'dart:async';
import 'package:flutter/material.dart';

class TitlePage extends StatefulWidget {
  const TitlePage({super.key});

  @override
  State<TitlePage> createState() => _TitlePageState();
}

class _TitlePageState extends State<TitlePage> {
  bool _showBlackLogo = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      setState(() {
        _showBlackLogo = !_showBlackLogo;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pushReplacementNamed(context, '/homepage');
          },
          child: Image.asset(
            _showBlackLogo ? "logo_black.png" : "logo_white.png",
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
