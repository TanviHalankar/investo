import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LeaderBoardScreen extends StatefulWidget {
  const LeaderBoardScreen({super.key});

  @override
  State<LeaderBoardScreen> createState() => _LeaderBoardScreenState();
}

class _LeaderBoardScreenState extends State<LeaderBoardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Platform-aware properties
  bool get isWeb => kIsWeb;
  double get maxWidth => isWeb ? 600 : double.infinity;
  double get horizontalPadding => isWeb ? 40 : 20;
  double get cardBorderRadius => isWeb ? 20 : 30;

  Stream<List<LeaderboardEntry>> _leaderboardStream() {
    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .map((snap) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      
      // Get all users and calculate their scores - ensure we process ALL users
      final users = <Map<String, dynamic>>[];
      
      for (var doc in snap.docs) {
        try {
          final data = doc.data();
          
          // Get username - try multiple sources
          String username = 'User';
          if (data['username'] != null) {
            username = data['username'].toString();
          } else if (data['email'] != null) {
            final email = data['email'].toString();
            username = email.split('@').first;
          }
          
          // Get portfolio value - check multiple sources
          double portfolioValue = 0.0;
          if (data['portfolioValue'] != null) {
            portfolioValue = (data['portfolioValue'] as num).toDouble();
          } else if (data['totalValue'] != null) {
            portfolioValue = (data['totalValue'] as num).toDouble();
          } else if (data['portfolio'] != null && data['portfolio'] is Map) {
            final portfolio = data['portfolio'] as Map;
            final virtualMoney = (portfolio['virtualMoney'] as num?)?.toDouble() ?? 10000.0;
            portfolioValue = virtualMoney; // Default to initial money if no holdings
          } else {
            portfolioValue = 10000.0; // Default starting amount
          }
          
          final returnPercent = (data['returnPercent'] as num?)?.toDouble() ?? 0.0;
          final points = (data['points'] as num?)?.toDouble() ?? 0.0;
          
          // Calculate score - use points if available, otherwise use portfolio value
          final score = points > 0 ? points : portfolioValue;
          
          users.add({
            'id': doc.id,
            'username': username,
            'portfolioValue': portfolioValue,
            'returnPercent': returnPercent,
            'points': score,
            'isCurrentUser': doc.id == uid,
          });
        } catch (e) {
          print('Error processing user ${doc.id}: $e');
          // Still add user with default values
          users.add({
            'id': doc.id,
            'username': 'User',
            'portfolioValue': 10000.0,
            'returnPercent': 0.0,
            'points': 10000.0,
            'isCurrentUser': doc.id == uid,
          });
        }
      }
      
      // Sort by points/score descending - ensure stable sort
      users.sort((a, b) {
        final scoreA = a['points'] as double;
        final scoreB = b['points'] as double;
        final scoreCompare = scoreB.compareTo(scoreA);
        // If scores are equal, sort by username for consistency
        if (scoreCompare == 0) {
          return (a['username'] as String).compareTo(b['username'] as String);
        }
        return scoreCompare;
      });
      
      // Build leaderboard entries with ranks
      int rank = 0;
      return users.map((user) {
        rank++;
        final points = user['points'] as double;
        final level = (points / 10000).floor() + 1;
        
        return LeaderboardEntry(
          rank: rank,
          username: user['username'] as String,
          portfolioValue: user['portfolioValue'] as double,
          totalReturn: user['returnPercent'] as double,
          level: level,
          streak: 0,
          badge: rank == 1 ? '🏆' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '⭐',
          experience: points.toInt(),
          isCurrentUser: user['isCurrentUser'] as bool,
        );
      }).toList();
    });
  }

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
              child: Column(
                children: [
                  // Header
                  _buildHeader(),

                  // Leaderboard content
                  Expanded(
                    child: StreamBuilder<List<LeaderboardEntry>>(
                      stream: _leaderboardStream(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFFfdcb6e),
                            ),
                          );
                        }
                        
                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading leaderboard: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }
                        
                        final entries = snapshot.data ?? [];
                        
                        if (entries.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.leaderboard_outlined,
                                  size: 64,
                                  color: Colors.white54,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'No users found',
                                  style: TextStyle(
                                    color: Colors.white54,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                        
                        return SingleChildScrollView(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                            child: Column(
                              children: [
                                const SizedBox(height: 20),
                                if (entries.length >= 3)
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: _buildPodium(entries.take(3).toList()),
                                  )
                                else if (entries.isNotEmpty)
                                  FadeTransition(
                                    opacity: _fadeAnimation,
                                    child: _buildPodium(entries),
                                  ),
                                const SizedBox(height: 30),
                                FadeTransition(
                                  opacity: _fadeAnimation,
                                  child: _buildLeaderboardList(entries),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        );
                      },
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 20,
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.leaderboard,
            color: Color(0xFFfdcb6e),
            size: 28,
          ),
          const SizedBox(width: 12),
          const Text(
            'Leaderboard',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF00d4aa).withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF00d4aa).withOpacity(0.3),
              ),
            ),
            child: const Text(
              'Season 1',
              style: TextStyle(
                color: Color(0xFF00d4aa),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    return Container(
      height: 180,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (top3.length > 1) _buildPodiumPlace(top3[1], 120),
          const SizedBox(width: 8),
          // 1st place
          if (top3.isNotEmpty) _buildPodiumPlace(top3[0], 160),
          const SizedBox(width: 8),
          // 3rd place
          if (top3.length > 2) _buildPodiumPlace(top3[2], 100),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace(LeaderboardEntry entry, double height) {
    final colors = [
      const Color(0xFFfdcb6e), // Gold
      const Color(0xFF74b9ff), // Silver
      const Color(0xFFe17055), // Bronze
    ];
    final color = colors[entry.rank - 1];

    return Expanded(
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // User info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: color.withOpacity(0.3)),
              ),
              child: Column(
                children: [
                  Text(
                    entry.badge,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    entry.username,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '\$${(entry.portfolioValue / 1000).toStringAsFixed(0)}K',
                    style: TextStyle(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Podium
            Container(
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color, color.withOpacity(0.6)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Center(
                child: Text(
                  '${entry.rank}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardEntry> entries) {
    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              const Text(
                'Full Rankings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.refresh,
                color: Colors.white.withOpacity(0.6),
                size: 20,
              ),
            ],
          ),
        ),

        // List items
        ...entries.map((entry) => _buildLeaderboardItem(entry)),
      ],
    );
  }

  Widget _buildLeaderboardItem(LeaderboardEntry entry) {
    final isCurrentUser = entry.isCurrentUser;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cardBorderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCurrentUser
                  ? const Color(0xFF00d4aa).withOpacity(0.15)
                  : Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(cardBorderRadius),
              border: Border.all(
                color: isCurrentUser
                    ? const Color(0xFF00d4aa).withOpacity(0.3)
                    : Colors.white.withOpacity(0.15),
                width: isCurrentUser ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getRankColor(entry.rank).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _getRankColor(entry.rank).withOpacity(0.3),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${entry.rank}',
                      style: TextStyle(
                        color: _getRankColor(entry.rank),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            entry.badge,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              entry.username,
                              style: TextStyle(
                                color: isCurrentUser
                                    ? const Color(0xFF00d4aa)
                                    : Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildStatChip('Lv.${entry.level}', const Color(0xFF6c5ce7)),
                          const SizedBox(width: 8),
                          _buildStatChip('${entry.streak}🔥', const Color(0xFFe17055)),
                        ],
                      ),
                    ],
                  ),
                ),

                // Portfolio value and return
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '\$${(entry.portfolioValue / 1000).toStringAsFixed(1)}K',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: entry.totalReturn >= 0
                            ? const Color(0xFF00d4aa).withOpacity(0.2)
                            : const Color(0xFFe17055).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${entry.totalReturn >= 0 ? '+' : ''}${entry.totalReturn.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: entry.totalReturn >= 0
                              ? const Color(0xFF00d4aa)
                              : const Color(0xFFe17055),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFFfdcb6e);
      case 2:
        return const Color(0xFF74b9ff);
      case 3:
        return const Color(0xFFe17055);
      default:
        return const Color(0xFF6c5ce7);
    }
  }
}

class LeaderboardEntry {
  final int rank;
  final String username;
  final double portfolioValue;
  final double totalReturn;
  final int level;
  final int streak;
  final String badge;
  final int experience;
  final bool isCurrentUser;

  LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.portfolioValue,
    required this.totalReturn,
    required this.level,
    required this.streak,
    required this.badge,
    required this.experience,
    this.isCurrentUser = false,
  });
}