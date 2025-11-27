// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart'; // or wherever your HomePage is

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Auto navigate to Home after 3 seconds
    Timer(const Duration(seconds: 6), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B4513), // Deep warm brown like your design
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Name
            const Text(
              'BanglaRead',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    offset: Offset(2, 2),
                    blurRadius: 8,
                    color: Colors.black45,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Book Stack Image
            Image.asset(
              'assets/images/image.jpg', // Use your exact image link
              width: 280,
              height: 380,
              fit: BoxFit.contain,            
            ),
            const SizedBox(height: 60),

            // Bengali Tagline
            const Text(
              'বাংলা সাহিত্যের ডিজিটাল রূপ',
              style: TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.w500,
                letterSpacing: 1.5,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'পড়ুন, ভালোবাসুন, শেয়ার করুন',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white70,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}