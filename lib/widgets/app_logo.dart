import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;

  const AppLogo({
    super.key,
    this.size = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: Color(0xFFDDEBD8),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.volunteer_activism,
        size: size * 0.55,
        color: const Color(0xFF123526),
      ),
    );
  }
}
