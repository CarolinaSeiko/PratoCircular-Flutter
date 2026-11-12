import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/app_logo.dart';

class SplashPage extends StatefulWidget {
  final VoidCallback onFinish;

  const SplashPage({
    super.key,
    required this.onFinish,
  });

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), widget.onFinish);
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF123526),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLogo(size: 108),
            SizedBox(height: 20),
            Text(
              'Prato Circular',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Doação que alimenta. Impacto que permanece.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFDDEBD8),
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
