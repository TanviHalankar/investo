import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class LearningScreen extends StatefulWidget {
  final String username;

  const LearningScreen({super.key, required this.username});

  @override
  State<LearningScreen> createState() => _LearningScreenState();
}

class _LearningScreenState extends State<LearningScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int selectedCategoryIndex = 0;
  int completedLessons = 3; // Example progress
  int totalLessons = 24;

  // Platform-aware properties
  bool get isWeb => kIsWeb;
  double get maxWidth => isWeb ? 800 : double.infinity;
  double get horizontalPadding => isWeb ? 40 : 20;
  double get cardBorderRadius => isWeb ? 16 : 20;

  final List<LearningCategory> categories = [
    LearningCategory(
      title: 'Basics',
      icon: Icons.school_outlined,
      color: const Color(0xFF00d4aa),
      completedLessons: 3,
      totalLessons: 6,
      description: 'Foundation concepts',
    ),
    LearningCategory(
      title: 'Analysis',
      icon: Icons.analytics_outlined,
      color: const Color(0xFF6c5ce7),
      completedLessons: 0,
      totalLessons: 8,
      description: 'Technical & Fundamental',
    ),
    LearningCategory(
      title: 'Strategies',
      icon: Icons.psychology_outlined,
      color: const Color(0xFFfdcb6e),
      completedLessons: 0,
      totalLessons: 6,
      description: 'Trading approaches',
    ),
    LearningCategory(
      title: 'Risk Mgmt',
      icon: Icons.security_outlined,
      color: const Color(0xFFe17055),
      completedLessons: 0,
      totalLessons: 4,
      description: 'Protect your capital',
    ),
  ];

  final List<Lesson> basicLessons = [
    Lesson(
      title: 'What is the Stock Market?',
      description: 'Understanding the fundamentals of stock trading',
      duration: '5 min',
      difficulty: 'Beginner',
      isCompleted: true,
      progress: 1.0,
      icon: Icons.trending_up,
    ),
    Lesson(
      title: 'Types of Stocks',
      description: 'Growth, Value, Dividend stocks explained',
      duration: '7 min',
      difficulty: 'Beginner',
      isCompleted: true,
      progress: 1.0,
      icon: Icons.category,
    ),
    Lesson(
      title: 'Reading Stock Charts',
      description: 'Basic chart patterns and indicators',
      duration: '10 min',
      difficulty: 'Beginner',
      isCompleted: true,
      progress: 1.0,
      icon: Icons.show_chart,
    ),
    Lesson(
      title: 'Market Orders vs Limit Orders',
      description: 'Different ways to buy and sell stocks',
      duration: '6 min',
      difficulty: 'Beginner',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.receipt_long,
    ),
    Lesson(
      title: 'Bull vs Bear Markets',
      description: 'Understanding market cycles and trends',
      duration: '8 min',
      difficulty: 'Beginner',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.swap_vert,
    ),
    Lesson(
      title: 'Building Your First Portfolio',
      description: 'Diversification and allocation strategies',
      duration: '12 min',
      difficulty: 'Intermediate',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.pie_chart,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

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
                  // Header with back button and progress
                  _buildHeader(),

                  // Main content
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Overall progress card
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildProgressCard(),
                            ),
                            const SizedBox(height: 24),

                            // Category tabs
                            FadeTransition(
                              opacity: _fadeAnimation,
                              child: _buildCategoryTabs(),
                            ),
                            const SizedBox(height: 20),

                            // Lessons list
                            SlideTransition(
                              position: _slideAnimation,
                              child: _buildLessonsList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
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
        vertical: 16,
      ),
      child: Row(
        children: [
          // Back button
          MouseRegion(
            cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: isWeb ? 18 : 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Title
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Learning Center',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 22 : 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Master the stock market',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: isWeb ? 13 : 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // Achievement badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFfdcb6e), Color(0xFFe17055)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.local_fire_department, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  '3 day streak',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isWeb ? 11 : 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard() {
    double overallProgress = completedLessons / totalLessons;

    return ClipRRect(
      borderRadius: BorderRadius.circular(cardBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          padding: EdgeInsets.all(isWeb ? 24 : 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(cardBorderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00d4aa), Color(0xFF00b894)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.psychology,
                      color: Colors.white,
                      size: isWeb ? 24 : 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your Learning Journey',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isWeb ? 18 : 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '$completedLessons of $totalLessons lessons completed',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: isWeb ? 13 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: TextStyle(
                      color: const Color(0xFF00d4aa),
                      fontSize: isWeb ? 20 : 22,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Progress bar
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: overallProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00d4aa), Color(0xFF00b894)],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Quick stats
              Row(
                children: [
                  _buildQuickStat('Time Invested', '2h 15m', Icons.schedule),
                  const SizedBox(width: 20),
                  _buildQuickStat('Current Level', 'Beginner', Icons.emoji_events),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.6), size: 16),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                color: Colors.white,
                fontSize: isWeb ? 13 : 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: isWeb ? 11 : 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: isWeb ? 80 : 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategoryIndex == index;

          return MouseRegion(
            cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  selectedCategoryIndex = index;
                });
              },
              child: Container(
                width: isWeb ? 140 : 120,
                margin: const EdgeInsets.only(right: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? category.color.withOpacity(0.2)
                            : Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? category.color.withOpacity(0.5)
                              : Colors.white.withOpacity(0.1),
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            category.icon,
                            color: isSelected ? category.color : Colors.white.withOpacity(0.7),
                            size: isWeb ? 22 : 24,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            category.title,
                            style: TextStyle(
                              color: isSelected ? category.color : Colors.white,
                              fontSize: isWeb ? 12 : 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${category.completedLessons}/${category.totalLessons}',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: isWeb ? 10 : 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLessonsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Lessons',
          style: TextStyle(
            color: Colors.white,
            fontSize: isWeb ? 20 : 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 16),

        ...basicLessons.asMap().entries.map((entry) {
          int index = entry.key;
          Lesson lesson = entry.value;

          return _buildLessonCard(lesson, index);
        }).toList(),
      ],
    );
  }

  Widget _buildLessonCard(Lesson lesson, int index) {
    return MouseRegion(
      cursor: isWeb ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: () {
          // Navigate to lesson content
          _showLessonDialog(lesson);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(cardBorderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
              child: Container(
                padding: EdgeInsets.all(isWeb ? 18 : 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(cardBorderRadius),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    // Lesson icon and status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: lesson.isCompleted
                            ? const Color(0xFF00d4aa).withOpacity(0.2)
                            : Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: lesson.isCompleted
                              ? const Color(0xFF00d4aa)
                              : Colors.white.withOpacity(0.2),
                        ),
                      ),
                      child: Icon(
                        lesson.isCompleted ? Icons.check : lesson.icon,
                        color: lesson.isCompleted
                            ? const Color(0xFF00d4aa)
                            : Colors.white.withOpacity(0.7),
                        size: isWeb ? 20 : 22,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Lesson details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isWeb ? 15 : 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: isWeb ? 12 : 13,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          Row(
                            children: [
                              _buildLessonTag(lesson.duration, Icons.schedule),
                              const SizedBox(width: 8),
                              _buildLessonTag(lesson.difficulty, Icons.signal_cellular_alt),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Progress indicator or play button
                    if (lesson.isCompleted)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00d4aa).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.replay,
                          color: Color(0xFF00d4aa),
                          size: 18,
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6c5ce7).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Color(0xFF6c5ce7),
                          size: 18,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.6), size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: isWeb ? 10 : 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showLessonDialog(Lesson lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1a1a2e),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          lesson.title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.description,
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(Icons.schedule, color: Colors.white.withOpacity(0.6), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Duration: ${lesson.duration}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.signal_cellular_alt, color: Colors.white.withOpacity(0.6), size: 16),
                const SizedBox(width: 4),
                Text(
                  'Difficulty: ${lesson.difficulty}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00d4aa),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to actual lesson content
            },
            child: Text(
              lesson.isCompleted ? 'Review' : 'Start Lesson',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class LearningCategory {
  final String title;
  final IconData icon;
  final Color color;
  final int completedLessons;
  final int totalLessons;
  final String description;

  LearningCategory({
    required this.title,
    required this.icon,
    required this.color,
    required this.completedLessons,
    required this.totalLessons,
    required this.description,
  });
}

class Lesson {
  final String title;
  final String description;
  final String duration;
  final String difficulty;
  final bool isCompleted;
  final double progress;
  final IconData icon;

  Lesson({
    required this.title,
    required this.description,
    required this.duration,
    required this.difficulty,
    required this.isCompleted,
    required this.progress,
    required this.icon,
  });
}