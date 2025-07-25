import 'package:flutter/material.dart';
import 'package:art_gen/pages/home_page.dart';

//TODO add about page stuff
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
              height: 250,
              child:
                  isDarkColor(bgColor)
                      ? Image.asset("logo_white.png", fit: BoxFit.contain)
                      : Image.asset("logo_black.png", fit: BoxFit.contain),
            ),
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Text(
              "This is DIN #1234567890",
              style: TextStyle(fontFamily: 'DIN', fontWeight: FontWeight.w400),
            ),
            Text(
              "This is DIN BOLD #1234567890",
              style: TextStyle(fontFamily: 'DIN', fontWeight: FontWeight.w700),
            ),
            Text("This is Akkurat #1234567890", style: TextStyle(fontFamily: 'Akkurat')),
            Text(
              "This is Akkurat BOLD #1234567890",
              style: TextStyle(
                fontFamily: 'Akkurat',
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}




//  child: Text(
//           'This app fetches random artworks and displays the title and artist.',
//           style: TextStyle(color: textColor, fontSize: 18, fontFamily: 'Akkurat'),
//           textAlign: TextAlign.center,
//         ),