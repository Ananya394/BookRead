// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import '../main.dart';   // or wherever HomePage is

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6D4C41),   // your warm brown
      body: SafeArea(                 // ← THIS PREVENTS OVERFLOW
        child: Center(
          child: SingleChildScrollView(   // ← THIS MAKES IT WORK ON SMALL SCREENS
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
                  ),
                ),
                const SizedBox(height: 40),

                // Book image – responsive size
                Image.asset(
                  'assets/images/image.jpg',   // your local image
                  width: MediaQuery.of(context).size.width * 0.75,  // 75% of screen width
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 50),

                // Taglines
                const Text(
                  'বাংলা সাহিত্যের ডিজিটাল রূপ',
                  style: TextStyle(fontSize: 24, color: Colors.white, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                const Text(
                  'পড়ুন • ভালোবাসুন • শেয়ার করুন',
                  style: TextStyle(fontSize: 17, color: Colors.white70, fontStyle: FontStyle.italic),
                ),
                const SizedBox(height: 40),   // safe bottom space
              ],
            ),
          ),
        ),
      ),
    );
  }
}