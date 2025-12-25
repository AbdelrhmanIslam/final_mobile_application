import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/auth_service.dart';
import '../../core/theme_manager.dart';
import '../screens/login_screen.dart';
import '../screens/wishlist_screen.dart';
import '../screens/sidebar_screens.dart';
import '../screens/get_started_screen.dart'; // Import this to go back to start

class LazaDrawer extends StatelessWidget {
  const LazaDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);
    final User? user = FirebaseAuth.instance.currentUser;
    final String userEmail = user?.email ?? "Guest";
    final String userName = user?.displayName ?? "User";

    // Helper to get dynamic colors
    final textColor = Theme.of(context).textTheme.bodyLarge?.color;
    final cardColor = Theme.of(context).cardColor;
    final iconColor = Theme.of(context).iconTheme.color;

    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: CircleAvatar(
                backgroundColor: cardColor,
                child: IconButton(
                  icon: Icon(Icons.close, color: iconColor),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),

            // Profile Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 25,
                    backgroundImage: AssetImage('assets/images/onboarding_man.png'),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: textColor),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail,
                          style: const TextStyle(color: LazaColors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Dark Mode Switch
            _buildMenuItem(
              context,
              Icons.wb_sunny_outlined,
              "Dark Mode",
              trailing: Switch(
                value: themeManager.themeMode == ThemeMode.dark,
                activeColor: LazaColors.primary,
                onChanged: (val) {
                  themeManager.toggleTheme(val);
                },
              ),
            ),

            _buildMenuItem(context, Icons.info_outline, "Account Information", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AccountInfoScreen()))),
            _buildMenuItem(context, Icons.lock_outline, "Password", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ChangePasswordScreen()))),
            _buildMenuItem(context, Icons.shopping_bag_outlined, "Order", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const OrdersScreen()))),
            _buildMenuItem(context, Icons.credit_card_outlined, "My Cards", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const MyCardsScreen()))),
            _buildMenuItem(context, Icons.favorite_border, "Wishlist", onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => const WishlistScreen()));
            }),
            _buildMenuItem(context, Icons.settings_outlined, "Settings", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SettingsScreen()))),

            const Spacer(),

            // LOGOUT BUTTON - Updated to go to GetStartedScreen
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextButton.icon(
                onPressed: () async {
                  // 1. Sign out from Firebase/Google
                  await AuthService().logout();

                  // 2. Navigate to Get Started Screen (and clear history)
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const GetStartedScreen()),
                        (route) => false,
                  );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text("Logout", style: TextStyle(color: Colors.red, fontSize: 17, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, {Widget? trailing, VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).iconTheme.color),
      title: Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color, fontSize: 15)),
      trailing: trailing,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20),
    );
  }
}