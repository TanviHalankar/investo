import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:investo/screens/home_page/prediction_screen.dart';


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

  // Modern dark color scheme with orange accents (matching home screen)
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

  final List<LearningCategory> categories = [
    LearningCategory(
      title: 'Basics',
      icon: Icons.school_outlined,
      color: accentOrange,
      completedLessons: 3,
      totalLessons: 6,
      description: 'Foundation concepts',
    ),
    LearningCategory(
      title: 'News',
      icon: Icons.newspaper_outlined,
      color: const Color(0xFF6c5ce7),
      completedLessons: 0,
      totalLessons: 8,
      description: 'Market updates & trends',
    ),
    LearningCategory(
      title: 'Risk Mgmt',
      icon: Icons.security_outlined,
      color: negativeRed,
      completedLessons: 0,
      totalLessons: 0,
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

  final List<Lesson> newsLessons = [
    Lesson(
      title: 'Latest Market Trends',
      description: 'Current market movements and analysis',
      duration: '8 min',
      difficulty: 'Beginner',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.trending_up,
    ),
    Lesson(
      title: 'Earnings Reports',
      description: 'Understanding quarterly company performance',
      duration: '10 min',
      difficulty: 'Intermediate',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.assessment,
    ),
    Lesson(
      title: 'Economic Indicators',
      description: 'How economic data affects markets',
      duration: '12 min',
      difficulty: 'Intermediate',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.insert_chart,
    ),
    Lesson(
      title: 'Global Market News',
      description: 'International events impacting investments',
      duration: '9 min',
      difficulty: 'Intermediate',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.public,
    ),
    Lesson(
      title: 'IPO Updates',
      description: 'Recent and upcoming public offerings',
      duration: '7 min',
      difficulty: 'Beginner',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.new_releases,
    ),
    Lesson(
      title: 'Sector Performance',
      description: 'Which industries are hot and which are not',
      duration: '8 min',
      difficulty: 'Intermediate',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.pie_chart,
    ),
    Lesson(
      title: 'Market Movers',
      description: 'Biggest gainers and losers of the day',
      duration: '5 min',
      difficulty: 'Beginner',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.swap_vert,
    ),
    Lesson(
      title: 'Analyst Recommendations',
      description: 'Expert opinions on stocks to watch',
      duration: '10 min',
      difficulty: 'Advanced',
      isCompleted: false,
      progress: 0.0,
      icon: Icons.person,
    ),
  ];

  final List<Lesson> riskManagementLessons = [];

  List<Lesson> getLessonsForCategory(int categoryIndex) {
    switch (categoryIndex) {
      case 0:
        return basicLessons;
      case 1:
        return newsLessons;
      case 2:
        return riskManagementLessons;
      default:
        return basicLessons;
    }
  }

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
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
      backgroundColor: darkBg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 24),
                        _buildProgressCard(),
                        const SizedBox(height: 28),
                        _buildCategoryTabs(),
                        const SizedBox(height: 28),
                        _buildLessonsList(),
                        const SizedBox(height: 100),
                      ],
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 16, horizontalPadding, 16),
      decoration: const BoxDecoration(
        color: darkBg,
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: cardDark,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: textSecondary, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Learning Center',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: textPrimary,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Master the stock market',
                      style: TextStyle(
                        fontSize: 14,
                        color: textTertiary,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [accentOrange, accentOrangeDim],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: accentOrange.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: darkBg, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '3 days',
                    style: TextStyle(
                      color: darkBg,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    double overallProgress = completedLessons / totalLessons;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [cardDark, cardLight],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1),
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
                        colors: [accentOrange, accentOrangeDim],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology,
                      color: darkBg,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Learning Journey',
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$completedLessons of $totalLessons lessons completed',
                          style: const TextStyle(
                            color: textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${(overallProgress * 100).toInt()}%',
                    style: const TextStyle(
                      color: accentOrange,
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: cardLight,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: overallProgress,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [accentOrange, accentOrangeDim],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildQuickStat('Time Invested', '2h 15m', Icons.schedule),
                  const SizedBox(width: 24),
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
        Icon(icon, color: textSecondary, size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryTabs() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SizedBox(
        height: 44,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategoryIndex == index;

            return GestureDetector(
              onTap: () {
              // Redirect to PredictionScreen when Risk Mgmt tab is tapped
              if (category.title == 'Risk Mgmt' || index == 2) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PredictionScreen(username: widget.username),
                  ),
                );
                return; // do not switch tab selection
              }
              setState(() {
                selectedCategoryIndex = index;
              });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? accentOrange : cardDark,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected ? [
                    BoxShadow(
                      color: accentOrange.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ] : [],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      category.icon,
                      color: isSelected ? darkBg : textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      category.title,
                      style: TextStyle(
                        color: isSelected ? darkBg : textSecondary,
                        fontSize: 14,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${category.completedLessons}/${category.totalLessons}',
                      style: TextStyle(
                        color: isSelected ? darkBg.withOpacity(0.7) : textTertiary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLessonsList() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lessons',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: textPrimary,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 18),
            ...getLessonsForCategory(selectedCategoryIndex).map((lesson) => _buildLessonCard(lesson)),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonCard(Lesson lesson) {
    return GestureDetector(
      onTap: () {
        if (lesson.title == 'Trade Risk Simulator') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PredictionScreen(username: widget.username),
            ),
          );
        } else {
          _showLessonDialog(lesson);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: cardDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lesson.isCompleted
                    ? positiveGreen.withOpacity(0.15)
                    : cardLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: lesson.isCompleted
                      ? positiveGreen
                      : borderColor,
                  width: 1,
                ),
              ),
              child: Icon(
                lesson.isCompleted ? Icons.check_rounded : lesson.icon,
                color: lesson.isCompleted ? positiveGreen : textSecondary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lesson.title,
                    style: const TextStyle(
                      color: textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    lesson.description,
                    style: const TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
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
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: lesson.isCompleted
                    ? positiveGreen.withOpacity(0.15)
                    : accentOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                lesson.isCompleted ? Icons.replay : Icons.play_arrow_rounded,
                color: lesson.isCompleted ? positiveGreen : accentOrange,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLessonTag(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cardLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textTertiary, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: textSecondary,
              fontSize: 12,
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
        backgroundColor: cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: borderColor, width: 1),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lesson.description,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Icon(Icons.schedule, color: textTertiary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Duration: ${lesson.duration}',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.signal_cellular_alt, color: textTertiary, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Difficulty: ${lesson.difficulty}',
                  style: const TextStyle(
                    color: textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [accentOrange, accentOrangeDim],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: accentOrange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: darkBg,
                elevation: 0,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(context);
                _showLessonContent(lesson);
              },
              child: const Text(
                'Start Lesson',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLessonContent(Lesson lesson) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: darkBg,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 5,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: textTertiary,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentOrange.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        lesson.icon,
                        color: accentOrange,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lesson.title,
                            style: const TextStyle(
                              color: textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Module ${selectedCategoryIndex + 1} • Lesson ${getLessonsForCategory(selectedCategoryIndex).indexOf(lesson) + 1}',
                            style: const TextStyle(
                              color: textSecondary,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close, color: textSecondary),
                    ),
                  ],
                ),
              ),
              const Divider(color: borderColor, height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Course content
                    _buildLessonContentSection('Introduction', [
                      _buildContentParagraph(
                        'This lesson will cover the fundamentals of ${lesson.title.toLowerCase()}. You will learn key concepts, terminology, and practical applications.',
                      ),
                      _buildContentImage('https://via.placeholder.com/600x300'),
                      _buildContentParagraph(
                        'The stock market is a complex system where investors buy and sell shares of publicly traded companies. Understanding how it works is essential for successful investing.',
                      ),
                    ]),
                    _buildLessonContentSection('Key Concepts', [
                      _buildContentParagraph(
                        'Here are the most important concepts you need to understand:',
                      ),
                      _buildContentList([
                        'Market capitalization: The total value of a company\'s outstanding shares',
                        'Volatility: The degree of variation in a trading price over time',
                        'Liquidity: How easily an asset can be bought or sold without affecting its price',
                        'Diversification: Spreading investments to reduce risk',
                      ]),
                      _buildContentParagraph(
                        'These concepts form the foundation of successful trading strategies and investment decisions.',
                      ),
                    ]),
                    _buildLessonContentSection('Practical Application', [
                      _buildContentParagraph(
                        'Now let\'s look at how to apply these concepts in real-world scenarios:',
                      ),
                      _buildContentImage('https://via.placeholder.com/600x400'),
                      _buildContentParagraph(
                        'When analyzing potential investments, consider both fundamental factors (company financials, management, industry trends) and technical indicators (price patterns, volume, momentum).',
                      ),
                      _buildContentTip(
                        'Start with small investments while you\'re learning. This minimizes risk while you gain experience.',
                      ),
                    ]),
                    _buildLessonContentSection('Summary', [
                      _buildContentParagraph(
                        'In this lesson, you learned about ${lesson.title.toLowerCase()} including key terminology, fundamental concepts, and practical applications. Continue practicing these concepts to build your confidence and expertise.',
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentOrange,
                          foregroundColor: darkBg,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          // Mark lesson as completed
                          setState(() {
                            if (!lesson.isCompleted) {
                              completedLessons++;
                              // In a real app, you would update the lesson's completed status
                            }
                          });
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Mark as Completed',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLessonContentSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          title,
          style: const TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildContentParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: textSecondary,
          fontSize: 16,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildContentImage(String imageUrl) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.network(
        imageUrl,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          height: 200,
          color: cardLight,
          alignment: Alignment.center,
          child: const Icon(Icons.image_not_supported, color: textTertiary, size: 40),
        ),
      ),
    );
  }

  Widget _buildContentList(List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, left: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items.map((item) => _buildListItem(item)).toList(),
      ),
    );
  }

  Widget _buildListItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('•', style: TextStyle(color: accentOrange, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContentTip(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: accentOrange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accentOrange.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline, color: accentOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textPrimary.withOpacity(0.9),
                fontSize: 15,
                height: 1.5,
              ),
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