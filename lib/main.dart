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
        
        // Show owl everywhere except onboarding and login
        final showOwl = currentRoute != '/onboarding' && currentRoute != '/login';
        
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
        // Use route argument to pass username properly
        '/home': (context) => HomeScreen.fromRoute(context),
      },
    );
  }
}

class AuthGate extends StatelessWidget {
  final bool showOnboarding;
  const AuthGate({super.key, required this.showOnboarding});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?> (
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.active) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final user = snapshot.data;
        if (showOnboarding) {
          return const OnboardingScreen();
        }
        if (user == null) {
          return const LoginScreen();
        }
        
        // Get user data from SharedPreferences
        final userDataService = UserDataService.instance;
        final currentUser = userDataService.currentUser;
        
        if (currentUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: currentUser.username,
            );
          });
          return const SizedBox.shrink();
        } else {
          final username = user.email?.split('@').first ?? 'User';
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacementNamed(
              context,
              '/home',
              arguments: username,
            );
          });
          return const SizedBox.shrink();
        }
      },
    );
  }
}
