import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase
import '../../core/app_colors.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _sendResetEmail() async {
    if (_emailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please enter your email")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      // ACTUAL FIREBASE LOGIC
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Reset link sent! Check your email."), backgroundColor: Colors.green)
        );
        // Continue flow to match Figma (Simulated)
        Navigator.push(context, MaterialPageRoute(builder: (context) => const VerificationCodeScreen()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red));
      }
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor, // Dynamic BG
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: cardColor,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Text(
                        "Forgot Password",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Cloud Image
                    Center(
                      child: Image.asset(
                        'assets/images/forgot_password_cloud.png',
                        height: 150,
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Icon(Icons.cloud_off, size: 100, color: LazaColors.grey),
                      ),
                    ),
                    const SizedBox(height: 50),

                    // Email Input
                    Text("Email Address", style: TextStyle(color: LazaColors.grey, fontSize: 13)),
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: textColor), // FIXES INVISIBLE TEXT
                      decoration: const InputDecoration(
                        hintText: "example@gmail.com",
                        hintStyle: TextStyle(color: LazaColors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: LazaColors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: LazaColors.primary)),
                      ),
                    ),

                    const SizedBox(height: 50),

                    const Text(
                      "Please write your email to receive a confirmation code to set a new password.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: LazaColors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: 90,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _sendResetEmail,
                style: ElevatedButton.styleFrom(
                  backgroundColor: LazaColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Confirm Mail", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}