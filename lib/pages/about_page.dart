import 'package:flutter/material.dart';
import 'package:art_gen/pages/home_page.dart';
import 'package:url_launcher/url_launcher.dart';

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
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,

        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //github button
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  final Uri githubURL = Uri.parse(
                    'https://github.com/jergusnadasky/RandArt',
                  );
                  if (await canLaunchUrl(githubURL)) {
                    await launchUrl(
                      githubURL,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    print('Could not launch $githubURL');
                  }
                },
                child:
                    isDarkColor(bgColor)
                        ? Image.asset(
                          height: 32,
                          width: 32,
                          "assets/GitHub_Invertocat_Light.png",
                        )
                        : Image.asset(
                          height: 32,
                          width: 32,
                          "assets/GitHub_Invertocat_Dark.png",
                        ),
              ),
            ),
            SizedBox(width: 24),
            //linkedInButton
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () async {
                  final Uri linkedInURL = Uri.parse(
                    'https://www.linkedin.com/in/jergusnadasky',
                  );
                  if (await canLaunchUrl(linkedInURL)) {
                    await launchUrl(
                      linkedInURL,
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    print('Could not launch $linkedInURL');
                  }
                },
                child:
                    isDarkColor(bgColor)
                        ? Image.asset(
                          height: 32,
                          width: 32,
                          "assets/InBug-White.png",
                        )
                        : Image.asset(
                          height: 32,
                          width: 32,
                          "assets/InBug-Black.png",
                        ),
              ),
            ),
            SizedBox(width: 16),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  launchUrl(Uri.parse('mailto:jergusko23@gmail.com'));
                },
                child:
                    isDarkColor(bgColor)
                        ? Icon(size: 32, Icons.email, color: Colors.white)
                        : Icon(size: 32, Icons.email, color: Colors.black),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: bgColor,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: bgColor,
        foregroundColor: textColor,
        title: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Center(
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
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
        ),
      ),
      body: Center(
        child: DefaultTextStyle(
          style: TextStyle(
            fontFamily: 'DIN',
            color: isDarkColor(bgColor) ? Colors.white : Colors.black,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 16),
              Text(
                'About RandArt',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'RandArt is a minimalist art browser that lets you discover random artworks from major public museum collections. '
                'It’s meant to be fast, simple, and beautiful—every visit reveals something new.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Art Sources:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('https://www.artic.edu/'));
                  },
                  child: Text(
                    'Art Institute of Chicago',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    launchUrl(Uri.parse('https://www.metmuseum.org/'));
                  },
                  child: Text(
                    'The Metropolitan Museum of Art',
                    style: TextStyle(
                      fontSize: 16,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Built With:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'This app is built using Flutter Web and deployed on Firebase Hosting. '
                'It fetches and processes artwork data using REST API calls, showcasing real-time interaction with public art collections.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Project Goals:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'This project helped me practice API integration, dynamic UI design, and asynchronous data handling in Flutter. '
                'I’m continuously learning and improving the app.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 16),
              Text(
                'Feedback & Features:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 8),
              Text(
                'Have ideas for features or spotted a bug? I\'m always open to feedback — feel free to reach out!',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 50),
              Text(
                'Created by Jergus Nadasky',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
