//TODO fix and implement appbar
// import 'package:flutter/material.dart';

// class Appbar extends StatefulWidget {
//   const Appbar({super.key});

//   Color? bgColor;
//   Color? textColor;

//   @override
//   State<Appbar> createState() => _AppbarState();
// }

// class _AppbarState extends State<Appbar> {
//   @override
//   Widget build(BuildContext context) {
//     return PreferredSize(
//         preferredSize: const Size.fromHeight(kToolbarHeight),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 600), // Reduced from 800ms
//           curve: Curves.easeOut,
//           color: bgColor,
//           child: AppBar(
//             automaticallyImplyLeading: false,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             foregroundColor: textColor,
//             title: GestureDetector(
//               child: Center(
//                 child: SizedBox(
//                   height: 250,
//                   child:
//                       isDarkColor(bgColor)
//                           ? Image.asset(
//                             "assets/logo_white.png",
//                             fit: BoxFit.contain,
//                           )
//                           : Image.asset(
//                             "assets/logo_black.png",
//                             fit: BoxFit.contain,
//                           ),
//                 ),
//               ),
//             ),
//             actions: [
//               IconButton(
//                 icon: Icon(Icons.pages, color: textColor),
//                 onPressed:
//                     () => Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder:
//                             (context, animation1, animation2) => AboutPage(
//                               bgColor: dominantColor ?? Colors.white,
//                               title: widget.title,
//                             ),
//                         transitionDuration: Duration.zero,
//                         reverseTransitionDuration: Duration.zero,
//                       ),
//                     ),
//               ),
//             ],
//           ),
//         ),
//       ),
//   }
// }