import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/network/api_client.dart';
import 'app_shell.dart';
import 'features/onboarding/screens/onboarding_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock to portrait for polished mobile experience
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Light system bars — warm white design
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.bg800,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // Initialise the API client singleton
  await ApiClient().init();

  // Check if user is already logged in
  final isLoggedIn = await ApiClient().isLoggedIn();

  runApp(GnyaanApp(isLoggedIn: isLoggedIn));
}

class GnyaanApp extends StatelessWidget {
  const GnyaanApp({super.key, required this.isLoggedIn});

  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gnyaan — AI Knowledge Engine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: isLoggedIn ? '/home' : '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const AppShell(),
      },
    );
  }
}
