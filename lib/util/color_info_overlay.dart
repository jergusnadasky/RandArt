import 'package:flutter/material.dart';

class ColorInfoOverlay extends StatelessWidget {
  final Color color;
  final String hex;
  final String rgb;
  final String hsl;

  const ColorInfoOverlay({
    super.key,
    required this.color,
    required this.hex,
    required this.rgb,
    required this.hsl,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [BoxShadow(blurRadius: 8, color: Colors.black26)],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.black),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("HEX: $hex"),
                Text("RGB: $rgb"),
                Text("HSL: $hsl"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
