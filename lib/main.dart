import 'package:flutter/material.dart';
import 'package:art_gen/pages/home_page.dart';
import 'package:art_gen/pages/animated_title_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "RandArt",

      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'DIN',
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TitleScreen(),
      routes: {'/homepage': (context) => ArtHomePage("RandArt")},
    );
  }
}
