import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:investo/screens/learning_screen.dart';
import 'package:investo/screens/portfolio_screen.dart';
import 'package:investo/screens/practice%20_trading.dart';
import 'package:investo/screens/prediction_screen.dart';

import '../api_service.dart';
import 'leader_board_screen.dart';

class HomeScreen extends StatefulWidget {
  final String username;

  const HomeScreen({super.key, required this.username});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Platform-aware properties
  bool get isWeb => kIsWeb;
  bool get isMobile => !kIsWeb;

  double get maxWidth => isWeb ? 600 : double.infinity;
  double get horizontalPadding => isWeb ? 40 : 20;
  double get cardBorderRadius => isWeb ? 20 : 30;
  double get buttonHeight => isWeb ? 48 : 56;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.elasticOut));

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 800;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1a1a2e),
              Color(0xFF16213e),
              Color(0xFF0f3460),
              Color(0xFF533483),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: isWeb ? 20 : 40,
                  ),
                  child: Column(
                    mainAxisAlignment: isWeb ? MainAxisAlignment.center : MainAxisAlignment.start,
                    children: [
                      // Web-specific top spacing
                      if (isWeb) const SizedBox(height: 40),

                      // Animated header section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: _buildWelcomeCard(),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Quick stats section - responsive layout
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: isLargeScreen
                            ? _buildQuickStatsWeb()
                            : _buildQuickStatsMobile(),
                      ),
                      const SizedBox(height: 30),

                      // Action buttons section
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildActionButtons(),
                      ),

                      // Web-specific bottom spacing
                      if (isWeb) const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.basic : SystemMouseCursors.basic,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(isWeb ? 32 : 28),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                // Animated stock market icon
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00d4aa), Color(0xFF00b894)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00d4aa).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.trending_up,
                    size: isWeb ? 36 : 40,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: isWeb ? 20 : 24),

                Text(
                  'Welcome back, ${widget.username}!',
                  style: TextStyle(
                    fontSize: isWeb ? 24 : 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                Text(
                  'Ready to master the stock market?',
                  style: TextStyle(
                    fontSize: isWeb ? 15 : 16,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00d4aa).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF00d4aa).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '🎯 Beginner Trader',
                    style: TextStyle(
                      color: const Color(0xFF00d4aa),
                      fontSize: isWeb ? 13 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStatsMobile() {
    return Row(
      children: [
        Expanded(child: _buildStatCard('Portfolio', '\$0', Icons.account_balance_wallet, const Color(0xFF6c5ce7))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Level', '1', Icons.emoji_events, const Color(0xFFfdcb6e))),
        const SizedBox(width: 16),
        Expanded(child: _buildStatCard('Streak', '0', Icons.local_fire_department, const Color(0xFFe17055))),
      ],
    );
  }

  Widget _buildQuickStatsWeb() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        SizedBox(
          width: 140,
          child: _buildStatCard('Portfolio', '\$0', Icons.account_balance_wallet, const Color(0xFF6c5ce7)),
        ),
        SizedBox(
          width: 140,
          child: _buildStatCard('Level', '1', Icons.emoji_events, const Color(0xFFfdcb6e)),
        ),
        SizedBox(
          width: 140,
          child: _buildStatCard('Streak', '0', Icons.local_fire_department, const Color(0xFFe17055)),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isWeb ? 16 : 20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              padding: EdgeInsets.all(isWeb ? 14 : 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(isWeb ? 16 : 20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  Icon(icon, color: color, size: isWeb ? 22 : 24),
                  SizedBox(height: isWeb ? 6 : 8),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isWeb ? 16 : 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: isWeb ? 11 : 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildPrimaryButton(
          'Start Learning',
          Icons.school,
          const Color(0xFF00d4aa),
              () {
            // Navigate to learning modules
                Navigator.push(context, MaterialPageRoute(builder: (context) => LearningScreen(username: widget.username,)));

          },
        ),
        const SizedBox(height: 16),

        // Responsive button layout
        isWeb
            ? _buildWebButtonLayout()
            : _buildMobileButtonLayout(),

        const SizedBox(height: 16),

        _buildSecondaryButton(
          'View Leaderboard',
          Icons.leaderboard,
          const Color(0xFFfdcb6e),
              () {
            // Navigate to leaderboard
                Navigator.push(context, MaterialPageRoute(builder: (context) => LeaderBoardScreen()));
          },
          fullWidth: true,
        ),
        _buildSecondaryButton(
          'Portfolio',
          Icons.leaderboard,
          const Color(0xFFfdcb6e),
              () {
            // Navigate to leaderboard
                Navigator.push(context, MaterialPageRoute(builder: (context) => PortfolioScreen()));
          },
          fullWidth: true,
        ),

        _buildSecondaryButton(
          'Get ML Prediction',
          Icons.analytics,
          const Color(0xFF00d4aa),
              () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PredictionScreen(username: widget.username),
              ),
            );
          },
        ),



      ],
    );
  }


  Widget _buildWebButtonLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            'Practice Trading',
            Icons.psychology,
            const Color(0xFF6c5ce7),
                () {
              // Navigate to practice trading
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeScreen(username: widget.username)));
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSecondaryButton(
            'Market News',
            Icons.newspaper,
            const Color(0xFF00b894),
                () {
              // Navigate to market news
            },
          ),
        ),
      ],
    );
  }


  Widget _buildMobileButtonLayout() {
    return Row(
      children: [
        Expanded(
          child: _buildSecondaryButton(
            'Practice Trading',
            Icons.psychology,
            const Color(0xFF6c5ce7),
                () {
              // Navigate to practice trading
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PracticeScreen(username: widget.username,)));
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSecondaryButton(
            'News',
            Icons.newspaper,
            const Color(0xFF00b894),
                () {
              // Navigate to market news
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(String text, IconData icon, Color color, VoidCallback onPressed) {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: buttonHeight,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(isWeb ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(isWeb ? 16 : 20),
            ),
            overlayColor: Colors.white.withOpacity(0.1),
          ),
          onPressed: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: isWeb ? 22 : 24),
              SizedBox(width: isWeb ? 10 : 12),
              Text(
                text,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isWeb ? 15 : 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, IconData icon, Color color, VoidCallback onPressed, {bool fullWidth = false}) {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isWeb ? 14 : 18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
            child: Container(
              width: fullWidth ? double.infinity : null,
              height: isWeb ? 44 : 50,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                borderRadius: BorderRadius.circular(isWeb ? 14 : 18),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isWeb ? 14 : 18),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: isWeb ? 12 : 8),
                  overlayColor: color.withOpacity(0.1),
                ),
                onPressed: onPressed,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
                  children: [
                    Icon(icon, color: color, size: isWeb ? 18 : 20),
                    if (fullWidth || (isWeb && text.length <= 12)) ...[
                      SizedBox(width: isWeb ? 6 : 8),
                      Flexible(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: color,
                            fontSize: isWeb ? 13 : (fullWidth ? 14 : 12),
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ] else if (!isWeb && !fullWidth) ...[
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: color,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}