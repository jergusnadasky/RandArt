import 'package:flutter/material.dart';
import 'package:art_gen/util/is_dark_color.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Color? bgColor;
  final Color? textColor;
  final Color? dominantColor;
  final String? title;
  final Widget customWidget;
  
  final dynamic onTapFunction;

  const CustomAppBar({
    super.key,
    this.bgColor,
    this.textColor,
    this.dominantColor,
    this.title,
    required this.customWidget,
    this.onTapFunction,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOut,
      color: bgColor,
      child: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: textColor,
        title: GestureDetector(
          onTap: onTapFunction,

          child: Center(
            child: SizedBox(
              height: 250,
              child:
                  (bgColor != null && isDarkColor(bgColor!))
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
        actions: [customWidget],
      ),
    );
  }
}
