import 'package:flutter/material.dart';
import 'package:art_gen/pages/home_page.dart';

class AboutPage extends StatelessWidget {
  final Color bgColor;
  final String title;

  const AboutPage({super.key, required this.bgColor, required this.title});

  @override
  Widget build(BuildContext context) {
    final textColor =
        bgColor.computeLuminance() < 0.5 ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        foregroundColor: textColor,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
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
                () => Navigator.pop(context), // you're already on about page
          ),
        ],
      ),
      body: Center(
        child: Text(
          'This app fetches random artworks and displays the title and artist.',
          style: TextStyle(color: textColor, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}


