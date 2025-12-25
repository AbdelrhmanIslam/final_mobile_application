import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import 'home_screen.dart';
import 'sidebar_screens.dart'; // Import OrdersScreen

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;
    final cardColor = Theme.of(context).cardColor;

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/images/Mask Group.png', // Ensure this file exists
              fit: BoxFit.cover,
              errorBuilder: (c,e,s) => const SizedBox(),
            ),
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(color: cardColor, shape: BoxShape.circle),
                    padding: const EdgeInsets.all(20),
                    child: Image.asset(
                      'assets/images/order_success.png',
                      height: 200,
                      errorBuilder: (c, e, s) => const Icon(Icons.check_circle, size: 100, color: LazaColors.primary),
                    ),
                  ),
                  const SizedBox(height: 40),

                  Text("Order Confirmed!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
                  const SizedBox(height: 10),
                  const Text("Your order has been confirmed, we will send you confirmation email shortly.", textAlign: TextAlign.center, style: TextStyle(color: LazaColors.grey, fontSize: 15)),
                  const SizedBox(height: 40),

                  // GO TO ORDERS BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Orders Screen
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const OrdersScreen()),
                        );
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: cardColor, elevation: 0),
                      child: const Text("Go to Orders", style: TextStyle(color: LazaColors.grey, fontSize: 17)),
                    ),
                  ),
                  const SizedBox(height: 15),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: LazaColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text("Continue Shopping", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
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