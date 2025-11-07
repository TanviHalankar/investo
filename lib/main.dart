import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investo/services/real_time_service.dart';
import 'package:investo/services/portfolio_service.dart';
import 'package:investo/services/guide_service.dart';
import 'package:investo/services/user_data_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'screens/login_screens/login_screen.dart';
import 'screens/login_screens/register_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_page/home_screen.dart';
import 'widgets/coach_overlay.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final prefs = await SharedPreferences.getInstance();
  final showOnboarding = prefs.getBool('onboarding_shown') ?? false;
  
  // Initialize user data service
  await UserDataService.instance.init();
  
  // Initialize real-time service
  final realTimeService = RealTimeService();
  realTimeService.connect();

  // Load virtual portfolio state (demo money, holdings, points)
  await PortfolioService().load();
  await GuideService().load();
  
  print('Guide service loaded: ${GuideService().current}');

  runApp(MyApp(showOnboarding: showOnboarding));
}

class MyApp extends StatelessWidget {
  final bool showOnboarding;
  const MyApp({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'StockMaster',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      builder: (context, child) {
        // Get current route name
        final currentRoute = ModalRoute.of(context)?.settings.name ?? '';
        
        // Show owl everywhere except onboarding, login, and register
        final showOwl = currentRoute != '/onboarding' && currentRoute != '/login' && currentRoute != '/register';
        
        return Stack(
          children: [
            if (child != null) child,
            if (showOwl)
              Positioned.fill(
                child: CoachOverlay(
                  stream: GuideService().stream,
                  characterName: 'Wise Owl',
                  onTap: () {
                    GuideService().showNextTip(context);
                  },
                ),
              ),
          ],
        );
      },
      home: AuthGate(showOnboarding: showOnboarding),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        // Use route argument to pass username properly
        '/home': (context) => HomeScreen.fromRoute(context),
      },
    );
  }
}

class AuthGate extends StatefulWidget {
  final bool showOnboarding;
  const AuthGate({super.key, required this.showOnboarding});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isNavigating = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (widget.showOnboarding) {
          return const OnboardingScreen();
        }
        if (user == null) {
          return const LoginScreen();
        }

        _hydrateAndNavigate(user);

        return const Scaffold(
          backgroundColor: Color(0xFF0D0D0D),
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  color: Color(0xFFFF9500),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading your account...',
                  style: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hydrateAndNavigate(User user) {
    if (_isNavigating) return;
    _isNavigating = true;

    Future.microtask(() async {
      try {
        final fallbackUsername =
            user.email?.split('@').first ?? 'User';

        await UserDataService.instance.ensureLocalUser(
          userId: user.uid,
          email: user.email ?? '',
          username: fallbackUsername,
          displayName: user.displayName,
          photoUrl: user.photoURL,
        );

        await UserDataService.instance.runPostSignInWarmup(waitForCompletion: true);

        if (!mounted) return;

        final resolvedUsername =
            UserDataService.instance.currentUser?.username ?? fallbackUsername;

        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: resolvedUsername,
        );
      } catch (e, stack) {
        debugPrint('AuthGate hydration error: $e');
        debugPrint(stack.toString());
        _isNavigating = false;
      }
    });
  }
}
