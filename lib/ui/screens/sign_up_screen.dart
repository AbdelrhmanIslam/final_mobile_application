import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/auth_service.dart'; // Import the service
import 'home_screen.dart'; // Navigate here on success

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // 1. Controllers capture text input
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false; // To show a loading spinner
  final AuthService _authService = AuthService(); // Instance of our helper

  // 2. Dispose controllers when screen is closed (Best Practice)
  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // Function to handle the button press
  void _handleSignUp() async {
    // Basic validation
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    // Call Firebase Email Sign Up (NOT Google)
    String? error = await _authService.signUp(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      username: _usernameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (error == null) {
      // Success! Go to Home Screen
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen())
        );
      }
    } else {
      // Show Error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. GET DYNAMIC COLORS
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return Scaffold(
      backgroundColor: bgColor, // <--- ADAPTS TO DARK MODE
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor), // <--- ADAPTS ICON COLOR
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Text(
                        "Sign Up",
                        style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: textColor // <--- ADAPTS TEXT COLOR
                        )
                    ),
                    const SizedBox(height: 40),

                    // Username
                    TextFormField(
                      controller: _usernameController,
                      style: TextStyle(color: textColor), // <--- TYPED TEXT COLOR
                      decoration: const InputDecoration(labelText: "Username"),
                    ),
                    const SizedBox(height: 20),

                    // Password
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: TextStyle(color: textColor), // <--- TYPED TEXT COLOR
                      decoration: const InputDecoration(labelText: "Password"),
                    ),
                    const SizedBox(height: 20),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      style: TextStyle(color: textColor), // <--- TYPED TEXT COLOR
                      decoration: const InputDecoration(labelText: "Email Address"),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ],
                ),
              ),
            ),

            // Bottom Button
            Container(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              width: double.infinity,
              height: 75,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp, // Disable if loading
                style: ElevatedButton.styleFrom(
                  backgroundColor: LazaColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}