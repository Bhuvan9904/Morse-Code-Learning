import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:memory_hack_app/screens/main_navigation_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:memory_hack_app/screens/splash_screen.dart';
import 'package:memory_hack_app/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
    ),
  );

  final prefs = await SharedPreferences.getInstance();
  final hasCompletedOnboarding = prefs.getBool('hasCompletedOnboarding') ?? false;

  runApp(MorseMemoryApp(
    initialScreen: hasCompletedOnboarding
        ? const MainNavigationScreen(initialIndex: 0)
        : const SplashScreen(),
  ));
}

class MorseMemoryApp extends StatelessWidget {
  final Widget initialScreen;

  const MorseMemoryApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morse Memory Hack',
      debugShowCheckedModeBanner: false,
      theme: _buildAppTheme(),
      home: initialScreen,
      navigatorKey: NavigatorKeys.root,
    );
  }

  ThemeData _buildAppTheme() {
    return ThemeData(
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCTA,
          foregroundColor: AppColors.textLight,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryCTA,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondary.withOpacity(0.2),
        selectedColor: AppColors.primaryCTA,
        labelStyle: const TextStyle(color: AppColors.textLight),
        padding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: AppColors.textLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textLight,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: AppColors.textLight,
        ),
      ),
      useMaterial3: true,
    );
  }
}

class NavigatorKeys {
  static final GlobalKey<NavigatorState> root = GlobalKey<NavigatorState>();
}
