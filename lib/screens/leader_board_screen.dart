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
  late Animation<double> _fadeAnimation;

  // Sorting mode: 'profit', 'portfolio', 'return'
  String _sortMode = 'profit';

  // Modern dark color scheme with orange accents
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color accentOrangeDim = Color(0xFFCC7700);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color negativeRed = Color(0xFFFF5252);

  // Platform-aware properties
  bool get isWeb => kIsWeb;
  double get maxWidth => isWeb ? 600 : double.infinity;
  double get horizontalPadding => isWeb ? 40 : 20;

  Stream<List<LeaderboardEntry>> _leaderboardStream() {
    final user = FirebaseAuth.instance.currentUser;
    
    if (user == null) {
      return Stream.value([]);
    }

    return FirebaseFirestore.instance
        .collection('users')
        .snapshots()
        .handleError((error) {
      debugPrint('Firestore error: $error');
      return <LeaderboardEntry>[];
    })
        .map((snap) {
      final uid = user.uid;
      final users = <Map<String, dynamic>>[];
      
      for (var doc in snap.docs) {
        try {
          final data = doc.data();
          
          String username = 'User';
          if (data['username'] != null) {
            username = data['username'].toString();
          } else if (data['email'] != null) {
            final email = data['email'].toString();
            username = email.split('@').first;
          }
          
          double portfolioValue = 0.0;
          if (data['portfolioValue'] != null) {
            portfolioValue = (data['portfolioValue'] as num).toDouble();
          } else if (data['totalValue'] != null) {
            portfolioValue = (data['totalValue'] as num).toDouble();
          } else if (data['portfolio'] != null && data['portfolio'] is Map) {
            final portfolio = data['portfolio'] as Map;
            final virtualMoney = (portfolio['virtualMoney'] as num?)?.toDouble() ?? 10000.0;
            portfolioValue = virtualMoney;
          } else {
            portfolioValue = 10000.0;
          }
          
          final initialMoney = 10000.0;
          final profitLoss = (data['profitLoss'] as num?)?.toDouble() ?? (portfolioValue - initialMoney);
          final returnPercent = (data['returnPercent'] as num?)?.toDouble() ?? 0.0;
          final points = (data['points'] as num?)?.toDouble() ?? 0.0;
          
          users.add({
            'id': doc.id,
            'username': username,
            'portfolioValue': portfolioValue,
            'profitLoss': profitLoss,
            'returnPercent': returnPercent,
            'points': points,
            'isCurrentUser': doc.id == uid,
          });
        } catch (e) {
          debugPrint('Error processing user ${doc.id}: $e');
          users.add({
            'id': doc.id,
            'username': 'User',
            'portfolioValue': 10000.0,
            'profitLoss': 0.0,
            'returnPercent': 0.0,
            'points': 10000.0,
            'isCurrentUser': doc.id == uid,
          });
        }
      }
      
      final sortMode = _sortMode;
      users.sort((a, b) {
        double compareValueA;
        double compareValueB;
        
        switch (sortMode) {
          case 'profit':
            compareValueA = a['profitLoss'] as double;
            compareValueB = b['profitLoss'] as double;
            break;
          case 'portfolio':
            compareValueA = a['portfolioValue'] as double;
            compareValueB = b['portfolioValue'] as double;
            break;
          case 'return':
            compareValueA = a['returnPercent'] as double;
            compareValueB = b['returnPercent'] as double;
            break;
          default:
            compareValueA = a['profitLoss'] as double;
            compareValueB = b['profitLoss'] as double;
        }
        
        final primaryCompare = compareValueB.compareTo(compareValueA);
        if (primaryCompare == 0) {
          if (sortMode != 'profit') {
            final profitA = a['profitLoss'] as double;
            final profitB = b['profitLoss'] as double;
            final profitCompare = profitB.compareTo(profitA);
            if (profitCompare != 0) return profitCompare;
          }
          return (a['username'] as String).compareTo(b['username'] as String);
        }
        return primaryCompare;
      });
      
      int rank = 0;
      final entries = users.map((user) {
        rank++;
        final points = user['points'] as double;
        final level = (points / 10000).floor() + 1;
        
        return LeaderboardEntry(
          rank: rank,
          username: user['username'] as String,
          portfolioValue: user['portfolioValue'] as double,
          profitLoss: user['profitLoss'] as double,
          totalReturn: user['returnPercent'] as double,
          level: level,
          streak: 0,
          badge: rank == 1 ? '🏆' : rank == 2 ? '🥈' : rank == 3 ? '🥉' : '⭐',
          experience: points.toInt(),
          isCurrentUser: user['isCurrentUser'] as bool,
        );
      }).toList();
      
      debugPrint('Leaderboard: Processed ${users.length} users, returning ${entries.length} entries');
      return entries;
    });
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Leaderboard content
            Expanded(
              child: StreamBuilder<List<LeaderboardEntry>>(
                key: ValueKey(_sortMode),
                stream: _leaderboardStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(color: accentOrange),
                    );
                  }
                  
                  if (snapshot.hasError) {
                    return _buildErrorState();
                  }
                  
                  final entries = snapshot.data ?? [];
                  
                  if (entries.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                      children: [
                        const SizedBox(height: 16),
                        // Top 3 Podium (simplified)
                        if (entries.length >= 3) _buildTopThree(entries.take(3).toList()),
                        if (entries.length >= 3) const SizedBox(height: 24),
                        // All Rankings
                        _buildAllRankings(entries),
                        const SizedBox(height: 100),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
      decoration: BoxDecoration(
        color: cardDark,
        border: Border(bottom: BorderSide(color: borderColor, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: cardLight,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: textPrimary),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),
          Icon(Icons.emoji_events, color: accentOrange, size: 28),
          const SizedBox(width: 12),
          Text(
            'Leaderboard',
            style: TextStyle(
              color: textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          _buildSortButton(),
        ],
      ),
    );
  }

  Widget _buildSortButton() {
    return PopupMenuButton<String>(
      icon: Icon(Icons.sort, color: accentOrange, size: 24),
      color: cardDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor),
      ),
      onSelected: (value) => setState(() => _sortMode = value),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profit',
          child: Row(
            children: [
              Icon(
                Icons.trending_up,
                color: _sortMode == 'profit' ? accentOrange : textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'By Profit',
                style: TextStyle(
                  color: _sortMode == 'profit' ? accentOrange : textPrimary,
                  fontWeight: _sortMode == 'profit' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'portfolio',
          child: Row(
            children: [
              Icon(
                Icons.account_balance_wallet,
                color: _sortMode == 'portfolio' ? accentOrange : textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'By Portfolio',
                style: TextStyle(
                  color: _sortMode == 'portfolio' ? accentOrange : textPrimary,
                  fontWeight: _sortMode == 'portfolio' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'return',
          child: Row(
            children: [
              Icon(
                Icons.percent,
                color: _sortMode == 'return' ? accentOrange : textSecondary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Text(
                'By Return %',
                style: TextStyle(
                  color: _sortMode == 'return' ? accentOrange : textPrimary,
                  fontWeight: _sortMode == 'return' ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopThree(List<LeaderboardEntry> top3) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Text(
            'Top Performers',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // 2nd Place
              if (top3.length > 1) Expanded(child: _buildTopCard(top3[1], 2)),
              if (top3.length > 1) const SizedBox(width: 8),
              // 1st Place
              if (top3.isNotEmpty) Expanded(child: _buildTopCard(top3[0], 1)),
              if (top3.length > 2) const SizedBox(width: 8),
              // 3rd Place
              if (top3.length > 2) Expanded(child: _buildTopCard(top3[2], 3)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopCard(LeaderboardEntry entry, int position) {
    final isFirst = position == 1;
    final positionColor = isFirst 
        ? accentOrange 
        : (position == 2 ? textSecondary : accentOrangeDim);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFirst ? accentOrange.withOpacity(0.1) : cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isFirst ? accentOrange : borderColor,
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            entry.badge,
            style: TextStyle(fontSize: isFirst ? 32 : 24),
          ),
          const SizedBox(height: 4),
          Text(
            '#$position',
            style: TextStyle(
              color: positionColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            entry.username,
            style: TextStyle(
              color: textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: entry.profitLoss >= 0
                  ? positiveGreen.withOpacity(0.2)
                  : negativeRed.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: entry.profitLoss >= 0 ? positiveGreen : negativeRed,
                width: 1,
              ),
            ),
            child: Text(
              '₹${(entry.profitLoss >= 0 ? '+' : '')}${entry.profitLoss.toStringAsFixed(0)}',
              style: TextStyle(
                color: entry.profitLoss >= 0 ? positiveGreen : negativeRed,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllRankings(List<LeaderboardEntry> entries) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Text(
                'All Rankings',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${entries.length} ${entries.length == 1 ? 'user' : 'users'}',
                  style: TextStyle(
                    color: textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Show ALL users
        ...entries.map((entry) => _buildUserCard(entry)),
      ],
    );
  }

  Widget _buildUserCard(LeaderboardEntry entry) {
    final isCurrentUser = entry.isCurrentUser;
    final isTopThree = entry.rank <= 3;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCurrentUser ? accentOrange.withOpacity(0.15) : cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentUser 
              ? accentOrange 
              : (isTopThree ? accentOrange.withOpacity(0.3) : borderColor),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank Badge
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isTopThree 
                  ? accentOrange.withOpacity(0.2) 
                  : cardLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isTopThree ? accentOrange : borderColor,
                width: isTopThree ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  entry.badge,
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  '#${entry.rank}',
                  style: TextStyle(
                    color: isTopThree ? accentOrange : textSecondary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.username,
                        style: TextStyle(
                          color: isCurrentUser ? accentOrange : textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCurrentUser)
                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentOrange,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            color: darkBg,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: cardLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Lv.${entry.level}',
                        style: TextStyle(
                          color: textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // Profit/Earnings (PRIMARY)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: entry.profitLoss >= 0
                      ? positiveGreen.withOpacity(0.15)
                      : negativeRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: entry.profitLoss >= 0 ? positiveGreen : negativeRed,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      entry.profitLoss >= 0 ? Icons.trending_up : Icons.trending_down,
                      color: entry.profitLoss >= 0 ? positiveGreen : negativeRed,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '₹${(entry.profitLoss >= 0 ? '+' : '')}${entry.profitLoss.toStringAsFixed(0)}',
                      style: TextStyle(
                        color: entry.profitLoss >= 0 ? positiveGreen : negativeRed,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹${(entry.portfolioValue / 1000).toStringAsFixed(1)}K',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: entry.totalReturn >= 0
                      ? positiveGreen.withOpacity(0.1)
                      : negativeRed.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${entry.totalReturn >= 0 ? '+' : ''}${entry.totalReturn.toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: entry.totalReturn >= 0 ? positiveGreen : negativeRed,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: negativeRed, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error loading leaderboard',
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please make sure you are logged in and have an internet connection.',
              style: TextStyle(color: textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => setState(() {}),
              icon: Icon(Icons.refresh),
              label: Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentOrange,
                foregroundColor: darkBg,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.leaderboard_outlined, size: 64, color: textTertiary),
            const SizedBox(height: 16),
            Text(
              'No users found',
              style: TextStyle(
                color: textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to start trading!',
              style: TextStyle(color: textSecondary, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class LeaderboardEntry {
  final int rank;
  final String username;
  final double portfolioValue;
  final double profitLoss;
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
    required this.profitLoss,
    required this.totalReturn,
    required this.level,
    required this.streak,
    required this.badge,
    required this.experience,
    this.isCurrentUser = false,
  });
}
