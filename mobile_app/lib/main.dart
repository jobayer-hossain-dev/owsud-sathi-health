import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/services/notification_service.dart';
import 'core/services/storage_service.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await NotificationService().init();
  } catch (_) {}

  final isOnboarded = await StorageService.isOnboardingComplete();
  final token = await StorageService.getToken();

  runApp(
    ProviderScope(
      child: OshudhSathiApp(
        isOnboarded: isOnboarded,
        isLoggedIn: token != null && token.isNotEmpty,
      ),
    ),
  );
}

class OshudhSathiApp extends StatelessWidget {
  final bool isOnboarded;
  final bool isLoggedIn;

  const OshudhSathiApp({
    super.key,
    required this.isOnboarded,
    required this.isLoggedIn,
  });

  @override
  Widget build(BuildContext context) {
    const baseTextTheme = TextTheme(
      bodyLarge: TextStyle(color: AppColors.textDark, fontSize: 16),
      bodyMedium: TextStyle(color: AppColors.textDark, fontSize: 14),
      bodySmall: TextStyle(color: AppColors.textLight, fontSize: 12),
      titleLarge: TextStyle(color: AppColors.textDark, fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(color: AppColors.textDark, fontSize: 16, fontWeight: FontWeight.bold),
      titleSmall: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
      labelLarge: TextStyle(color: AppColors.textDark, fontSize: 14, fontWeight: FontWeight.bold),
      labelMedium: TextStyle(color: AppColors.textDark, fontSize: 12),
      labelSmall: TextStyle(color: AppColors.textLight, fontSize: 10),
    );

    return MaterialApp(
      title: 'OshudhSathi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
          onSurface: AppColors.textDark,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardTheme: CardThemeData(
          color: AppColors.cardBg,
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          labelStyle: const TextStyle(color: AppColors.textLight),
          hintStyle: const TextStyle(color: AppColors.textLight),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
        ),
        fontFamilyFallback: const ['Roboto', 'Segoe UI', 'Arial', 'sans-serif'],
        textTheme: GoogleFonts.notoSansBengaliTextTheme(baseTextTheme),
      ),
      home: isLoggedIn
          ? const MainNavigationScreen()
          : (isOnboarded ? const LoginScreen() : const OnboardingScreen()),
    );
  }
}
