import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import 'sign_up_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Theme Colors for Dark/Light Mode
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    // Check if there is history to go back to
    final bool canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        // LOGIC FIX: Only show back button if we can actually go back
        leading: canPop
            ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: cardColor,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        )
            : null, // Hides the button if no history (like after Logout)
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            "Let’s Get Started",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const Spacer(),

          // Social Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // FACEBOOK
                _socialButton(
                  text: "Facebook",
                  color: const Color(0xFF4267B2),
                  icon: Icons.facebook,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming Soon"))),
                ),
                const SizedBox(height: 15),

                // TWITTER
                _socialButton(
                  text: "Twitter",
                  color: const Color(0xFF1DA1F2),
                  icon: Icons.alternate_email,
                  onPressed: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming Soon"))),
                ),
                const SizedBox(height: 15),

                // GOOGLE
                _socialButton(
                  text: "Google",
                  color: const Color(0xFFEA4335),
                  icon: Icons.g_mobiledata,
                  onPressed: () async {
                    String? error = await AuthService().signInWithGoogle();
                    if (context.mounted) {
                      if (error == null) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => const HomeScreen()),
                              (route) => false,
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
                      }
                    }
                  },
                ),
              ],
            ),
          ),

          const Spacer(),

          // Sign In Link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Already have an account? ", style: TextStyle(color: LazaColors.grey)),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: Text(
                  "Signin",
                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Bottom Primary Button
          Container(
            width: double.infinity,
            height: 75,
            child: ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
              style: ElevatedButton.styleFrom(
                backgroundColor: LazaColors.primary,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                elevation: 0,
              ),
              child: const Text(
                "Create an Account",
                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget
  Widget _socialButton({required String text, required Color color, required IconData icon, required VoidCallback onPressed}) {
    return Container(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(text, style: const TextStyle(color: Colors.white, fontSize: 17)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 0,
        ),
      ),
    );
  }
}