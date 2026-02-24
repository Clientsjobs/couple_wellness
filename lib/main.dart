import 'package:couple_wellness/firebase_options.dart';
import 'package:couple_wellness/l10n/app_localizations.dart';
import 'package:couple_wellness/screens/auth/sign_in_screen.dart';
import 'package:couple_wellness/screens/home/main_dashboard.dart';
import 'package:couple_wellness/screens/splash/splash_screen.dart';
import 'package:couple_wellness/services/auth_service.dart';
import 'package:couple_wellness/services/user_service.dart';
import 'package:couple_wellness/utils/responsive_sizer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  Locale _locale = const Locale('en', '');
  bool _showSplash = true;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    // Show splash for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _showSplash = false;
      });
    }
    _loadUserLanguage();
    _listenToLanguageChanges();
  }

  Future<void> _loadUserLanguage() async {
    try {
      final userData = await _userService.getUserData();
      if (userData != null && mounted) {
        final langCode = userData['preferredLanguage'] ?? 'en';
        setState(() {
          _locale = Locale(langCode, '');
        });
      }
    } catch (e) {
      debugPrint('Error loading language: $e');
    }
  }

  void _listenToLanguageChanges() {
    _userService.userStream.listen((snapshot) {
      if (snapshot != null && snapshot.exists && mounted) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          final langCode = data['preferredLanguage'] ?? 'en';
          if (_locale.languageCode != langCode) {
            setState(() {
              _locale = Locale(langCode, '');
            });
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: _locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: _showSplash
              ? const SplashScreen()
              : StreamBuilder<User?>(
                  stream: _authService.authStateChanges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Scaffold(
                        body: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (snapshot.hasData) {
                      return const MainDashboard();
                    }
                    return const LogInScreen();
                  },
                ),
        );
      },
    );
  }
}
