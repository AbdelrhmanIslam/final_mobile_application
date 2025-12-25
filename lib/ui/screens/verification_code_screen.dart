import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async'; // Required for Timer
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/app_colors.dart';
import 'new_password_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  const VerificationCodeScreen({super.key});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  int _secondsRemaining = 20;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 20;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  Future<void> _resendEmail() async {
    // For MVP, we assume the email is the one currently passed or typed.
    // Since we didn't pass the email variable to this screen in the simple flow,
    // we will just restart the timer to simulate the action for the UI.
    // In a full app, you would pass 'email' to this widget's constructor.

    _startTimer();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resent Verification Email")),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Theme Colors
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    // Format time 00:XX
    String timeStr = "00:${_secondsRemaining.toString().padLeft(2, '0')}";

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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Verification Code",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),

                    Image.asset(
                      'assets/images/forgot_password_cloud.png',
                      height: 150,
                      fit: BoxFit.contain,
                      errorBuilder: (c,e,s) => const Icon(Icons.cloud, size: 100, color: LazaColors.primary),
                    ),
                    const SizedBox(height: 50),

                    // Input Boxes (Visual Only for MVP)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildCodeBox(context),
                        _buildCodeBox(context),
                        _buildCodeBox(context),
                        _buildCodeBox(context),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // TIMER / RESEND LOGIC
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (!_canResend)
                          Text(
                              timeStr,
                              style: TextStyle(color: textColor, fontWeight: FontWeight.bold)
                          ),
                        if (!_canResend)
                          const Text(
                              " resend confirmation code.",
                              style: TextStyle(color: LazaColors.grey, fontSize: 13)
                          ),

                        // Show RESEND button if timer finished
                        if (_canResend)
                          TextButton(
                            onPressed: _resendEmail,
                            child: const Text(
                              "Resend Code",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.all(20),
              width: double.infinity,
              height: 90,
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to New Password (Simulation)
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const NewPasswordScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: LazaColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Confirm Code", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w500)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCodeBox(BuildContext context) {
    final boxColor = Theme.of(context).cardColor;
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;

    return Container(
      width: 70,
      height: 80,
      decoration: BoxDecoration(
        color: boxColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: LazaColors.grey.withOpacity(0.2)),
      ),
      child: Center(
        child: TextFormField(
          onChanged: (value) {
            if (value.length == 1) FocusScope.of(context).nextFocus();
          },
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: textColor),
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: [
            LengthLimitingTextInputFormatter(1),
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ),
    );
  }
}