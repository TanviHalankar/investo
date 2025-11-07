import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:investo/screens/trade_prediction_screen.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../../services/user_data_service.dart';
import '../../model/user_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  // Modern dark color scheme with orange accents (matching home_screen.dart)
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentOrangeDim = Color(0xFFCC7700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);

  AnimationController? _controller;
  Animation<double>? _fadeAnimation;
  Animation<Offset>? _slideAnimation;
  Animation<double>? _scaleAnimation;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOut)
    );
    _slideAnimation = Tween<Offset>(
        begin: const Offset(0, 0.3),
        end: Offset.zero
    ).animate(CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut)
    ));
    _scaleAnimation = Tween<double>(
        begin: 0.8,
        end: 1.0
    ).animate(CurvedAnimation(
        parent: _controller!,
        curve: const Interval(0.4, 1.0, curve: Curves.elasticOut)
    ));
    _controller?.forward();
  }

  @override
  void dispose() {
    _controller?.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (_isSigningIn) return;
    setState(() {
      _isSigningIn = true;
    });

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser != null) {
        final fallbackUsername =
            firebaseUser.email?.split('@').first ?? 'User';

        await UserDataService.instance.ensureLocalUser(
          userId: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          username: fallbackUsername,
          displayName: firebaseUser.displayName,
          photoUrl: firebaseUser.photoURL,
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
      }
    } catch (e) {
      _showErrorSnackBar('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isSigningIn = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _signInWithGoogle() async {
    // TODO: Implement Google Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Google Sign In - Coming Soon!'),
        backgroundColor: Colors.blue.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _signInWithApple() async {
    // TODO: Implement Apple Sign In
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Apple Sign In - Coming Soon!'),
        backgroundColor: Colors.grey.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: darkBg,
      body: Container(
        width: size.width,
        height: size.height,
        color: darkBg,
        child: Stack(
          children: [
            // Animated floating elements
            ...List.generate(6, (index) => _buildFloatingElement(index)),

            // Main content with proper keyboard handling
            SafeArea(
              child: SingleChildScrollView(
                // physics: const BouncingScrollPhysics(),
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                      child: _fadeAnimation != null && _slideAnimation != null && _scaleAnimation != null
                          ? FadeTransition(
                        opacity: _fadeAnimation!,
                        child: SlideTransition(
                          position: _slideAnimation!,
                          child: ScaleTransition(
                            scale: _scaleAnimation!,
                            child: _buildLoginCard(context),
                          ),
                        ),
                      )
                          : _buildLoginCard(context),
                    ),
                  ),
                ),
              ),
            ),

            if (_isSigningIn)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.55),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          color: accentOrange,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Signing you in...',
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingElement(int index) {
    final positions = [
      {'top': 100.0, 'left': 50.0, 'size': 80.0},
      {'top': 200.0, 'right': 80.0, 'size': 120.0},
      {'top': 400.0, 'left': 30.0, 'size': 60.0},
      {'bottom': 200.0, 'right': 40.0, 'size': 100.0},
      {'bottom': 350.0, 'left': 60.0, 'size': 90.0},
      {'top': 300.0, 'right': 200.0, 'size': 70.0},
    ];

    final pos = positions[index];

    return Positioned(
      top: pos['top'],
      bottom: pos['bottom'],
      left: pos['left'],
      right: pos['right'],
      child: TweenAnimationBuilder(
        duration: Duration(milliseconds: 2000 + (index * 500)),
        tween: Tween<double>(begin: 0, end: 1),
        builder: (context, double value, child) {
          return Transform.translate(
            offset: Offset(0, 20 * (0.5 - value).abs()),
            child: Container(
              width: pos['size'] as double,
              height: pos['size'] as double,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accentOrange.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          );
        },
        onEnd: () {
          // Restart animation
          setState(() {});
        },
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [cardDark, cardLight],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 30,
            offset: const Offset(0, 20),
            spreadRadius: -5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo with pulsing animation - made smaller
          TweenAnimationBuilder(
            duration: const Duration(milliseconds: 2000),
            tween: Tween<double>(begin: 0.8, end: 1.0),
            builder: (context, double value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [accentOrange, accentOrangeDim, accentOrange],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: accentOrange.withOpacity(0.5),
                        blurRadius: 15,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.trending_up_rounded,
                    size: 40,
                    color: darkBg,
                  ),
                ),
              );
            },
            onEnd: () {
              // Restart pulsing animation
              setState(() {});
            },
          ),
          const SizedBox(height: 20),

          // Welcome text with gradient - smaller font
          const Text(
            'Welcome Back!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: textPrimary,
              letterSpacing: -0.8,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Login to StockMaster',
            style: TextStyle(
              fontSize: 16,
              color: textSecondary,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),

          // Email field with glassmorphism - reduced padding
          _buildGlassTextField(
            controller: _emailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          // Password field
          _buildGlassTextField(
            controller: _passwordController,
            label: 'Password',
            icon: Icons.lock_outline,
            obscureText: true,
          ),
          const SizedBox(height: 24),

          // Login button with gradient - reduced height
          Container(
            width: double.infinity,
            height: 50,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentOrange, accentOrangeDim],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: accentOrange.withOpacity(0.4),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _isSigningIn ? null : _login,
                borderRadius: BorderRadius.circular(16),
                child: const Center(
                  child: Text(
                    'Sign In',
                    style: TextStyle(
                      color: darkBg,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Divider with text - more compact
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 1,
                  color: borderColor,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or continue with',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  height: 1,
                  color: borderColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Social login buttons - made smaller
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                onTap: _signInWithGoogle,
                icon: Icons.g_mobiledata,
                color: const Color(0xFFDB4437),
                label: 'Google',
              ),
              _buildSocialButton(
                onTap: _signInWithApple,
                icon: Icons.apple,
                color: const Color(0xFF000000),
                label: 'Apple',
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Sign up link - more compact
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const RegisterScreen(),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: RichText(
              text: TextSpan(
                text: "Don't have an account? ",
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 14,
                ),
                children: const [
                  TextSpan(
                    text: "Sign up",
                    style: TextStyle(
                      color: accentOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(
          color: textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: textSecondary,
            fontSize: 13,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentOrange, accentOrangeDim],
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: darkBg,
              size: 18,
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required VoidCallback onTap,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    return Container(
      width: 120,
      height: 44,
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: textPrimary,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}