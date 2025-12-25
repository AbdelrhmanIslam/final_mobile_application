import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Check if Dark Mode is active
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // Light: Purple BG | Dark: Dark BG
      backgroundColor: isDark ? LazaColors.darkBg : LazaColors.primary,
      body: Center(
        child: Image.asset(
          'assets/icons/laza_logo.png',
          width: 150,
          // Light: White Logo | Dark: Purple Logo
          color: isDark ? LazaColors.primary : Colors.white,
        ),
      ),
    );
  }
}