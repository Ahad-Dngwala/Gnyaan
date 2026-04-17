import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'app_shell.dart';
import 'features/onboarding/screens/onboarding_screen.dart';

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

  runApp(const GnyaanApp());
}

class GnyaanApp extends StatelessWidget {
  const GnyaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gnyaan — AI Knowledge Engine',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: '/onboarding',
      routes: {
        '/onboarding': (_) => const OnboardingScreen(),
        '/home': (_) => const AppShell(),
      },
    );
  }
}
