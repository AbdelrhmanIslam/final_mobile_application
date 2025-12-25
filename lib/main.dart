import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/app_colors.dart';
import 'core/theme_manager.dart';
import 'core/user_data_provider.dart'; // Import New Provider
import 'ui/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MultiProvider( // Use MultiProvider to handle both Theme and User Data
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeManager()),
        ChangeNotifierProvider(create: (_) => UserDataProvider()),
      ],
      child: const LazaApp(),
    ),
  );
}

class LazaApp extends StatelessWidget {
  const LazaApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeManager = Provider.of<ThemeManager>(context);

    return MaterialApp(
      title: 'Laza',
      debugShowCheckedModeBanner: false,
      themeMode: themeManager.themeMode,

      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: LazaColors.primary,
        scaffoldBackgroundColor: LazaColors.white,
        cardColor: LazaColors.lightBg,
        iconTheme: const IconThemeData(color: LazaColors.dark),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(bodyColor: LazaColors.dark),
        useMaterial3: true,
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: LazaColors.primary,
        scaffoldBackgroundColor: LazaColors.darkBg,
        cardColor: LazaColors.darkCard,
        iconTheme: const IconThemeData(color: Colors.white),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).primaryTextTheme).apply(bodyColor: Colors.white),
        useMaterial3: true,
      ),

      home: const SplashScreen(),
    );
  }
}