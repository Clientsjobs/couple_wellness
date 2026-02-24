import 'dart:async';
import 'package:couple_wellness/screens/onboarding/onboarding_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Initialize Animation Controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 1500,
      ), // Adjust speed of appearance
    );

    // 2. Define Fade-in Animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    // 3. Start Animation
    _controller.forward();

    // 4. Navigate to next screen after delay
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      // Replace with your home route
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnboardingScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Clean white background
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Your Logo from the screenshot
              // Image.asset(
              //   'assets/images/logo.png', // Ensure logo is added to assets
              //   width: 120,
              // ),
              const SizedBox(height: 30),

              // App Title
              const Text(
                "Together",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4A148C), // Deep Purple from image
                  letterSpacing: 1.2,
                ),
              ),

              const SizedBox(height: 10),

              // Slogan
              const Text(
                "Wellness for couples",
                style: TextStyle(
                  fontSize: 18,
                  color: Color(0xFF9575CD), // Lighter purple/lavender
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
