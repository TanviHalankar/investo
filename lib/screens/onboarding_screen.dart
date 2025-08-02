import 'package:flutter/material.dart';
import 'package:concentric_transition/concentric_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardingPageData(
        title: "Welcome to StockMaster",
        subtitle: "Learn trading the smart way.",
        image: "assets/images/stock1.png", // Replace with actual image asset
        bgColor: const Color(0xFF0F4C75),
      ),
      _OnboardingPageData(
        title: "Trade with Simulations",
        subtitle: "No real money, just real learning!",
        image: "assets/images/wallet.png",
        bgColor: const Color(0xFF3282B8),
      ),
      _OnboardingPageData(
        title: "AI Insights for You",
        subtitle: "Smart predictions tailored just for you.",
        image: "assets/images/ai.png",
        bgColor: const Color(0xFF1B262C),
      ),
    ];

    return Scaffold(
      body: ConcentricPageView(
        colors: pages.map((p) => p.bgColor).toList(),
        itemCount: pages.length,
        onFinish: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_shown', true);
          Navigator.pushReplacementNamed(context, '/login');
        },
        itemBuilder: (int index) {
          final page = pages[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(page.image, height: 200),
                const SizedBox(height: 40),
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _OnboardingPageData {
  final String title;
  final String subtitle;
  final String image; // now using image path instead of Icon
  final Color bgColor;

  _OnboardingPageData({
    required this.title,
    required this.subtitle,
    required this.image,
    required this.bgColor,
  });
}
