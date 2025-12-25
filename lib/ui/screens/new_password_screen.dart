import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'login_screen.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
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
                        "New Password",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Password Input
                    Text("Password", style: TextStyle(color: LazaColors.grey, fontSize: 13)),
                    TextFormField(
                      obscureText: _obscureText,
                      style: TextStyle(color: textColor), // Visible Text
                      decoration: const InputDecoration(
                        hintText: "••••••••",
                        hintStyle: TextStyle(color: LazaColors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: LazaColors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: LazaColors.primary)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Confirm Password
                    Text("Confirm Password", style: TextStyle(color: LazaColors.grey, fontSize: 13)),
                    TextFormField(
                      obscureText: _obscureText,
                      style: TextStyle(color: textColor), // Visible Text
                      decoration: const InputDecoration(
                        hintText: "••••••••",
                        hintStyle: TextStyle(color: LazaColors.grey),
                        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: LazaColors.grey)),
                        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: LazaColors.primary)),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Center(
                      child: Text(
                        "Please write your new password.",
                        style: TextStyle(color: LazaColors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Reset Button
            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: 90,
              child: ElevatedButton(
                onPressed: () {
                  // Simulate Success and go to Login
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                        (route) => false,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Password Reset Successfully!")),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LazaColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Reset Password", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}