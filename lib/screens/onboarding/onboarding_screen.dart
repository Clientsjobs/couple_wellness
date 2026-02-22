import 'package:couple_wellness/constants/app_colors.dart';
import 'package:couple_wellness/screens/auth/sign_in_screen.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardingData> _screens = [
    OnboardingData(
      title: "Strengthen Your Bond",
      subtitle:
          "Build deeper connection through mindful communication and shared wellness goals.",
      icon: Icons.favorite_rounded, // Custom logo logic can go here
      color: AppColors.onboarding1,
    ),
    OnboardingData(
      title: "Health & Wellness Tools",
      subtitle:
          "Track pregnancy, ovulation, and intimate health with science-backed calculators.",
      icon: Icons.timeline_rounded,
      color: AppColors.onboarding2,
    ),
    OnboardingData(
      title: "AI-Powered Guidance",
      subtitle:
          "Get personalized, respectful advice on relationships and intimacy.",
      icon: Icons.auto_awesome_rounded,
      color: AppColors.onboarding3,
      isLast: true,
    ),
  ];

  void _onNextPage() {
    if (_currentIndex < _screens.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    } else {
      // Navigate to Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LogInScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _screens[_currentIndex].color,
        child: SafeArea(
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LogInScreen()),
                  ),
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemCount: _screens.length,
                  itemBuilder: (context, index) {
                    return OnboardingContent(data: _screens[index]);
                  },
                ),
              ),

              // Bottom Section: Indicator & Button
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    // Dot Indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _screens.length,
                        (index) => _buildDot(index),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _onNextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: _screens[_currentIndex].color,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentIndex == _screens.length - 1
                                  ? "Get Started"
                                  : "Continue",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right_rounded, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentIndex == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white54,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final OnboardingData data;
  const OnboardingContent({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Container
          Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(32),
            ),
            child: Icon(data.icon, size: 80, color: Colors.white),
          ),
          const SizedBox(height: 60),
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            data.subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isLast;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.isLast = false,
  });
}
