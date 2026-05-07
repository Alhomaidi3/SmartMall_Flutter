import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'screens/user/login_screen.dart';
import 'screens/user/signup_screen.dart';
import 'screens/user/onboarding_screen.dart';
import 'widgets/user_bottom_navigation_bar.dart';  
import 'widgets/admin_bottom_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.dark;

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Mall Guide',

      theme: ThemeData(
        brightness: Brightness.light,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          onPrimary: Colors.white,
          secondary: Colors.grey,
          onSecondary: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
          outline: Color(0xFFE0E0E0),
          outlineVariant: Color(0xFFF5F5F5),
          surfaceContainerHighest: Color(0xFFF5F5F5),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: Colors.black,
          unselectedItemColor: Colors.black54,
        ),
      ),

      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          onPrimary: Colors.black,
          secondary: Colors.grey,
          onSecondary: Colors.white,
          surface: Colors.black,
          onSurface: Colors.white,
          outline: Color(0xFF424242),
          outlineVariant: Color(0xFF303030),
          surfaceContainerHighest: Color(0xFF1E1E1E),
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.black,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white70,
        ),
      ),

      themeMode: _themeMode,

      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,

      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
          
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          
          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());
          
          case '/home':
          case '/main':
            return MaterialPageRoute(
              builder: (_) => MainScreen(
                onThemeChanged: _toggleTheme,
              ),
            );
          
          case '/admin':
            return MaterialPageRoute(
              builder: (_) => AdminMainScreen(
                onThemeChanged: _toggleTheme,
              ),
            );
          
          default:
            return MaterialPageRoute(builder: (_) => const OnboardingScreen());
            
        }
      },
    );
  }
}