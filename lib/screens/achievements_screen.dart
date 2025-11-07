import 'package:flutter/material.dart';
import '../model/achievement.dart';
import '../services/achievement_service.dart';
import '../services/portfolio_service.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final AchievementService _achievementService = AchievementService();
  final PortfolioService _portfolioService = PortfolioService();
  Set<String> _completedAchievements = {};
  Map<String, int> _progress = {};
  bool _isLoading = true;
  int _currentPoints = 0;
  String _selectedCategory = 'All';

  // Color scheme
  static const Color darkBg = Color(0xFF0D0D0D);
  static const Color cardDark = Color(0xFF1A1A1A);
  static const Color cardLight = Color(0xFF242424);
  static const Color accentOrange = Color(0xFFFF9500);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF999999);
  static const Color textTertiary = Color(0xFF666666);
  static const Color borderColor = Color(0xFF2A2A2A);
  static const Color positiveGreen = Color(0xFF00E676);
  static const Color accentOrangeDim = Color(0xFFCC7700);

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    setState(() {
      _isLoading = true;
    });

    final completed = await _achievementService.getCompletedAchievements();
    final progress = await _achievementService.getUserProgress();
    
    // Get current points from PortfolioService
    _currentPoints = _portfolioService.state.points;
    
    // Listen to portfolio updates to refresh points
    _portfolioService.stream.listen((state) {
      if (mounted) {
        setState(() {
          _currentPoints = state.points;
        });
      }
    });

    setState(() {
      _completedAchievements = completed;
      _progress = progress;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final allAchievements = _achievementService.getAllAchievements();
    final categories = ['All', ..._achievementService.getCategories().toSet().toList()];
    final filteredAchievements = _selectedCategory == 'All'
        ? allAchievements
        : allAchievements.where((a) => a.category == _selectedCategory).toList();
    final completedCount = filteredAchievements
        .where((a) => _completedAchievements.contains(a.id))
        .length;
    final totalCount = filteredAchievements.length;
    final progressPercent = totalCount > 0 ? (completedCount / totalCount) : 0.0;

    return Scaffold(
      backgroundColor: darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardDark,
                border: Border(
                  bottom: BorderSide(color: borderColor, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: cardLight,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: textPrimary),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(Icons.emoji_events, color: accentOrange, size: 28),
                  const SizedBox(width: 8),
                  const Text(
                    'Achievements',
                    style: TextStyle(
                      color: textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(Icons.refresh, color: textSecondary),
                    onPressed: () => _loadAchievements(),
                    tooltip: 'Refresh achievements',
                  ),
                ],
              ),
            ),

            // Progress Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [accentOrange.withOpacity(0.2), accentOrangeDim.withOpacity(0.1)],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: accentOrange.withOpacity(0.3), width: 1),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Progress',
                            style: TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$completedCount / $totalCount',
                            style: TextStyle(
                              color: textPrimary,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.stars, color: accentOrange, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Total Points: $_currentPoints',
                                style: TextStyle(
                                  color: accentOrange,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: accentOrange.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.emoji_events,
                          color: accentOrange,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progressPercent,
                      backgroundColor: cardLight,
                      valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
                      minHeight: 8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${(progressPercent * 100).toInt()}% Complete',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Categories Tabs
            SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryAchievements = category == 'All'
                      ? allAchievements
                      : _achievementService.getAchievementsByCategory(category);
                  final completed = categoryAchievements
                      .where((a) => _completedAchievements.contains(a.id))
                      .length;
                  return _buildCategoryChip(
                    category,
                    completed,
                    categoryAchievements.length,
                    isSelected: _selectedCategory == category,
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Achievements List
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: accentOrange),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredAchievements.length,
                      itemBuilder: (context, index) {
                        final achievement = filteredAchievements[index];
                        final isCompleted = _completedAchievements.contains(achievement.id);
                        final currentProgress = _progress[achievement.id] ?? 0;
                        return _buildAchievementCard(achievement, isCompleted, currentProgress);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, int completed, int total, {required bool isSelected}) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$category ($completed/$total)'),
        selected: isSelected,
        onSelected: (_) {
          setState(() {
            _selectedCategory = category;
          });
        },
        selectedColor: accentOrange,
        checkmarkColor: darkBg,
        labelStyle: TextStyle(
          color: isSelected ? darkBg : textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        backgroundColor: cardDark,
        side: BorderSide(
          color: isSelected ? accentOrange : borderColor,
        ),
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isCompleted, int progress) {
    final progressPercent = achievement.targetValue > 0
        ? (progress / achievement.targetValue).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCompleted ? positiveGreen : borderColor,
          width: isCompleted ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Badge Icon
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isCompleted
                    ? positiveGreen.withOpacity(0.2)
                    : cardLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCompleted ? positiveGreen : borderColor,
                  width: 2,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? Text(
                        achievement.badgeEmoji,
                        style: const TextStyle(fontSize: 32),
                      )
                    : Icon(
                        achievement.icon,
                        color: textTertiary,
                        size: 28,
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          achievement.title,
                          style: TextStyle(
                            color: isCompleted ? positiveGreen : textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (isCompleted)
                        Icon(Icons.check_circle, color: positiveGreen, size: 20),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Progress Bar
                  if (!isCompleted && achievement.type != AchievementType.oneTime)
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progressPercent,
                            backgroundColor: cardLight,
                            valueColor: AlwaysStoppedAnimation<Color>(accentOrange),
                            minHeight: 6,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${progress} / ${achievement.targetValue}',
                              style: TextStyle(
                                color: textTertiary,
                                fontSize: 12,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: accentOrange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '+${achievement.pointsReward} pts',
                                style: TextStyle(
                                  color: accentOrange,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  else
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (achievement.hint != null)
                          Expanded(
                            child: Text(
                              achievement.hint!,
                              style: TextStyle(
                                color: textTertiary,
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? positiveGreen.withOpacity(0.2)
                                : accentOrange.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${achievement.pointsReward} pts',
                            style: TextStyle(
                              color: isCompleted ? positiveGreen : accentOrange,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

