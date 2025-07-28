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
                child: isDarkColor(bgColor)
                    ? Image.asset(height: 32, width: 32, "GitHub_Invertocat_Light.png")
                    : Image.asset(height: 32, width: 32, "GitHub_Invertocat_Dark.png"),
              ),
            ),
            SizedBox(width: 24,),
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
                child: isDarkColor(bgColor)
                    ? Image.asset(height: 32, width: 32, "InBug-White.png")
                    : Image.asset(height: 32, width: 32, "InBug-Black.png"),
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
      body: Center(child: Column(children: [
          
          ],
        )),
    );
  }
}




//  child: Text(
//           'This app fetches random artworks and displays the title and artist.',
//           style: TextStyle(color: textColor, fontSize: 18, fontFamily: 'Akkurat'),
//           textAlign: TextAlign.center,
//         ),