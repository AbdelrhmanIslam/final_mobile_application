import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'get_started_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _selectedGender = 2;

  @override
  Widget build(BuildContext context) {
    // 1. Check Theme
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    // 2. Determine Background Colors
    final Color mainBackground = isDark ? LazaColors.darkBg : LazaColors.primary;

    // 3. Determine Button Colors (Unselected)
    // If Dark Mode -> Dark Button. If Light Mode -> Light Grey Button.
    final Color unselectedBtnColor = isDark ? const Color(0xFF1D1E20) : LazaColors.lightBg;

    return Scaffold(
      backgroundColor: mainBackground,
      body: Stack(
        children: [
          // Background Image
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: BoxDecoration(
              color: mainBackground,
              image: const DecorationImage(
                image: AssetImage('assets/images/onboarding_man.png'),
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
              ),
            ),
          ),

          // Gradient Overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  mainBackground.withOpacity(0.0),
                  mainBackground.withOpacity(1.0),
                ],
                stops: const [0.6, 0.9],
              ),
            ),
          ),

          // Bottom Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(15),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
              decoration: BoxDecoration(
                color: cardColor, // Dark in Dark Mode
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Look Good, Feel Good",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Create your individual & unique style and look amazing everyday.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: LazaColors.grey,
                    ),
                  ),
                  const SizedBox(height: 25),

                  // Gender Buttons
                  Row(
                    children: [
                      // MEN BUTTON
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedGender = 1);
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const GetStartedScreen()));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            // Dynamic Background Color
                            backgroundColor: _selectedGender == 1 ? LazaColors.primary : unselectedBtnColor,
                            foregroundColor: _selectedGender == 1 ? Colors.white : LazaColors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text("Men"),
                        ),
                      ),
                      const SizedBox(width: 15),

                      // WOMEN BUTTON
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _selectedGender = 2);
                            Future.delayed(const Duration(milliseconds: 200), () {
                              if (mounted) Navigator.push(context, MaterialPageRoute(builder: (context) => const GetStartedScreen()));
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            // Dynamic Background Color
                            backgroundColor: _selectedGender == 2 ? LazaColors.primary : unselectedBtnColor,
                            foregroundColor: _selectedGender == 2 ? Colors.white : LazaColors.grey,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          child: const Text("Women"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const GetStartedScreen())),
                    child: const Text(
                      "Skip",
                      style: TextStyle(color: LazaColors.grey, fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}